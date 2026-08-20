import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'ai_service.dart';
import 'tflite_diagnosis_content_bank.dart';
import 'tflite_label_parser.dart';
import 'tflite_species_display.dart';

/// Real on-device plant-disease classifier — see MODEL_INTEGRATION.md §5.
/// Fulfils the exact same [AIService] contract as `MockAIService`; swapped
/// in via the `USE_REAL_AI_MODEL` DI flag in app.dart. Never referenced
/// directly by presentation/ code — see MODEL_INTEGRATION.md §2.
///
/// Trained via transfer learning on MobileNetV2 (71 classes: 20 species +
/// an open-set "Unknown Disease" rejection class) — see CLAUDE.md's Phase
/// 18 Locked Decisions for the full training/evaluation writeup.
class TFLiteAIService implements AIService {
  TFLiteAIService();

  static const _modelAssetPath = 'assets/models/plant_disease_model.tflite';
  static const _labelsAssetPath = 'assets/models/labels.txt';

  /// Below this confidence, or on a direct `Unknown Disease` prediction,
  /// the result is routed to the uncertain/unsupported-plant outcome
  /// rather than a confident wrong diagnosis. Chosen from the FAR/FRR
  /// threshold sweep run during training: FAR (an unsupported plant
  /// misdiagnosed as a specific disease) drops from 14.7% at threshold 0
  /// to 8.0% here, while FRR (a real diagnosis wrongly flagged unknown)
  /// only rises to ~9.4% — the best tradeoff point found on the sweep.
  static const _confidenceThreshold = 0.65;

  /// Model load / a single inference should never hang indefinitely on a
  /// stuck native call — mirrors the location-fetch hard-timeout pattern
  /// from `LocationRepositoryImpl` (see CLAUDE.md Phase 11).
  static const _timeout = Duration(seconds: 10);

  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> _ensureLoaded() async {
    if (_interpreter != null) return;
    final interpreter = await Interpreter.fromAsset(_modelAssetPath)
        .timeout(_timeout);
    final labelsText = await rootBundle.loadString(_labelsAssetPath);
    final labels = labelsText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final outputShape = interpreter.getOutputTensors().first.shape;
    if (labels.length != outputShape.last) {
      throw StateError(
        'labels.txt has ${labels.length} entries but the model outputs '
        '${outputShape.last} classes — asset mismatch.',
      );
    }

    _interpreter = interpreter;
    _labels = labels;
  }

