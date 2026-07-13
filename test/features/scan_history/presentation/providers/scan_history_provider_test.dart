import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/features/scan_history/domain/entities/scan.dart';
import 'package:smart_garden_ai/features/scan_history/domain/repositories/scan_repository.dart';
import 'package:smart_garden_ai/features/scan_history/domain/usecases/get_all_scans.dart';
import 'package:smart_garden_ai/features/scan_history/presentation/providers/scan_history_provider.dart';

class _FakeScanRepository implements ScanRepository {
  _FakeScanRepository(this.scans);

  final List<Scan> scans;

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
  Future<void> deleteScan(int id) async => throw UnimplementedError();
}

Scan _scan(int id, DateTime scannedAt, {int? plantId, ScanSeverity severity = ScanSeverity.none}) =>
    Scan(
      id: id,
      plantId: plantId,
      imagePath: '/tmp/$id.jpg',
      diagnosisLabel: 'Healthy',
      confidence: 0.9,
      severity: severity,
      rawResultJson: '{}',
      scannedAt: scannedAt,
    );

void main() {
  test('recentScans is always newest-first regardless of insertion order', () async {
    final scans = [
      _scan(1, DateTime(2026, 1, 1)),
      _scan(2, DateTime(2026, 3, 1)),
      _scan(3, DateTime(2026, 2, 1)),
    ];
    final provider = ScanHistoryProvider(GetAllScans(_FakeScanRepository(scans)));
    await provider.loadScans();

    expect(provider.recentScans.map((s) => s.id), [2, 3, 1]);
  });

  test('recentScans ignores the severity/link filters — unlike scans', () async {
    final scans = [
      _scan(1, DateTime(2026, 1, 1), severity: ScanSeverity.severe, plantId: 5),
      _scan(2, DateTime(2026, 2, 1), severity: ScanSeverity.mild),
    ];
    final provider = ScanHistoryProvider(GetAllScans(_FakeScanRepository(scans)));
    await provider.loadScans();

    // Simulate the user having filtered Scan History before returning Home.
    provider.setSeverityFilter(ScanSeverity.severe);
    provider.setLinkFilter(ScanLinkFilter.linked);

    // The filtered `scans` getter now excludes scan 2...
    expect(provider.scans.map((s) => s.id), [1]);
    // ...but `recentScans` still returns everything, newest-first.
    expect(provider.recentScans.map((s) => s.id), [2, 1]);
  });
}
