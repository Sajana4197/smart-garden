/// User-adjustable TTS rate/pitch — pure Dart, no Flutter/plugin imports
/// (domain layer rule in PROJECT_SPEC.md §3). Defaults match the values
/// `SpeechRepositoryImpl` hardcoded before Phase 15 (CLAUDE.md §3). Voice
/// *selection* (enumerating device TTS voices) is out of scope for this
/// phase — rate and pitch are the two dials exposed.
class SpeechSettings {
  const SpeechSettings({this.rate = 0.5, this.pitch = 1.0});

  final double rate;
  final double pitch;

  static const double minRate = 0.25;
  static const double maxRate = 1.0;
  static const double minPitch = 0.5;
  static const double maxPitch = 2.0;

  SpeechSettings copyWith({double? rate, double? pitch}) => SpeechSettings(
        rate: rate ?? this.rate,
        pitch: pitch ?? this.pitch,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeechSettings && other.rate == rate && other.pitch == pitch;
  }

  @override
  int get hashCode => Object.hash(rate, pitch);
}
