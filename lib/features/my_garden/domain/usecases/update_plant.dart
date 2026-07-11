import '../entities/plant.dart';
import '../repositories/plant_repository.dart';

class UpdatePlant {
  UpdatePlant(this._repository);

  final PlantRepository _repository;

  Future<void> call(Plant plant) => _repository.updatePlant(plant);
}
