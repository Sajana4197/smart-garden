import 'dart:io';

import '../../../../services/storage/image_storage_service.dart';
import '../../domain/repositories/gallery_repository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  GalleryRepositoryImpl(this._imageStorageService);

  final ImageStorageService _imageStorageService;

  @override
  Future<String> storePickedPhoto(String rawPath) {
    return _imageStorageService.saveToSandbox(File(rawPath), prefix: 'gallery');
  }
}
