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

/// Real on-device plant-disease pipeline — see MODEL_INTEGRATION.md §5.
/// Fulfils the exact same [AIService] contract as `MockAIService`; swapped
/// in via the `USE_REAL_AI_MODEL` DI flag in app.dart. Never referenced
/// directly by presentation/ code — see MODEL_INTEGRATION.md §2.
///
/// **Two-model pipeline** (added post-Phase-19, replacing the original
/// single-classifier design): a leaf detector crops the photo to the leaf
/// region *before* the disease classifier ever sees it. This exists
/// because live real-photo testing of the original single-model pipeline
/// showed a real background-domain-gap problem — the classifier was
/// trained on lab-style, near-isolated leaf photos, and struggled on real
/// phone photos with clutter/backgrounds. See CLAUDE.md's model-v2 Locked
/// Decision for the full investigation (including the bugs found and
/// fixed while building this: a too-tight crop with no padding, a min-area
/// check applied before padding instead of after, a Roboflow free-tier
/// quota exhaustion that forced training a local detector instead, and a
/// double-preprocessing bug in the *test* harness that briefly masked a
/// real improvement).
///
/// The classifier itself (MobileNetV2 transfer learning, 71 classes: 20
/// species + `Unknown Disease`) is architecturally unchanged from Phase
/// 18 — only its training data changed (added real-world PlantDoc images,
/// and every training/val/test image was run through the same leaf-crop
/// step this service performs at inference time, so training and
/// inference see the same kind of input).
class TFLiteAIService implements AIService {
  TFLiteAIService();

  static const _classifierAssetPath = 'assets/models/plant_disease_model.tflite';
  static const _labelsAssetPath = 'assets/models/labels.txt';
  static const _detectorAssetPath = 'assets/models/leaf_detector.tflite';

  /// Below this confidence, or on a direct `Unknown Disease` prediction,
  /// the result is routed to the uncertain/unsupported-plant outcome
  /// rather than a confident wrong diagnosis. Carried over from the v1
  /// FAR/FRR threshold sweep (CLAUDE.md Phase 18) — not re-derived for
  /// v2, since re-running that sweep needs the v2 model's own test-set
  /// probabilities, not something this service can do on-device. Revisit
  /// if a future training session re-runs that analysis for v2.
  static const _confidenceThreshold = 0.65;

  /// Matches the Kaggle training notebook's crop step exactly (same
  /// values used when cropping every training/val/test image) — see
  /// CLAUDE.md's model-v2 Locked Decision. Padding is generous
  /// specifically because the detector's box is often tighter than the
  /// whole visible leaf; the min-area check (checked *after* padding,
  /// not before — a real bug caught during training) falls back to
  /// classifying the full original photo rather than a near-useless
  /// fragment crop.
  static const _cropPaddingRatio = 0.35;
  static const _cropMinAreaRatio = 0.10;

  /// Model load / a single inference should never hang indefinitely on a
  /// stuck native call — mirrors the location-fetch hard-timeout pattern
  /// from `LocationRepositoryImpl` (see CLAUDE.md Phase 11).
  static const _timeout = Duration(seconds: 10);

  Interpreter? _classifierInterpreter;
  Interpreter? _detectorInterpreter;
  List<String>? _labels;

  Future<void> _ensureLoaded() async {
    if (_classifierInterpreter != null && _detectorInterpreter != null) return;

    final classifier = await Interpreter.fromAsset(_classifierAssetPath)
        .timeout(_timeout);
    final detector = await Interpreter.fromAsset(_detectorAssetPath)
        .timeout(_timeout);
    final labelsText = await rootBundle.loadString(_labelsAssetPath);
    final labels = labelsText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final outputShape = classifier.getOutputTensors().first.shape;
    if (labels.length != outputShape.last) {
      throw StateError(
        'labels.txt has ${labels.length} entries but the classifier '
        'outputs ${outputShape.last} classes — asset mismatch.',
      );
    }

    _classifierInterpreter = classifier;
    _detectorInterpreter = detector;
    _labels = labels;
  }

