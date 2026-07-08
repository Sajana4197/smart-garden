import 'package:flutter/material.dart';

/// Holds the app's current [ThemeMode] so any widget can toggle it via
/// `provider`. Persistence is wired up in Phase 15 (Settings).
class ThemeModeController extends ChangeNotifier {
  ThemeModeController({ThemeMode initialMode = ThemeMode.system})
      : _themeMode = initialMode;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void toggleLightDark() {
    setThemeMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
