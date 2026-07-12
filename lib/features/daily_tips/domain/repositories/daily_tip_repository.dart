import '../entities/daily_tip_state.dart';
import '../entities/plant_tip.dart';

/// Data-access seam for the local tip bank and the persisted
/// "tip of the day" state. Date-seeded selection logic lives in the
/// [GetDailyTip](../usecases/get_daily_tip.dart) use case, not here — this
/// interface only reads/writes.
abstract class DailyTipRepository {
  Future<List<PlantTip>> getAllTips();

  /// Null if no tip has ever been shown (e.g. first launch).
  Future<DailyTipState?> getState();

  Future<void> saveState(DailyTipState state);
}
