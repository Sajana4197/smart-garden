import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/db_constants.dart';

/// Single seam through which every feature reaches the local SQLite
/// database — see PROJECT_SPEC.md §5. Repositories depend on this (via a
/// feature's local datasource), never open `sqflite` directly.
class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  /// Wraps an already-open [Database] (e.g. an in-memory `sqflite_common_ffi`
  /// instance built with [onCreateSchema]) so repository tests can run
  /// against a real schema without touching device storage.
  @visibleForTesting
  AppDatabase.forTesting(Database database) : _database = database;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, DbConstants.databaseName);
    return openDatabase(
      path,
      version: DbConstants.schemaVersion,
      onCreate: onCreateSchema,
    );
  }

  /// Creates the `plants`, `scans`, and `daily_tip_state` tables per
  /// PROJECT_SPEC.md §5. Shared between production init and tests so the
  /// schema is defined exactly once.
  static Future<void> onCreateSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.plantsTable} (
        ${DbConstants.plantId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.plantName} TEXT NOT NULL,
        ${DbConstants.plantSpecies} TEXT,
        ${DbConstants.plantImagePath} TEXT NOT NULL,
        ${DbConstants.plantDateAdded} TEXT NOT NULL,
        ${DbConstants.plantLastScanId} INTEGER,
        ${DbConstants.plantNotes} TEXT,
        ${DbConstants.plantStatus} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.scansTable} (
        ${DbConstants.scanId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.scanPlantId} INTEGER,
        ${DbConstants.scanImagePath} TEXT NOT NULL,
        ${DbConstants.scanDiagnosisLabel} TEXT NOT NULL,
        ${DbConstants.scanConfidence} REAL NOT NULL,
        ${DbConstants.scanSeverity} TEXT NOT NULL,
        ${DbConstants.scanRawResultJson} TEXT NOT NULL,
        ${DbConstants.scanScannedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.scanPlantId})
          REFERENCES ${DbConstants.plantsTable} (${DbConstants.plantId})
          ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.dailyTipStateTable} (
        ${DbConstants.dailyTipLastShownDate} TEXT,
        ${DbConstants.dailyTipLastTipId} TEXT
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
