import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_theme_mode.dart';
import '../../domain/entities/speech_settings.dart';
import '../../domain/entities/temperature_unit.dart';

/// Persists individual settings via `shared_preferences`, mirroring
/// `OnboardingLocalDataSource`'s sync-read/async-write pattern.
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._prefs);

  static const String _themeModeKey = 'settings_theme_mode';
  static const String _temperatureUnitKey = 'settings_temperature_unit';
  static const String _speechRateKey = 'settings_speech_rate';
  static const String _speechPitchKey = 'settings_speech_pitch';

  final SharedPreferences _prefs;

  AppThemeMode getThemeMode() {
    final stored = _prefs.getString(_themeModeKey);
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) => _prefs.setString(_themeModeKey, mode.name);

  TemperatureUnit getTemperatureUnit() {
    final stored = _prefs.getString(_temperatureUnitKey);
    return TemperatureUnit.values.firstWhere(
      (unit) => unit.name == stored,
      orElse: () => TemperatureUnit.celsius,
    );
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) =>
      _prefs.setString(_temperatureUnitKey, unit.name);

  double getSpeechRate() => _prefs.getDouble(_speechRateKey) ?? const SpeechSettings().rate;

  Future<void> setSpeechRate(double rate) => _prefs.setDouble(_speechRateKey, rate);

  double getSpeechPitch() => _prefs.getDouble(_speechPitchKey) ?? const SpeechSettings().pitch;

  Future<void> setSpeechPitch(double pitch) => _prefs.setDouble(_speechPitchKey, pitch);
}
