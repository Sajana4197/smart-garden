import 'dart:io';

import 'models/plant_diagnosis_result.dart';

export 'models/plant_diagnosis_result.dart';

/// The single seam between presentation code and the AI "brain" — see
/// MODEL_INTEGRATION.md §2. `features/ai_loading`, `features/result`,
/// `features/recommendation`, `features/my_garden`, and
/// `features/scan_history` depend only on this interface, injected via
/// provider/DI — never on `MockAIService`/`TFLiteAIService` directly.
abstract class AIService {
  /// Analyzes a plant/leaf image and returns a diagnosis.
  ///
  /// Implementations may take variable time (mock simulates latency; real
  /// on-device inference has its own cost) — callers must always treat this
  /// as a potentially slow async operation and show the AI Loading UI while
  /// awaiting it.
  ///
  /// Throws [AIServiceException] on failure (corrupt image, model load
  /// failure, inference error) — never returns a null/garbage result.
  Future<PlantDiagnosisResult> analyzeImage(File imageFile);

  /// Whether this implementation is ready to serve requests (e.g. model
  /// loaded). Mock always resolves true immediately; a future TFLite
  /// implementation may report false until the interpreter is loaded.
  Future<bool> isReady();
}

enum AIServiceErrorType {
  /// Unreadable/corrupt file.
  invalidImage,

  /// Model failed to load (TFLite case) — mock never throws this.
  modelUnavailable,

  /// Generic failure during analysis.
  inferenceFailed,

  /// Took too long.
  timeout,
}

class AIServiceException implements Exception {
  AIServiceException(this.message, this.type);

  final String message;
  final AIServiceErrorType type;

  @override
  String toString() => 'AIServiceException($type): $message';
}
