import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/habit.dart';
import '../utils/constants.dart';
import 'create_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  // Mock data para demonstração
  List<Habit> get _mockHabits => [
        Habit(
          id: '1',
          name: 'Beber 2L de água',
          maslowLevel: 1,
          habitType: 'quantitative',
          frequency: 'daily',
          targetValue: 2,
          unit: 'L',
          streakCurrent: 12,
          streakBest: 21,
        ),
        Habit(
          id: '2',
          name: 'Dormir 8 horas',
          maslowLevel: 1,
          habitType: 'quantitative',
          frequency: 'daily',
          targetValue: 8,
          unit: 'horas',
          streakCurrent: 5,
          streakBest: 14,
        ),
        Habit(
          id: '3',
          name: 'Fazer exercício',
          maslowLevel: 2,
          habitType: 'qualitative',
          frequency: 'daily',
          streakCurrent: 3,
          streakBest: 9,
        ),
        Habit(
          id: '4',
          name: 'Ler um livro',
          maslowLevel: 5,
          habitType: 'quantitative',
          frequency: 'daily',
          targetValue: 30,
          unit: 'min',
          streakCurrent: 7,
          streakBest: 7,
        ),
        Habit(
          id: '5',
          name: 'Meditar',
          maslowLevel: 5,
          habitType: 'qualitative',
          frequency: 'daily',
          streakCurrent: 0,
          streakBest: 3,
        ),
      ];

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

  IconData _maslowIcon(int level) {
    switch (level) {
      case 1:
        return Icons.restaurant_rounded;
      case 2:
        return Icons.shield_rounded;
      case 3:
        return Icons.people_rounded;
      case 4:
        return Icons.favorite_rounded;
      case 5:
        return Icons.star_rounded;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = _mockHabits;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('Hábitos', style: AppTextStyles.heading1),
                  const Spacer(),
                  // Botão criar
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CreateHabitScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Lista de hábitos
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  return _buildHabitCard(context, habits[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit) {
    final neon = _neonColor(habit.maslowLevel);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => HabitDetailScreen(habit: habit)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Ícone com glow
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: neon.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: neon.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: neon.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(_maslowIcon(habit.maslowLevel),
                  color: neon, size: 24),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    MaslowLevels.getName(habit.maslowLevel),
                    style: TextStyle(
                      color: neon.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Streak
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        color: AppColors.accentOrange, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${habit.streakCurrent}',
                      style: const TextStyle(
                        color: AppColors.accentOrange,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'dias',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.2), size: 22),
          ],
        ),
      ),
    );
  }
}
