import 'package:flutter/foundation.dart';

import '../../domain/entities/scan.dart';
import '../../domain/usecases/get_all_scans.dart';

enum ScanSortOrder { newestFirst, oldestFirst }

enum ScanLinkFilter { all, linked, unlinked }

/// Holds the full loaded scan list plus in-memory filter/sort state for the
/// Scan History screen — see CLAUDE.md §5 (one ChangeNotifier per
/// meaningful unit of state per feature). Registered app-wide in app.dart,
/// not screen-scoped: `StatefulShellRoute.indexedStack` keeps this screen's
/// subtree alive across tab switches without rebuilding it, so a
/// screen-local provider created once on first visit would never see scans
/// added afterward from AI Loading — same pitfall documented for
/// `MyGardenProvider` in CLAUDE.md §3.
class ScanHistoryProvider extends ChangeNotifier {
  ScanHistoryProvider(this._getAllScans);

  final GetAllScans _getAllScans;

  List<Scan> _allScans = const [];
  bool _isLoading = false;
  bool _hasError = false;

  ScanSortOrder _sortOrder = ScanSortOrder.newestFirst;
  ScanLinkFilter _linkFilter = ScanLinkFilter.all;
  ScanSeverity? _severityFilter;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get hasAnyScans => _allScans.isNotEmpty;
  ScanSortOrder get sortOrder => _sortOrder;
  ScanLinkFilter get linkFilter => _linkFilter;
  ScanSeverity? get severityFilter => _severityFilter;

  /// Filtered and sorted view over the loaded scans — recomputed on every
  /// read rather than cached, since the underlying list is small (single
  /// user's local scan history) and filters change far more often than the
  /// list itself does.
  List<Scan> get scans {
    final filtered = _allScans.where((scan) {
      final matchesSeverity =
          _severityFilter == null || scan.severity == _severityFilter;
      final matchesLink = switch (_linkFilter) {
        ScanLinkFilter.all => true,
        ScanLinkFilter.linked => scan.plantId != null,
        ScanLinkFilter.unlinked => scan.plantId == null,
      };
      return matchesSeverity && matchesLink;
    }).toList();

    filtered.sort(
      (a, b) => _sortOrder == ScanSortOrder.newestFirst
          ? b.scannedAt.compareTo(a.scannedAt)
          : a.scannedAt.compareTo(b.scannedAt),
    );
    return filtered;
  }

  Future<void> loadScans() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      _allScans = await _getAllScans();
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSortOrder(ScanSortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void setLinkFilter(ScanLinkFilter filter) {
    _linkFilter = filter;
    notifyListeners();
  }

  void setSeverityFilter(ScanSeverity? severity) {
    _severityFilter = severity;
    notifyListeners();
  }
}
