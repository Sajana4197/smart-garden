import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/features/my_garden/domain/entities/plant.dart';
import 'package:smart_garden_ai/features/my_garden/domain/repositories/plant_repository.dart';
import 'package:smart_garden_ai/features/plant_health_dashboard/domain/entities/garden_health_summary.dart';
import 'package:smart_garden_ai/features/plant_health_dashboard/domain/usecases/get_garden_health_summary.dart';
import 'package:smart_garden_ai/features/scan_history/domain/entities/scan.dart';
import 'package:smart_garden_ai/features/scan_history/domain/repositories/scan_repository.dart';

class _FakePlantRepository implements PlantRepository {
  _FakePlantRepository(this.plants);

  final List<Plant> plants;

  @override
  Future<List<Plant>> getAllPlants() async => plants;

  @override
  Future<Plant?> getPlantById(int id) async {
    for (final plant in plants) {
      if (plant.id == id) return plant;
    }
    return null;
  }

  @override
  Future<int> addPlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> updatePlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> deletePlant(int id) async => throw UnimplementedError();
}

class _FakeScanRepository implements ScanRepository {
  _FakeScanRepository(this.scansByPlantId);

  final Map<int, List<Scan>> scansByPlantId;

  @override
  Future<List<Scan>> getAllScans() async =>
      scansByPlantId.values.expand((s) => s).toList();

  @override
  Future<List<Scan>> getScansForPlant(int plantId) async =>
      scansByPlantId[plantId] ?? const [];

  @override
  Future<Scan?> getScanById(int id) async => throw UnimplementedError();

  @override
  Future<int> addScan(Scan scan) async => throw UnimplementedError();

  @override
  Future<void> updateScan(Scan scan) async => throw UnimplementedError();

  @override
  Future<void> deleteScan(int id) async => throw UnimplementedError();
}

Plant _plant({
  required int id,
  required PlantHealthStatus status,
  DateTime? dateAdded,
}) {
  return Plant(
    id: id,
    name: 'Plant $id',
    imagePath: '/tmp/$id.jpg',
    dateAdded: dateAdded ?? DateTime(2026, 1, id),
    status: status,
  );
}

Scan _scan({required int plantId, required ScanSeverity severity, required DateTime scannedAt}) {
  return Scan(
    plantId: plantId,
    imagePath: '/tmp/scan.jpg',
    diagnosisLabel: 'Some diagnosis',
    confidence: 0.9,
    severity: severity,
    rawResultJson: '{}',
    scannedAt: scannedAt,
  );
}

void main() {
  test('counts plants per status, zero-filling missing statuses', () async {
    final plants = [
      _plant(id: 1, status: PlantHealthStatus.healthy),
      _plant(id: 2, status: PlantHealthStatus.healthy),
      _plant(id: 3, status: PlantHealthStatus.severe),
    ];
    final getSummary = GetGardenHealthSummary(
      _FakePlantRepository(plants),
      _FakeScanRepository(const {}),
    );

    final summary = await getSummary();

    expect(summary.totalPlants, 3);
    expect(summary.statusCounts[PlantHealthStatus.healthy], 2);
    expect(summary.statusCounts[PlantHealthStatus.mild], 0);
    expect(summary.statusCounts[PlantHealthStatus.moderate], 0);
    expect(summary.statusCounts[PlantHealthStatus.severe], 1);
  });

  test('needsAttention includes only moderate/severe, most severe first', () async {
    final plants = [
      _plant(id: 1, status: PlantHealthStatus.healthy),
      _plant(id: 2, status: PlantHealthStatus.moderate),
      _plant(id: 3, status: PlantHealthStatus.severe),
      _plant(id: 4, status: PlantHealthStatus.mild),
    ];
    final getSummary = GetGardenHealthSummary(
      _FakePlantRepository(plants),
      _FakeScanRepository(const {}),
    );

    final summary = await getSummary();

    expect(summary.needsAttention.map((e) => e.plant.id), [3, 2]);
  });

  test('needsAttention breaks a severity tie by most recently added first', () async {
    final plants = [
      _plant(
        id: 1,
        status: PlantHealthStatus.severe,
        dateAdded: DateTime(2026, 1, 1),
      ),
      _plant(
        id: 2,
        status: PlantHealthStatus.severe,
        dateAdded: DateTime(2026, 6, 1),
      ),
    ];
    final getSummary = GetGardenHealthSummary(
      _FakePlantRepository(plants),
      _FakeScanRepository(const {}),
    );

    final summary = await getSummary();

    expect(summary.needsAttention.map((e) => e.plant.id), [2, 1]);
  });

  test('trend is unknown with fewer than two scans', () async {
    final plants = [_plant(id: 1, status: PlantHealthStatus.severe)];
    final getSummary = GetGardenHealthSummary(
      _FakePlantRepository(plants),
      _FakeScanRepository({
        1: [_scan(plantId: 1, severity: ScanSeverity.severe, scannedAt: DateTime(2026, 1, 1))],
      }),
    );

    final summary = await getSummary();

    expect(summary.needsAttention.single.trend, HealthTrend.unknown);
  });

  test('trend is improving when the latest scan is less severe than the previous', () async {
    final plants = [_plant(id: 1, status: PlantHealthStatus.moderate)];
    final getSummary = GetGardenHealthSummary(
      _FakePlantRepository(plants),
      _FakeScanRepository({
        1: [
          _scan(plantId: 1, severity: ScanSeverity.severe, scannedAt: DateTime(2026, 1, 1)),
          _scan(plantId: 1, severity: ScanSeverity.mild, scannedAt: DateTime(2026, 2, 1)),
        ],
      }),
    );

    final summary = await getSummary();

    expect(summary.needsAttention.single.trend, HealthTrend.improving);
  });

  test('trend is worsening when the latest scan is more severe than the previous', () async {
    final plants = [_plant(id: 1, status: PlantHealthStatus.severe)];
    final getSummary = GetGardenHealthSummary(
      _FakePlantRepository(plants),
      _FakeScanRepository({
        1: [
          _scan(plantId: 1, severity: ScanSeverity.mild, scannedAt: DateTime(2026, 1, 1)),
          _scan(plantId: 1, severity: ScanSeverity.severe, scannedAt: DateTime(2026, 2, 1)),
        ],
      }),
    );

    final summary = await getSummary();

    expect(summary.needsAttention.single.trend, HealthTrend.worsening);
  });

  test('trend is stable when severity is unchanged', () async {
    final plants = [_plant(id: 1, status: PlantHealthStatus.moderate)];
    final getSummary = GetGardenHealthSummary(
      _FakePlantRepository(plants),
      _FakeScanRepository({
        1: [
          _scan(plantId: 1, severity: ScanSeverity.moderate, scannedAt: DateTime(2026, 1, 1)),
          _scan(plantId: 1, severity: ScanSeverity.moderate, scannedAt: DateTime(2026, 2, 1)),
        ],
      }),
    );

    final summary = await getSummary();

    expect(summary.needsAttention.single.trend, HealthTrend.stable);
  });
}
