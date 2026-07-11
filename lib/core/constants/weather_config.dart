/// OpenWeatherMap API key — supplied at build/run time via
/// `--dart-define=WEATHER_API_KEY=...`, never hardcoded or committed (see
/// CLAUDE.md §2 rule 8 and ROADMAP.md Phase 11).
abstract final class WeatherConfig {
  static const String apiKey = String.fromEnvironment('WEATHER_API_KEY');

  static bool get isConfigured => apiKey.isNotEmpty;
}
