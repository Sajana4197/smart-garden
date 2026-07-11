import '../../../../services/ai/models/plant_diagnosis_result.dart';
import '../../domain/entities/care_recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_local_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  RecommendationRepositoryImpl([RecommendationLocalDataSource? localDataSource])
      : _localDataSource = localDataSource ?? const RecommendationLocalDataSource();

  final RecommendationLocalDataSource _localDataSource;

  @override
  CareRecommendation getRecommendation({
    required String diagnosisLabel,
    required DiagnosisSeverity severity,
  }) {
    return _localDataSource.getRecommendation(diagnosisLabel, severity);
  }
}
