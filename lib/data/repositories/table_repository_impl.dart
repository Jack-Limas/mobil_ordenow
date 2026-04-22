import '../../domain/entities/table.dart';
import '../../domain/repositories/table_repository.dart';
import '../datasources/local/table_local_datasource.dart';
import '../datasources/remote/table_remote_datasource.dart';

class TableRepositoryImpl implements TableRepository {
  TableRepositoryImpl({
    required TableRemoteDataSource remoteDataSource,
    required TableLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final TableRemoteDataSource _remoteDataSource;
  final TableLocalDataSource _localDataSource;

  @override
  Future<List<TableEntity>> getTables() async {
    try {
      final remoteTables = await _remoteDataSource.getTables();
      await _localDataSource.saveTables(remoteTables);
      return remoteTables;
    } catch (_) {
      return _localDataSource.getTables();
    }
  }

  @override
  Future<TableEntity?> getSelectedTable() async {
    return _localDataSource.getSelectedTable();
  }

  @override
  Future<void> selectTable(String tableId) async {
    await _localDataSource.saveSelectedTableId(tableId);
  }
}
