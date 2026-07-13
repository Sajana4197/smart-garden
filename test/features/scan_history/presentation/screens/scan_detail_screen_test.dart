import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/features/scan_history/domain/entities/scan.dart';
import 'package:smart_garden_ai/features/scan_history/presentation/screens/scan_detail_screen.dart';

void main() {
  testWidgets(
    'shows an error state instead of crashing when rawResultJson is unparseable',
    (tester) async {
      final scan = Scan(
        id: 1,
        imagePath: '/tmp/test.jpg',
        diagnosisLabel: 'Healthy',
        confidence: 0.9,
        severity: ScanSeverity.none,
        rawResultJson: 'not valid json at all',
        scannedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(home: ScanDetailScreen(scan: scan)),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Could not load this scan'), findsOneWidget);
    },
  );

  testWidgets(
    'shows an error state instead of crashing when rawResultJson is missing required fields',
    (tester) async {
      final scan = Scan(
        id: 1,
        imagePath: '/tmp/test.jpg',
        diagnosisLabel: 'Healthy',
        confidence: 0.9,
        severity: ScanSeverity.none,
        rawResultJson: '{"plantCommonName": "Tomato"}',
        scannedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(home: ScanDetailScreen(scan: scan)),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Could not load this scan'), findsOneWidget);
    },
  );
}
