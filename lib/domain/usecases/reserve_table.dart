import '../repositories/table_repository.dart';

class ReserveTable {
  ReserveTable(this._repository);

  final TableRepository _repository;

  Future<void> call(String tableId) {
    return _repository.reserveTable(tableId);
  }
}
