/// Playback state of the "read aloud" feature — pure Dart, no
/// Flutter/plugin imports (domain layer rule in PROJECT_SPEC.md §3).
enum SpeechStatus { idle, speaking, paused }
