import '../repositories/camera_capture_repository.dart';

class StoreCapturedPhoto {
  StoreCapturedPhoto(this._repository);

  final CameraCaptureRepository _repository;

  Future<String> call(String rawPath) => _repository.storeCapturedPhoto(rawPath);
}
