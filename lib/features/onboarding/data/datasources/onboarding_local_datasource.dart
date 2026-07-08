import 'package:shared_preferences/shared_preferences.dart';

/// Persists the onboarding-complete flag via `shared_preferences`.
class OnboardingLocalDataSource {
  const OnboardingLocalDataSource(this._prefs);

  static const String _onboardingCompleteKey = 'onboarding_complete';

  final SharedPreferences _prefs;

  bool isOnboardingComplete() => _prefs.getBool(_onboardingCompleteKey) ?? false;

  Future<void> setOnboardingComplete() =>
      _prefs.setBool(_onboardingCompleteKey, true);
}
