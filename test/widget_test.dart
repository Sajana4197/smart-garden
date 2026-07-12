import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_garden_ai/app.dart';
import 'package:smart_garden_ai/core/routing/app_router.dart';

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  // `appRouter` is a process-wide singleton, so each test must reset its
  // location back to Splash to simulate a fresh app launch.
  setUp(() {
    appRouter.go(AppRoutes.splash);
  });

  testWidgets('Fresh install routes Splash -> Onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(SmartGardenApp(prefs: prefs));

    expect(find.text('SmartGarden AI'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Returning user routes Splash -> Home', (
    WidgetTester tester,
  ) async {
    await prefs.setBool('onboarding_complete', true);

    await tester.pumpWidget(SmartGardenApp(prefs: prefs));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Skip'), findsNothing);
    expect(find.byTooltip('Component gallery (debug)'), findsOneWidget);
  });

  testWidgets('Tapping the daily tip card navigates to All Tips', (
    WidgetTester tester,
  ) async {
    await prefs.setBool('onboarding_complete', true);

    await tester.pumpWidget(SmartGardenApp(prefs: prefs));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byKey(const Key('dailyTipCard')), findsOneWidget);

    await tester.tap(find.byKey(const Key('dailyTipCard')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    expect(find.text('All Tips'), findsOneWidget);
  });
}
