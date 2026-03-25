import 'package:supabase_flutter/supabase_flutter.dart';
import 'environment.dart';

class SupabaseConfig {
  static Future<void> init() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}