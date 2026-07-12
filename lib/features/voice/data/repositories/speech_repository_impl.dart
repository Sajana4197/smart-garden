import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../../domain/entities/speech_status.dart';
import '../../domain/repositories/speech_repository.dart';

/// Rate/pitch/language are hardcoded sane defaults for now — Settings is
/// still a stub (ROADMAP.md Phase 15 will wire these to user controls, per
/// CLAUDE.md §3's precedent for Phase 11/13-era features built ahead of
/// Settings).
class SpeechRepositoryImpl implements SpeechRepository {
  SpeechRepositoryImpl({FlutterTts? flutterTts})
      : _tts = flutterTts ?? FlutterTts() {
    _tts.setSpeechRate(0.5);
    _tts.setPitch(1.0);
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
}
