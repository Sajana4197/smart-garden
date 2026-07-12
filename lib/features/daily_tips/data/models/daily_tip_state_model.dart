import '../../../../core/constants/db_constants.dart';
import '../../domain/entities/daily_tip_state.dart';

/// DTO adding `sqflite` map (de)serialization on top of [DailyTipState].
class DailyTipStateModel extends DailyTipState {
  const DailyTipStateModel({
    required super.lastShownDate,
    required super.lastTipId,
  });

  factory DailyTipStateModel.fromMap(Map<String, Object?> map) {
    return DailyTipStateModel(
      lastShownDate: map[DbConstants.dailyTipLastShownDate]! as String,
      lastTipId: map[DbConstants.dailyTipLastTipId]! as String,
    );
  }

  factory DailyTipStateModel.fromEntity(DailyTipState state) {
    return DailyTipStateModel(
      lastShownDate: state.lastShownDate,
      lastTipId: state.lastTipId,
    );
  }

  Map<String, Object?> toMap() {
    return {
      DbConstants.dailyTipLastShownDate: lastShownDate,
      DbConstants.dailyTipLastTipId: lastTipId,
    };
  }
}
