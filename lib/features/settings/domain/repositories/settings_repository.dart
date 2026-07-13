import '../entities/app_settings.dart';
import '../entities/app_theme_mode.dart';
import '../entities/speech_settings.dart';
import '../entities/temperature_unit.dart';

/// Abstract seam `presentation` (via use cases) depends on — never the
/// concrete `SettingsRepositoryImpl` — per PROJECT_SPEC.md §3 dependency
/// rule. [getSettings] is synchronous: the underlying `shared_preferences`
/// instance is already loaded before the app starts (see `main.dart`), so
/// callers — notably `app.dart`'s bootstrap, which needs an initial
/// `ThemeMode`/TTS rate before the widget tree exists — never need to await
/// it.
abstract class SettingsRepository {
  AppSettings getSettings();

  Future<void> saveThemeMode(AppThemeMode mode);

  Future<void> saveTemperatureUnit(TemperatureUnit unit);

  Future<void> saveSpeechSettings(SpeechSettings settings);
}
