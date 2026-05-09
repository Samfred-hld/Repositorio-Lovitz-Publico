import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'supabase_client.dart';
import '../utils/constants.dart';
import '../models/habit.dart';
import '../models/habit_record.dart';
import '../models/achievement.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SupabaseClient _client = SupabaseConfig.client;
  String get _userId => AuthService().userId ?? '';

  // ==================== HABITS ====================

  Future<List<Habit>> getHabits({bool activeOnly = true}) async {
    if (_userId.isEmpty) return [];

    var query = _client
        .from(ApiConstants.habitsTable)
        .select()
        .eq('user_id', _userId);

    if (activeOnly) {
      query = query.eq('is_active', true);
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => Habit.fromJson(e)).toList();
  }

  Future<Habit> createHabit(Habit habit) async {
    if (_userId.isEmpty) throw Exception('Usuário não autenticado');

    // Ensure user row exists in users table (FK constraint)
    await _ensureUserExists();

    final data = habit.toJson();
    data['user_id'] = _userId;

    final result = await _client
        .from(ApiConstants.habitsTable)
        .insert(data)
        .select()
        .single();

    return Habit.fromJson(result);
  }

  /// Ensures the authenticated user has a row in the users table.
  /// Fixes FK violation when Auth user was created but users table row wasn't.
  Future<void> _ensureUserExists() async {
    final existing = await _client
        .from(ApiConstants.usersTable)
        .select('id')
        .eq('id', _userId)
        .maybeSingle();

    if (existing == null) {
      final authUser = _client.auth.currentUser;
      await _client.from(ApiConstants.usersTable).upsert({
        'id': _userId,
        'email': authUser?.email ?? '',
        'full_name': authUser?.userMetadata?['full_name'] ?? '',
      });
    }
  }

  Future<Habit> updateHabit(String id, Map<String, dynamic> updates) async {
    final result = await _client
        .from(ApiConstants.habitsTable)
        .update(updates)
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();

    return Habit.fromJson(result);
  }

  Future<void> deleteHabit(String id) async {
    await _client
        .from(ApiConstants.habitsTable)
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  // ==================== HABIT LOGS ====================

  Future<List<HabitRecord>> getHabitLogs({
    String? habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _client
        .from(ApiConstants.habitLogsTable)
        .select()
        .eq('user_id', _userId);

    if (habitId != null) {
      query = query.eq('habit_id', habitId);
    }
    if (startDate != null) {
      query = query.gte('log_date', startDate.toIso8601String().split('T')[0]);
    }
    if (endDate != null) {
      query = query.lte('log_date', endDate.toIso8601String().split('T')[0]);
    }

    final data = await query.order('log_date', ascending: false);
    return (data as List).map((e) => HabitRecord.fromJson(e)).toList();
  }

  Future<HabitRecord> createHabitLog(HabitRecord record) async {
    final data = record.toJson();
    data['user_id'] = _userId;

    final result = await _client
        .from(ApiConstants.habitLogsTable)
        .upsert(data, onConflict: 'habit_id, log_date')
        .select()
        .single();

    return HabitRecord.fromJson(result);
  }

  Future<void> deleteHabitLog(String id) async {
    await _client
        .from(ApiConstants.habitLogsTable)
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  // ==================== ACHIEVEMENTS ==================

  Future<List<Achievement>> getUserAchievements() async {
    final data = await _client
        .from(ApiConstants.userAchievementsTable)
        .select('*, achievements(*)')
        .eq('user_id', _userId)
        .order('unlocked_at', ascending: false);

    return (data as List).map((e) => Achievement.fromJson(e)).toList();
  }

  Future<void> unlockAchievement(String achievementId) async {
    await _client.from(ApiConstants.userAchievementsTable).upsert({
      'user_id': _userId,
      'achievement_id': achievementId,
    }, onConflict: 'user_id, achievement_id');
  }

  // ==================== STATS ====================

  Future<Map<String, dynamic>> getUserStats() async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Defaults in case any query fails
    int xpTotal = 0, level = 1, activeHabits = 0, completedToday = 0;

    try {
      final user = await _client
          .from(ApiConstants.usersTable)
          .select('xp_total, level')
          .eq('id', _userId)
          .maybeSingle();
      if (user != null) {
        xpTotal = user['xp_total'] ?? 0;
        level = user['level'] ?? 1;
      }
    } catch (_) {}

    try {
      final habits = await _client
          .from(ApiConstants.habitsTable)
          .select('id')
          .eq('user_id', _userId)
          .eq('is_active', true) as List;
      activeHabits = habits.length;
    } catch (_) {}

    try {
      final todayLogs = await _client
          .from(ApiConstants.habitLogsTable)
          .select('completed, points')
          .eq('user_id', _userId)
          .eq('log_date', today) as List;
      completedToday =
          todayLogs.where((l) => l['completed'] == true).length;
    } catch (_) {}

    return {
      'xp_total': xpTotal,
      'level': level,
      'active_habits': activeHabits,
      'completed_today': completedToday,
      'total_habits_today': activeHabits,
      'points_today': 0,
    };
  }
}
