/// User's theme preference — pure Dart, no Flutter imports (domain layer
/// rule in PROJECT_SPEC.md §3). Mapped onto Flutter's own `ThemeMode` in
/// presentation (see `presentation/utils/theme_mode_mapping.dart`) rather
/// than storing that type directly in domain/persistence. See ROADMAP.md
/// Phase 15.
enum AppThemeMode { system, light, dark }
