/// Tracks whether the user has completed the onboarding carousel at least
/// once. Backs both the Splash routing decision and Onboarding's completion
/// action.
abstract class OnboardingRepository {
  Future<bool> isOnboardingComplete();
  Future<void> completeOnboarding();
}
