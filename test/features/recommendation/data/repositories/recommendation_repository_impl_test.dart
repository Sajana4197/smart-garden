import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/features/recommendation/data/repositories/recommendation_repository_impl.dart';
import 'package:smart_garden_ai/services/ai/models/plant_diagnosis_result.dart';

void main() {
  test('delegates to the local data source and returns its recommendation', () {
    final repository = RecommendationRepositoryImpl();

    final recommendation = repository.getRecommendation(
      diagnosisLabel: 'Root Rot',
      severity: DiagnosisSeverity.severe,
    );

    expect(recommendation.wateringAdvice, contains('Stop watering'));
    expect(recommendation.treatmentSteps, isNotEmpty);
  });
}
