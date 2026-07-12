import '../repositories/speech_repository.dart';

class StopSpeech {
  StopSpeech(this._repository);

  final SpeechRepository _repository;

  Future<void> call() => _repository.stop();
}
