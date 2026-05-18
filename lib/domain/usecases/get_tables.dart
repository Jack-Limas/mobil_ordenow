import '../entities/table.dart';
import '../repositories/table_repository.dart';

class GetTables {
  GetTables(this._repository);

  final TableRepository _repository;

  Future<List<TableEntity>> call() {
    return _repository.getTables();
  }
}
