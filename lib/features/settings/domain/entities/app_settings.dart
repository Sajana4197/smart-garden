import 'app_theme_mode.dart';
import 'speech_settings.dart';
import 'temperature_unit.dart';

/// Aggregate of every user-configurable setting — pure Dart, no Flutter/DB
/// imports (domain layer rule in PROJECT_SPEC.md §3). See ROADMAP.md
/// Phase 15.
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.speechSettings = const SpeechSettings(),
  });

  final AppThemeMode themeMode;
  final TemperatureUnit temperatureUnit;
  final SpeechSettings speechSettings;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    TemperatureUnit? temperatureUnit,
    SpeechSettings? speechSettings,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        temperatureUnit: temperatureUnit ?? this.temperatureUnit,
        speechSettings: speechSettings ?? this.speechSettings,
      );
}
