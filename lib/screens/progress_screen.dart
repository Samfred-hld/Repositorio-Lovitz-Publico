import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/maslow_pyramid_painter.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  // Mesmos níveis da home (base → topo visual)
  static const List<MaslowLevel> _maslowLevels = [
    MaslowLevel(
      label: 'Fisiológico',
      percentage: '83%',
      icon: Icons.restaurant_rounded,
      color: AppColors.maslowFisiologico,
    ),
    MaslowLevel(
      label: 'Segurança',
      percentage: '67%',
      icon: Icons.shield_rounded,
      color: AppColors.maslowSeguranca,
    ),
    MaslowLevel(
      label: 'Social',
      percentage: '42%',
      icon: Icons.people_rounded,
      color: AppColors.maslowPertencimento,
    ),
    MaslowLevel(
      label: 'Estima',
      percentage: '28%',
      icon: Icons.star_rounded,
      color: AppColors.maslowEstima,
    ),
    MaslowLevel(
      label: 'Autorrealização',
      percentage: '15%',
      icon: Icons.auto_awesome_rounded,
      color: AppColors.maslowAutorealizacao,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progresso', style: AppTextStyles.heading1),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 28),
              Text('Conquistas Recentes', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              _buildAchievementsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard('🔥', '12', 'Dias de Streak', AppColors.accentOrange),
        _statCard('✅', '47', 'Hábitos Completos', AppColors.accentSuccess),
        _statCard('⭐', '1,250', 'XP Total', AppColors.accentXP),
        _statCard('🏆', '5', 'Conquistas', AppColors.maslowAutorealizacao),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              Text(value,
                  style: AppTextStyles.heading2.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAchievementsList() {
    final achievements = [
      ('🔥', 'Primeira Semana', '7 dias consecutivos'),
      ('💧', 'Hidratação Total', 'Meta de água por 30 dias'),
      ('📚', 'Leitor Dedicado', '100 páginas lidas'),
    ];

    return Column(
      children: achievements
          .map((a) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.cardBackground,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Text(a.$1, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.$2,
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.w600)),
                          Text(a.$3, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle,
                        color: AppColors.accentSuccess),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
