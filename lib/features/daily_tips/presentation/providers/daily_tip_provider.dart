import 'package:flutter/foundation.dart';

import '../../domain/entities/plant_tip.dart';
import '../../domain/usecases/get_daily_tip.dart';

/// Holds the Home Dashboard's tip-of-the-day — see CLAUDE.md §5 (one
/// ChangeNotifier per meaningful unit of state per feature).
class DailyTipProvider extends ChangeNotifier {
  DailyTipProvider(this._getDailyTip);

  final GetDailyTip _getDailyTip;

  PlantTip? _tip;
  bool _isLoading = false;
  bool _hasError = false;

  PlantTip? get tip => _tip;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  Future<void> loadTip() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      _tip = await _getDailyTip();
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
