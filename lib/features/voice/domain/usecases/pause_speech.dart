import '../repositories/speech_repository.dart';

class PauseSpeech {
  PauseSpeech(this._repository);

  final SpeechRepository _repository;

  Future<void> call() => _repository.pause();
}
