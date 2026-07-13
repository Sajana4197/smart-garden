import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

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
import 'package:smart_garden_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:smart_garden_ai/features/voice/domain/entities/speech_status.dart';
import 'package:smart_garden_ai/features/voice/domain/repositories/speech_repository.dart';
import 'package:smart_garden_ai/features/voice/domain/usecases/pause_speech.dart';
import 'package:smart_garden_ai/features/voice/domain/usecases/speak_text.dart';
import 'package:smart_garden_ai/features/voice/domain/usecases/stop_speech.dart';
import 'package:smart_garden_ai/services/app_info/app_info_service.dart';

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._settings);

  AppSettings _settings;
  int saveThemeModeCount = 0;
  int saveTemperatureUnitCount = 0;

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
    _settings = _settings.copyWith(speechSettings: settings);
  }
}

class _FakeSpeechRepository implements SpeechRepository {
  @override
  Stream<SpeechStatus> get statusStream => const Stream.empty();

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  Future<void> setSpeechPitch(double pitch) async {}
}

Future<void> _pumpSettingsScreen(WidgetTester tester, _FakeSettingsRepository repository) async {
  await tester.binding.setSurfaceSize(const Size(400, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final speechRepository = _FakeSpeechRepository();

  await tester.pumpWidget(
    MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<AppInfoService>(create: (_) => AppInfoService()),
          Provider<SpeechRepository>(create: (_) => speechRepository),
          Provider<SpeakText>(create: (_) => SpeakText(speechRepository)),
          Provider<PauseSpeech>(create: (_) => PauseSpeech(speechRepository)),
          Provider<StopSpeech>(create: (_) => StopSpeech(speechRepository)),
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider(
              repository,
              SetThemeMode(repository),
              SetTemperatureUnit(repository),
              SetSpeechSettings(repository),
              ClearGardenData(_UnreachablePlantRepository(), _UnreachableScanRepository()),
              speechRepository,
              ThemeModeController(),
            ),
          ),
        ],
        child: const SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'SmartGarden AI',
      packageName: 'com.smartgarden.ai.smart_garden_ai',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets('renders every settings section', (tester) async {
    await _pumpSettingsScreen(tester, _FakeSettingsRepository(const AppSettings()));

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);
    expect(find.text('Voice'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Version 1.0.0 (1)'), findsOneWidget);
  });

  testWidgets('tapping a theme mode segment persists the new mode', (tester) async {
    final repository = _FakeSettingsRepository(const AppSettings());
    await _pumpSettingsScreen(tester, repository);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(repository.saveThemeModeCount, 1);
    expect(repository.getSettings().themeMode, AppThemeMode.dark);
  });

  testWidgets('tapping a temperature unit segment persists the new unit', (tester) async {
    final repository = _FakeSettingsRepository(const AppSettings());
    await _pumpSettingsScreen(tester, repository);

    await tester.tap(find.text('Fahrenheit (°F)'));
    await tester.pumpAndSettle();

    expect(repository.saveTemperatureUnitCount, 1);
    expect(repository.getSettings().temperatureUnit, TemperatureUnit.fahrenheit);
  });

  testWidgets('Clear Garden Data shows a confirmation dialog that Cancel dismisses', (
    tester,
  ) async {
    await _pumpSettingsScreen(tester, _FakeSettingsRepository(const AppSettings()));

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(find.text('Clear all garden data?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Clear all garden data?'), findsNothing);
  });
}

class _UnreachablePlantRepository implements PlantRepository {
  @override
  Future<List<Plant>> getAllPlants() async => throw UnimplementedError();

  @override
  Future<Plant?> getPlantById(int id) async => throw UnimplementedError();

  @override
  Future<int> addPlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> updatePlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> deletePlant(int id) async => throw UnimplementedError();
}

class _UnreachableScanRepository implements ScanRepository {
  @override
  Future<List<Scan>> getAllScans() async => throw UnimplementedError();

  @override
  Future<List<Scan>> getScansForPlant(int plantId) async => throw UnimplementedError();

  @override
  Future<Scan?> getScanById(int id) async => throw UnimplementedError();

  @override
  Future<int> addScan(Scan scan) async => throw UnimplementedError();

  @override
  Future<void> updateScan(Scan scan) async => throw UnimplementedError();

  @override
  Future<void> deleteScan(int id) async => throw UnimplementedError();
}
