import '../../domain/entities/current_weather.dart';

/// Maps OpenWeatherMap's `weather[].main` field to our coarse
/// [WeatherCondition] bucket — shared by both the current-conditions and
/// forecast models since both API responses use the same field.
WeatherCondition weatherConditionFromOwmMain(String owmMain) {
  switch (owmMain) {
    case 'Clear':
      return WeatherCondition.clear;
    case 'Clouds':
      return WeatherCondition.clouds;
    case 'Rain':
      return WeatherCondition.rain;
    case 'Drizzle':
      return WeatherCondition.drizzle;
    case 'Thunderstorm':
      return WeatherCondition.thunderstorm;
    case 'Snow':
      return WeatherCondition.snow;
    case 'Mist':
    case 'Smoke':
    case 'Haze':
    case 'Dust':
    case 'Fog':
    case 'Sand':
    case 'Ash':
    case 'Squall':
    case 'Tornado':
      return WeatherCondition.atmosphere;
    default:
      return WeatherCondition.unknown;
  }
}
