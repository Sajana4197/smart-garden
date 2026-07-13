import '../../../my_garden/domain/entities/plant.dart';

/// Direction of health change for a plant, derived by comparing its two
/// most recent scans. `unknown` covers plants with fewer than two linked
/// scans — not enough history to call a direction.
enum HealthTrend { improving, worsening, stable, unknown }

/// One "needs attention" list entry — the plant plus its computed trend.
class NeedsAttentionEntry {
  const NeedsAttentionEntry({required this.plant, required this.trend});

  final Plant plant;
  final HealthTrend trend;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NeedsAttentionEntry &&
        other.plant == plant &&
        other.trend == trend;
  }

  @override
  int get hashCode => Object.hash(plant, trend);
}

/// Garden-wide aggregate over `plants`/`scans` — pure Dart, no Flutter/DB
/// imports (domain layer rule in PROJECT_SPEC.md §3). See ROADMAP.md
/// Phase 14.
class GardenHealthSummary {
  const GardenHealthSummary({
    required this.statusCounts,
    required this.needsAttention,
  });

  /// Count of plants per [PlantHealthStatus], always containing all four
  /// keys (zero-filled) so the distribution visualization never has to
  /// null-check a missing status.
  final Map<PlantHealthStatus, int> statusCounts;

  /// Moderate/severe plants, most severe and most recently added first.
  final List<NeedsAttentionEntry> needsAttention;

  int get totalPlants =>
      statusCounts.values.fold(0, (sum, count) => sum + count);
}
