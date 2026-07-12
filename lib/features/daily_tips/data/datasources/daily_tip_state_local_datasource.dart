import '../../../../core/constants/db_constants.dart';
import '../../../../services/database/app_database.dart';
import '../models/daily_tip_state_model.dart';

/// `daily_tip_state` is a single-row table (PROJECT_SPEC.md §5) — there's no
/// primary key to update against, so [saveState] clears the table and
/// re-inserts rather than upserting by id.
class DailyTipStateLocalDataSource {
  DailyTipStateLocalDataSource({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<DailyTipStateModel?> getState() async {
    final db = await _appDatabase.database;
    final rows = await db.query(DbConstants.dailyTipStateTable, limit: 1);
    if (rows.isEmpty) return null;
    return DailyTipStateModel.fromMap(rows.first);
  }

  Future<void> saveState(DailyTipStateModel state) async {
    final db = await _appDatabase.database;
    await db.delete(DbConstants.dailyTipStateTable);
    await db.insert(DbConstants.dailyTipStateTable, state.toMap());
  }
}
