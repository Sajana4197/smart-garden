/// SQLite schema constants — table/column names and the schema version.
/// See PROJECT_SPEC.md §5. Bump [schemaVersion] and add an `onUpgrade`
/// migration step whenever a column changes; never alter columns silently.
abstract final class DbConstants {
  static const String databaseName = 'smart_garden.db';
  static const int schemaVersion = 1;

  static const String plantsTable = 'plants';
  static const String plantId = 'id';
  static const String plantName = 'name';
  static const String plantSpecies = 'species';
  static const String plantImagePath = 'image_path';
  static const String plantDateAdded = 'date_added';
  static const String plantLastScanId = 'last_scan_id';
  static const String plantNotes = 'notes';
  static const String plantStatus = 'status';

  static const String scansTable = 'scans';
  static const String scanId = 'id';
  static const String scanPlantId = 'plant_id';
  static const String scanImagePath = 'image_path';
  static const String scanDiagnosisLabel = 'diagnosis_label';
  static const String scanConfidence = 'confidence';
  static const String scanSeverity = 'severity';
  static const String scanRawResultJson = 'raw_result_json';
  static const String scanScannedAt = 'scanned_at';

  static const String dailyTipStateTable = 'daily_tip_state';
  static const String dailyTipLastShownDate = 'last_shown_date';
  static const String dailyTipLastTipId = 'last_tip_id';
}
