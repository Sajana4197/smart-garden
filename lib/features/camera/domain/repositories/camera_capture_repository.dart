abstract class CameraCaptureRepository {
  /// Copies the just-captured photo at [rawPath] into sandbox storage and
  /// returns the stable path.
  Future<String> storeCapturedPhoto(String rawPath);
}
