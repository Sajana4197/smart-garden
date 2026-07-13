import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/features/voice/domain/entities/speech_status.dart';
import 'package:smart_garden_ai/features/voice/domain/repositories/speech_repository.dart';
import 'package:smart_garden_ai/features/voice/domain/usecases/pause_speech.dart';
import 'package:smart_garden_ai/features/voice/domain/usecases/speak_text.dart';
import 'package:smart_garden_ai/features/voice/domain/usecases/stop_speech.dart';
import 'package:smart_garden_ai/features/voice/presentation/providers/speech_provider.dart';

class _FakeSpeechRepository implements SpeechRepository {
  final _controller = StreamController<SpeechStatus>.broadcast();
  final List<String> spokenTexts = [];
  int pauseCount = 0;
  int stopCount = 0;

  @override
  Stream<SpeechStatus> get statusStream => _controller.stream;

  @override
  Future<void> speak(String text) async {
    spokenTexts.add(text);
    _controller.add(SpeechStatus.speaking);
  }

  @override
  Future<void> pause() async {
    pauseCount++;
    _controller.add(SpeechStatus.paused);
  }

  @override
  Future<void> stop() async {
    stopCount++;
    _controller.add(SpeechStatus.idle);
  }

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  Future<void> setSpeechPitch(double pitch) async {}

  void close() => _controller.close();
}

SpeechProvider _buildProvider(_FakeSpeechRepository repository) {
  return SpeechProvider(
    repository,
    SpeakText(repository),
    PauseSpeech(repository),
    StopSpeech(repository),
  );
}

void main() {
  test('starts idle', () {
    final repository = _FakeSpeechRepository();
    final provider = _buildProvider(repository);

    expect(provider.status, SpeechStatus.idle);

    provider.dispose();
    repository.close();
  });

  test('speak() delegates to the repository and updates status to speaking', () async {
    final repository = _FakeSpeechRepository();
    final provider = _buildProvider(repository);

    await provider.speak('hello plant');
    await Future<void>.delayed(Duration.zero);

    expect(repository.spokenTexts, ['hello plant']);
    expect(provider.status, SpeechStatus.speaking);

    provider.dispose();
    repository.close();
  });

  test('pause() delegates to the repository and updates status to paused', () async {
    final repository = _FakeSpeechRepository();
    final provider = _buildProvider(repository);

    await provider.speak('hello plant');
    await provider.pause();
    await Future<void>.delayed(Duration.zero);

    expect(repository.pauseCount, 1);
    expect(provider.status, SpeechStatus.paused);

    provider.dispose();
    repository.close();
  });

  test('stop() delegates to the repository and updates status to idle', () async {
    final repository = _FakeSpeechRepository();
    final provider = _buildProvider(repository);

    await provider.speak('hello plant');
    await provider.stop();
    await Future<void>.delayed(Duration.zero);

    expect(repository.stopCount, 1);
    expect(provider.status, SpeechStatus.idle);

    provider.dispose();
    repository.close();
  });

  test('dispose() stops any in-flight speech', () {
    final repository = _FakeSpeechRepository();
    final provider = _buildProvider(repository);

    provider.dispose();

    expect(repository.stopCount, 1);
    repository.close();
  });
}
