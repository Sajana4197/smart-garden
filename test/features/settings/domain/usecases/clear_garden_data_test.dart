import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/features/my_garden/domain/entities/plant.dart';
import 'package:smart_garden_ai/features/my_garden/domain/repositories/plant_repository.dart';
import 'package:smart_garden_ai/features/scan_history/domain/entities/scan.dart';
import 'package:smart_garden_ai/features/scan_history/domain/repositories/scan_repository.dart';
import 'package:smart_garden_ai/features/settings/domain/usecases/clear_garden_data.dart';

class _FakePlantRepository implements PlantRepository {
  _FakePlantRepository(this.plants);

  final List<Plant> plants;
  final List<int> deletedIds = [];

  @override
  Future<List<Plant>> getAllPlants() async => plants;

  @override
  Future<Plant?> getPlantById(int id) async => throw UnimplementedError();

  @override
  Future<int> addPlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> updatePlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> deletePlant(int id) async => deletedIds.add(id);
}

class _FakeScanRepository implements ScanRepository {
  _FakeScanRepository(this.scans);

  final List<Scan> scans;
  final List<int> deletedIds = [];

  @override
  Future<List<Scan>> getAllScans() async => scans;

  @override
  Future<List<Scan>> getScansForPlant(int plantId) async => throw UnimplementedError();

  @override
  Future<Scan?> getScanById(int id) async => throw UnimplementedError();

  @override
  Future<int> addScan(Scan scan) async => throw UnimplementedError();

  @override
  Future<void> updateScan(Scan scan) async => throw UnimplementedError();

  @override
  Future<void> deleteScan(int id) async => deletedIds.add(id);
}

Plant _plant(int id) => Plant(
      id: id,
      name: 'Plant $id',
      imagePath: '/tmp/$id.jpg',
      dateAdded: DateTime(2026, 1, id),
      status: PlantHealthStatus.healthy,
    );

Scan _scan(int id) => Scan(
      id: id,
      imagePath: '/tmp/scan$id.jpg',
      diagnosisLabel: 'Healthy',
      confidence: 0.9,
      severity: ScanSeverity.none,
      rawResultJson: '{}',
      scannedAt: DateTime(2026, 1, id),
    );

void main() {
  test('deletes every scan and every plant', () async {
    final plantRepository = _FakePlantRepository([_plant(1), _plant(2)]);
    final scanRepository = _FakeScanRepository([_scan(10), _scan(11), _scan(12)]);
    final clearGardenData = ClearGardenData(plantRepository, scanRepository);

    await clearGardenData();

    expect(plantRepository.deletedIds, [1, 2]);
    expect(scanRepository.deletedIds, [10, 11, 12]);
  });

  test('does nothing and does not throw when the garden is already empty', () async {
    final plantRepository = _FakePlantRepository(const []);
    final scanRepository = _FakeScanRepository(const []);
    final clearGardenData = ClearGardenData(plantRepository, scanRepository);

    await clearGardenData();

    expect(plantRepository.deletedIds, isEmpty);
    expect(scanRepository.deletedIds, isEmpty);
  });
}
