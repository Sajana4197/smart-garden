import 'package:geolocator/geolocator.dart';

import '../../domain/entities/geo_position.dart';
import '../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<GeoPosition> getCurrentPosition() {
    // Bounded so a slow GPS fix (or, as seen in the widget-test sandbox
    // where no platform channel handler exists at all, an unresponsive
    // plugin call) can never hang the Home Dashboard's weather card
    // forever — PROJECT_SPEC.md §6 requires graceful degradation, not a
    // spinner that never resolves.
    return _resolvePosition().timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw LocationException(LocationErrorType.serviceDisabled),
    );
  }

  Future<GeoPosition> _resolvePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationException(LocationErrorType.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationException(LocationErrorType.permissionDenied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationException(LocationErrorType.permissionDeniedForever);
    }

    final position = await Geolocator.getCurrentPosition();
    return GeoPosition(latitude: position.latitude, longitude: position.longitude);
  }
}
