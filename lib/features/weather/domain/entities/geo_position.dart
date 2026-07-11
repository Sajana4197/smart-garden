/// Device latitude/longitude — pure Dart, no Flutter/plugin imports (domain
/// layer rule in PROJECT_SPEC.md §3). Insulates the rest of the app from
/// `geolocator`'s `Position` type, which only `LocationRepositoryImpl` sees.
class GeoPosition {
  const GeoPosition({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}
