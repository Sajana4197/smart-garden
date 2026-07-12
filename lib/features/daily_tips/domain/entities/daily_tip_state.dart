/// Persisted "which tip was last shown, and on what date" state — mirrors
/// the `daily_tip_state` table (PROJECT_SPEC.md §5). [lastShownDate] is an
/// ISO calendar date (`yyyy-MM-dd`, no time component) so same-day
/// comparisons don't depend on time-of-day.
class DailyTipState {
  const DailyTipState({required this.lastShownDate, required this.lastTipId});

  final String lastShownDate;
  final String lastTipId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyTipState &&
        other.lastShownDate == lastShownDate &&
        other.lastTipId == lastTipId;
  }

  @override
  int get hashCode => Object.hash(lastShownDate, lastTipId);
}
