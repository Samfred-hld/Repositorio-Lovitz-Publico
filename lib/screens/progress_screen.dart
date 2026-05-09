import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PeriodTabBar(),
              const SizedBox(height: 24),
              Text('Seu progresso', style: AppTextStyles.heading1),
              Text(
                'Visão geral do seu desenvolvimento',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 24),
              _LevelBarChart(),
              const SizedBox(height: 24),
              _WeeklySummaryCard(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hábitos de Hoje', style: AppTextStyles.heading2),
                  const Text('Ver todos >', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              const _HabitListItem(
                title: 'Meditar',
                category: 'Fisiológico',
                icon: Icons.self_improvement,
                color: AppColors.maslowFisiologico,
                isCompleted: true,
              ),
              const SizedBox(height: 12),
              const _HabitListItem(
                title: 'Ler 10 páginas',
                category: 'Estima',
                icon: Icons.menu_book,
                color: AppColors.maslowEstima,
                isCompleted: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTab('Hoje', false),
        _buildTab('Semana', true), // active tab
        _buildTab('Mês', false),
        _buildTab('Ano', false),
        const Icon(Icons.menu, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 24,
            color: AppColors.primary,
          )
        ]
      ],
    );
  }
}

class _LevelBarChart extends StatelessWidget {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progresso por nível', style: AppTextStyles.heading3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('Semana', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        IconData icon;
                        switch (value.toInt()) {
                          case 0: icon = Icons.local_fire_department_rounded; break;
                          case 1: icon = Icons.shield_rounded; break;
                          case 2: icon = Icons.people_rounded; break;
                          case 3: icon = Icons.emoji_emotions_rounded; break;
                          case 4: icon = Icons.auto_awesome_rounded; break;
                          default: icon = Icons.circle;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Icon(icon, color: AppColors.textSecondary, size: 20),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: [
                  _buildBarGroup(0, 60, AppColors.maslowFisiologico),
                  _buildBarGroup(1, 40, AppColors.maslowSeguranca),
                  _buildBarGroup(2, 80, AppColors.maslowPertencimento),
                  _buildBarGroup(3, 30, AppColors.maslowEstima),
                  _buildBarGroup(4, 10, AppColors.maslowAutorealizacao),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
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
          Text('Resumo da semana', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('12', 'Sequência', AppColors.accentOrange),
              _buildStat('7/9', 'Hábitos', AppColors.primary),
              _buildStat('78%', 'Taxa', AppColors.accentSuccess),
              _buildStat('20', 'Pontos', AppColors.accentXP),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _HabitListItem extends StatelessWidget {
  final String title;
  final String category;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  const _HabitListItem({
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.textSecondary, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title, style: AppTextStyles.bodyLarge),
                          Text(category, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isCompleted ? AppColors.primary : AppColors.textTertiary,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
