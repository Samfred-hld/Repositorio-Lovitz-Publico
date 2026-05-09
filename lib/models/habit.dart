class Habit {
  final String? id;
  final String name;
  final String? description;
  final int maslowLevel;
  final String habitType; // 'quantitative' or 'qualitative'
  final String? frequency; // 'daily', 'weekly', 'monthly'
  final double? targetValue;
  final String? unit;
  final int? weight;
  final String? icon;
  final String? color;
  final bool isActive;
  final int streakCurrent;
  final int streakBest;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  Habit({
    this.id,
    required this.name,
    this.description,
    required this.maslowLevel,
    required this.habitType,
    this.frequency,
    this.targetValue,
    this.unit,
    this.weight,
    this.icon,
    this.color,
    this.isActive = true,
    this.streakCurrent = 0,
    this.streakBest = 0,
    this.createdDate,
    this.updatedDate,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      maslowLevel: json['maslow_level'] ?? 1,
      habitType: json['habit_type'] ?? 'qualitative',
      frequency: json['frequency'],
      targetValue: json['target_value']?.toDouble(),
      unit: json['unit'],
      weight: json['weight'],
      icon: json['icon'],
      color: json['color'],
      isActive: json['is_active'] ?? true,
      streakCurrent: json['streak_current'] ?? 0,
      streakBest: json['streak_best'] ?? 0,
      createdDate: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedDate: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'maslow_level': maslowLevel,
      'habit_type': habitType,
      'is_active': isActive,
      'streak_current': streakCurrent,
      'streak_best': streakBest,
    };
    // Only include non-null optional fields so DB defaults apply
    if (description != null) data['description'] = description;
    if (frequency != null) data['frequency'] = frequency;
    if (targetValue != null) data['target_value'] = targetValue;
    if (unit != null) data['unit'] = unit;
    if (weight != null) data['weight'] = weight;
    if (icon != null) data['icon'] = icon;
    if (color != null) data['color'] = color;
    return data;
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    int? maslowLevel,
    String? habitType,
    String? frequency,
    double? targetValue,
    String? unit,
    int? weight,
    String? icon,
    String? color,
    bool? isActive,
    int? streakCurrent,
    int? streakBest,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      maslowLevel: maslowLevel ?? this.maslowLevel,
      habitType: habitType ?? this.habitType,
      frequency: frequency ?? this.frequency,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      weight: weight ?? this.weight,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      streakCurrent: streakCurrent ?? this.streakCurrent,
      streakBest: streakBest ?? this.streakBest,
    );
  }
}
