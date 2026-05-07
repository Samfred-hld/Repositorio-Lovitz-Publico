import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/habit.dart';
import '../models/habit_record.dart';
import '../models/achievement.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'api_key': ApiConstants.apiKey,
      };

  // ==================== HABITS ====================

  Future<List<Habit>> getHabits({String? query}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.habits}')
        .replace(queryParameters: {
      if (query != null) 'q': query,
      'sort_by': '-created_date',
    });

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data is List ? data : (data['data'] ?? []);
      return items.map((e) => Habit.fromJson(e)).toList();
    }
    throw Exception('Erro ao carregar hábitos: ${response.statusCode}');
  }

  Future<Habit> createHabit(Habit habit) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.habits}');
    final response = await http.post(
      uri,
      headers: _headers,
      body: json.encode(habit.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Habit.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao criar hábito: ${response.statusCode}');
  }

  Future<Habit> updateHabit(String id, Map<String, dynamic> updates) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.habits}/$id');
    final response = await http.put(
      uri,
      headers: _headers,
      body: json.encode(updates),
    );
    if (response.statusCode == 200) {
      return Habit.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao atualizar hábito: ${response.statusCode}');
  }

  Future<void> deleteHabit(String id) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.habits}/$id');
    final response = await http.delete(uri, headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao deletar hábito: ${response.statusCode}');
    }
  }

  // ==================== HABIT RECORDS ====================

  Future<List<HabitRecord>> getHabitRecords({String? query}) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.habitRecords}')
            .replace(queryParameters: {
      if (query != null) 'q': query,
      'sort_by': '-date',
    });

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data is List ? data : (data['data'] ?? []);
      return items.map((e) => HabitRecord.fromJson(e)).toList();
    }
    throw Exception('Erro ao carregar registros: ${response.statusCode}');
  }

  Future<HabitRecord> createHabitRecord(HabitRecord record) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.habitRecords}');
    final response = await http.post(
      uri,
      headers: _headers,
      body: json.encode(record.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return HabitRecord.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao criar registro: ${response.statusCode}');
  }

  Future<HabitRecord> updateHabitRecord(
      String id, Map<String, dynamic> updates) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.habitRecords}/$id');
    final response = await http.put(
      uri,
      headers: _headers,
      body: json.encode(updates),
    );
    if (response.statusCode == 200) {
      return HabitRecord.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao atualizar registro: ${response.statusCode}');
  }

  // ==================== ACHIEVEMENTS ====================

  Future<List<Achievement>> getAchievements({String? query}) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.achievements}')
            .replace(queryParameters: {
      if (query != null) 'q': query,
      'sort_by': '-unlocked_date',
    });

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data is List ? data : (data['data'] ?? []);
      return items.map((e) => Achievement.fromJson(e)).toList();
    }
    throw Exception('Erro ao carregar conquistas: ${response.statusCode}');
  }

  Future<Achievement> createAchievement(Achievement achievement) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.achievements}');
    final response = await http.post(
      uri,
      headers: _headers,
      body: json.encode(achievement.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Achievement.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao criar conquista: ${response.statusCode}');
  }
}
