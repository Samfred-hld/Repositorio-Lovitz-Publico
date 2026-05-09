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

  SupabaseClient get _client => SupabaseConfig.client;
  String get _userId => AuthService().userId ?? '';

  // ==================== HABITS ====================

  Future<List<Habit>> getHabits({bool activeOnly = true}) async {
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
    final data = habit.toJson();
    data['user_id'] = _userId;

    final result = await _client
        .from(ApiConstants.habitsTable)
        .insert(data)
        .select()
        .single();

    return Habit.fromJson(result);
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
    // Busca dados em paralelo
    final results = await Future.wait([
      _client
          .from(ApiConstants.usersTable)
          .select('xp_total, level')
          .eq('id', _userId)
          .single(),
      _client
          .from(ApiConstants.habitsTable)
          .select('id')
          .eq('user_id', _userId)
          .eq('is_active', true),
      _client
          .from(ApiConstants.habitLogsTable)
          .select('completed, points')
          .eq('user_id', _userId)
          .eq('log_date', DateTime.now().toIso8601String().split('T')[0]),
    ]);

    final user = results[0] as Map<String, dynamic>;
    final habits = results[1] as List;
    final todayLogs = results[2] as List;

    final completedToday = todayLogs.where((l) => l['completed'] == true).length;
    final pointsToday =
        todayLogs.fold<int>(0, (sum, l) => sum + (l['points'] as int? ?? 0));

    return {
      'xp_total': user['xp_total'] ?? 0,
      'level': user['level'] ?? 1,
      'active_habits': habits.length,
      'completed_today': completedToday,
      'total_habits_today': habits.length,
      'points_today': pointsToday,
    };
  }
}
