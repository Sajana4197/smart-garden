import '../entities/plant_tip.dart';
import '../repositories/daily_tip_repository.dart';

/// Loads the full local tip bank for the "All Tips" browse screen.
class GetAllTips {
  GetAllTips(this._repository);

  final DailyTipRepository _repository;

  Future<List<PlantTip>> call() => _repository.getAllTips();
}
