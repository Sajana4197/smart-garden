import '../repositories/onboarding_repository.dart';

/// Whether the user has completed onboarding before — read by Splash to
/// decide where to route next.
class CheckOnboardingStatus {
  const CheckOnboardingStatus(this._repository);

  final OnboardingRepository _repository;

  Future<bool> call() => _repository.isOnboardingComplete();
}
