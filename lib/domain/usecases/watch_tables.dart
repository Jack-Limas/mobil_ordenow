import '../entities/table.dart';
import '../repositories/table_repository.dart';

class WatchTables {
  WatchTables(this._repository);

  final TableRepository _repository;

  Stream<List<TableEntity>> call() {
    return _repository.watchTables();
  }
}
