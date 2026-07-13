import '../entities/temperature_unit.dart';
import '../repositories/settings_repository.dart';

class SetTemperatureUnit {
  SetTemperatureUnit(this._repository);

  final SettingsRepository _repository;

  Future<void> call(TemperatureUnit unit) => _repository.saveTemperatureUnit(unit);
}
