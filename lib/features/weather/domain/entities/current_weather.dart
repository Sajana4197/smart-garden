/// Broad weather condition — drives the icon shown alongside the raw
/// [CurrentWeather.description] text. Deliberately coarse (a handful of
/// buckets) rather than mirroring every OpenWeatherMap condition code.
enum WeatherCondition { clear, clouds, rain, drizzle, thunderstorm, snow, atmosphere, unknown }

/// Current conditions for one location — pure Dart, no Flutter/DB imports
/// (domain layer rule in PROJECT_SPEC.md §3). See ROADMAP.md Phase 11.
class CurrentWeather {
  const CurrentWeather({
    required this.locationName,
    required this.temperatureCelsius,
    required this.condition,
    required this.description,
    required this.humidityPercent,
    required this.observedAt,
  });

  final String locationName;
  final double temperatureCelsius;
  final WeatherCondition condition;

  /// Human-readable condition text from the API (e.g. "light rain").
  final String description;
  final int humidityPercent;
  final DateTime observedAt;
}
