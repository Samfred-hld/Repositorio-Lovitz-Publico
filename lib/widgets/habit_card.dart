import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/habit.dart';
import 'progress_ring.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const HabitCard({
    super.key,
    required this.habit,
    this.progress = 0.0,
    this.isCompleted = false,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final maslowColor = _getMaslowColor(habit.maslowLevel);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isCompleted
              ? AppColors.cardBackground.withOpacity(0.15)
              : AppColors.cardBackground,
          border: Border.all(
            color: isCompleted
                ? AppColors.accentSuccess.withOpacity(0.3)
                : AppColors.cardBorder,
            width: 1,
          ),
          boxShadow: isCompleted ? [] : AppShadows.card,
        ),
        child: Row(
          children: [
            // Progress ring with icon
            GestureDetector(
              onTap: onToggle,
              child: ProgressRing(
                progress: isCompleted ? 1.0 : progress,
                size: 52,
                strokeWidth: 5,
                fillColor:
                    isCompleted ? AppColors.accentSuccess : maslowColor,
                child: _buildHabitIcon(maslowColor),
              ),
            ),
            const SizedBox(width: 14),

            // Habit info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: isCompleted
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (habit.description != null &&
                      habit.description!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      habit.description!,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  // Maslow level badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: maslowColor.withOpacity(0.15),
                          border: Border.all(
                            color: maslowColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getMaslowEmoji(habit.maslowLevel),
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getMaslowName(habit.maslowLevel),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: maslowColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (habit.habitType == 'quantitative' &&
                          habit.targetValue != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${_formatValue(progress * habit.targetValue!)} / ${_formatValue(habit.targetValue!)} ${habit.unit ?? ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Streak counter
            if (habit.streakCurrent > 0) ...[
              const SizedBox(width: 8),
              _buildStreakBadge(habit.streakCurrent),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHabitIcon(Color color) {
    final iconName = habit.icon;
    if (iconName != null && iconName.isNotEmpty) {
      return Icon(
        _getIconData(iconName),
        color: color,
        size: 22,
      );
    }
    return Text(
      _getMaslowEmoji(habit.maslowLevel),
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accentOrange.withOpacity(0.25),
            AppColors.accentOrange.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: AppColors.accentOrange.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            '$streak',
            style: AppTextStyles.streakNumber.copyWith(fontSize: 14),
          ),
          Text(
            'dias',
            style: AppTextStyles.bodySmall.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }

  Color _getMaslowColor(int level) {
    switch (level) {
      case 1:
        return AppColors.maslowFisiologico;
      case 2:
        return AppColors.maslowSeguranca;
      case 3:
        return AppColors.maslowPertencimento;
      case 4:
        return AppColors.maslowEstima;
      case 5:
        return AppColors.maslowAutorealizacao;
      default:
        return AppColors.accentOrange;
    }
  }

  String _getMaslowName(int level) {
    switch (level) {
      case 1:
        return 'Fisiológicas';
      case 2:
        return 'Segurança';
      case 3:
        return 'Social';
      case 4:
        return 'Estima';
      case 5:
        return 'Autorrealização';
      default:
        return '';
    }
  }

  String _getMaslowEmoji(int level) {
    switch (level) {
      case 1:
        return '🍎';
      case 2:
        return '🛡️';
      case 3:
        return '❤️';
      case 4:
        return '⭐';
      case 5:
        return '🌟';
      default:
        return '❓';
    }
  }

  IconData _getIconData(String name) {
    final iconMap = <String, IconData>{
      'water': Icons.water_drop,
      'book': Icons.menu_book,
      'fitness': Icons.fitness_center,
      'sleep': Icons.bedtime,
      'food': Icons.restaurant,
      'run': Icons.directions_run,
      'meditation': Icons.self_improvement,
      'heart': Icons.favorite,
      'star': Icons.star,
      'sun': Icons.wb_sunny,
      'moon': Icons.nightlight_round,
      'music': Icons.music_note,
      'code': Icons.code,
      'work': Icons.work,
      'school': Icons.school,
    };
    return iconMap[name.toLowerCase()] ?? Icons.check_circle_outline;
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }
}
