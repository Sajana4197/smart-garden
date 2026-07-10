import '../entities/plant.dart';

/// Abstract seam `presentation` (via use cases) depends on — never the
/// concrete `PlantRepositoryImpl` — per PROJECT_SPEC.md §3 dependency rule.
abstract class PlantRepository {
  Future<List<Plant>> getAllPlants();

  Future<Plant?> getPlantById(int id);

  /// Inserts [plant] and returns the DB-assigned id.
  Future<int> addPlant(Plant plant);

  Future<void> updatePlant(Plant plant);

  Future<void> deletePlant(int id);
}
