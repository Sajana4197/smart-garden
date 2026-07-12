import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/features/daily_tips/domain/entities/daily_tip_state.dart';
import 'package:smart_garden_ai/features/daily_tips/domain/entities/plant_tip.dart';
import 'package:smart_garden_ai/features/daily_tips/domain/repositories/daily_tip_repository.dart';
import 'package:smart_garden_ai/features/daily_tips/domain/usecases/get_daily_tip.dart';

class _FakeDailyTipRepository implements DailyTipRepository {
  _FakeDailyTipRepository(this._tips, {DailyTipState? initialState})
      : _state = initialState;

  final List<PlantTip> _tips;
  DailyTipState? _state;
  int saveCount = 0;

  @override
  Future<List<PlantTip>> getAllTips() async => _tips;

  @override
  Future<DailyTipState?> getState() async => _state;

  @override
  Future<void> saveState(DailyTipState state) async {
    _state = state;
    saveCount++;
  }
}

void main() {
  final tips = List.generate(
    5,
    (i) => PlantTip(id: 'tip_$i', title: 'Title $i', body: 'Body $i'),
  );

  test('first call of the day selects deterministically and persists state', () async {
    final repository = _FakeDailyTipRepository(tips);
    final getDailyTip = GetDailyTip(repository);

    final tip = await getDailyTip(now: DateTime(2026, 7, 12));

    // seed = 2026*10000 + 7*100 + 12 = 20260712; 20260712 % 5 == 2.
    expect(tip, tips[2]);
    expect(repository.saveCount, 1);
  });

  test('same calendar day returns the same tip without re-selecting', () async {
    final repository = _FakeDailyTipRepository(tips);
    final getDailyTip = GetDailyTip(repository);

    final morning = await getDailyTip(now: DateTime(2026, 7, 12, 8));
    final evening = await getDailyTip(now: DateTime(2026, 7, 12, 22));

    expect(evening, morning);
    expect(repository.saveCount, 1);
  });

  test('a new calendar day re-selects and persists again', () async {
    final repository = _FakeDailyTipRepository(tips);
    final getDailyTip = GetDailyTip(repository);

    await getDailyTip(now: DateTime(2026, 7, 12));
    await getDailyTip(now: DateTime(2026, 7, 13));

    expect(repository.saveCount, 2);
  });

  test('same date always yields the same tip (deterministic, not random)', () async {
    final repository = _FakeDailyTipRepository(tips);
    final getDailyTip = GetDailyTip(repository);

    final first = await getDailyTip(now: DateTime(2026, 3, 5));

    final repository2 = _FakeDailyTipRepository(tips);
    final getDailyTip2 = GetDailyTip(repository2);
    final second = await getDailyTip2(now: DateTime(2026, 3, 5));

    expect(second, first);
  });

  test('falls back to a fresh selection if the persisted tip id vanished from the bank', () async {
    final repository = _FakeDailyTipRepository(
      tips,
      initialState: const DailyTipState(
        lastShownDate: '2026-07-12',
        lastTipId: 'no_longer_exists',
      ),
    );
    final getDailyTip = GetDailyTip(repository);

    final tip = await getDailyTip(now: DateTime(2026, 7, 12));

    expect(tips.contains(tip), isTrue);
  });

  test('throws when the tip bank is empty', () async {
    final repository = _FakeDailyTipRepository(const []);
    final getDailyTip = GetDailyTip(repository);

    expect(
      () => getDailyTip(now: DateTime(2026, 7, 12)),
      throwsA(isA<StateError>()),
    );
  });
}
