import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/speech_status.dart';
import '../../domain/repositories/speech_repository.dart';
import '../../domain/usecases/pause_speech.dart';
import '../../domain/usecases/speak_text.dart';
import '../../domain/usecases/stop_speech.dart';

/// Screen-scoped "read aloud" state — see CLAUDE.md §5 (one ChangeNotifier
/// per meaningful unit of state per feature). Unlike `WeatherProvider`/
/// `MyGardenProvider`, this is deliberately **not** registered app-wide:
/// it's created fresh wherever `ReadAloudControls` is placed (Result,
/// Recommendation) and disposed — stopping any in-flight speech — when
/// that screen is popped. The underlying [SpeechRepository] it subscribes
/// to *is* an app-wide singleton (one TTS engine for the app's lifetime),
/// injected in rather than owned here.
class SpeechProvider extends ChangeNotifier {
  SpeechProvider(
    this._repository,
    this._speakText,
    this._pauseSpeech,
    this._stopSpeech,
  ) {
    _subscription = _repository.statusStream.listen((status) {
      _status = status;
      notifyListeners();
    });
  }

  final SpeechRepository _repository;
  final SpeakText _speakText;
  final PauseSpeech _pauseSpeech;
  final StopSpeech _stopSpeech;
  late final StreamSubscription<SpeechStatus> _subscription;

  SpeechStatus _status = SpeechStatus.idle;
  SpeechStatus get status => _status;

  Future<void> speak(String text) => _speakText(text);

  Future<void> pause() => _pauseSpeech();

  Future<void> stop() => _stopSpeech();

  @override
  void dispose() {
    _subscription.cancel();
    // Don't let speech from this screen keep playing after the user has
    // navigated away from it.
    _repository.stop();
    super.dispose();
  }
}
