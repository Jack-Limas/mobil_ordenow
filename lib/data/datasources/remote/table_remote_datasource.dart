import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/constants.dart';
import '../../models/table_model.dart';
import 'supabase_service.dart';

class TableRemoteDataSource {
  static const _uuid = Uuid();

  Future<List<TableModel>> getTables() async {
    final tables = await SupabaseService.getTables();
    return tables.map(TableModel.fromJson).toList();
  }

  Stream<List<TableModel>> watchTables() {
    return SupabaseService.watchTables().map(
      (tables) => tables.map(TableModel.fromJson).toList(),
    );
  }

  Future<void> reserveTable(String tableId) {
    return SupabaseService.updateTableStatus(
      tableId: tableId,
      occupied: true,
      needsPayment: false,
    );
  }

  Future<void> releaseTable(String tableId) {
    return SupabaseService.updateTableStatus(
      tableId: tableId,
      occupied: false,
      needsPayment: false,
    );
  }

  Future<void> seedTablesIfEmpty() async {
    try {
      final existing = await SupabaseService.getTables();
      if (existing.isNotEmpty) {
        debugPrint('ℹ️ restaurant_tables ya tiene ${existing.length} mesas — seed omitido.');
        return;
      }

      final rows = List.generate(20, (i) => {
        'id': _uuid.v4(),
        'number': i + 1,
        'occupied': false,
        'needs_payment': false,
      });

      await SupabaseService.client
          .from(SupabaseTables.table)
          .insert(rows);

      debugPrint('✅ Seed completado: 20 mesas insertadas en restaurant_tables.');
    } catch (e) {
      debugPrint('❌ seedTablesIfEmpty falló: $e');
    }
  }
}
