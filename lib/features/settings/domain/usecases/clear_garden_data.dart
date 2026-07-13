import '../../../my_garden/domain/repositories/plant_repository.dart';
import '../../../scan_history/domain/repositories/scan_repository.dart';

/// Permanently deletes every saved plant and scan — the Settings "clear
/// data" action (ROADMAP.md Phase 15). Depends on both features'
/// repository interfaces directly (pure domain, no Flutter/DB imports),
/// same cross-feature pattern as `SavePlantToGarden`/`GetGardenHealthSummary`
/// (CLAUDE.md §3), since resetting the garden is inherently a cross-feature
/// action. Deliberately scoped to garden content only — onboarding
/// completion, weather cache, daily tip state, and app settings are left
/// untouched (see CLAUDE.md §3 for the scoping decision).
class ClearGardenData {
  ClearGardenData(this._plantRepository, this._scanRepository);

  final PlantRepository _plantRepository;
  final ScanRepository _scanRepository;

  Future<void> call() async {
    final scans = await _scanRepository.getAllScans();
    for (final scan in scans) {
      await _scanRepository.deleteScan(scan.id!);
    }

    final plants = await _plantRepository.getAllPlants();
    for (final plant in plants) {
      await _plantRepository.deletePlant(plant.id!);
    }
  }
}
