import 'package:flutter/foundation.dart';

import '../../domain/entities/weather_snapshot.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_cached_weather.dart';
import '../../domain/usecases/get_current_weather.dart';

/// Why the Home Dashboard weather card isn't showing a fresh live reading —
/// null means the last [loadWeather] call succeeded outright.
enum WeatherDegradedReason {
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  network,
  notConfigured,
}

/// Holds the Home Dashboard's weather state — see CLAUDE.md §5 (one
/// ChangeNotifier per meaningful unit of state per feature). Registered
/// app-wide in app.dart rather than screen-scoped, following the same
/// `StatefulShellRoute.indexedStack` reasoning as `MyGardenProvider`/
/// `ScanHistoryProvider` (CLAUDE.md §3): Home is a bottom-nav branch whose
/// subtree survives tab switches without rebuilding.
class WeatherProvider extends ChangeNotifier {
  WeatherProvider(this._getCurrentWeather, this._getCachedWeather);

  final GetCurrentWeather _getCurrentWeather;
  final GetCachedWeather _getCachedWeather;

  bool _isLoading = true;
  WeatherSnapshot? _snapshot;
  bool _isFromCache = false;
  WeatherDegradedReason? _degradedReason;

  bool get isLoading => _isLoading;
  WeatherSnapshot? get snapshot => _snapshot;

  /// True when [snapshot] is a previously-cached value rather than the
  /// result of the most recent fetch attempt.
  bool get isFromCache => _isFromCache;

  /// Null if the last fetch attempt succeeded; otherwise why it didn't.
  WeatherDegradedReason? get degradedReason => _degradedReason;

  Future<void> loadWeather() async {
    _isLoading = true;
    notifyListeners();
    try {
      _snapshot = await _getCurrentWeather();
      _isFromCache = false;
      _degradedReason = null;
    } on LocationException catch (e) {
      _degradedReason = switch (e.type) {
        LocationErrorType.permissionDenied => WeatherDegradedReason.permissionDenied,
        LocationErrorType.permissionDeniedForever =>
          WeatherDegradedReason.permissionDeniedForever,
        LocationErrorType.serviceDisabled => WeatherDegradedReason.serviceDisabled,
      };
      await _fallBackToCache();
    } on WeatherException catch (e) {
      _degradedReason = switch (e.type) {
        WeatherErrorType.notConfigured => WeatherDegradedReason.notConfigured,
        WeatherErrorType.network => WeatherDegradedReason.network,
      };
      await _fallBackToCache();
    } catch (_) {
      // Anything else (e.g. a platform-channel failure geolocator itself
      // doesn't model as a LocationException) must still leave the provider
      // in a renderable state — PROJECT_SPEC.md §6 requires weather failures
      // to degrade gracefully, never crash.
      _degradedReason = WeatherDegradedReason.network;
      await _fallBackToCache();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fallBackToCache() async {
    final cached = await _getCachedWeather();
    if (cached != null) {
      _snapshot = cached;
      _isFromCache = true;
    } else {
      _snapshot = null;
      _isFromCache = false;
    }
  }
}
