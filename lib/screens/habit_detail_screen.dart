import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/habit.dart';
import '../utils/constants.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  // Cor neon por nível Maslow
  Color _neonColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFFF4D4D);
      case 2:
        return const Color(0xFFFFAA00);
      case 3:
        return const Color(0xFF00F2FF);
      case 4:
        return const Color(0xFF007FFF);
      case 5:
        return const Color(0xFFBF00FF);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final neon = _neonColor(habit.maslowLevel);
    final totalCompletions = 128; // TODO: vir do banco
    final totalTarget = 365;
    final streak = habit.streakCurrent;
    final progress = totalCompletions / totalTarget;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Card principal do hábito
                    _buildMainCard(neon, totalCompletions, totalTarget, progress),
                    const SizedBox(height: 20),

                    // Calendário de conclusão
                    _buildCalendar(neon),
                    const SizedBox(height: 20),

                    // Stats grid
                    _buildStatsGrid(neon, streak, totalCompletions),
                    const SizedBox(height: 24),

                    // Botões de ação
                    _buildActionButtons(context, neon),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.accentOrange, size: 24),
          ),
          const Spacer(),
          Text(
            'Detalhes do Hábito',
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentOrange.withOpacity(0.3),
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz_rounded,
                  color: AppColors.accentOrange, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(
      Color neon, int totalCompletions, int totalTarget, double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habit.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: neon, size: 20),
              const SizedBox(width: 8),
              Text(
                'Nível: ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                ),
              ),
              Text(
                MaslowLevels.getName(habit.maslowLevel),
                style: TextStyle(
                  color: neon,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [neon, neon.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: neon.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Total de conclusões: ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          Text(
            '$totalCompletions/$totalTarget',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(Color neon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Header do calendário
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.chevron_left_rounded,
                    color: neon, size: 24),
              ),
              Text(
                'Histórico de conclusão',
                style: AppTextStyles.heading3,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.chevron_right_rounded,
                    color: neon, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dias da semana
          Row(
            children: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Grid do calendário (mês de exemplo)
          _buildCalendarGrid(neon),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Color neon) {
    // Exemplo: Maio 2026, começa na sexta (index 4)
    // Dias completados (simulado)
    final completedDays = {1, 3, 5, 8, 10, 11, 12, 14, 15, 17, 19, 20, 22};
    final today = 9; // dia atual

    final firstDayWeekday = 4; // quinta = index 4 (0=seg)
    final daysInMonth = 31;

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    // Espaços vazios antes do dia 1
    for (int i = 0; i < firstDayWeekday; i++) {
      currentRow.add(const Expanded(child: SizedBox()));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final isCompleted = completedDays.contains(day);
      final isToday = day == today;

      currentRow.add(
        Expanded(
          child: Center(
            child: isCompleted
                ? _glowingDay(day, neon)
                : isToday
                    ? _todayDay(day)
                    : _normalDay(day),
          ),
        ),
      );

      if (currentRow.length == 7) {
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: currentRow),
        ));
        currentRow = [];
      }
    }

    // Última linha incompleta
    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(const Expanded(child: SizedBox()));
      }
      rows.add(Row(children: currentRow));
    }

    return Column(children: rows);
  }

  Widget _glowingDay(int day, Color neon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: neon.withOpacity(0.25),
        border: Border.all(color: neon, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: neon.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: neon.withOpacity(0.3),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$day',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _todayDay(int day) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Center(
        child: Text(
          '$day',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _normalDay(int day) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Color neon, int streak, int totalCompletions) {
    return Row(
      children: [
        Expanded(child: _statCard(neon, Icons.local_fire_department_rounded, 'Sequência atual:', '$streak dias')),
        const SizedBox(width: 12),
        Expanded(child: _statCard(neon, Icons.check_circle_rounded, 'Total de conclusões:', '$totalCompletions')),
      ],
    );
  }

  Widget _statCard(Color neon, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: neon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: neon.withOpacity(0.2)),
            ),
            child: Icon(icon, color: neon, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color neon) {
    return Column(
      children: [
        // Editar
        SizedBox(
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // TODO: navegar para edição
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: neon.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: neon.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neon.withOpacity(0.15),
                      blurRadius: 14,
                    ),
                    BoxShadow(
                      color: neon.withOpacity(0.08),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Editar Hábito',
                    style: TextStyle(
                      color: neon,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Excluir
        SizedBox(
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _showDeleteDialog(context, neon);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Excluir Hábito',
                    style: TextStyle(
                      color: neon.withOpacity(0.7),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, Color neon) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Text('Excluir Hábito',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Tem certeza que deseja excluir "${habit.name}"? Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              // TODO: excluir do banco
            },
            child: const Text('Excluir',
                style: TextStyle(color: Color(0xFFFF4D4D))),
          ),
        ],
      ),
    );
  }
}
