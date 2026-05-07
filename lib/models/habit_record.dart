class HabitRecord {
  final String? id;
  final String habitId;
  final String date;
  final bool completed;
  final double? value;
  final int? qualityRating;
  final String? notes;
  final DateTime? createdDate;

  HabitRecord({
    this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    this.value,
    this.qualityRating,
    this.notes,
    this.createdDate,
  });

  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    return HabitRecord(
      id: json['id'],
      habitId: json['habit_id'] ?? '',
      date: json['date'] ?? '',
      completed: json['completed'] ?? false,
      value: json['value']?.toDouble(),
      qualityRating: json['quality_rating'],
      notes: json['notes'],
      createdDate: json['created_date'] != null
          ? DateTime.tryParse(json['created_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'date': date,
      'completed': completed,
      'value': value,
      'quality_rating': qualityRating,
      'notes': notes,
    };
  }
}
