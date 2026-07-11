import '../../domain/entities/current_weather.dart';
import 'condition_mapper.dart';

/// DTO for [CurrentWeather] — adds JSON parsing for both OpenWeatherMap's
/// live response shape and our own local-cache shape (PROJECT_SPEC.md §3
/// "extend domain entities, add fromJson/toMap etc.").
class CurrentWeatherModel extends CurrentWeather {
  const CurrentWeatherModel({
    required super.locationName,
    required super.temperatureCelsius,
    required super.condition,
    required super.description,
    required super.humidityPercent,
    required super.observedAt,
  });

  factory CurrentWeatherModel.fromOpenWeatherJson(Map<String, Object?> json) {
    final weatherList = json['weather']! as List;
    final weather = weatherList.first as Map<String, Object?>;
    final main = json['main']! as Map<String, Object?>;

    return CurrentWeatherModel(
      locationName: json['name'] as String? ?? 'Unknown location',
      temperatureCelsius: (main['temp']! as num).toDouble(),
      condition: weatherConditionFromOwmMain(weather['main']! as String),
      description: weather['description'] as String? ?? '',
      humidityPercent: (main['humidity']! as num).round(),
      observedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['dt']! as num).toInt() * 1000,
      ),
    );
  }

  Map<String, Object?> toCacheJson() => {
        'locationName': locationName,
        'temperatureCelsius': temperatureCelsius,
        'condition': condition.name,
        'description': description,
        'humidityPercent': humidityPercent,
        'observedAt': observedAt.toIso8601String(),
      };

  factory CurrentWeatherModel.fromCacheJson(Map<String, Object?> json) {
    return CurrentWeatherModel(
      locationName: json['locationName']! as String,
      temperatureCelsius: (json['temperatureCelsius']! as num).toDouble(),
      condition: WeatherCondition.values.byName(json['condition']! as String),
      description: json['description']! as String,
      humidityPercent: (json['humidityPercent']! as num).toInt(),
      observedAt: DateTime.parse(json['observedAt']! as String),
    );
  }
}
