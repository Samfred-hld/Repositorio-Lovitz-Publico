import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LegendCard extends StatelessWidget {
  final String label; // e.g., "D-7", "D-3", "D-1"
  final String? avatarEmoji;
  final Color? avatarColor;
  final bool isActive;
  final bool isToday;
  final VoidCallback? onTap;

  const LegendCard({
    super.key,
    required this.label,
    this.avatarEmoji,
    this.avatarColor,
    this.isActive = false,
    this.isToday = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        avatarColor ?? _colorFromLabel(label);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 72,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    effectiveColor.withOpacity(0.4),
                    effectiveColor.withOpacity(0.15),
                  ],
                )
              : null,
          color: isActive ? null : AppColors.cardBackground,
          border: Border.all(
            color: isToday
                ? AppColors.accentXP.withOpacity(0.6)
                : isActive
                    ? effectiveColor.withOpacity(0.3)
                    : AppColors.cardBorder,
            width: isToday ? 2 : 1,
          ),
          boxShadow: isActive ? AppShadows.card : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar circle
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    effectiveColor.withOpacity(0.8),
                    effectiveColor.withOpacity(0.4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: effectiveColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  avatarEmoji ?? _emojiFromLabel(label),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday
                    ? AppColors.accentXP
                    : isActive
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFromLabel(String label) {
    // Generate consistent color from label
    final hash = label.hashCode;
    final colors = [
      AppColors.maslowAutorealizacao,
      AppColors.maslowEstima,
      AppColors.accentSuccess,
      AppColors.accentOrange,
      AppColors.accentXP,
      AppColors.maslowPertencimento,
      AppColors.maslowEstima,
    ];
    return colors[hash.abs() % colors.length];
  }

  String _emojiFromLabel(String label) {
    if (label.contains('+')) return '🌟';
    if (label.contains('D-1')) return '⚡';
    if (label.contains('D-3')) return '🔥';
    if (label.contains('D-7')) return '💎';
    return '👤';
  }
}
