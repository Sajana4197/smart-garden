import '../entities/speech_status.dart';

/// Data-access seam over the device's text-to-speech engine — see
/// ROADMAP.md Phase 13. One shared instance lives for the app's lifetime
/// (wired in `app.dart`, mirroring the `services/ai` singleton pattern),
/// since the underlying engine is itself a single device resource; screens
/// each hold their own short-lived `SpeechProvider` subscribing to
/// [statusStream] rather than owning a repository each.
abstract class SpeechRepository {
  Stream<SpeechStatus> get statusStream;

  Future<void> speak(String text);

  /// Pauses the current utterance where the platform supports it. On
  /// platforms without true positional pause/resume (notably Android),
  /// calling [speak] again after this restarts from the beginning — a
  /// documented `flutter_tts` limitation, not a bug in this app.
  Future<void> pause();

  Future<void> stop();
}
