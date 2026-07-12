/// A single curated care tip from the local tip bank — pure Dart, no
/// Flutter/DB imports (domain layer rule in PROJECT_SPEC.md §3).
class PlantTip {
  const PlantTip({required this.id, required this.title, required this.body});

  final String id;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlantTip &&
        other.id == id &&
        other.title == title &&
        other.body == body;
  }

  @override
  int get hashCode => Object.hash(id, title, body);
}
