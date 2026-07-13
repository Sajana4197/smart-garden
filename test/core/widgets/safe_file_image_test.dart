import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/core/widgets/safe_file_image.dart';

void main() {
  testWidgets('shows a themed fallback instead of crashing when the file is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeFileImage(path: '/definitely/does/not/exist.jpg'),
        ),
      ),
    );
    // Real disk I/O (the missing-file read) doesn't resolve inside
    // flutter_test's fake-async zone without escaping into runAsync().
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });

  testWidgets('fallback respects explicit width/height', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeFileImage(path: '/missing.jpg', width: 56, height: 56),
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    final container = tester.widget<Container>(
      find.ancestor(
        of: find.byIcon(Icons.broken_image_outlined),
        matching: find.byType(Container),
      ),
    );
    expect(container.constraints, const BoxConstraints.tightFor(width: 56, height: 56));
  });
}
