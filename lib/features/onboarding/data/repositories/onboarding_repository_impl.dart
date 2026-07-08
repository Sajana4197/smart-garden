import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._localDataSource);

  final OnboardingLocalDataSource _localDataSource;

  @override
  Future<bool> isOnboardingComplete() async =>
      _localDataSource.isOnboardingComplete();

  @override
  Future<void> completeOnboarding() =>
      _localDataSource.setOnboardingComplete();
}
