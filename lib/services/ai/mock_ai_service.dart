import 'dart:io';
import 'dart:math';

import 'ai_service.dart';
import 'mock_result_bank.dart';

/// Mock [AIService] implementation — see MODEL_INTEGRATION.md §4. Active
/// implementation for every phase until Phase 18 swaps in
/// `TFLiteAIService` via DI; kept in the codebase permanently afterward
/// since it remains valuable for widget/integration tests.
class MockAIService implements AIService {
  MockAIService({
    this.forcedResultIndex,
    this.failureProbability = 0.0,
    Random? random,
  }) : _random = random ?? Random();

  /// Forces a specific result-bank index for deterministic widget/
  /// integration tests (§4.3) — leave null for normal randomized app use.
  final int? forcedResultIndex;

  /// Probability (0.0-1.0) of throwing a simulated [AIServiceException]
  /// with type [AIServiceErrorType.inferenceFailed]. Defaults to 0 so it
  /// never surprises a demo; enable explicitly to exercise error-state UI
  /// (Phase 17).
  final double failureProbability;

  final Random _random;

  @override
  Future<bool> isReady() async => true;

  @override
  Future<PlantDiagnosisResult> analyzeImage(File imageFile) async {
    final latencyMs = 1500 + _random.nextInt(1500);
    await Future.delayed(Duration(milliseconds: latencyMs));

    if (failureProbability > 0 && _random.nextDouble() < failureProbability) {
      throw AIServiceException(
        'The analysis could not be completed. Please try again.',
        AIServiceErrorType.inferenceFailed,
      );
    }

    final index = forcedResultIndex ?? _random.nextInt(mockResultBank.length);
    final template = mockResultBank[index % mockResultBank.length];
    return template.copyWith(analyzedAt: DateTime.now());
  }
}
