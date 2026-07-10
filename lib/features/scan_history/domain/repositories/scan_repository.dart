import '../entities/scan.dart';

/// Abstract seam `presentation` (via use cases) depends on — never the
/// concrete `ScanRepositoryImpl` — per PROJECT_SPEC.md §3 dependency rule.
abstract class ScanRepository {
  Future<List<Scan>> getAllScans();

  Future<List<Scan>> getScansForPlant(int plantId);

  Future<Scan?> getScanById(int id);

  /// Inserts [scan] and returns the DB-assigned id.
  Future<int> addScan(Scan scan);

  /// Used to link a previously-unlinked scan to a My Garden entry
  /// (Phase 9's "Save to My Garden" flow) or make other corrections.
  Future<void> updateScan(Scan scan);

  Future<void> deleteScan(int id);
}
