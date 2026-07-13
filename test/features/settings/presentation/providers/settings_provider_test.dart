import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/core/theme/theme_mode_controller.dart';
import 'package:smart_garden_ai/features/my_garden/domain/entities/plant.dart';
import 'package:smart_garden_ai/features/my_garden/domain/repositories/plant_repository.dart';
import 'package:smart_garden_ai/features/scan_history/domain/entities/scan.dart';
import 'package:smart_garden_ai/features/scan_history/domain/repositories/scan_repository.dart';
import 'package:smart_garden_ai/features/settings/domain/entities/app_settings.dart';
import 'package:smart_garden_ai/features/settings/domain/entities/app_theme_mode.dart';
import 'package:smart_garden_ai/features/settings/domain/entities/speech_settings.dart';
import 'package:smart_garden_ai/features/settings/domain/entities/temperature_unit.dart';
import 'package:smart_garden_ai/features/settings/domain/repositories/settings_repository.dart';
import 'package:smart_garden_ai/features/settings/domain/usecases/clear_garden_data.dart';
import 'package:smart_garden_ai/features/settings/domain/usecases/set_speech_settings.dart';
import 'package:smart_garden_ai/features/settings/domain/usecases/set_temperature_unit.dart';
import 'package:smart_garden_ai/features/settings/domain/usecases/set_theme_mode.dart';
import 'package:smart_garden_ai/features/settings/presentation/providers/settings_provider.dart';
import 'package:smart_garden_ai/features/voice/domain/entities/speech_status.dart';
import 'package:smart_garden_ai/features/voice/domain/repositories/speech_repository.dart';

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._settings);

  AppSettings _settings;
  int saveThemeModeCount = 0;
  int saveTemperatureUnitCount = 0;
  int saveSpeechSettingsCount = 0;

  @override
  AppSettings getSettings() => _settings;

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    saveThemeModeCount++;
    _settings = _settings.copyWith(themeMode: mode);
  }

  @override
  Future<void> saveTemperatureUnit(TemperatureUnit unit) async {
    saveTemperatureUnitCount++;
    _settings = _settings.copyWith(temperatureUnit: unit);
  }

  @override
  Future<void> saveSpeechSettings(SpeechSettings settings) async {
    saveSpeechSettingsCount++;
    _settings = _settings.copyWith(speechSettings: settings);
  }
}

class _FakeSpeechRepository implements SpeechRepository {
  double? lastRate;
  double? lastPitch;

  @override
  Stream<SpeechStatus> get statusStream => const Stream.empty();

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> setSpeechRate(double rate) async => lastRate = rate;

  @override
  Future<void> setSpeechPitch(double pitch) async => lastPitch = pitch;
}

class _FakePlantRepository implements PlantRepository {
  @override
  Future<List<Plant>> getAllPlants() async => const [];

  @override
  Future<Plant?> getPlantById(int id) async => throw UnimplementedError();

  @override
  Future<int> addPlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> updatePlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> deletePlant(int id) async {}
}

class _FakeScanRepository implements ScanRepository {
  @override
  Future<List<Scan>> getAllScans() async => const [];

  @override
  Future<List<Scan>> getScansForPlant(int plantId) async => throw UnimplementedError();

  @override
  Future<Scan?> getScanById(int id) async => throw UnimplementedError();

  @override
  Future<int> addScan(Scan scan) async => throw UnimplementedError();

  @override
  Future<void> updateScan(Scan scan) async => throw UnimplementedError();

  @override
  Future<void> deleteScan(int id) async {}
}

SettingsProvider _buildProvider({
  required _FakeSettingsRepository repository,
  required _FakeSpeechRepository speechRepository,
  required ThemeModeController themeModeController,
}) {
  return SettingsProvider(
    repository,
    SetThemeMode(repository),
    SetTemperatureUnit(repository),
    SetSpeechSettings(repository),
    ClearGardenData(_FakePlantRepository(), _FakeScanRepository()),
    speechRepository,
    themeModeController,
  );
}

void main() {
  test('reads initial settings from the repository at construction', () {
    final repository = _FakeSettingsRepository(
      const AppSettings(themeMode: AppThemeMode.dark),
    );
    final provider = _buildProvider(
      repository: repository,
      speechRepository: _FakeSpeechRepository(),
      themeModeController: ThemeModeController(),
    );

    expect(provider.settings.themeMode, AppThemeMode.dark);
  });

  test('setThemeMode persists and propagates to ThemeModeController', () async {
    final repository = _FakeSettingsRepository(const AppSettings());
    final themeModeController = ThemeModeController();
    final provider = _buildProvider(
      repository: repository,
      speechRepository: _FakeSpeechRepository(),
      themeModeController: themeModeController,
    );

    await provider.setThemeMode(AppThemeMode.dark);

    expect(repository.saveThemeModeCount, 1);
    expect(provider.settings.themeMode, AppThemeMode.dark);
    expect(themeModeController.themeMode, ThemeMode.dark);
  });

  test('setThemeMode is a no-op when the mode is unchanged', () async {
    final repository = _FakeSettingsRepository(
      const AppSettings(themeMode: AppThemeMode.light),
    );
    final provider = _buildProvider(
      repository: repository,
      speechRepository: _FakeSpeechRepository(),
      themeModeController: ThemeModeController(),
    );

    await provider.setThemeMode(AppThemeMode.light);

    expect(repository.saveThemeModeCount, 0);
  });

  test('setTemperatureUnit persists and updates settings', () async {
    final repository = _FakeSettingsRepository(const AppSettings());
    final provider = _buildProvider(
      repository: repository,
      speechRepository: _FakeSpeechRepository(),
      themeModeController: ThemeModeController(),
    );

    await provider.setTemperatureUnit(TemperatureUnit.fahrenheit);

    expect(repository.saveTemperatureUnitCount, 1);
    expect(provider.settings.temperatureUnit, TemperatureUnit.fahrenheit);
  });

  test('setSpeechRate persists and applies live to the SpeechRepository', () async {
    final repository = _FakeSettingsRepository(const AppSettings());
    final speechRepository = _FakeSpeechRepository();
    final provider = _buildProvider(
      repository: repository,
      speechRepository: speechRepository,
      themeModeController: ThemeModeController(),
    );

    await provider.setSpeechRate(0.9);

    expect(repository.saveSpeechSettingsCount, 1);
    expect(speechRepository.lastRate, 0.9);
    expect(provider.settings.speechSettings.rate, 0.9);
  });

  test('setSpeechPitch persists and applies live to the SpeechRepository', () async {
    final repository = _FakeSettingsRepository(const AppSettings());
    final speechRepository = _FakeSpeechRepository();
    final provider = _buildProvider(
      repository: repository,
      speechRepository: speechRepository,
      themeModeController: ThemeModeController(),
    );

    await provider.setSpeechPitch(1.8);

    expect(repository.saveSpeechSettingsCount, 1);
    expect(speechRepository.lastPitch, 1.8);
    expect(provider.settings.speechSettings.pitch, 1.8);
  });

  test('clearGardenData toggles isClearing around the call', () async {
    final repository = _FakeSettingsRepository(const AppSettings());
    final provider = _buildProvider(
      repository: repository,
      speechRepository: _FakeSpeechRepository(),
      themeModeController: ThemeModeController(),
    );

    expect(provider.isClearing, isFalse);
    final future = provider.clearGardenData();
    expect(provider.isClearing, isTrue);
    await future;
    expect(provider.isClearing, isFalse);
  });
}
