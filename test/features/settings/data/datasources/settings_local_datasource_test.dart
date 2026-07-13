import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_garden_ai/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:smart_garden_ai/features/settings/domain/entities/app_theme_mode.dart';
import 'package:smart_garden_ai/features/settings/domain/entities/speech_settings.dart';
import 'package:smart_garden_ai/features/settings/domain/entities/temperature_unit.dart';

void main() {
  late SettingsLocalDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    dataSource = SettingsLocalDataSource(prefs);
  });

  test('defaults to system theme, celsius, and stock speech settings', () {
    expect(dataSource.getThemeMode(), AppThemeMode.system);
    expect(dataSource.getTemperatureUnit(), TemperatureUnit.celsius);
    expect(dataSource.getSpeechRate(), const SpeechSettings().rate);
    expect(dataSource.getSpeechPitch(), const SpeechSettings().pitch);
  });

  test('setThemeMode then getThemeMode round-trips', () async {
    await dataSource.setThemeMode(AppThemeMode.dark);
    expect(dataSource.getThemeMode(), AppThemeMode.dark);
  });

  test('setTemperatureUnit then getTemperatureUnit round-trips', () async {
    await dataSource.setTemperatureUnit(TemperatureUnit.fahrenheit);
    expect(dataSource.getTemperatureUnit(), TemperatureUnit.fahrenheit);
  });

  test('setSpeechRate/setSpeechPitch then getters round-trip independently', () async {
    await dataSource.setSpeechRate(0.75);
    await dataSource.setSpeechPitch(1.5);

    expect(dataSource.getSpeechRate(), 0.75);
    expect(dataSource.getSpeechPitch(), 1.5);
  });
}
