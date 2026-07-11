/// Diagnosis severity produced by [AIService.analyzeImage] — see
/// MODEL_INTEGRATION.md §3. Named to match `ScanSeverity`
/// (features/scan_history/domain/entities/scan.dart) so a
/// [PlantDiagnosisResult] maps onto a persisted `Scan` with no translation
/// table.
enum DiagnosisSeverity { none, mild, moderate, severe }

/// The single data shape produced by every `AIService` implementation —
/// pure Dart, no Flutter/DB imports (PROJECT_SPEC.md §3 domain rule).
/// Extend-only after Phase 7 — see MODEL_INTEGRATION.md §3.
class PlantDiagnosisResult {
  const PlantDiagnosisResult({
    required this.plantCommonName,
    this.plantSpeciesLatin,
    required this.diagnosisLabel,
    required this.isHealthy,
    required this.confidence,
    required this.severity,
    required this.description,
    required this.visualSymptoms,
    required this.analyzedAt,
  });

  final String plantCommonName;
  final String? plantSpeciesLatin;
  final String diagnosisLabel;
  final bool isHealthy;

  /// 0.0-1.0
  final double confidence;
  final DiagnosisSeverity severity;
  final String description;
  final List<String> visualSymptoms;
  final DateTime analyzedAt;

  PlantDiagnosisResult copyWith({DateTime? analyzedAt}) {
    return PlantDiagnosisResult(
      plantCommonName: plantCommonName,
      plantSpeciesLatin: plantSpeciesLatin,
      diagnosisLabel: diagnosisLabel,
      isHealthy: isHealthy,
      confidence: confidence,
      severity: severity,
      description: description,
      visualSymptoms: visualSymptoms,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  /// For `scans.raw_result_json` (PROJECT_SPEC.md §5) — full serialized
  /// result kept alongside the flattened columns for replay/debug.
  Map<String, Object?> toJson() => {
        'plantCommonName': plantCommonName,
        'plantSpeciesLatin': plantSpeciesLatin,
        'diagnosisLabel': diagnosisLabel,
        'isHealthy': isHealthy,
        'confidence': confidence,
        'severity': severity.name,
        'description': description,
        'visualSymptoms': visualSymptoms,
        'analyzedAt': analyzedAt.toIso8601String(),
      };

  factory PlantDiagnosisResult.fromJson(Map<String, Object?> json) {
    return PlantDiagnosisResult(
      plantCommonName: json['plantCommonName']! as String,
      plantSpeciesLatin: json['plantSpeciesLatin'] as String?,
      diagnosisLabel: json['diagnosisLabel']! as String,
      isHealthy: json['isHealthy']! as bool,
      confidence: (json['confidence']! as num).toDouble(),
      severity: DiagnosisSeverity.values.byName(json['severity']! as String),
      description: json['description']! as String,
      visualSymptoms: (json['visualSymptoms']! as List).cast<String>(),
      analyzedAt: DateTime.parse(json['analyzedAt']! as String),
    );
  }
}
