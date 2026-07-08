import 'package:flutter/foundation.dart';

import '../../domain/usecases/complete_onboarding.dart';

/// Holds the onboarding carousel's current page and drives completion.
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(this._completeOnboarding);

  final CompleteOnboarding _completeOnboarding;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  void setPage(int page) {
    if (_currentPage == page) return;
    _currentPage = page;
    notifyListeners();
  }

  Future<void> complete() => _completeOnboarding();
}
