import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_garden_ai/features/daily_tips/domain/entities/daily_tip_state.dart';
import 'package:smart_garden_ai/features/daily_tips/domain/entities/plant_tip.dart';
import 'package:smart_garden_ai/features/daily_tips/domain/repositories/daily_tip_repository.dart';
import 'package:smart_garden_ai/features/daily_tips/domain/usecases/get_all_tips.dart';
import 'package:smart_garden_ai/features/daily_tips/presentation/screens/all_tips_screen.dart';

class _FakeDailyTipRepository implements DailyTipRepository {
  _FakeDailyTipRepository(this._tips);

  final List<PlantTip> _tips;

  @override
  Future<List<PlantTip>> getAllTips() async => _tips;

  @override
  Future<DailyTipState?> getState() async => null;

  @override
  Future<void> saveState(DailyTipState state) async {}
}

void main() {
  testWidgets('AllTipsScreen renders every tip from the bank', (tester) async {
    final tips = [
      const PlantTip(id: 'tip_a', title: 'Water Wisely', body: 'Body A'),
      const PlantTip(id: 'tip_b', title: 'Give It Light', body: 'Body B'),
    ];
    final getAllTips = GetAllTips(_FakeDailyTipRepository(tips));

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<GetAllTips>.value(
          value: getAllTips,
          child: const AllTipsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All Tips'), findsOneWidget);
    expect(find.text('Water Wisely'), findsOneWidget);
    expect(find.text('Give It Light'), findsOneWidget);
    expect(find.text('Body A'), findsOneWidget);
    expect(find.text('Body B'), findsOneWidget);
  });
}
