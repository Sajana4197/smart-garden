import 'package:flutter/foundation.dart';

import '../../domain/entities/garden_health_summary.dart';
import '../../domain/usecases/get_garden_health_summary.dart';

/// Holds the aggregated garden health summary — see CLAUDE.md §5 (one
/// ChangeNotifier per meaningful unit of state per feature). Registered
/// app-wide in app.dart, not screen-scoped: `StatefulShellRoute.indexedStack`
/// keeps this screen's subtree alive across tab switches without rebuilding
/// it, so a screen-local provider created once on first visit would never
/// see plants/scans added afterward — same pitfall documented for
/// `MyGardenProvider`/`ScanHistoryProvider` in CLAUDE.md §3. Every mutating
/// action elsewhere in the app (save/edit/delete a plant, add/link a scan)
/// explicitly calls `loadSummary()` on this shared instance right after it
/// succeeds.
class PlantHealthDashboardProvider extends ChangeNotifier {
  PlantHealthDashboardProvider(this._getGardenHealthSummary);

  final GetGardenHealthSummary _getGardenHealthSummary;

  GardenHealthSummary? _summary;
  bool _isLoading = false;
  bool _hasError = false;

  GardenHealthSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  Future<void> loadSummary() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      _summary = await _getGardenHealthSummary();
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
