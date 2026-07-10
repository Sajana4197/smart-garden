import '../../../../core/constants/db_constants.dart';
import '../../domain/entities/plant.dart';

/// DTO adding `sqflite` map (de)serialization on top of [Plant].
class PlantModel extends Plant {
  const PlantModel({
    super.id,
    required super.name,
    super.species,
    required super.imagePath,
    required super.dateAdded,
    super.lastScanId,
    super.notes,
    required super.status,
  });

  factory PlantModel.fromMap(Map<String, Object?> map) {
    return PlantModel(
      id: map[DbConstants.plantId] as int?,
      name: map[DbConstants.plantName]! as String,
      species: map[DbConstants.plantSpecies] as String?,
      imagePath: map[DbConstants.plantImagePath]! as String,
      dateAdded: DateTime.parse(map[DbConstants.plantDateAdded]! as String),
      lastScanId: map[DbConstants.plantLastScanId] as int?,
      notes: map[DbConstants.plantNotes] as String?,
      status: PlantHealthStatus.values.byName(
        map[DbConstants.plantStatus]! as String,
      ),
    );
  }

  factory PlantModel.fromEntity(Plant plant) => PlantModel(
        id: plant.id,
        name: plant.name,
        species: plant.species,
        imagePath: plant.imagePath,
        dateAdded: plant.dateAdded,
        lastScanId: plant.lastScanId,
        notes: plant.notes,
        status: plant.status,
      );

  /// [includeId] is false on insert, where `sqflite` assigns the id.
  Map<String, Object?> toMap({bool includeId = true}) {
    return {
      if (includeId) DbConstants.plantId: id,
      DbConstants.plantName: name,
      DbConstants.plantSpecies: species,
      DbConstants.plantImagePath: imagePath,
      DbConstants.plantDateAdded: dateAdded.toIso8601String(),
      DbConstants.plantLastScanId: lastScanId,
      DbConstants.plantNotes: notes,
      DbConstants.plantStatus: status.name,
    };
  }
}
