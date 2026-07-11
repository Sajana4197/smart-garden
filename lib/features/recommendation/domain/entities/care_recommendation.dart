/// How soon a recommendation's steps should be acted on. Distinct from
/// `DiagnosisSeverity` (services/ai) — urgency is a recommendation-facing
/// concept derived from severity, not the diagnosis itself.
enum RecommendationUrgency { routine, monitor, urgent }

/// Structured care guidance produced by the domain-layer mapping in
/// `GetCareRecommendation` — see ROADMAP.md Phase 8 and
/// MODEL_INTEGRATION.md §3. Pure Dart, no Flutter/DB imports.
class CareRecommendation {
  const CareRecommendation({
    required this.wateringAdvice,
    required this.lightAdvice,
    required this.treatmentSteps,
    required this.urgency,
  });

  final String wateringAdvice;
  final String lightAdvice;
  final List<String> treatmentSteps;
  final RecommendationUrgency urgency;
}
