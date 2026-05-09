import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/habit.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'create_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _api = ApiService();
  List<Habit> _habits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega quando volta de outra tela
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    try {
      final habits = await _api.getHabits();
      if (mounted) {
        setState(() {
          _habits = habits;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar hábitos: $e'),
            backgroundColor: const Color(0xFFFF4D4D),
          ),
        );
      }
    }
  }

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
                  GestureDetector(
                    onTap: () async {
                      final created = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CreateHabitScreen()),
                      );
                      if (created == true) _loadHabits();
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

            // Conteúdo
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : _habits.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadHabits,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _habits.length,
                            itemBuilder: (context, index) {
                              return _buildHabitCard(_habits[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_task_rounded,
              size: 64, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(
            'Nenhum hábito ainda',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no + para criar seu primeiro hábito',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final neon = _neonColor(habit.maslowLevel);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => HabitDetailScreen(habit: habit)),
        );
        _loadHabits(); // recarrega ao voltar (streak pode ter mudado)
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
            // Ícone
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

            // Streak real
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
                  habit.streakCurrent == 1 ? 'dia' : 'dias',
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
