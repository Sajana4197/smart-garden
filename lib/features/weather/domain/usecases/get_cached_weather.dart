import '../entities/weather_snapshot.dart';
import '../repositories/weather_repository.dart';

class GetCachedWeather {
  GetCachedWeather(this._repository);

  final WeatherRepository _repository;

  Future<WeatherSnapshot?> call() => _repository.getCachedWeather();
}
