import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_garden_ai/core/constants/db_constants.dart';
import 'package:smart_garden_ai/features/my_garden/data/datasources/plant_local_datasource.dart';
import 'package:smart_garden_ai/features/my_garden/data/repositories/plant_repository_impl.dart';
import 'package:smart_garden_ai/features/my_garden/domain/entities/plant.dart';
import 'package:smart_garden_ai/services/database/app_database.dart';

void main() {
  late Database rawDb;
  late PlantRepositoryImpl repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    rawDb = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DbConstants.schemaVersion,
        onCreate: AppDatabase.onCreateSchema,
      ),
    );
    repository = PlantRepositoryImpl(
      PlantLocalDataSource(appDatabase: AppDatabase.forTesting(rawDb)),
    );
  });

  tearDown(() async {
    await rawDb.close();
  });

  Plant buildPlant({int? id, String name = 'Monstera'}) {
    return Plant(
      id: id,
      name: name,
      species: 'Monstera Deliciosa',
      imagePath: '/sandbox/monstera.jpg',
      dateAdded: DateTime(2026, 7, 1),
      lastScanId: null,
      notes: 'Kitchen windowsill',
      status: PlantHealthStatus.healthy,
    );
  }

  test('getAllPlants returns empty list when no plants saved', () async {
    expect(await repository.getAllPlants(), isEmpty);
  });

  test('addPlant persists a plant and assigns an id', () async {
    final id = await repository.addPlant(buildPlant());

    expect(id, greaterThan(0));
    final fetched = await repository.getPlantById(id);
    expect(fetched, buildPlant(id: id));
  });

  test('getAllPlants returns every saved plant, newest first', () async {
    final firstId = await repository.addPlant(
      buildPlant(name: 'Basil').copyWithDate(DateTime(2026, 6, 1)),
    );
    final secondId = await repository.addPlant(
      buildPlant(name: 'Fern').copyWithDate(DateTime(2026, 7, 1)),
    );

    final all = await repository.getAllPlants();

    expect(all.map((p) => p.id), [secondId, firstId]);
  });

  test('updatePlant overwrites the stored fields', () async {
    final id = await repository.addPlant(buildPlant());

    final updated = Plant(
      id: id,
      name: 'Monstera (renamed)',
      species: 'Monstera Deliciosa',
      imagePath: '/sandbox/monstera.jpg',
      dateAdded: DateTime(2026, 7, 1),
      lastScanId: 42,
      notes: 'Moved to the office',
      status: PlantHealthStatus.mild,
    );
    await repository.updatePlant(updated);

    expect(await repository.getPlantById(id), updated);
  });

  test('deletePlant removes the plant', () async {
    final id = await repository.addPlant(buildPlant());

    await repository.deletePlant(id);

    expect(await repository.getPlantById(id), isNull);
  });

  test('getPlantById returns null for an unknown id', () async {
    expect(await repository.getPlantById(999), isNull);
  });
}

extension on Plant {
  Plant copyWithDate(DateTime date) {
    return Plant(
      id: id,
      name: name,
      species: species,
      imagePath: imagePath,
      dateAdded: date,
      lastScanId: lastScanId,
      notes: notes,
      status: status,
    );
  }
}
