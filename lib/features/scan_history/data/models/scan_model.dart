import '../../../../core/constants/db_constants.dart';
import '../../domain/entities/scan.dart';

/// DTO adding `sqflite` map (de)serialization on top of [Scan].
class ScanModel extends Scan {
  const ScanModel({
    super.id,
    super.plantId,
    required super.imagePath,
    required super.diagnosisLabel,
    required super.confidence,
    required super.severity,
    required super.rawResultJson,
    required super.scannedAt,
  });

  factory ScanModel.fromMap(Map<String, Object?> map) {
    return ScanModel(
      id: map[DbConstants.scanId] as int?,
      plantId: map[DbConstants.scanPlantId] as int?,
      imagePath: map[DbConstants.scanImagePath]! as String,
      diagnosisLabel: map[DbConstants.scanDiagnosisLabel]! as String,
      confidence: (map[DbConstants.scanConfidence]! as num).toDouble(),
      severity: ScanSeverity.values.byName(
        map[DbConstants.scanSeverity]! as String,
      ),
      rawResultJson: map[DbConstants.scanRawResultJson]! as String,
      scannedAt: DateTime.parse(map[DbConstants.scanScannedAt]! as String),
    );
  }

  factory ScanModel.fromEntity(Scan scan) => ScanModel(
        id: scan.id,
        plantId: scan.plantId,
        imagePath: scan.imagePath,
        diagnosisLabel: scan.diagnosisLabel,
        confidence: scan.confidence,
        severity: scan.severity,
        rawResultJson: scan.rawResultJson,
        scannedAt: scan.scannedAt,
      );

  /// [includeId] is false on insert, where `sqflite` assigns the id.
  Map<String, Object?> toMap({bool includeId = true}) {
    return {
      if (includeId) DbConstants.scanId: id,
      DbConstants.scanPlantId: plantId,
      DbConstants.scanImagePath: imagePath,
      DbConstants.scanDiagnosisLabel: diagnosisLabel,
      DbConstants.scanConfidence: confidence,
      DbConstants.scanSeverity: severity.name,
      DbConstants.scanRawResultJson: rawResultJson,
      DbConstants.scanScannedAt: scannedAt.toIso8601String(),
    };
  }
}
