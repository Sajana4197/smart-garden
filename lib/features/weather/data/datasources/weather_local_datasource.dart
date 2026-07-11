import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_snapshot_model.dart';

/// Persists the last successfully fetched [WeatherSnapshotModel] via
/// `shared_preferences` — the offline-resilience cache PROJECT_SPEC.md §6
/// requires ("cached last-known value + offline indicator").
class WeatherLocalDataSource {
  WeatherLocalDataSource(this._prefs);

  static const String _cacheKey = 'weather_last_snapshot';

  final SharedPreferences _prefs;

  Future<void> cacheSnapshot(WeatherSnapshotModel snapshot) {
    return _prefs.setString(_cacheKey, jsonEncode(snapshot.toCacheJson()));
  }

  WeatherSnapshotModel? getCachedSnapshot() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return null;
    return WeatherSnapshotModel.fromCacheJson(
      jsonDecode(raw) as Map<String, Object?>,
    );
  }
}
