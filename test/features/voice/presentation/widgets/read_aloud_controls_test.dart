import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_garden_ai/features/voice/domain/entities/speech_status.dart';
import 'package:smart_garden_ai/features/voice/domain/repositories/speech_repository.dart';
import 'package:smart_garden_ai/features/voice/domain/usecases/pause_speech.dart';
import 'package:smart_garden_ai/features/voice/domain/usecases/speak_text.dart';
import 'package:smart_garden_ai/features/voice/domain/usecases/stop_speech.dart';
import 'package:smart_garden_ai/features/voice/presentation/widgets/read_aloud_controls.dart';

class _FakeSpeechRepository implements SpeechRepository {
  final _controller = StreamController<SpeechStatus>.broadcast();
  String? lastSpoken;

  @override
  Stream<SpeechStatus> get statusStream => _controller.stream;

  @override
  Future<void> speak(String text) async {
    lastSpoken = text;
    _controller.add(SpeechStatus.speaking);
  }

  @override
  Future<void> pause() async => _controller.add(SpeechStatus.paused);

  @override
  Future<void> stop() async => _controller.add(SpeechStatus.idle);

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  Future<void> setSpeechPitch(double pitch) async {}
}

void main() {
  testWidgets('tapping through Read Aloud -> Pause -> Stop drives the repository', (
    tester,
  ) async {
    final repository = _FakeSpeechRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              Provider<SpeechRepository>.value(value: repository),
              Provider<SpeakText>(create: (_) => SpeakText(repository)),
              Provider<PauseSpeech>(create: (_) => PauseSpeech(repository)),
              Provider<StopSpeech>(create: (_) => StopSpeech(repository)),
            ],
            child: const ReadAloudControls(text: 'diagnosis text to speak'),
          ),
        ),
      ),
    );

    expect(find.text('Read Aloud'), findsOneWidget);
    expect(find.byIcon(Icons.stop_circle_outlined), findsNothing);

    await tester.tap(find.text('Read Aloud'));
    await tester.pump();

    expect(repository.lastSpoken, 'diagnosis text to speak');
    expect(find.text('Pause'), findsOneWidget);
    expect(find.byIcon(Icons.stop_circle_outlined), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pump();

    expect(find.text('Resume'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.stop_circle_outlined));
    await tester.pump();

    expect(find.text('Read Aloud'), findsOneWidget);
    expect(find.byIcon(Icons.stop_circle_outlined), findsNothing);
  });
}
