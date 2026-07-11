import '../entities/scan.dart';
import '../repositories/scan_repository.dart';

class GetScansForPlant {
  GetScansForPlant(this._repository);

  final ScanRepository _repository;

  Future<List<Scan>> call(int plantId) => _repository.getScansForPlant(plantId);
}
