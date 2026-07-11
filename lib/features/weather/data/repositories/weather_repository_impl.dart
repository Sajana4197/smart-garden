import '../../domain/entities/geo_position.dart';
import '../../domain/entities/weather_snapshot.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_datasource.dart';
import '../datasources/weather_remote_datasource.dart';
import '../models/weather_snapshot_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final WeatherRemoteDataSource _remoteDataSource;
  final WeatherLocalDataSource _localDataSource;

  @override
  Future<WeatherSnapshot> fetchWeather(GeoPosition position) async {
    final current = await _remoteDataSource.fetchCurrentWeather(position);
    final forecast = await _remoteDataSource.fetchForecast(position);
    final snapshot = WeatherSnapshotModel(
      current: current,
      forecast: forecast,
      fetchedAt: DateTime.now(),
    );
    await _localDataSource.cacheSnapshot(snapshot);
    return snapshot;
  }

  @override
  Future<WeatherSnapshot?> getCachedWeather() async {
    return _localDataSource.getCachedSnapshot();
  }
}
