/// Derived plant health status. Shares its vocabulary with
/// `AppStatusBadge`'s `AppHealthStatus` and `scans.severity`
/// (UI_GUIDELINES.md §2) so presentation code maps between them 1:1 rather
/// than reconciling different status vocabularies — see CLAUDE.md §3.
enum PlantHealthStatus { healthy, mild, moderate, severe }

/// A saved My Garden entry — pure Dart, no Flutter/DB imports (domain layer
/// rule in PROJECT_SPEC.md §3). See PROJECT_SPEC.md §5 for the `plants`
/// table this mirrors.
class Plant {
  const Plant({
    this.id,
    required this.name,
    this.species,
    required this.imagePath,
    required this.dateAdded,
    this.lastScanId,
    this.notes,
    required this.status,
  });

  /// Null until the plant has been persisted (assigned by the DB on insert).
  final int? id;
  final String name;
  final String? species;
  final String imagePath;
  final DateTime dateAdded;
  final int? lastScanId;
  final String? notes;
  final PlantHealthStatus status;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plant &&
        other.id == id &&
        other.name == name &&
        other.species == species &&
        other.imagePath == imagePath &&
        other.dateAdded == dateAdded &&
        other.lastScanId == lastScanId &&
        other.notes == notes &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        species,
        imagePath,
        dateAdded,
        lastScanId,
        notes,
        status,
      );
}
