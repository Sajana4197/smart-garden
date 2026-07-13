import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_garden_ai/core/theme/app_theme.dart';
import 'package:smart_garden_ai/features/my_garden/domain/entities/plant.dart';
import 'package:smart_garden_ai/features/my_garden/domain/repositories/plant_repository.dart';
import 'package:smart_garden_ai/features/plant_health_dashboard/domain/usecases/get_garden_health_summary.dart';
import 'package:smart_garden_ai/features/plant_health_dashboard/presentation/providers/plant_health_dashboard_provider.dart';
import 'package:smart_garden_ai/features/plant_health_dashboard/presentation/screens/plant_health_dashboard_screen.dart';
import 'package:smart_garden_ai/features/scan_history/domain/entities/scan.dart';
import 'package:smart_garden_ai/features/scan_history/domain/repositories/scan_repository.dart';

class _FakePlantRepository implements PlantRepository {
  _FakePlantRepository(this.plants);

  final List<Plant> plants;

  @override
  Future<List<Plant>> getAllPlants() async => plants;

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

Future<void> _pumpDashboard(
  WidgetTester tester,
  PlantHealthDashboardProvider provider,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: ChangeNotifierProvider<PlantHealthDashboardProvider>.value(
        value: provider,
        child: const PlantHealthDashboardScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows empty state when no plants are saved', (tester) async {
    final provider = PlantHealthDashboardProvider(
      GetGardenHealthSummary(_FakePlantRepository(const []), _FakeScanRepository()),
    );
    await provider.loadSummary();

    await _pumpDashboard(tester, provider);

    expect(find.text('Nothing to show yet'), findsOneWidget);
  });

  testWidgets('renders stat cards, distribution legend, and needs-attention list',
      (tester) async {
    final plants = [
      Plant(
        id: 1,
        name: 'Fiddle Leaf Fig',
        imagePath: '/tmp/fiddle.jpg',
        dateAdded: DateTime(2026, 1, 1),
        status: PlantHealthStatus.severe,
      ),
      Plant(
        id: 2,
        name: 'Monstera',
        imagePath: '/tmp/monstera.jpg',
        dateAdded: DateTime(2026, 2, 1),
        status: PlantHealthStatus.healthy,
      ),
    ];
    final provider = PlantHealthDashboardProvider(
      GetGardenHealthSummary(_FakePlantRepository(plants), _FakeScanRepository()),
    );
    await provider.loadSummary();

    await _pumpDashboard(tester, provider);

    expect(find.text('2'), findsOneWidget); // Total Plants
    expect(find.text('1'), findsOneWidget); // Needs Attention count
    expect(find.text('Health Distribution'), findsOneWidget);
    expect(find.text('Healthy (1)'), findsOneWidget);
    expect(find.text('Severe (1)'), findsOneWidget);
    // Appears twice by design: the "Needs Attention" stat card label and
    // the "Needs Attention" section header below it.
    expect(find.text('Needs Attention'), findsNWidgets(2));
    expect(find.text('Fiddle Leaf Fig'), findsOneWidget);
    expect(find.text('Monstera'), findsNothing);
  });

  testWidgets('shows a positive message when nothing needs attention', (tester) async {
    final plants = [
      Plant(
        id: 1,
        name: 'Monstera',
        imagePath: '/tmp/monstera.jpg',
        dateAdded: DateTime(2026, 1, 1),
        status: PlantHealthStatus.healthy,
      ),
    ];
    final provider = PlantHealthDashboardProvider(
      GetGardenHealthSummary(_FakePlantRepository(plants), _FakeScanRepository()),
    );
    await provider.loadSummary();

    await _pumpDashboard(tester, provider);

    expect(find.text('All your plants are doing well.'), findsOneWidget);
  });

  testWidgets('shows an error state with retry when loading fails', (tester) async {
    final provider = PlantHealthDashboardProvider(
      GetGardenHealthSummary(_ThrowingPlantRepository(), _FakeScanRepository()),
    );
    await provider.loadSummary();

    await _pumpDashboard(tester, provider);

    expect(find.text('Could not load health data'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });
}

class _ThrowingPlantRepository implements PlantRepository {
  @override
  Future<List<Plant>> getAllPlants() async => throw StateError('boom');

  @override
  Future<Plant?> getPlantById(int id) async => throw UnimplementedError();

  @override
  Future<int> addPlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> updatePlant(Plant plant) async => throw UnimplementedError();

  @override
  Future<void> deletePlant(int id) async => throw UnimplementedError();
}
