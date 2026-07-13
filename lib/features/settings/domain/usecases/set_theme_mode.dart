import '../entities/app_theme_mode.dart';
import '../repositories/settings_repository.dart';

class SetThemeMode {
  SetThemeMode(this._repository);

  final SettingsRepository _repository;

  Future<void> call(AppThemeMode mode) => _repository.saveThemeMode(mode);
}
