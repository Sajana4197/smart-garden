import '../entities/geo_position.dart';
import '../entities/weather_snapshot.dart';

enum WeatherErrorType {
  /// No `WEATHER_API_KEY` was supplied via `--dart-define` at build time.
  notConfigured,

  /// The device has no usable network connection, or the API call failed.
  network,
}

class WeatherException implements Exception {
  WeatherException(this.type, this.message);

  final WeatherErrorType type;
  final String message;

  @override
  String toString() => 'WeatherException($type): $message';
}

/// Abstract seam `presentation` (via use cases) depends on — never the
/// concrete `WeatherRepositoryImpl` — per PROJECT_SPEC.md §3 dependency rule.
abstract class WeatherRepository {
  /// Fetches live current conditions + short forecast for [position] and
  /// caches it locally on success. Throws [WeatherException] on failure —
  /// callers should fall back to [getCachedWeather] to keep showing the last
  /// known value, per PROJECT_SPEC.md §6's offline-resilience requirement.
  Future<WeatherSnapshot> fetchWeather(GeoPosition position);

  /// The last snapshot successfully cached by [fetchWeather], if any.
  Future<WeatherSnapshot?> getCachedWeather();
}
