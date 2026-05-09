import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/habit.dart';
import '../models/habit_record.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final _api = ApiService();
  late Habit _habit;
  List<HabitRecord> _monthLogs = [];
  bool _loading = true;
  bool _loggedToday = false;
  late DateTime _calendarMonth;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Carrega logs do mês atual para o calendário
      final start = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
      final end = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);

      final logs = await _api.getHabitLogs(
        habitId: _habit.id,
        startDate: start,
        endDate: end,
      );

      // Recarrega o hábito para ter streak atualizado
      final habits = await _api.getHabits();
      final updated = habits.where((h) => h.id == _habit.id).firstOrNull;

      // Verifica se já completou hoje
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayLog = logs.where((l) => l.logDate == today).toList();

      if (mounted) {
        setState(() {
          _monthLogs = logs;
          if (updated != null) _habit = updated;
          _loggedToday = todayLog.isNotEmpty && todayLog.first.completed;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: const Color(0xFFFF4D4D),
          ),
        );
      }
    }
  }

  Future<void> _toggleToday() async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    try {
      if (_loggedToday) {
        // Desfaz o registro de hoje
        final todayLog = _monthLogs.where((l) => l.logDate == today).firstOrNull;
        if (todayLog?.id != null) {
          await _api.deleteHabitLog(todayLog!.id!);
        }
      } else {
        // Registra conclusão de hoje
        final record = HabitRecord(
          habitId: _habit.id!,
          logDate: today,
          completed: true,
        );
        await _api.createHabitLog(record);
      }

      await _loadData(); // recarrega tudo
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: const Color(0xFFFF4D4D),
          ),
        );
      }
    }
  }

  Future<void> _deleteHabit() async {
    try {
      await _api.deleteHabit(_habit.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${_habit.name}" excluído'),
            backgroundColor: const Color(0xFF6FCF97),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
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

  @override
  Widget build(BuildContext context) {
    final neon = _neonColor(_habit.maslowLevel);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2))
            : Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      color: neon,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildMainCard(neon),
                            const SizedBox(height: 20),
                            _buildCalendar(neon),
                            const SizedBox(height: 20),
                            _buildStatsGrid(neon),
                            const SizedBox(height: 16),
                            _buildLogButton(neon),
                            const SizedBox(height: 24),
                            _buildActionButtons(context, neon),
                            const SizedBox(height: 32),
                          ],
                        ),
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
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.accentOrange, size: 24),
          ),
          const Spacer(),
          Text('Detalhes do Hábito',
              style: AppTextStyles.heading2
                  .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.accentOrange.withOpacity(0.3)),
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

  Widget _buildMainCard(Color neon) {
    // Total de conclusões reais (soma de logs completados)
    final totalCompletions =
        _monthLogs.where((l) => l.completed).length;
    // Meta: 365 dias (1 ano) ou pode vir do hábito
    final totalTarget = 365;
    final progress =
        totalTarget > 0 ? (totalCompletions / totalTarget).clamp(0.0, 1.0) : 0.0;

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
          Text(_habit.name,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: neon, size: 20),
              const SizedBox(width: 8),
              Text('Nível: ',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 15)),
              Text(MaslowLevels.getName(_habit.maslowLevel),
                  style:
                      TextStyle(color: neon, fontSize: 15, fontWeight: FontWeight.w500)),
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
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [neon, neon.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(color: neon.withOpacity(0.6), blurRadius: 12, spreadRadius: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              children: [
                const TextSpan(text: 'Total de conclusões: '),
                TextSpan(
                  text: '$totalCompletions/$totalTarget',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
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
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(
                        _calendarMonth.year, _calendarMonth.month - 1);
                  });
                  _loadData();
                },
                icon: Icon(Icons.chevron_left_rounded, color: neon, size: 24),
              ),
              Text(
                _monthLabel(),
                style: AppTextStyles.heading3,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(
                        _calendarMonth.year, _calendarMonth.month + 1);
                  });
                  _loadData();
                },
                icon:
                    Icon(Icons.chevron_right_rounded, color: neon, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dias da semana
          Row(
            children: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(neon),
        ],
      ),
    );
  }

  String _monthLabel() {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${months[_calendarMonth.month - 1]} ${_calendarMonth.year}';
  }

  Widget _buildCalendarGrid(Color neon) {
    final completedDays = <int>{};
    for (final log in _monthLogs) {
      if (log.completed) {
        final day = int.tryParse(log.logDate.split('-').last);
        if (day != null) completedDays.add(day);
      }
    }

    final now = DateTime.now();
    final today = (now.year == _calendarMonth.year &&
            now.month == _calendarMonth.month)
        ? now.day
        : -1;

    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    // Monday=0, Sunday=6
    final firstWeekday = (firstDay.weekday + 6) % 7;
    final daysInMonth =
        DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    for (int i = 0; i < firstWeekday; i++) {
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
          BoxShadow(color: neon.withOpacity(0.6), blurRadius: 10, spreadRadius: 1),
          BoxShadow(color: neon.withOpacity(0.3), blurRadius: 18, spreadRadius: 2),
        ],
      ),
      child: Center(
        child: Text('$day',
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
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
        child: Text('$day',
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _normalDay(int day) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Center(
        child: Text('$day',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
      ),
    );
  }

  Widget _buildStatsGrid(Color neon) {
    final totalLogs = _monthLogs.where((l) => l.completed).length;

    return Row(
      children: [
        Expanded(
            child: _statCard(neon, Icons.local_fire_department_rounded,
                'Sequência atual:', '${_habit.streakCurrent} dias')),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard(neon, Icons.check_circle_rounded,
                'Total de conclusões:', '$totalLogs')),
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
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.white.withOpacity(0.5))),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogButton(Color neon) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _toggleToday,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: _loggedToday
                  ? const Color(0xFF6FCF97).withOpacity(0.15)
                  : neon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _loggedToday
                    ? const Color(0xFF6FCF97).withOpacity(0.6)
                    : neon.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_loggedToday
                          ? const Color(0xFF6FCF97)
                          : neon)
                      .withOpacity(0.3),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _loggedToday
                      ? Icons.check_circle_rounded
                      : Icons.add_task_rounded,
                  color: _loggedToday
                      ? const Color(0xFF6FCF97)
                      : neon,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  _loggedToday ? 'Concluído hoje ✓' : 'Marcar como concluído',
                  style: TextStyle(
                    color: _loggedToday
                        ? const Color(0xFF6FCF97)
                        : neon,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color neon) {
    return Column(
      children: [
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
                  border: Border.all(color: neon.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(color: neon.withOpacity(0.15), blurRadius: 14),
                  ],
                ),
                child: Center(
                  child: Text('Editar Hábito',
                      style: TextStyle(
                          color: neon,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showDeleteDialog(context, neon),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text('Excluir Hábito',
                      style: TextStyle(
                          color: neon.withOpacity(0.7),
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
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
        title:
            const Text('Excluir Hábito', style: TextStyle(color: Colors.white)),
        content: Text(
          'Tem certeza que deseja excluir "${_habit.name}"? Esta ação não pode ser desfeita.',
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
              _deleteHabit();
            },
            child: const Text('Excluir',
                style: TextStyle(color: Color(0xFFFF4D4D))),
          ),
        ],
      ),
    );
  }
}
