import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_garden_ai/features/ai_loading/presentation/screens/ai_loading_screen.dart';
import 'package:smart_garden_ai/features/scan_history/domain/entities/scan.dart';
import 'package:smart_garden_ai/features/scan_history/domain/repositories/scan_repository.dart';
import 'package:smart_garden_ai/services/ai/ai_service.dart';

class _FakeAIService implements AIService {
  _FakeAIService({this.result, this.exception});

  final PlantDiagnosisResult? result;
  final AIServiceException? exception;

  @override
  Future<PlantDiagnosisResult> analyzeImage(File imageFile) async {
    if (exception != null) throw exception!;
    return result!;
  }

  @override
  Future<bool> isReady() async => true;
}

class _FakeScanRepository implements ScanRepository {
  _FakeScanRepository({this.throwOnAdd = false});

  final bool throwOnAdd;

  @override
  Future<int> addScan(Scan scan) async {
    if (throwOnAdd) throw StateError('DB write failed');
    return 1;
  }

  @override
  Future<List<Scan>> getAllScans() async => throw UnimplementedError();

  @override
  Future<List<Scan>> getScansForPlant(int plantId) async => throw UnimplementedError();

  @override
  Future<Scan?> getScanById(int id) async => throw UnimplementedError();

  @override
  Future<void> updateScan(Scan scan) async => throw UnimplementedError();

  @override
  Future<void> deleteScan(int id) async => throw UnimplementedError();
}

PlantDiagnosisResult _fakeResult() => PlantDiagnosisResult(
      plantCommonName: 'Tomato',
      diagnosisLabel: 'Healthy',
      isHealthy: true,
      confidence: 0.9,
      severity: DiagnosisSeverity.none,
      description: 'Looks fine.',
      visualSymptoms: const [],
      analyzedAt: DateTime(2026, 1, 1),
    );

void main() {
  testWidgets('shows the typed AIServiceException error with Retry', (tester) async {
    final aiService = _FakeAIService(
      exception: AIServiceException('Bad photo.', AIServiceErrorType.invalidImage),
    );
    final scanRepository = _FakeScanRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<AIService>.value(value: aiService),
            Provider<ScanRepository>.value(value: scanRepository),
          ],
          child: const AiLoadingScreen(imagePath: '/tmp/test.jpg'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));

    expect(find.text('Unreadable photo'), findsOneWidget);
    expect(find.text('Bad photo.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets(
    'shows a generic error (not a crash) when persisting a successful analysis fails',
    (tester) async {
      final aiService = _FakeAIService(result: _fakeResult());
      final scanRepository = _FakeScanRepository(throwOnAdd: true);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<AIService>.value(value: aiService),
              Provider<ScanRepository>.value(value: scanRepository),
            ],
            child: const AiLoadingScreen(imagePath: '/tmp/test.jpg'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));

      expect(tester.takeException(), isNull);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    },
  );
}
