class Achievement {
  final String? id;
  final String achievementId;
  final String? title;
  final String? description;
  final String? icon;
  final int? xpReward;
  final String unlockedAt;
  final Map<String, dynamic>? progress;

  Achievement({
    this.id,
    required this.achievementId,
    this.title,
    this.description,
    this.icon,
    this.xpReward,
    required this.unlockedAt,
    this.progress,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    // Quando vem do join com achievements(*)
    final achievement = json['achievements'] as Map<String, dynamic>?;
    return Achievement(
      id: json['id'],
      achievementId: json['achievement_id'] ?? '',
      title: achievement?['title'],
      description: achievement?['description'],
      icon: achievement?['icon'],
      xpReward: achievement?['xp_reward'],
      unlockedAt: json['unlocked_at'] ?? '',
      progress: json['progress'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievement_id': achievementId,
      'progress': progress,
    };
  }
}
