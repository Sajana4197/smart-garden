import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/core/widgets/staggered_fade_in.dart';

void main() {
  testWidgets('renders the child, fully opaque once settled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StaggeredFadeIn(index: 3, child: Text('Item content')),
        ),
      ),
    );

    expect(find.text('Item content'), findsOneWidget);

    // pumpAndSettle() alone won't advance past the stagger delay — it stops
    // as soon as no animation is actively ticking, which is true before the
    // Future.delayed fires. Advance the clock past it explicitly first.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    final fadeTransition = find.descendant(
      of: find.byType(StaggeredFadeIn),
      matching: find.byType(FadeTransition),
    );
    final opacity = tester.widget<FadeTransition>(fadeTransition).opacity.value;
    expect(opacity, 1.0);
  });

  testWidgets('disposes cleanly if removed before its delay fires', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StaggeredFadeIn(index: 8, child: Text('Item content')),
        ),
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });
}
