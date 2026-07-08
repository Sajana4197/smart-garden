import '../repositories/onboarding_repository.dart';

/// Marks onboarding as complete so future launches skip straight to Home.
class CompleteOnboarding {
  const CompleteOnboarding(this._repository);

  final OnboardingRepository _repository;

  Future<void> call() => _repository.completeOnboarding();
}
