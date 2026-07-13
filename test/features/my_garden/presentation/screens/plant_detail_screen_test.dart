import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_garden_ai/core/theme/app_theme.dart';
import 'package:smart_garden_ai/features/my_garden/domain/entities/plant.dart';
import 'package:smart_garden_ai/features/my_garden/presentation/screens/plant_detail_screen.dart';
import 'package:smart_garden_ai/features/scan_history/domain/entities/scan.dart';
import 'package:smart_garden_ai/features/scan_history/domain/repositories/scan_repository.dart';
import 'package:smart_garden_ai/features/scan_history/domain/usecases/get_scans_for_plant.dart';

class _ThrowingScanRepository implements ScanRepository {
  @override
  Future<List<Scan>> getAllScans() async => throw UnimplementedError();

  @override
  Future<List<Scan>> getScansForPlant(int plantId) async => throw StateError('DB error');

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
  testWidgets(
    'shows a retryable error instead of a stuck spinner when loading scan history fails',
    (tester) async {
      final plant = Plant(
        id: 1,
        name: 'Fern',
        imagePath: '/tmp/fern.jpg',
        dateAdded: DateTime(2026, 1, 1),
        status: PlantHealthStatus.healthy,
      );
      final getScansForPlant = GetScansForPlant(_ThrowingScanRepository());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Provider<GetScansForPlant>.value(
            value: getScansForPlant,
            child: PlantDetailScreen(plant: plant),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // `find.text()`/`find.byType()` don't reliably locate content in this
      // test's element tree shape (a `Provider.value` directly wrapping a
      // route-less `MaterialApp.home`); walking `tester.allWidgets` does.
      final texts = tester.allWidgets.whereType<Text>().map((t) => t.data);
      expect(texts, contains('Could not load scan history'));
      expect(texts, contains('Try Again'));
    },
  );
}
