import '../entities/table.dart';
import '../repositories/table_repository.dart';

class GetSelectedTable {
  GetSelectedTable(this._repository);

  final TableRepository _repository;

  Future<TableEntity?> call() {
    return _repository.getSelectedTable();
  }
}