  @override
  Future<bool> isReady() async {
    if (_classifierInterpreter != null && _detectorInterpreter != null) {
      return true;
    }
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

    final classifierInterpreter = _classifierInterpreter!;
    final detectorInterpreter = _detectorInterpreter!;
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

    final classifierInputShape =
        classifierInterpreter.getInputTensors().first.shape; // [1, H, W, 3]
    final detectorInputShape =
        detectorInterpreter.getInputTensors().first.shape; // [1, H, W, 3]

    final List<double> scores;
    try {
      scores = await compute(
        _decodeAndInfer,
        _InferenceRequest(
          classifierInterpreterAddress: classifierInterpreter.address,
          detectorInterpreterAddress: detectorInterpreter.address,
          imageBytes: bytes,
          classifierWidth: classifierInputShape[2],
          classifierHeight: classifierInputShape[1],
          detectorWidth: detectorInputShape[2],
          detectorHeight: detectorInputShape[1],
          outputLength: labels.length,
          cropPaddingRatio: _cropPaddingRatio,
          cropMinAreaRatio: _cropMinAreaRatio,
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

class _InferenceRequest {
  const _InferenceRequest({
    required this.classifierInterpreterAddress,
    required this.detectorInterpreterAddress,
    required this.imageBytes,
    required this.classifierWidth,
    required this.classifierHeight,
    required this.detectorWidth,
    required this.detectorHeight,
    required this.outputLength,
    required this.cropPaddingRatio,
    required this.cropMinAreaRatio,
  });

  final int classifierInterpreterAddress;
  final int detectorInterpreterAddress;
  final Uint8List imageBytes;
  final int classifierWidth;
  final int classifierHeight;
  final int detectorWidth;
  final int detectorHeight;
  final int outputLength;
  final double cropPaddingRatio;
  final double cropMinAreaRatio;
}

/// A detected box in the *original* (un-resized) image's pixel space.
class _DetectedBox {
  const _DetectedBox(this.centerX, this.centerY, this.width, this.height, this.confidence);
  final double centerX;
  final double centerY;
  final double width;
  final double height;
  final double confidence;
}

/// Runs entirely on a background isolate: decode → detect leaf → crop
/// (with padding/fallback) → classify. CPU-bound work that must not block
/// the UI thread (MODEL_INTEGRATION.md §5 point 4). Top-level function:
/// required by [compute].
List<double> _decodeAndInfer(_InferenceRequest request) {
  final decoded = img_lib.decodeImage(request.imageBytes);
  if (decoded == null) {
    throw const FormatException('Could not decode image bytes.');
  }

  final croppedForClassifier = _detectAndCrop(decoded, request);

  final resized = img_lib.copyResize(
    croppedForClassifier,
    width: request.classifierWidth,
    height: request.classifierHeight,
  );

  // Normalize to [-1, 1] — matches training's
  // `mobilenet_v2.preprocess_input`, not a plain 0-1 rescale.
  final inputMatrix = List.generate(
    request.classifierHeight,
    (y) => List.generate(request.classifierWidth, (x) {
      final pixel = resized.getPixel(x, y);
      return [
        (pixel.r / 127.5) - 1.0,
        (pixel.g / 127.5) - 1.0,
        (pixel.b / 127.5) - 1.0,
      ];
    }),
  );

  final classifierInterpreter =
      Interpreter.fromAddress(request.classifierInterpreterAddress);
  final output = [List<double>.filled(request.outputLength, 0.0)];
  classifierInterpreter.run([inputMatrix], output);
  return output.first;
}

/// Runs the leaf detector and returns either a cropped (+ padded) region
/// of [original], or [original] itself unchanged if no sufficiently
/// confident/sized detection was found — mirrors the training notebook's
/// `crop_to_leaf` fallback behavior exactly, so inference sees the same
/// kind of input the classifier was actually trained on.
img_lib.Image _detectAndCrop(img_lib.Image original, _InferenceRequest request) {
  final resizedForDetector = img_lib.copyResize(
    original,
    width: request.detectorWidth,
    height: request.detectorHeight,
  );

  // YOLO models are conventionally trained on inputs normalized to [0, 1]
  // (plain divide-by-255) — different from the classifier's [-1, 1]
  // MobileNetV2 preprocessing above. Getting this wrong would silently
  // degrade every detection, the same class of bug already caught once
  // this session in the Python test harness (a double-preprocessing bug
  // that briefly masked a real improvement) — verify this on a real
  // device against a known test photo before trusting it blindly.
  final detectorInput = List.generate(
    request.detectorHeight,
    (y) => List.generate(request.detectorWidth, (x) {
      final pixel = resizedForDetector.getPixel(x, y);
      return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
    }),
  );

  final detectorInterpreter =
      Interpreter.fromAddress(request.detectorInterpreterAddress);
  final outputShape = detectorInterpreter.getOutputTensors().first.shape;
  // Expected shape [1, 4 + numClasses, numAnchors] — the box-regression
  // head's 4 values (center-x, center-y, width, height) come first,
  // followed by one confidence score per class. We deliberately ignore
  // *which* class fired — this detector's classes are an artifact of
  // whatever dataset trained it, not something this app's pipeline cares
  // about; only the box location matters, so we just want the single
  // highest-confidence detection across every anchor and every class.
  final numAttributes = outputShape[1];
  final numAnchors = outputShape[2];
  final numClasses = numAttributes - 4;

  final rawOutput = List.generate(
    numAttributes,
    (_) => List<double>.filled(numAnchors, 0.0),
  );
  detectorInterpreter.run([detectorInput], [rawOutput]);

  _DetectedBox? best;
  for (var anchor = 0; anchor < numAnchors; anchor++) {
    var bestClassScore = 0.0;
    for (var c = 0; c < numClasses; c++) {
      final score = rawOutput[4 + c][anchor];
      if (score > bestClassScore) bestClassScore = score;
    }
    if (best == null || bestClassScore > best.confidence) {
      best = _DetectedBox(
        rawOutput[0][anchor],
        rawOutput[1][anchor],
        rawOutput[2][anchor],
        rawOutput[3][anchor],
        bestClassScore,
      );
    }
  }

  const confidenceThreshold = 0.25; // matches the Kaggle notebook's crop_to_leaf default
  if (best == null || best.confidence < confidenceThreshold) {
    return original;
  }

  // Box coordinates may be normalized (0-1) or already in the detector's
  // input pixel space (0-detectorWidth/Height) depending on export
  // settings — detect which by magnitude rather than assuming, then
  // scale up to the detector's input pixel space uniformly.
  final looksNormalized =
      best.centerX <= 2.0 && best.centerY <= 2.0 && best.width <= 2.0 && best.height <= 2.0;
  final detCx = looksNormalized ? best.centerX * request.detectorWidth : best.centerX;
  final detCy = looksNormalized ? best.centerY * request.detectorHeight : best.centerY;
  final detW = looksNormalized ? best.width * request.detectorWidth : best.width;
  final detH = looksNormalized ? best.height * request.detectorHeight : best.height;

  // Scale from the detector's (stretched) input space back to the
  // original image's actual pixel dimensions.
  final scaleX = original.width / request.detectorWidth;
  final scaleY = original.height / request.detectorHeight;
  final cx = detCx * scaleX;
  final cy = detCy * scaleY;
  final w = detW * scaleX;
  final h = detH * scaleY;

  final padW = w * request.cropPaddingRatio;
  final padH = h * request.cropPaddingRatio;
  final paddedW = w + 2 * padW;
  final paddedH = h + 2 * padH;

  if ((paddedW * paddedH) / (original.width * original.height) <
      request.cropMinAreaRatio) {
    return original; // still too small/fragment-like even after padding
  }

  final x1 = (cx - w / 2 - padW).clamp(0, original.width.toDouble()).toInt();
  final y1 = (cy - h / 2 - padH).clamp(0, original.height.toDouble()).toInt();
  final x2 = (cx + w / 2 + padW).clamp(0, original.width.toDouble()).toInt();
  final y2 = (cy + h / 2 + padH).clamp(0, original.height.toDouble()).toInt();

  if (x2 <= x1 || y2 <= y1) return original;

  return img_lib.copyCrop(
    original,
    x: x1,
    y: y1,
    width: x2 - x1,
    height: y2 - y1,
  );
}
