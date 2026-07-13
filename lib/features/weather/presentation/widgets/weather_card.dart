import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../settings/domain/entities/temperature_unit.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/current_weather.dart';
import '../providers/weather_provider.dart';

IconData _iconForCondition(WeatherCondition condition) => switch (condition) {
      WeatherCondition.clear => Icons.wb_sunny_outlined,
      WeatherCondition.clouds => Icons.wb_cloudy_outlined,
      WeatherCondition.rain => Icons.water_drop_outlined,
      WeatherCondition.drizzle => Icons.grain,
      WeatherCondition.thunderstorm => Icons.thunderstorm_outlined,
      WeatherCondition.snow => Icons.ac_unit,
      WeatherCondition.atmosphere => Icons.foggy,
      WeatherCondition.unknown => Icons.help_outline,
    };

/// Client-side conversion only — `CurrentWeather.temperatureCelsius` always
/// stores Celsius (CLAUDE.md §3), so this is purely a display concern and
/// never touches the weather fetch/API layer.
String _formatTemperature(double celsius, TemperatureUnit unit) {
  if (unit == TemperatureUnit.fahrenheit) {
    return '${(celsius * 9 / 5 + 32).round()}°F';
  }
  return '${celsius.round()}°C';
}

String _messageFor(WeatherDegradedReason reason) => switch (reason) {
      WeatherDegradedReason.permissionDenied =>
        'Location access is needed to show local weather.',
      WeatherDegradedReason.permissionDeniedForever =>
        "Location access is off. Enable it in your device Settings to see local weather.",
      WeatherDegradedReason.serviceDisabled =>
        'Turn on location services to see local weather.',
      WeatherDegradedReason.network => "Couldn't reach the weather service.",
      WeatherDegradedReason.notConfigured => "Weather isn't set up yet.",
    };

/// Home Dashboard's weather card — replaces the Phase 3 static placeholder
/// per ROADMAP.md Phase 11. Renders one of three states from
/// [WeatherProvider]: loading, a snapshot (live or cached, with an offline/
/// permission badge in the latter case), or a fully degraded empty state
/// with a context-appropriate action (retry, grant access, or open Settings).
class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  Future<void> _handleAction(BuildContext context) async {
    final provider = context.read<WeatherProvider>();
    switch (provider.degradedReason) {
      case WeatherDegradedReason.permissionDeniedForever:
        await Geolocator.openAppSettings();
      case WeatherDegradedReason.serviceDisabled:
        await Geolocator.openLocationSettings();
      case WeatherDegradedReason.permissionDenied:
      case WeatherDegradedReason.network:
      case WeatherDegradedReason.notConfigured:
      case null:
        await provider.loadWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final temperatureUnit = context.watch<SettingsProvider>().settings.temperatureUnit;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.isLoading && provider.snapshot == null) {
      return AppCard(
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('Checking local weather…', style: textTheme.bodyMedium),
          ],
        ),
      );
    }

    final snapshot = provider.snapshot;
    if (snapshot == null) {
      final reason = provider.degradedReason!;
      return AppCard(
        onTap: () => _handleAction(context),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                _messageFor(reason),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final current = snapshot.current;
    return AppCard(
      onTap: provider.degradedReason != null ? () => _handleAction(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(_iconForCondition(current.condition), size: 40, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(current.locationName, style: textTheme.titleMedium),
                    Text(
                      current.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatTemperature(current.temperatureCelsius, temperatureUnit),
                style: textTheme.headlineSmall,
              ),
            ],
          ),
          if (provider.degradedReason != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.cloud_off_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Showing last known weather — ${_messageFor(provider.degradedReason!)}',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
