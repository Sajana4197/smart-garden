import '../../../my_garden/domain/entities/plant.dart';
import '../../../my_garden/domain/repositories/plant_repository.dart';
import '../../../scan_history/domain/entities/scan.dart';
import '../../../scan_history/domain/repositories/scan_repository.dart';
import '../entities/garden_health_summary.dart';

/// Aggregates `plants`/`scans` into a [GardenHealthSummary] — status counts,
/// and a "needs attention" list (moderate/severe plants) each with a trend
/// derived from its two most recent scans. Depends on both features'
/// repository interfaces directly (pure domain, no Flutter/DB imports)
/// rather than a dedicated dashboard repository, since this is a read-only
/// aggregation over data those repositories already expose — same
/// cross-feature pattern as `SavePlantToGarden`. See ROADMAP.md Phase 14.
class GetGardenHealthSummary {
  GetGardenHealthSummary(this._plantRepository, this._scanRepository);

  final PlantRepository _plantRepository;
  final ScanRepository _scanRepository;

  Future<GardenHealthSummary> call() async {
    final plants = await _plantRepository.getAllPlants();

    final statusCounts = <PlantHealthStatus, int>{
      for (final status in PlantHealthStatus.values) status: 0,
    };
    for (final plant in plants) {
      statusCounts[plant.status] = statusCounts[plant.status]! + 1;
    }

    final attentionPlants = plants
        .where(
          (plant) =>
              plant.status == PlantHealthStatus.moderate ||
              plant.status == PlantHealthStatus.severe,
        )
        .toList()
      ..sort((a, b) {
        final severityCompare =
            _statusRank(b.status).compareTo(_statusRank(a.status));
        if (severityCompare != 0) return severityCompare;
        return b.dateAdded.compareTo(a.dateAdded);
      });

    final needsAttention = <NeedsAttentionEntry>[
      for (final plant in attentionPlants)
        NeedsAttentionEntry(plant: plant, trend: await _trendFor(plant.id!)),
    ];

    return GardenHealthSummary(
      statusCounts: statusCounts,
      needsAttention: needsAttention,
    );
  }

  Future<HealthTrend> _trendFor(int plantId) async {
    final scans = await _scanRepository.getScansForPlant(plantId);
    if (scans.length < 2) return HealthTrend.unknown;

    final sorted = [...scans]
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    final latestRank = _severityRank(sorted[0].severity);
    final previousRank = _severityRank(sorted[1].severity);

    if (latestRank < previousRank) return HealthTrend.improving;
    if (latestRank > previousRank) return HealthTrend.worsening;
    return HealthTrend.stable;
  }

  int _statusRank(PlantHealthStatus status) => switch (status) {
        PlantHealthStatus.healthy => 0,
        PlantHealthStatus.mild => 1,
        PlantHealthStatus.moderate => 2,
        PlantHealthStatus.severe => 3,
      };

  int _severityRank(ScanSeverity severity) => switch (severity) {
        ScanSeverity.none => 0,
        ScanSeverity.mild => 1,
        ScanSeverity.moderate => 2,
        ScanSeverity.severe => 3,
      };
}
