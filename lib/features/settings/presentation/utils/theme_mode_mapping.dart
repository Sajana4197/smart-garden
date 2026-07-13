import 'package:flutter/material.dart';

import '../../domain/entities/app_theme_mode.dart';

/// Maps the domain `AppThemeMode` (pure Dart) onto Flutter's own
/// `ThemeMode` — kept out of `domain/` per PROJECT_SPEC.md §3 (no Flutter
/// imports there). Shared by `app.dart`'s bootstrap (seeding
/// `ThemeModeController`'s initial value) and `SettingsProvider` (applying
/// live changes), so the mapping lives in exactly one place.
ThemeMode toFlutterThemeMode(AppThemeMode mode) => switch (mode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
