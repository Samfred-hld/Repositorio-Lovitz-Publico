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

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user != null) {
      await client.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
      });
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static String? get currentUserId => client.auth.currentUser?.id;
}
