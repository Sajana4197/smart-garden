import '../../domain/entities/plant.dart';
import '../../domain/repositories/plant_repository.dart';
import '../datasources/plant_local_datasource.dart';
import '../models/plant_model.dart';

class PlantRepositoryImpl implements PlantRepository {
  PlantRepositoryImpl(this._localDataSource);

  final PlantLocalDataSource _localDataSource;

  @override
  Future<List<Plant>> getAllPlants() => _localDataSource.getAllPlants();

  @override
  Future<Plant?> getPlantById(int id) => _localDataSource.getPlantById(id);

  @override
  Future<int> addPlant(Plant plant) {
    return _localDataSource.insertPlant(PlantModel.fromEntity(plant));
  }

  @override
  Future<void> updatePlant(Plant plant) {
    return _localDataSource.updatePlant(PlantModel.fromEntity(plant));
  }

  @override
  Future<void> deletePlant(int id) => _localDataSource.deletePlant(id);
}
