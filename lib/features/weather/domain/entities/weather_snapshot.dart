import 'current_weather.dart';
import 'forecast_day.dart';

/// A fetched-together bundle of current conditions + short forecast, plus
/// when it was fetched — [fetchedAt] is what lets the UI show "as of X ago"
/// when serving a cached snapshot instead of a live one.
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.current,
    required this.forecast,
    required this.fetchedAt,
  });

  final CurrentWeather current;
  final List<ForecastDay> forecast;
  final DateTime fetchedAt;
}
