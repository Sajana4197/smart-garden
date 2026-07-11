import '../entities/geo_position.dart';

enum LocationErrorType {
  /// User denied the permission prompt (can be asked again).
  permissionDenied,

  /// User denied permanently ("don't ask again") — must be granted from OS
  /// Settings; no in-app retry can succeed.
  permissionDeniedForever,

  /// Device-level location services (GPS) are turned off.
  serviceDisabled,
}

class LocationException implements Exception {
  LocationException(this.type);

  final LocationErrorType type;

  @override
  String toString() => 'LocationException($type)';
}

/// Abstract seam `presentation` (via use cases) depends on — never a
/// concrete geolocator-backed implementation directly — per
/// PROJECT_SPEC.md §3 dependency rule.
abstract class LocationRepository {
  /// Resolves the device's current position, requesting permission if
  /// needed. Throws [LocationException] if permission/service isn't
  /// available — never returns a null/garbage position.
  Future<GeoPosition> getCurrentPosition();
}
