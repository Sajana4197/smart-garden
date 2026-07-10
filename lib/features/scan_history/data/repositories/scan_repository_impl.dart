import '../../domain/entities/scan.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_local_datasource.dart';
import '../models/scan_model.dart';

class ScanRepositoryImpl implements ScanRepository {
  ScanRepositoryImpl(this._localDataSource);

  final ScanLocalDataSource _localDataSource;

  @override
  Future<List<Scan>> getAllScans() => _localDataSource.getAllScans();

  @override
  Future<List<Scan>> getScansForPlant(int plantId) {
    return _localDataSource.getScansForPlant(plantId);
  }

  @override
  Future<Scan?> getScanById(int id) => _localDataSource.getScanById(id);

  @override
  Future<int> addScan(Scan scan) {
    return _localDataSource.insertScan(ScanModel.fromEntity(scan));
  }

  @override
  Future<void> updateScan(Scan scan) {
    return _localDataSource.updateScan(ScanModel.fromEntity(scan));
  }

  @override
  Future<void> deleteScan(int id) => _localDataSource.deleteScan(id);
}
