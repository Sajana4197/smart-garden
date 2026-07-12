import '../../domain/entities/plant_tip.dart';

/// DTO adding JSON (de)serialization on top of [PlantTip] for the bundled
/// `assets/tips/plant_tips.json` tip bank.
class PlantTipModel extends PlantTip {
  const PlantTipModel({
    required super.id,
    required super.title,
    required super.body,
  });

  factory PlantTipModel.fromJson(Map<String, dynamic> json) {
    return PlantTipModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}
