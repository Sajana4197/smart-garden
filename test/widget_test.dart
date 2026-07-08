import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/app.dart';

void main() {
  testWidgets('SmartGardenApp shows placeholder home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmartGardenApp());
    await tester.pumpAndSettle();

    expect(find.text('SmartGarden AI'), findsOneWidget);
  });
}
