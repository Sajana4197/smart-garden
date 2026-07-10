/// Diagnosis severity for a single scan — matches the `scans.severity`
/// vocabulary in PROJECT_SPEC.md §5 and `AppStatusBadge`'s `AppHealthStatus`
/// (minus `none`, which has no severity-badge equivalent).
enum ScanSeverity { none, mild, moderate, severe }

/// A single completed diagnosis scan — pure Dart, no Flutter/DB imports
/// (domain layer rule in PROJECT_SPEC.md §3). See PROJECT_SPEC.md §5 for the
/// `scans` table this mirrors.
class Scan {
  const Scan({
    this.id,
    this.plantId,
    required this.imagePath,
    required this.diagnosisLabel,
    required this.confidence,
    required this.severity,
    required this.rawResultJson,
    required this.scannedAt,
  });

  /// Null until the scan has been persisted (assigned by the DB on insert).
  final int? id;

  /// Null if this scan hasn't been linked to a My Garden entry.
  final int? plantId;
  final String imagePath;
  final String diagnosisLabel;

  /// 0.0-1.0
  final double confidence;
  final ScanSeverity severity;

  /// Full serialized `PlantDiagnosisResult` for replay/debug (Phase 7+).
  final String rawResultJson;
  final DateTime scannedAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Scan &&
        other.id == id &&
        other.plantId == plantId &&
        other.imagePath == imagePath &&
        other.diagnosisLabel == diagnosisLabel &&
        other.confidence == confidence &&
        other.severity == severity &&
        other.rawResultJson == rawResultJson &&
        other.scannedAt == scannedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        plantId,
        imagePath,
        diagnosisLabel,
        confidence,
        severity,
        rawResultJson,
        scannedAt,
      );
}
