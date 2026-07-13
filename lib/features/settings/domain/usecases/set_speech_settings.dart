import '../entities/speech_settings.dart';
import '../repositories/settings_repository.dart';

class SetSpeechSettings {
  SetSpeechSettings(this._repository);

  final SettingsRepository _repository;

  Future<void> call(SpeechSettings settings) => _repository.saveSpeechSettings(settings);
}
