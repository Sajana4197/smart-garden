import '../../domain/entities/weather_snapshot.dart';
import 'current_weather_model.dart';
import 'forecast_day_model.dart';

/// DTO for [WeatherSnapshot] — bundles the current-conditions and forecast
/// responses together for local caching as one JSON blob.
class WeatherSnapshotModel extends WeatherSnapshot {
  const WeatherSnapshotModel({
    required CurrentWeatherModel super.current,
    required List<ForecastDayModel> super.forecast,
    required super.fetchedAt,
  });

  Map<String, Object?> toCacheJson() => {
        'current': (current as CurrentWeatherModel).toCacheJson(),
        'forecast': forecast
            .map((day) => (day as ForecastDayModel).toCacheJson())
            .toList(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory WeatherSnapshotModel.fromCacheJson(Map<String, Object?> json) {
    return WeatherSnapshotModel(
      current: CurrentWeatherModel.fromCacheJson(
        json['current']! as Map<String, Object?>,
      ),
      forecast: (json['forecast']! as List)
          .cast<Map<String, Object?>>()
          .map(ForecastDayModel.fromCacheJson)
          .toList(),
      fetchedAt: DateTime.parse(json['fetchedAt']! as String),
    );
  }
}
