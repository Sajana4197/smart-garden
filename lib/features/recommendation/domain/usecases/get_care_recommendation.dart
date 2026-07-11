import '../../../../services/ai/models/plant_diagnosis_result.dart';
import '../entities/care_recommendation.dart';
import '../repositories/recommendation_repository.dart';

class GetCareRecommendation {
  GetCareRecommendation(this._repository);

  final RecommendationRepository _repository;

  CareRecommendation call({
    required String diagnosisLabel,
    required DiagnosisSeverity severity,
  }) {
    return _repository.getRecommendation(
      diagnosisLabel: diagnosisLabel,
      severity: severity,
    );
  }
}