  @override
  Future<bool> isReady() async {
    if (_interpreter != null) return true;
    try {
      await _ensureLoaded();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<PlantDiagnosisResult> analyzeImage(File imageFile) async {
    try {
      await _ensureLoaded();
    } catch (_) {
      throw AIServiceException(
        'The plant-diagnosis model could not be loaded. Please restart '
        'the app.',
        AIServiceErrorType.modelUnavailable,
      );
    }

    final interpreter = _interpreter!;
    final labels = _labels!;

    final Uint8List bytes;
    try {
      bytes = await imageFile.readAsBytes();
    } catch (_) {
      throw AIServiceException(
        "This photo couldn't be read. Please try again.",
        AIServiceErrorType.invalidImage,
      );
    }

    final inputShape = interpreter.getInputTensors().first.shape; // [1, H, W, 3]

    final List<double> scores;
    try {
      scores = await compute(
        _decodeAndInfer,
        _InferenceRequest(
          interpreterAddress: interpreter.address,
          imageBytes: bytes,
          targetWidth: inputShape[2],
          targetHeight: inputShape[1],
          outputLength: labels.length,
        ),
      ).timeout(_timeout);
    } on FormatException {
      throw AIServiceException(
        "This photo couldn't be read. Please try again.",
        AIServiceErrorType.invalidImage,
      );
    } on TimeoutException {
      throw AIServiceException(
        'The analysis took too long. Please try again.',
        AIServiceErrorType.timeout,
      );
    } catch (_) {
      throw AIServiceException(
        'The analysis could not be completed. Please try again.',
        AIServiceErrorType.inferenceFailed,
      );
    }

    var bestIndex = 0;
    var bestScore = scores[0];
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }

    return _buildResult(labels[bestIndex], bestScore);
  }

  PlantDiagnosisResult _buildResult(String rawLabel, double confidence) {
    final isUncertain = confidence < _confidenceThreshold ||
        rawLabel == TFLiteLabelParser.unknownDiseaseRawLabel;

    if (isUncertain) {
      final content =
          tfliteDiagnosisContentBank[TFLiteLabelParser.unknownDiseaseRawLabel]!;
      return PlantDiagnosisResult(
        plantCommonName: 'Unrecognized plant',
        diagnosisLabel: TFLiteLabelParser.unknownDiseaseRawLabel,
        isHealthy: false,
        confidence: confidence,
        severity: content.defaultSeverity,
        description: content.description,
        visualSymptoms: content.visualSymptoms,
        analyzedAt: DateTime.now(),
      );
    }

    final parsed = TFLiteLabelParser.parse(rawLabel);
    final diagnosisLabel =
        TFLiteLabelParser.canonicalDiseaseType(parsed.diseaseRaw);
    final content = tfliteDiagnosisContentBank[diagnosisLabel] ??
        tfliteDiagnosisContentBank[TFLiteLabelParser.unknownDiseaseRawLabel]!;
    final rawSpecies = parsed.species ?? 'Unknown plant';

    return PlantDiagnosisResult(
      plantCommonName: TFLiteSpeciesDisplay.commonName(rawSpecies),
      plantSpeciesLatin: TFLiteSpeciesDisplay.latinName(rawSpecies),
      diagnosisLabel: diagnosisLabel,
      isHealthy: diagnosisLabel == TFLiteLabelParser.healthyCanonicalLabel,
      confidence: confidence,
      severity: content.defaultSeverity,
      description: content.description,
      visualSymptoms: content.visualSymptoms,
      analyzedAt: DateTime.now(),
    );
  }
}

/// Everything [_decodeAndInfer] needs, sent across the isolate boundary via
/// [compute] — must stay plain data (no FFI pointers/Interpreter objects,
/// which aren't transferable), hence passing [interpreterAddress] as a raw
/// int and reconstructing the interpreter with `Interpreter.fromAddress`
/// inside the isolate. This is `tflite_flutter`'s own documented pattern
/// for isolate execution (see its bundled `image_classification_mobilenet`
/// example).
class _InferenceRequest {
  const _InferenceRequest({
    required this.interpreterAddress,
    required this.imageBytes,
    required this.targetWidth,
    required this.targetHeight,
    required this.outputLength,
  });

  final int interpreterAddress;
  final Uint8List imageBytes;
  final int targetWidth;
  final int targetHeight;
  final int outputLength;
}

/// Runs entirely on a background isolate — decode, resize, normalize, and
/// inference are all CPU-bound work that must not block the UI thread
/// (MODEL_INTEGRATION.md §5 point 4). Top-level function: required by
/// [compute].
List<double> _decodeAndInfer(_InferenceRequest request) {
  final decoded = img_lib.decodeImage(request.imageBytes);
  if (decoded == null) {
    throw const FormatException('Could not decode image bytes.');
  }

  final resized = img_lib.copyResize(
    decoded,
    width: request.targetWidth,
    height: request.targetHeight,
  );

  // Normalize to [-1, 1] — matches training's
  // `mobilenet_v2.preprocess_input`, not a plain 0-1 rescale.
  final inputMatrix = List.generate(
    request.targetHeight,
    (y) => List.generate(request.targetWidth, (x) {
      final pixel = resized.getPixel(x, y);
      return [
        (pixel.r / 127.5) - 1.0,
        (pixel.g / 127.5) - 1.0,
        (pixel.b / 127.5) - 1.0,
      ];
    }),
  );

  final interpreter = Interpreter.fromAddress(request.interpreterAddress);
  final output = [List<double>.filled(request.outputLength, 0.0)];
  interpreter.run([inputMatrix], output);
  return output.first;
}
