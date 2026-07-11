import '../entities/plant.dart';
import '../repositories/plant_repository.dart';

class GetAllPlants {
  GetAllPlants(this._repository);

  final PlantRepository _repository;

  Future<List<Plant>> call() => _repository.getAllPlants();
}
