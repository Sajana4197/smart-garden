import 'package:flutter/foundation.dart';

import '../../../voice/domain/repositories/speech_repository.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/entities/temperature_unit.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/clear_garden_data.dart';
import '../../domain/usecases/set_speech_settings.dart';
import '../../domain/usecases/set_temperature_unit.dart';
import '../../domain/usecases/set_theme_mode.dart';
import '../utils/theme_mode_mapping.dart';

/// Holds the current [AppSettings] and applies changes both to persistence
/// and, where relevant, to the live app-wide singletons that consume them
/// (`ThemeModeController`, the shared `SpeechRepository`) — see CLAUDE.md §5
/// (one ChangeNotifier per meaningful unit of state per feature). Registered
/// app-wide in `app.dart` like `MyGardenProvider`/`ScanHistoryProvider`
/// (same `StatefulShellRoute.indexedStack` reasoning, CLAUDE.md §3), even
/// though nothing outside the Settings screen currently mutates it.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(
    SettingsRepository repository,
    this._setThemeMode,
    this._setTemperatureUnit,
    this._setSpeechSettings,
    this._clearGardenData,
    this._speechRepository,
    this._themeModeController,
  ) : _settings = repository.getSettings();

  final SetThemeMode _setThemeMode;
  final SetTemperatureUnit _setTemperatureUnit;
  final SetSpeechSettings _setSpeechSettings;
  final ClearGardenData _clearGardenData;
  final SpeechRepository _speechRepository;
  final ThemeModeController _themeModeController;

  AppSettings _settings;
  bool _isClearing = false;

  AppSettings get settings => _settings;
  bool get isClearing => _isClearing;

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_settings.themeMode == mode) return;
    await _setThemeMode(mode);
    _settings = _settings.copyWith(themeMode: mode);
    _themeModeController.setThemeMode(toFlutterThemeMode(mode));
    notifyListeners();
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    if (_settings.temperatureUnit == unit) return;
    await _setTemperatureUnit(unit);
    _settings = _settings.copyWith(temperatureUnit: unit);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    final updated = _settings.speechSettings.copyWith(rate: rate);
    await _setSpeechSettings(updated);
    await _speechRepository.setSpeechRate(rate);
    _settings = _settings.copyWith(speechSettings: updated);
    notifyListeners();
  }

  Future<void> setSpeechPitch(double pitch) async {
    final updated = _settings.speechSettings.copyWith(pitch: pitch);
    await _setSpeechSettings(updated);
    await _speechRepository.setSpeechPitch(pitch);
    _settings = _settings.copyWith(speechSettings: updated);
    notifyListeners();
  }

  Future<void> clearGardenData() async {
    _isClearing = true;
    notifyListeners();
    try {
      await _clearGardenData();
    } finally {
      _isClearing = false;
      notifyListeners();
    }
  }
}
