class Achievement {
  final String? id;
  final String achievementId;
  final String unlockedDate;
  final Map<String, dynamic>? progressData;
  final DateTime? createdDate;

  Achievement({
    this.id,
    required this.achievementId,
    required this.unlockedDate,
    this.progressData,
    this.createdDate,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      achievementId: json['achievement_id'] ?? '',
      unlockedDate: json['unlocked_date'] ?? '',
      progressData: json['progress_data'],
      createdDate: json['created_date'] != null
          ? DateTime.tryParse(json['created_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievement_id': achievementId,
      'unlocked_date': unlockedDate,
      'progress_data': progressData,
    };
  }
}
