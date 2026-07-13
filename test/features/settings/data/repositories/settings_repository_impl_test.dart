import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_garden_ai/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:smart_garden_ai/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:smart_garden_ai/features/settings/domain/entities/app_theme_mode.dart';
import 'package:smart_garden_ai/features/settings/domain/entities/speech_settings.dart';
import 'package:smart_garden_ai/features/settings/domain/entities/temperature_unit.dart';

void main() {
  late SettingsRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = SettingsRepositoryImpl(SettingsLocalDataSource(prefs));
  });

  test('getSettings aggregates defaults from the local data source', () {
    final settings = repository.getSettings();

    expect(settings.themeMode, AppThemeMode.system);
    expect(settings.temperatureUnit, TemperatureUnit.celsius);
    expect(settings.speechSettings, const SpeechSettings());
  });

  test('save methods persist and getSettings reflects the new values', () async {
    await repository.saveThemeMode(AppThemeMode.light);
    await repository.saveTemperatureUnit(TemperatureUnit.fahrenheit);
    await repository.saveSpeechSettings(const SpeechSettings(rate: 0.8, pitch: 1.2));

    final settings = repository.getSettings();

    expect(settings.themeMode, AppThemeMode.light);
    expect(settings.temperatureUnit, TemperatureUnit.fahrenheit);
    expect(settings.speechSettings, const SpeechSettings(rate: 0.8, pitch: 1.2));
  });
}
