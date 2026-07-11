import '../../domain/entities/current_weather.dart';
import '../../domain/entities/forecast_day.dart';
import 'condition_mapper.dart';

/// DTO for [ForecastDay] — see PROJECT_SPEC.md §3 (models extend domain
/// entities, add fromJson/toMap etc.).
class ForecastDayModel extends ForecastDay {
  const ForecastDayModel({
    required super.date,
    required super.minTempCelsius,
    required super.maxTempCelsius,
    required super.condition,
  });

  /// OpenWeatherMap's free forecast endpoint returns one entry per 3-hour
  /// interval, not per day — this groups those entries by calendar date and
  /// collapses each group to a single min/max/condition, picking the entry
  /// closest to local midday as the day's representative condition (a 3am
  /// "clear" reading is a worse summary of the day than a midday one).
  static List<ForecastDayModel> fromOpenWeatherForecastJson(
    Map<String, Object?> json,
  ) {
    final entries = (json['list']! as List).cast<Map<String, Object?>>();
    final byDate = <DateTime, List<Map<String, Object?>>>{};

    for (final entry in entries) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(
        (entry['dt']! as num).toInt() * 1000,
      );
      final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
      byDate.putIfAbsent(dateOnly, () => []).add(entry);
    }

    final days = byDate.entries.map((dayEntries) {
      final date = dayEntries.key;
      final readings = dayEntries.value;

      var minTemp = double.infinity;
      var maxTemp = double.negativeInfinity;
      Map<String, Object?>? middayReading;
      var smallestHourDelta = 25;

      for (final reading in readings) {
        final main = reading['main']! as Map<String, Object?>;
        final tempMin = (main['temp_min']! as num).toDouble();
        final tempMax = (main['temp_max']! as num).toDouble();
        if (tempMin < minTemp) minTemp = tempMin;
        if (tempMax > maxTemp) maxTemp = tempMax;

        final hour = DateTime.fromMillisecondsSinceEpoch(
          (reading['dt']! as num).toInt() * 1000,
        ).hour;
        final hourDelta = (hour - 12).abs();
        if (hourDelta < smallestHourDelta) {
          smallestHourDelta = hourDelta;
          middayReading = reading;
        }
      }

      final representativeWeather =
          ((middayReading ?? readings.first)['weather']! as List).first
              as Map<String, Object?>;

      return ForecastDayModel(
        date: date,
        minTempCelsius: minTemp,
        maxTempCelsius: maxTemp,
        condition: weatherConditionFromOwmMain(
          representativeWeather['main']! as String,
        ),
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return days;
  }

  Map<String, Object?> toCacheJson() => {
        'date': date.toIso8601String(),
        'minTempCelsius': minTempCelsius,
        'maxTempCelsius': maxTempCelsius,
        'condition': condition.name,
      };

  factory ForecastDayModel.fromCacheJson(Map<String, Object?> json) {
    return ForecastDayModel(
      date: DateTime.parse(json['date']! as String),
      minTempCelsius: (json['minTempCelsius']! as num).toDouble(),
      maxTempCelsius: (json['maxTempCelsius']! as num).toDouble(),
      condition: WeatherCondition.values.byName(json['condition']! as String),
    );
  }
}
