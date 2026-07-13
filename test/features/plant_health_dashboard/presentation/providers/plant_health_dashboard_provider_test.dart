import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/features/my_garden/domain/entities/plant.dart';
import 'package:smart_garden_ai/features/my_garden/domain/repositories/plant_repository.dart';
import 'package:smart_garden_ai/features/plant_health_dashboard/domain/usecases/get_garden_health_summary.dart';
import 'package:smart_garden_ai/features/plant_health_dashboard/presentation/providers/plant_health_dashboard_provider.dart';
import 'package:smart_garden_ai/features/scan_history/domain/entities/scan.dart';
import 'package:smart_garden_ai/features/scan_history/domain/repositories/scan_repository.dart';

class _FakePlantRepository implements PlantRepository {
  _FakePlantRepository(this.plants, {this.shouldThrow = false});

  final List<Plant> plants;
  final bool shouldThrow;

  @override
  Future<List<Plant>> getAllPlants() async {
    if (shouldThrow) throw StateError('boom');
    return plants;
  }

  @override
  Future<Plant?> getPlantById(int id) async => throw UnimplementedError();

  @override
  Future<int> addPlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> updatePlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> deletePlant(int id) async => throw UnimplementedError();
}

class _FakeScanRepository implements ScanRepository {
  @override
  Future<List<Scan>> getAllScans() async => const [];

  @override
  Future<List<Scan>> getScansForPlant(int plantId) async => const [];

  @override
  Future<Scan?> getScanById(int id) async => throw UnimplementedError();

  @override
  Future<int> addScan(Scan scan) async => throw UnimplementedError();

  @override
  Future<void> updateScan(Scan scan) async => throw UnimplementedError();

  @override
  Future<void> deleteScan(int id) async => throw UnimplementedError();
}

void main() {
  test('starts with no summary and not loading', () {
    final provider = PlantHealthDashboardProvider(
      GetGardenHealthSummary(_FakePlantRepository(const []), _FakeScanRepository()),
    );

    expect(provider.summary, isNull);
    expect(provider.isLoading, isFalse);
    expect(provider.hasError, isFalse);
  });

  test('loadSummary() populates the summary on success', () async {
    final plants = [
      Plant(
        id: 1,
        name: 'Fern',
        imagePath: '/tmp/fern.jpg',
        dateAdded: DateTime(2026, 1, 1),
        status: PlantHealthStatus.healthy,
      ),
    ];
    final provider = PlantHealthDashboardProvider(
      GetGardenHealthSummary(_FakePlantRepository(plants), _FakeScanRepository()),
    );

    await provider.loadSummary();

    expect(provider.hasError, isFalse);
    expect(provider.isLoading, isFalse);
    expect(provider.summary!.totalPlants, 1);
  });

  test('loadSummary() sets hasError on failure', () async {
    final provider = PlantHealthDashboardProvider(
      GetGardenHealthSummary(
        _FakePlantRepository(const [], shouldThrow: true),
        _FakeScanRepository(),
      ),
    );

    await provider.loadSummary();

    expect(provider.hasError, isTrue);
    expect(provider.isLoading, isFalse);
    expect(provider.summary, isNull);
  });
}
