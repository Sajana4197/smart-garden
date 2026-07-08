import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Assembles the light and dark [ThemeData] for SmartGarden AI.
///
/// Seed color (`#2E7D32`) and font family (Manrope, bundled locally as
/// `assets/fonts/Manrope-Variable.ttf` — never fetched over the network, per
/// the offline-first rule in PROJECT_SPEC.md §6) are locked decisions — see
/// CLAUDE.md §3 Locked Decisions.
abstract final class AppTheme {
  static const Color seedColor = Color(0xFF2E7D32);
  static const String fontFamily = 'Manrope';

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: fontFamily),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontFamily: fontFamily,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      extensions: [brightness == Brightness.light ? AppColors.light : AppColors.dark],
    );
  }
}
