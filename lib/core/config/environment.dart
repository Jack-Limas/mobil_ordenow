import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // In phase 1 the app can run without backend configuration.
    }
  }

  static String get supabaseUrl {
    final value = dotenv.env['SUPABASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw Exception('SUPABASE_URL is not defined in .env');
    }
    return value;
  }

  static String get supabaseAnonKey {
    final value = dotenv.env['SUPABASE_ANON_KEY']?.trim();
    if (value == null || value.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not defined in .env');
    }
    return value;
  }
}
