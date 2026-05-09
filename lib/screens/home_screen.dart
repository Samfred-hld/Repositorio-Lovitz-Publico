import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/maslow_pyramid_painter.dart';
import '../services/api_service.dart';
import '../models/habit.dart';
import '../utils/constants.dart';
import 'maslow_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final _api = ApiService();

  // Dados reais
  List<Habit> _habits = [];
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final habits = await _api.getHabits();
      final stats = await _api.getUserStats();

      if (mounted) {
        setState(() {
          _habits = habits;
          _stats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Calcula % de conclusão por nível Maslow
  Map<int, Map<String, dynamic>> _maslowProgress() {
    final result = <int, Map<String, dynamic>>{};
    for (int level = 1; level <= 5; level++) {
      final levelHabits = _habits.where((h) => h.maslowLevel == level).toList();
      final total = levelHabits.length;
      // Usa streak > 0 como proxy de "em progresso"
      final withProgress = levelHabits.where((h) => h.streakCurrent > 0).length;
      final pct = total > 0 ? ((withProgress / total) * 100).round() : 0;
      result[level] = {'total': total, 'pct': pct};
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _loading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary, strokeWidth: 2)),
                        )
                      : Column(
                          children: [
                            _buildSummaryCards(),
                            const SizedBox(height: 32),
                            _buildMaslowSection(),
                            const SizedBox(height: 24),
                            _buildContinueJourney(),
                          ],
                        ),
                  SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFA78BFA), Color(0xFFE040FB)],
                  ).createShader(bounds),
                  child: Text(
                    'Habit Tracker',
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 26,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sua jornada de crescimento começa com pequenos hábitos.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6040C0), Color(0xFF8B70E8)],
              ),
            ),
            child: const Center(
              child:
                  Icon(Icons.person_rounded, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white.withOpacity(0.70),
                    size: 24,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFF5252),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARDS DE RESUMO (dados reais) ────────────────────────────
  Widget _buildSummaryCards() {
    final completedToday = _stats['completed_today'] ?? 0;
    final totalHabits = _stats['active_habits'] ?? 0;
    final bestStreak = _habits.fold<int>(
        0, (max, h) => h.streakBest > max ? h.streakBest : max);
    final currentStreak = _habits.fold<int>(
        0, (max, h) => h.streakCurrent > max ? h.streakCurrent : max);

    final pctText = totalHabits > 0
        ? '${((completedToday / totalHabits) * 100).round()}%'
        : '0%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppColors.accentOrange,
              label: 'Sequência atual',
              value: '$currentStreak',
              subtext: 'dias',
              valueColor: const Color(0xFFE040FB),
              footer: 'Melhor sequência: $bestStreak dias',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.primary,
              label: 'Hábitos concluídos',
              value: '$completedToday/$totalHabits',
              subtext: 'hoje',
              valueColor: AppColors.primary,
              footer: '$pctText da sua meta diária',
            ),
          ),
        ],
      ),
    );
  }

  // ─── SEÇÃO PIRÂMIDE DE MASLOW (dados reais) ──────────────────
  Widget _buildMaslowSection() {
    final progress = _maslowProgress();

    final levels = [
      _LevelData('Fisiológico', Icons.local_fire_department_rounded,
          AppColors.maslowFisiologico, 1),
      _LevelData('Segurança', Icons.shield_rounded,
          AppColors.maslowSeguranca, 2),
      _LevelData('Pertencimento', Icons.people_rounded,
          AppColors.maslowPertencimento, 3),
      _LevelData('Estima', Icons.emoji_emotions_rounded,
          AppColors.maslowEstima, 4),
      _LevelData('Autorrealização', Icons.auto_awesome_rounded,
          AppColors.maslowAutorealizacao, 5),
    ];

    final maslowLevels = levels
        .map((l) => MaslowLevel(
              label: l.label,
              percentage: '${progress[l.level]?['pct'] ?? 0}%',
              icon: l.icon,
              color: l.color,
            ))
        .toList();

    final emojis = ['🔥', '🛡️', '❤️', '⭐', '🌟'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pirâmide de Maslow',
                  style: AppTextStyles.heading2.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text('Acompanhe seu progresso em cada nível.',
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13, color: AppColors.textTertiary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 360,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final pyramidWidth = totalWidth * 0.60;
                final labelsWidth = totalWidth - pyramidWidth - 16;
                final reversedLevels = maslowLevels.reversed.toList();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: pyramidWidth,
                      height: 360,
                      child: CustomPaint(
                        painter: MaslowPyramidPainter(levels: reversedLevels),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: labelsWidth,
                      height: 360,
                      child: Column(
                        children: List.generate(5, (i) {
                          final level = maslowLevels[4 - i];
                          final emoji = emojis[4 - i];
                          final levelNum = 5 - i;
                          final pctValue = progress[levelNum]?['pct'] ?? 0;
                          final total = progress[levelNum]?['total'] ?? 0;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        MaslowDetailScreen(level: level)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Text(emoji,
                                        style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(level.label,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.85),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500)),
                                          Text('$total hábitos',
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.35),
                                                  fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _ProgressCircle(
                                      percentage: pctValue,
                                      color: level.color,
                                      size: 40,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─── CONTINUE SUA JORNADA (dados reais) ──────────────────────
  Widget _buildContinueJourney() {
    final completedToday = _stats['completed_today'] ?? 0;
    final totalHabits = _stats['active_habits'] ?? 0;
    final remaining = totalHabits - completedToday;
    final pct = totalHabits > 0
        ? ((completedToday / totalHabits) * 100).round()
        : 0;

    final journeyText = totalHabits == 0
        ? 'Crie seu primeiro hábito para começar!'
        : remaining <= 0
            ? 'Parabéns! Todos os hábitos concluídos hoje! 🎉'
            : '$completedToday de $totalHabits hábitos concluídos hoje. '
                'Faltam apenas $remaining!';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CustomPaint(
                painter: _ProgressCirclePainter(
                  percentage: pct,
                  color: remaining <= 0
                      ? const Color(0xFF6FCF97)
                      : AppColors.accentSuccess,
                  strokeWidth: 6,
                ),
                child: Center(
                  child: Text(
                    '$pct%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Continue sua jornada',
                      style: AppTextStyles.heading3.copyWith(
                          color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(journeyText,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary, fontSize: 13)),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                            color: AppColors.primaryLight, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          totalHabits == 0
                              ? 'Crie um hábito'
                              : 'Meta: $totalHabits/$totalHabits hábitos',
                          style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelData {
  final String label;
  final IconData icon;
  final Color color;
  final int level;

  const _LevelData(this.label, this.icon, this.color, this.level);
}

// ─── WIDGETS ─────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtext;
  final String footer;
  final Color valueColor;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtext,
    required this.footer,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 12),
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                      letterSpacing: -1)),
              const SizedBox(width: 4),
              Text(subtext,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontSize: 16, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(footer,
              style: AppTextStyles.bodySmall
                  .copyWith(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  final int percentage;
  final Color color;
  final double size;

  const _ProgressCircle({
    required this.percentage,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgressCirclePainter(
          percentage: percentage,
          color: color,
          strokeWidth: 4,
        ),
        child: Center(
          child: Text(
            '$percentage%',
            style: TextStyle(
                color: Colors.white,
                fontSize: size > 30 ? 10 : 9,
                fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _ProgressCirclePainter extends CustomPainter {
  final int percentage;
  final Color color;
  final double strokeWidth;

  _ProgressCirclePainter({
    required this.percentage,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (percentage > 0) {
      final sweepAngle = 2 * 3.14159265 * (percentage / 100);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159265 / 2,
        sweepAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressCirclePainter old) =>
      old.percentage != percentage || old.color != color;
}
