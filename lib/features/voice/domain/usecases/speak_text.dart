import '../repositories/speech_repository.dart';

class SpeakText {
  SpeakText(this._repository);

  final SpeechRepository _repository;

  Future<void> call(String text) => _repository.speak(text);
}
