/// Display unit for weather temperatures — see ROADMAP.md Phase 15.
/// `CurrentWeather.temperatureCelsius` always stores Celsius (the value
/// OpenWeatherMap returns for `units=metric`, CLAUDE.md §3); this only
/// controls client-side display formatting, not the API request.
enum TemperatureUnit { celsius, fahrenheit }
