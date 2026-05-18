import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasources/local/hive_service.dart';
import '../../data/datasources/remote/table_remote_datasource.dart';
import '../services/notification_service.dart';
import 'environment.dart';
import 'supabase_config.dart';

class AppBootstrap {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await HiveService.init();
    await Environment.init();
    await SupabaseConfig.init();
    await TableRemoteDataSource().seedTablesIfEmpty();
    await NotificationService.initialize();
  }
}
