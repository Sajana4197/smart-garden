import '../entities/weather_snapshot.dart';
import '../repositories/location_repository.dart';
import '../repositories/weather_repository.dart';

/// Resolves the device's location, then fetches live weather for it.
/// Lets [LocationException]/[WeatherException] propagate — `WeatherProvider`
/// decides how to degrade (cached value, offline indicator, permission
/// prompt) per PROJECT_SPEC.md §6, since that's presentation-level policy,
/// not something this thin orchestration step should hardcode.
class GetCurrentWeather {
  GetCurrentWeather(this._locationRepository, this._weatherRepository);

  final LocationRepository _locationRepository;
  final WeatherRepository _weatherRepository;

  Future<WeatherSnapshot> call() async {
    final position = await _locationRepository.getCurrentPosition();
    return _weatherRepository.fetchWeather(position);
  }
}
