import '../../domain/entities/daily_tip_state.dart';
import '../../domain/entities/plant_tip.dart';
import '../../domain/repositories/daily_tip_repository.dart';
import '../datasources/daily_tip_state_local_datasource.dart';
import '../datasources/tip_bank_datasource.dart';
import '../models/daily_tip_state_model.dart';

class DailyTipRepositoryImpl implements DailyTipRepository {
  DailyTipRepositoryImpl(this._tipBankDataSource, this._stateLocalDataSource);

  final TipBankDataSource _tipBankDataSource;
  final DailyTipStateLocalDataSource _stateLocalDataSource;

  @override
  Future<List<PlantTip>> getAllTips() => _tipBankDataSource.getAllTips();

  @override
  Future<DailyTipState?> getState() => _stateLocalDataSource.getState();

  @override
  Future<void> saveState(DailyTipState state) {
    return _stateLocalDataSource.saveState(
      DailyTipStateModel.fromEntity(state),
    );
  }
}
