import '../../../scan_history/domain/entities/scan.dart';
import '../../../scan_history/domain/repositories/scan_repository.dart';
import '../entities/plant.dart';
import '../repositories/plant_repository.dart';

/// Creates a new My Garden entry and, if it originated from a scan, links
/// that scan back to it (`scans.plant_id`) — see `ScanRepository.updateScan`'s
/// doc comment and PROJECT_SPEC.md §5. Depends on both features' repository
/// interfaces (pure domain, no Flutter/DB imports) since linking a plant to
/// its originating scan is inherently a cross-feature action.
class SavePlantToGarden {
  SavePlantToGarden(this._plantRepository, this._scanRepository);

  final PlantRepository _plantRepository;
  final ScanRepository _scanRepository;

  Future<Plant> call({
    required String name,
    String? species,
    required String imagePath,
    String? notes,
    required PlantHealthStatus status,
    int? sourceScanId,
  }) async {
    final dateAdded = DateTime.now();
    final plantId = await _plantRepository.addPlant(
      Plant(
        name: name,
        species: species,
        imagePath: imagePath,
        dateAdded: dateAdded,
        lastScanId: sourceScanId,
        notes: notes,
        status: status,
      ),
    );

    if (sourceScanId != null) {
      final scan = await _scanRepository.getScanById(sourceScanId);
      if (scan != null) {
        await _scanRepository.updateScan(
          Scan(
            id: scan.id,
            plantId: plantId,
            imagePath: scan.imagePath,
            diagnosisLabel: scan.diagnosisLabel,
            confidence: scan.confidence,
            severity: scan.severity,
            rawResultJson: scan.rawResultJson,
            scannedAt: scan.scannedAt,
          ),
        );
      }
    }

    return Plant(
      id: plantId,
      name: name,
      species: species,
      imagePath: imagePath,
      dateAdded: dateAdded,
      lastScanId: sourceScanId,
      notes: notes,
      status: status,
    );
  }
}
