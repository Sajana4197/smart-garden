import 'models/plant_diagnosis_result.dart';

/// Curated mock diagnosis results — see MODEL_INTEGRATION.md §4. Covers
/// multiple plant species, healthy cases, and disease cases across mild/
/// moderate/severe severities so Recommendation content (Phase 8) has real
/// variety to map against. `analyzedAt` here is a placeholder;
/// `MockAIService` stamps the real time via `copyWith` at selection time.
final List<PlantDiagnosisResult> mockResultBank = [
  PlantDiagnosisResult(
    plantCommonName: 'Tomato',
    plantSpeciesLatin: 'Solanum lycopersicum',
    diagnosisLabel: 'Healthy',
    isHealthy: true,
    confidence: 0.97,
    severity: DiagnosisSeverity.none,
    description:
        'This tomato plant shows no signs of disease or nutrient stress. '
        'Leaves are a uniform deep green with no spotting, wilting, or '
        'discoloration.',
    visualSymptoms: const [],
    analyzedAt: DateTime(2000),
  ),
  PlantDiagnosisResult(
    plantCommonName: 'Basil',
    plantSpeciesLatin: 'Ocimum basilicum',
    diagnosisLabel: 'Healthy',
    isHealthy: true,
    confidence: 0.95,
    severity: DiagnosisSeverity.none,
    description:
        'This basil plant looks vibrant and well-hydrated, with glossy '
        'leaves and no visible pest damage.',
    visualSymptoms: const [],
    analyzedAt: DateTime(2000),
  ),
  PlantDiagnosisResult(
    plantCommonName: 'Tomato',
    plantSpeciesLatin: 'Solanum lycopersicum',
    diagnosisLabel: 'Powdery Mildew',
    isHealthy: false,
    confidence: 0.88,
    severity: DiagnosisSeverity.mild,
    description:
        'A fungal infection is beginning to appear on the leaf surface. '
        'Caught early, it responds well to improved airflow and a light '
        'fungicide treatment.',
    visualSymptoms: const [
      'White powdery patches on upper leaf surface',
      'Slight yellowing around affected areas',
    ],
    analyzedAt: DateTime(2000),
  ),
  PlantDiagnosisResult(
    plantCommonName: 'Pepper',
    plantSpeciesLatin: 'Capsicum annuum',
    diagnosisLabel: 'Aphid Infestation',
    isHealthy: false,
    confidence: 0.82,
    severity: DiagnosisSeverity.mild,
    description:
        'A small colony of aphids is feeding on new growth. This is '
        'manageable with a simple insecticidal soap treatment before it '
        'spreads further.',
    visualSymptoms: const [
      'Clusters of small insects on stems and leaf undersides',
      'Slightly curled new leaves',
      'Sticky residue (honeydew) on nearby leaves',
    ],
    analyzedAt: DateTime(2000),
  ),
  PlantDiagnosisResult(
    plantCommonName: 'Rose',
    plantSpeciesLatin: 'Rosa',
    diagnosisLabel: 'Black Spot',
    isHealthy: false,
    confidence: 0.91,
    severity: DiagnosisSeverity.moderate,
    description:
        'A common fungal disease that has spread across several leaves. '
        'Left untreated, it can cause significant leaf drop and weaken '
        'the plant over the season.',
    visualSymptoms: const [
      'Circular black spots with fringed edges',
      'Yellowing leaf tissue surrounding spots',
      'Some premature leaf drop',
    ],
    analyzedAt: DateTime(2000),
  ),
  PlantDiagnosisResult(
    plantCommonName: 'Basil',
    plantSpeciesLatin: 'Ocimum basilicum',
    diagnosisLabel: 'Downy Mildew',
    isHealthy: false,
    confidence: 0.85,
    severity: DiagnosisSeverity.moderate,
    description:
        'A moisture-loving pathogen has taken hold, likely due to high '
        'humidity or overhead watering. Improving airflow and reducing '
        'leaf wetness will help contain it.',
    visualSymptoms: const [
      'Yellow angular patches on upper leaf surface',
      'Grey-purple fuzzy growth on leaf undersides',
    ],
    analyzedAt: DateTime(2000),
  ),
  PlantDiagnosisResult(
    plantCommonName: 'Cucumber',
    plantSpeciesLatin: 'Cucumis sativus',
    diagnosisLabel: 'Bacterial Wilt',
    isHealthy: false,
    confidence: 0.9,
    severity: DiagnosisSeverity.severe,
    description:
        'This plant is showing advanced signs of bacterial wilt, likely '
        'spread by cucumber beetles. This condition progresses quickly and '
        'affected vines should be removed to protect nearby plants.',
    visualSymptoms: const [
      'Sudden wilting of individual leaves and vines',
      'Milky white sap when the stem is cut',
      'Vines collapsing despite adequate soil moisture',
    ],
    analyzedAt: DateTime(2000),
  ),
  PlantDiagnosisResult(
    plantCommonName: 'Monstera',
    plantSpeciesLatin: 'Monstera deliciosa',
    diagnosisLabel: 'Root Rot',
    isHealthy: false,
    confidence: 0.93,
    severity: DiagnosisSeverity.severe,
    description:
        'Signs point to root rot from prolonged overwatering or poor '
        'drainage. This is urgent — repotting into fresh, well-draining '
        'soil and trimming affected roots is needed soon.',
    visualSymptoms: const [
      'Yellowing and drooping lower leaves',
      'Soft, dark stem base',
      'Foul odor from the soil',
    ],
    analyzedAt: DateTime(2000),
  ),
];
