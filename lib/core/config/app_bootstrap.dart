import 'package:flutter/foundation.dart'; // Importante para debugPrint
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
    
    // 1. Inicializamos la configuración de Supabase
    await SupabaseConfig.init();
    
    // 2. Le damos un respiro de 300 milisegundos al sistema para que el SDK se asiente bien
    await Future.delayed(const Duration(milliseconds: 300));

    // 3. Ejecutamos la siembra de tablas de forma segura
    try {
      await TableRemoteDataSource().seedTablesIfEmpty();
    } catch (e) {
      debugPrint("⚠️ Supabase aún se está conectando, se reintentará en la siguiente consulta: $e");
    }

    // 4. Inicializamos las notificaciones al final
    await NotificationService.initialize();
  }
}