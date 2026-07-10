import '../repositories/gallery_repository.dart';

class StorePickedPhoto {
  StorePickedPhoto(this._repository);

  final GalleryRepository _repository;

  Future<String> call(String rawPath) => _repository.storePickedPhoto(rawPath);
}
