import 'package:supabase_flutter/supabase_flutter.dart';

import 'environment.dart';

class SupabaseConfig {
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
      );
    } catch (_) {
      // Supabase is enabled in phase 2 once .env is configured.
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
