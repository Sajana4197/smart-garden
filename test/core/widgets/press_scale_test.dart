import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/core/widgets/press_scale.dart';

void main() {
  testWidgets('never swallows the wrapped child\'s own tap', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PressScale(
            child: ElevatedButton(
              onPressed: () => tapCount++,
              child: const Text('Tap me'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pumpAndSettle();

    expect(tapCount, 1);
  });

  testWidgets('scales down while pressed and back up on release', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PressScale(child: SizedBox(width: 100, height: 40)),
        ),
      ),
    );

    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1.0);

    final gesture = await tester.startGesture(tester.getCenter(find.byType(PressScale)));
    await tester.pump();

    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 0.97);

    await gesture.up();
    await tester.pump();

    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1.0);
  });

  testWidgets('does not animate when disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PressScale(
            enabled: false,
            child: SizedBox(width: 100, height: 40),
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedScale), findsNothing);
  });
}
