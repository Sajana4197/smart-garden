import '../entities/plant.dart';
import '../repositories/plant_repository.dart';

class GetPlantById {
  GetPlantById(this._repository);

  final PlantRepository _repository;

  Future<Plant?> call(int id) => _repository.getPlantById(id);
}
