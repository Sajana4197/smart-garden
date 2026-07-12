import '../entities/daily_tip_state.dart';
import '../entities/plant_tip.dart';
import '../repositories/daily_tip_repository.dart';

/// Resolves "today's" tip: stable across every call made on the same
/// calendar day, deterministically re-derived (not randomized) the first
/// time a new day is seen. See ROADMAP.md Phase 12.
///
/// [now] is injectable so callers/tests can simulate a date instead of
/// depending on the real clock (Phase 12 exit criteria: "changes next day").
class GetDailyTip {
  GetDailyTip(this._repository);

  final DailyTipRepository _repository;

  Future<PlantTip> call({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final todayKey = _dateKey(today);

    final tips = await _repository.getAllTips();
    if (tips.isEmpty) {
      throw StateError('Tip bank is empty.');
    }

    final state = await _repository.getState();
    if (state != null && state.lastShownDate == todayKey) {
      for (final tip in tips) {
        if (tip.id == state.lastTipId) return tip;
      }
      // Persisted id no longer exists in the bank (e.g. bank was updated) —
      // fall through and re-select deterministically below.
    }

    final tip = _selectForDate(tips, today);
    await _repository.saveState(
      DailyTipState(lastShownDate: todayKey, lastTipId: tip.id),
    );
    return tip;
  }

  /// Date-seeded index — same date always yields the same tip, and the
  /// index shifts most days without needing randomness or extra state.
  PlantTip _selectForDate(List<PlantTip> tips, DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    return tips[seed % tips.length];
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
