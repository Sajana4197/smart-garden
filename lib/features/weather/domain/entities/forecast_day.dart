import 'current_weather.dart';

/// One day of the short forecast — aggregated from the API's 3-hour-interval
/// data down to a single min/max/condition per calendar day. Pure Dart, no
/// Flutter/DB imports (domain layer rule in PROJECT_SPEC.md §3).
class ForecastDay {
  const ForecastDay({
    required this.date,
    required this.minTempCelsius,
    required this.maxTempCelsius,
    required this.condition,
  });

  final DateTime date;
  final double minTempCelsius;
  final double maxTempCelsius;
  final WeatherCondition condition;
}
