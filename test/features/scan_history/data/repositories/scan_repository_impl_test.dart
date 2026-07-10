import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_garden_ai/core/constants/db_constants.dart';
import 'package:smart_garden_ai/features/scan_history/data/datasources/scan_local_datasource.dart';
import 'package:smart_garden_ai/features/scan_history/data/repositories/scan_repository_impl.dart';
import 'package:smart_garden_ai/features/scan_history/domain/entities/scan.dart';
import 'package:smart_garden_ai/services/database/app_database.dart';

void main() {
  late Database rawDb;
  late ScanRepositoryImpl repository;

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
    repository = ScanRepositoryImpl(
      ScanLocalDataSource(appDatabase: AppDatabase.forTesting(rawDb)),
    );
  });

  tearDown(() async {
    await rawDb.close();
  });

  Scan buildScan({int? id, int? plantId, DateTime? scannedAt}) {
    return Scan(
      id: id,
      plantId: plantId,
      imagePath: '/sandbox/scan.jpg',
      diagnosisLabel: 'Powdery Mildew',
      confidence: 0.87,
      severity: ScanSeverity.moderate,
      rawResultJson: '{"label":"Powdery Mildew"}',
      scannedAt: scannedAt ?? DateTime(2026, 7, 1, 9),
    );
  }

  test('getAllScans returns empty list when no scans saved', () async {
    expect(await repository.getAllScans(), isEmpty);
  });

  test('addScan persists a scan and assigns an id', () async {
    final id = await repository.addScan(buildScan());

    expect(id, greaterThan(0));
    expect(await repository.getScanById(id), buildScan(id: id));
  });

  test('addScan supports a scan with no linked plant', () async {
    final id = await repository.addScan(buildScan(plantId: null));

    final fetched = await repository.getScanById(id);

    expect(fetched!.plantId, isNull);
  });

  test('getAllScans returns every saved scan, newest first', () async {
    final firstId = await repository.addScan(
      buildScan(scannedAt: DateTime(2026, 6, 1)),
    );
    final secondId = await repository.addScan(
      buildScan(scannedAt: DateTime(2026, 7, 1)),
    );

    final all = await repository.getAllScans();

    expect(all.map((s) => s.id), [secondId, firstId]);
  });

  test('getScansForPlant filters to scans linked to that plant', () async {
    final linkedId = await repository.addScan(buildScan(plantId: 1));
    await repository.addScan(buildScan(plantId: 2));
    await repository.addScan(buildScan(plantId: null));

    final forPlantOne = await repository.getScansForPlant(1);

    expect(forPlantOne.map((s) => s.id), [linkedId]);
  });

  test('updateScan links a previously-unlinked scan to a plant', () async {
    final id = await repository.addScan(buildScan(plantId: null));

    await repository.updateScan(buildScan(id: id, plantId: 7));

    final fetched = await repository.getScanById(id);
    expect(fetched!.plantId, 7);
  });

  test('deleteScan removes the scan', () async {
    final id = await repository.addScan(buildScan());

    await repository.deleteScan(id);

    expect(await repository.getScanById(id), isNull);
  });

  test('getScanById returns null for an unknown id', () async {
    expect(await repository.getScanById(999), isNull);
  });
}
