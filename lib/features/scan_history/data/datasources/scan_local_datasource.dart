import '../../../../core/constants/db_constants.dart';
import '../../../../services/database/app_database.dart';
import '../models/scan_model.dart';

class ScanLocalDataSource {
  ScanLocalDataSource({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<List<ScanModel>> getAllScans() async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      DbConstants.scansTable,
      orderBy: '${DbConstants.scanScannedAt} DESC',
    );
    return rows.map(ScanModel.fromMap).toList();
  }

  Future<List<ScanModel>> getScansForPlant(int plantId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      DbConstants.scansTable,
      where: '${DbConstants.scanPlantId} = ?',
      whereArgs: [plantId],
      orderBy: '${DbConstants.scanScannedAt} DESC',
    );
    return rows.map(ScanModel.fromMap).toList();
  }

  Future<ScanModel?> getScanById(int id) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      DbConstants.scansTable,
      where: '${DbConstants.scanId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ScanModel.fromMap(rows.first);
  }

  Future<int> insertScan(ScanModel scan) async {
    final db = await _appDatabase.database;
    return db.insert(DbConstants.scansTable, scan.toMap(includeId: false));
  }

  Future<void> updateScan(ScanModel scan) async {
    final db = await _appDatabase.database;
    await db.update(
      DbConstants.scansTable,
      scan.toMap(includeId: false),
      where: '${DbConstants.scanId} = ?',
      whereArgs: [scan.id],
    );
  }

  Future<void> deleteScan(int id) async {
    final db = await _appDatabase.database;
    await db.delete(
      DbConstants.scansTable,
      where: '${DbConstants.scanId} = ?',
      whereArgs: [id],
    );
  }
}
