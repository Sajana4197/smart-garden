import '../../domain/entities/app_settings.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/entities/speech_settings.dart';
import '../../domain/entities/temperature_unit.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  AppSettings getSettings() => AppSettings(
        themeMode: _localDataSource.getThemeMode(),
        temperatureUnit: _localDataSource.getTemperatureUnit(),
        speechSettings: SpeechSettings(
          rate: _localDataSource.getSpeechRate(),
          pitch: _localDataSource.getSpeechPitch(),
        ),
      );

  @override
  Future<void> saveThemeMode(AppThemeMode mode) => _localDataSource.setThemeMode(mode);

  @override
  Future<void> saveTemperatureUnit(TemperatureUnit unit) =>
      _localDataSource.setTemperatureUnit(unit);

  @override
  Future<void> saveSpeechSettings(SpeechSettings settings) async {
    await _localDataSource.setSpeechRate(settings.rate);
    await _localDataSource.setSpeechPitch(settings.pitch);
  }
}
