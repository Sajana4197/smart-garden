abstract class GalleryRepository {
  /// Copies the just-picked photo at [rawPath] into sandbox storage and
  /// returns the stable path.
  Future<String> storePickedPhoto(String rawPath);
}
