import 'dart:io';

import '../../../../services/storage/image_storage_service.dart';
import '../../domain/repositories/camera_capture_repository.dart';

class CameraCaptureRepositoryImpl implements CameraCaptureRepository {
  CameraCaptureRepositoryImpl(this._imageStorageService);

  final ImageStorageService _imageStorageService;

  @override
  Future<String> storeCapturedPhoto(String rawPath) {
    return _imageStorageService.saveToSandbox(File(rawPath), prefix: 'camera');
  }
}
