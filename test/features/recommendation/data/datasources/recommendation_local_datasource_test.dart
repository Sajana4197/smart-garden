import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/features/recommendation/data/datasources/recommendation_local_datasource.dart';
import 'package:smart_garden_ai/features/recommendation/domain/entities/care_recommendation.dart';
import 'package:smart_garden_ai/services/ai/models/plant_diagnosis_result.dart';

void main() {
  const dataSource = RecommendationLocalDataSource();

  test('returns curated content for a known diagnosis label', () {
    final recommendation = dataSource.getRecommendation(
      'Powdery Mildew',
      DiagnosisSeverity.moderate,
    );

    expect(recommendation.wateringAdvice, contains('overhead watering'));
    expect(recommendation.treatmentSteps, isNotEmpty);
  });

  test('falls back to generic guidance for an unknown diagnosis label — never crashes', () {
    final recommendation = dataSource.getRecommendation(
      'Some Future Model Output We Have No Content For',
      DiagnosisSeverity.mild,
    );

    expect(recommendation.wateringAdvice, isNotEmpty);
    expect(recommendation.lightAdvice, isNotEmpty);
    expect(recommendation.treatmentSteps, isNotEmpty);
  });

  test('every mock result bank label resolves to non-empty curated content', () {
    // Mirrors MODEL_INTEGRATION.md §3's requirement that every Phase 7 mock
    // outcome yields a sensible recommendation.
    const labels = [
      'Healthy',
      'Powdery Mildew',
      'Aphid Infestation',
      'Black Spot',
      'Downy Mildew',
      'Bacterial Wilt',
      'Root Rot',
    ];

    for (final label in labels) {
      final recommendation = dataSource.getRecommendation(label, DiagnosisSeverity.mild);
      expect(recommendation.wateringAdvice, isNotEmpty, reason: label);
      expect(recommendation.lightAdvice, isNotEmpty, reason: label);
      expect(recommendation.treatmentSteps, isNotEmpty, reason: label);
    }
  });

  test('maps severity to urgency correctly', () {
    expect(
      dataSource.getRecommendation('Healthy', DiagnosisSeverity.none).urgency,
      RecommendationUrgency.routine,
    );
    expect(
      dataSource.getRecommendation('Healthy', DiagnosisSeverity.mild).urgency,
      RecommendationUrgency.routine,
    );
    expect(
      dataSource.getRecommendation('Healthy', DiagnosisSeverity.moderate).urgency,
      RecommendationUrgency.monitor,
    );
    expect(
      dataSource.getRecommendation('Healthy', DiagnosisSeverity.severe).urgency,
      RecommendationUrgency.urgent,
    );
  });
}
