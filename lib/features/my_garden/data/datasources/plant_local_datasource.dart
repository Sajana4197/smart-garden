import '../../../../core/constants/db_constants.dart';
import '../../../../services/database/app_database.dart';
import '../models/plant_model.dart';

class PlantLocalDataSource {
  PlantLocalDataSource({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<List<PlantModel>> getAllPlants() async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      DbConstants.plantsTable,
      orderBy: '${DbConstants.plantDateAdded} DESC',
    );
    return rows.map(PlantModel.fromMap).toList();
  }

  Future<PlantModel?> getPlantById(int id) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      DbConstants.plantsTable,
      where: '${DbConstants.plantId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PlantModel.fromMap(rows.first);
  }

  Future<int> insertPlant(PlantModel plant) async {
    final db = await _appDatabase.database;
    return db.insert(DbConstants.plantsTable, plant.toMap(includeId: false));
  }

  Future<void> updatePlant(PlantModel plant) async {
    final db = await _appDatabase.database;
    await db.update(
      DbConstants.plantsTable,
      plant.toMap(includeId: false),
      where: '${DbConstants.plantId} = ?',
      whereArgs: [plant.id],
    );
  }

  Future<void> deletePlant(int id) async {
    final db = await _appDatabase.database;
    await db.delete(
      DbConstants.plantsTable,
      where: '${DbConstants.plantId} = ?',
      whereArgs: [id],
    );
  }
}
