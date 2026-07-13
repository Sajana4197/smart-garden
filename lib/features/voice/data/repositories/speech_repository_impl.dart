import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../../domain/entities/speech_status.dart';
import '../../domain/repositories/speech_repository.dart';

/// Rate/pitch are seeded from persisted `SettingsRepository` values at
/// construction (`app.dart`) and can be changed live via [setSpeechRate]/
/// [setSpeechPitch] (ROADMAP.md Phase 15). Language stays hardcoded —
/// device TTS voice/language selection is out of scope for this app.
class SpeechRepositoryImpl implements SpeechRepository {
  SpeechRepositoryImpl({
    FlutterTts? flutterTts,
    double initialRate = 0.5,
    double initialPitch = 1.0,
  }) : _tts = flutterTts ?? FlutterTts() {
    _tts.setSpeechRate(initialRate);
    _tts.setPitch(initialPitch);
    _tts.setLanguage('en-US');
    _tts.setStartHandler(() => _statusController.add(SpeechStatus.speaking));
    _tts.setContinueHandler(
      () => _statusController.add(SpeechStatus.speaking),
    );
    _tts.setPauseHandler(() => _statusController.add(SpeechStatus.paused));
    _tts.setCompletionHandler(() => _statusController.add(SpeechStatus.idle));
    _tts.setCancelHandler(() => _statusController.add(SpeechStatus.idle));
    _tts.setErrorHandler((_) => _statusController.add(SpeechStatus.idle));
  }

  final FlutterTts _tts;
  final StreamController<SpeechStatus> _statusController =
      StreamController<SpeechStatus>.broadcast();

  @override
  Stream<SpeechStatus> get statusStream => _statusController.stream;

  @override
  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  @override
  Future<void> pause() async {
    await _tts.pause();
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<void> setSpeechRate(double rate) => _tts.setSpeechRate(rate);

  @override
  Future<void> setSpeechPitch(double pitch) => _tts.setPitch(pitch);
}
