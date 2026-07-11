import '../repositories/plant_repository.dart';

class DeletePlant {
  DeletePlant(this._repository);

  final PlantRepository _repository;

  Future<void> call(int id) => _repository.deletePlant(id);
}
