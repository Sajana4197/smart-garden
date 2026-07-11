import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/weather_config.dart';
import '../../domain/entities/geo_position.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/current_weather_model.dart';
import '../models/forecast_day_model.dart';

/// Talks to OpenWeatherMap's free "Current Weather Data" and "5 day / 3 hour
/// Forecast" endpoints — see CLAUDE.md §3 (Weather API provider). Throws
/// [WeatherException] for every failure mode (missing key, network error,
/// non-200 response, unparseable body) so callers never see a raw
/// exception type from `http`/`dart:convert`.
class WeatherRemoteDataSource {
  WeatherRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';

  final http.Client _client;

  Future<CurrentWeatherModel> fetchCurrentWeather(GeoPosition position) async {
    final json = await _get('$_baseUrl/weather', position);
    return CurrentWeatherModel.fromOpenWeatherJson(json);
  }

  Future<List<ForecastDayModel>> fetchForecast(GeoPosition position) async {
    final json = await _get('$_baseUrl/forecast', position);
    return ForecastDayModel.fromOpenWeatherForecastJson(json);
  }

  Future<Map<String, Object?>> _get(String path, GeoPosition position) async {
    if (!WeatherConfig.isConfigured) {
      throw WeatherException(
        WeatherErrorType.notConfigured,
        'No weather API key configured.',
      );
    }

    final uri = Uri.parse(path).replace(
      queryParameters: {
        'lat': position.latitude.toString(),
        'lon': position.longitude.toString(),
        'appid': WeatherConfig.apiKey,
        'units': 'metric',
      },
    );

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } catch (e) {
      throw WeatherException(WeatherErrorType.network, 'Could not reach the weather service.');
    }

    if (response.statusCode != 200) {
      throw WeatherException(
        WeatherErrorType.network,
        'Weather service returned ${response.statusCode}.',
      );
    }

    try {
      return jsonDecode(response.body) as Map<String, Object?>;
    } catch (e) {
      throw WeatherException(WeatherErrorType.network, 'Could not parse the weather response.');
    }
  }
}
