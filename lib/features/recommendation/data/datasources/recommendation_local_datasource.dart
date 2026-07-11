import '../../../../services/ai/models/plant_diagnosis_result.dart';
import '../../domain/entities/care_recommendation.dart';

class _RecommendationContent {
  const _RecommendationContent({
    required this.wateringAdvice,
    required this.lightAdvice,
    required this.treatmentSteps,
  });

  final String wateringAdvice;
  final String lightAdvice;
  final List<String> treatmentSteps;
}

/// Curated care-recommendation copy, keyed by `PlantDiagnosisResult.
/// diagnosisLabel` — covers every outcome in `mock_result_bank.dart`
/// (ROADMAP.md Phase 8). Any new diagnosisLabel a future real model
/// introduces must get an entry here, or it falls back to [_fallback] per
/// MODEL_INTEGRATION.md §3 — never a crash or blank state.
class RecommendationLocalDataSource {
  const RecommendationLocalDataSource();

  static const _contentBank = <String, _RecommendationContent>{
    'Healthy': _RecommendationContent(
      wateringAdvice:
          'Continue your current watering routine — soil moisture and '
          'drainage are working well for this plant.',
      lightAdvice:
          'Current light exposure looks appropriate; no changes needed.',
      treatmentSteps: [
        'No treatment needed right now.',
        'Recheck in 1–2 weeks as part of routine care.',
      ],
    ),
    'Powdery Mildew': _RecommendationContent(
      wateringAdvice:
          'Avoid overhead watering — water at the soil line to keep '
          'foliage dry and slow the spread of spores.',
      lightAdvice:
          'Increase air circulation and, where possible, more direct '
          'morning sun to help leaves dry out faster.',
      treatmentSteps: [
        'Remove and discard the most affected leaves.',
        'Apply a light fungicide or a diluted baking-soda spray to '
            'affected areas.',
        'Space plants further apart to improve airflow.',
      ],
    ),
    'Aphid Infestation': _RecommendationContent(
      wateringAdvice: "No change needed — this isn't a moisture issue.",
      lightAdvice:
          'Keep the plant in its current light spot; stressed plants '
          'attract more pests.',
      treatmentSteps: [
        'Spray affected stems and leaf undersides with insecticidal soap '
            'or a strong jet of water.',
        'Introduce or attract natural predators like ladybugs if growing '
            'outdoors.',
        'Recheck every few days until the colony is gone.',
      ],
    ),
    'Black Spot': _RecommendationContent(
      wateringAdvice:
          'Water at the base of the plant in the morning so leaves dry '
          'out over the course of the day.',
      lightAdvice:
          'Ensure good sun exposure and prune nearby foliage to improve '
          'airflow around the plant.',
      treatmentSteps: [
        "Remove and dispose of infected leaves — don't compost them.",
        'Apply a fungicide labeled for black spot every 7–10 days.',
        'Clean up fallen leaves around the base of the plant regularly.',
      ],
    ),
    'Downy Mildew': _RecommendationContent(
      wateringAdvice:
          'Water in the morning and avoid wetting the leaves; let the '
          'soil surface dry between waterings.',
      lightAdvice:
          'Move to a spot with better airflow and, if indoors, run a '
          'small fan nearby.',
      treatmentSteps: [
        'Remove and discard affected leaves promptly.',
        'Apply a copper-based fungicide to the remaining foliage.',
        'Reduce humidity around the plant where possible.',
      ],
    ),
    'Bacterial Wilt': _RecommendationContent(
      wateringAdvice:
          "Watering more won't help — the plant's water uptake is "
          'blocked internally.',
      lightAdvice:
          'Keep the plant in its current light; focus on removing the '
          'source rather than adjusting conditions.',
      treatmentSteps: [
        'Remove and destroy affected vines or plants promptly to protect '
            'nearby plants.',
        'Control cucumber beetles, the primary carrier, with row covers '
            'or an approved insecticide.',
        'Disinfect tools used on the plant before using them elsewhere.',
      ],
    ),
    'Root Rot': _RecommendationContent(
      wateringAdvice:
          'Stop watering until the topsoil is dry, then water less '
          'frequently and only when the top inch is dry.',
      lightAdvice:
          "Keep in indirect light while recovering — the plant's roots "
          "don't need extra stress right now.",
      treatmentSteps: [
        'Remove the plant from its pot and trim away soft, dark, mushy '
            'roots.',
        'Repot into fresh, well-draining soil and a pot with drainage '
            'holes.',
        'Hold off on fertilizer until new growth appears.',
      ],
    ),
  };

  static const _fallback = _RecommendationContent(
    wateringAdvice:
        'Water when the top inch of soil feels dry, and avoid letting '
        'the plant sit in standing water.',
    lightAdvice:
        'Provide bright, indirect light unless you know this plant '
        'prefers otherwise.',
    treatmentSteps: [
      "We don't have specific guidance for this diagnosis yet.",
      'Monitor the plant closely and consult a local gardening resource '
          'or expert.',
      'Rescan in a few days to track any changes.',
    ],
  );

  CareRecommendation getRecommendation(
    String diagnosisLabel,
    DiagnosisSeverity severity,
  ) {
    final content = _contentBank[diagnosisLabel] ?? _fallback;
    return CareRecommendation(
      wateringAdvice: content.wateringAdvice,
      lightAdvice: content.lightAdvice,
      treatmentSteps: content.treatmentSteps,
      urgency: _urgencyFor(severity),
    );
  }

  static RecommendationUrgency _urgencyFor(DiagnosisSeverity severity) {
    switch (severity) {
      case DiagnosisSeverity.none:
      case DiagnosisSeverity.mild:
        return RecommendationUrgency.routine;
      case DiagnosisSeverity.moderate:
        return RecommendationUrgency.monitor;
      case DiagnosisSeverity.severe:
        return RecommendationUrgency.urgent;
    }
  }
}
