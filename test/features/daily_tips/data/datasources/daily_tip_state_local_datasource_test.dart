import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_garden_ai/core/constants/db_constants.dart';
import 'package:smart_garden_ai/features/daily_tips/data/datasources/daily_tip_state_local_datasource.dart';
import 'package:smart_garden_ai/features/daily_tips/data/models/daily_tip_state_model.dart';
import 'package:smart_garden_ai/services/database/app_database.dart';

void main() {
  late Database rawDb;
  late DailyTipStateLocalDataSource dataSource;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    rawDb = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DbConstants.schemaVersion,
        onCreate: AppDatabase.onCreateSchema,
      ),
    );
    dataSource = DailyTipStateLocalDataSource(
      appDatabase: AppDatabase.forTesting(rawDb),
    );
  });

  tearDown(() async {
    await rawDb.close();
  });

  test('getState returns null when no state has ever been saved', () async {
    expect(await dataSource.getState(), isNull);
  });

  test('saveState then getState round-trips the same values', () async {
    await dataSource.saveState(
      const DailyTipStateModel(lastShownDate: '2026-07-12', lastTipId: 'tip_003'),
    );

    final state = await dataSource.getState();

    expect(state?.lastShownDate, '2026-07-12');
    expect(state?.lastTipId, 'tip_003');
  });

  test('saveState overwrites the previous single row rather than appending', () async {
    await dataSource.saveState(
      const DailyTipStateModel(lastShownDate: '2026-07-12', lastTipId: 'tip_003'),
    );
    await dataSource.saveState(
      const DailyTipStateModel(lastShownDate: '2026-07-13', lastTipId: 'tip_010'),
    );

    final rows = await rawDb.query(DbConstants.dailyTipStateTable);
    final state = await dataSource.getState();

    expect(rows, hasLength(1));
    expect(state?.lastShownDate, '2026-07-13');
    expect(state?.lastTipId, 'tip_010');
  });
}
