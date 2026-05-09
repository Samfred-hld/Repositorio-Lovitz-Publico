class HabitRecord {
  final String? id;
  final String habitId;
  final String? userId;
  final String logDate;
  final bool completed;
  final double? value;
  final int? quality;
  final int points;
  final String? notes;
  final DateTime? createdAt;

  HabitRecord({
    this.id,
    required this.habitId,
    this.userId,
    required this.logDate,
    required this.completed,
    this.value,
    this.quality,
    this.points = 0,
    this.notes,
    this.createdAt,
  });

  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    return HabitRecord(
      id: json['id'],
      habitId: json['habit_id'] ?? '',
      userId: json['user_id'],
      logDate: json['log_date'] ?? '',
      completed: json['completed'] ?? false,
      value: json['value']?.toDouble(),
      quality: json['quality'],
      points: json['points'] ?? 0,
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'log_date': logDate,
      'completed': completed,
      'value': value,
      'quality': quality,
      'notes': notes,
    };
  }

  HabitRecord copyWith({
    String? id,
    String? habitId,
    String? userId,
    String? logDate,
    bool? completed,
    double? value,
    int? quality,
    int? points,
    String? notes,
  }) {
    return HabitRecord(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
      completed: completed ?? this.completed,
      value: value ?? this.value,
      quality: quality ?? this.quality,
      points: points ?? this.points,
      notes: notes ?? this.notes,
    );
  }
}
