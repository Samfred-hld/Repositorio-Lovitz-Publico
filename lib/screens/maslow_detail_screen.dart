import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/maslow_pyramid_painter.dart';

class MaslowDetailScreen extends StatelessWidget {
  final MaslowLevel level;

  const MaslowDetailScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: const Text('Pirâmide de Maslow', style: TextStyle(color: Colors.white, fontSize: 16)),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Visão geral'),
              Tab(text: 'Detalhes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            const Center(child: Text('Detalhes...', style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ExpandedLevelCard(level: level),
        const SizedBox(height: 16),
        const _CollapsedLevelCard(title: 'Estima', progress: 0.0),
        const SizedBox(height: 12),
        const _CollapsedLevelCard(title: 'Pertencimento', progress: 0.0),
        const SizedBox(height: 12),
        const _CollapsedLevelCard(title: 'Segurança', progress: 0.0),
        const SizedBox(height: 12),
        const _CollapsedLevelCard(title: 'Fisiológico', progress: 0.0),
      ],
    );
  }
}

class _ExpandedLevelCard extends StatelessWidget {
  final MaslowLevel level;

  const _ExpandedLevelCard({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(level.icon, color: level.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  level.label,
                  style: AppTextStyles.heading2,
                ),
              ),
              Text(
                level.percentage,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Descrição curta sobre o nível...',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.0,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(level.color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          const Text('0/2 hábitos concluídos', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hábitos neste nível:', style: AppTextStyles.heading3),
              const Text('0/2', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          _buildHabitItem('Meditar', '10 min por dia', Icons.self_improvement),
          const SizedBox(height: 8),
          _buildHabitItem('Escrever diário', 'Refletir sobre o dia', Icons.book),
        ],
      ),
    );
  }

  Widget _buildHabitItem(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsedLevelCard extends StatelessWidget {
  final String title;
  final double progress;

  const _CollapsedLevelCard({required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_border, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTextStyles.bodyLarge),
                    Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
