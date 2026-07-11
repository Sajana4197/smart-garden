import '../../../../services/ai/models/plant_diagnosis_result.dart';
import '../entities/care_recommendation.dart';

/// Abstract seam `presentation` (via `GetCareRecommendation`) depends on —
/// never the concrete `RecommendationRepositoryImpl` — per PROJECT_SPEC.md
/// §3 dependency rule.
abstract class RecommendationRepository {
  /// Never throws and never returns an empty/blank recommendation — an
  /// unrecognized [diagnosisLabel] falls back to generic guidance rather
  /// than crashing, per MODEL_INTEGRATION.md §3.
  CareRecommendation getRecommendation({
    required String diagnosisLabel,
    required DiagnosisSeverity severity,
  });
}
