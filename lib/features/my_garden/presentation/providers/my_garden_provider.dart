import 'package:flutter/foundation.dart';

import '../../domain/entities/plant.dart';
import '../../domain/usecases/delete_plant.dart';
import '../../domain/usecases/get_all_plants.dart';

/// Holds the My Garden list's loaded plants — see CLAUDE.md §5 (one
/// ChangeNotifier per meaningful unit of state per feature).
class MyGardenProvider extends ChangeNotifier {
  MyGardenProvider(this._getAllPlants, this._deletePlant);

  final GetAllPlants _getAllPlants;
  final DeletePlant _deletePlant;

  List<Plant> _plants = const [];
  bool _isLoading = false;
  bool _hasError = false;

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  Future<void> loadPlants() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      _plants = await _getAllPlants();
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePlant(int id) async {
    await _deletePlant(id);
    await loadPlants();
  }
}
