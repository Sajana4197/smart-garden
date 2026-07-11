import '../entities/scan.dart';
import '../repositories/scan_repository.dart';

class GetAllScans {
  GetAllScans(this._repository);

  final ScanRepository _repository;

  Future<List<Scan>> call() => _repository.getAllScans();
}
