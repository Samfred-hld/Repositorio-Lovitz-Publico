import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
    );
  }
}
