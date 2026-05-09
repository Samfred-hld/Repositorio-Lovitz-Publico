import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/habit.dart';

/// ============================================================
/// DASHBOARD SCREEN — Dark, Futuristic, Neon, Gamified
/// ============================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final _api = ApiService();
  List<Habit> _habits = [];
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  late final AnimationController _fadeController;
  late final AnimationController _streakController;
  late final AnimationController _completedController;
  late final AnimationController _progressBarController;
  late final AnimationController _pyramidController;
  late final AnimationController _pulseController;
  late final List<Animation<double>> _sectionAnimations;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _streakController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _completedController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _progressBarController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _pyramidController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);

    _sectionAnimations = List.generate(5, (i) {
      return CurvedAnimation(
        parent: _fadeController,
        curve: Interval(i * 0.12, (i * 0.12 + 0.5).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      );
    });

    _fadeController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _streakController.dispose();
    _completedController.dispose();
    _progressBarController.dispose();
    _pyramidController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final habits = await _api.getHabits();
      final stats = await _api.getUserStats();
      if (!mounted) return;
      setState(() {
        _habits = habits;
        _stats = stats;
        _loading = false;
      });
      _streakController.forward();
      _completedController.forward();
      Future.delayed(const Duration(milliseconds: 300),
          () => mounted ? _progressBarController.forward() : null);
      Future.delayed(const Duration(milliseconds: 500),
          () => mounted ? _pyramidController.forward() : null);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _streakController.forward();
        _completedController.forward();
        _progressBarController.forward();
        _pyramidController.forward();
      }
    }
  }

  Map<int, Map<String, dynamic>> _maslowProgress() {
    final result = <int, Map<String, dynamic>>{};
    for (int level = 1; level <= 5; level++) {
      final levelHabits = _habits.where((h) => h.maslowLevel == level).toList();
      final total = levelHabits.length;
      final withProgress = levelHabits.where((h) => h.streakCurrent > 0).length;
      final pct = total > 0 ? ((withProgress / total) * 100).round() : 0;
      result[level] = {'total': total, 'pct': pct};
    }
    return result;
  }

  // ─── Neon palette ──────────────────────────────────────────
  static const _neonPurple = Color(0xFFBF00FF);
  static const _neonRed = Color(0xFFFF4D4D);
  static const _neonOrange = Color(0xFFFFAA00);
  static const _neonCyan = Color(0xFF00F2FF);
  static const _neonBlue = Color(0xFF007FFF);
  static const _neonGreen = Color(0xFF39FF14);

  static const _maslowColors = [
    Color(0xFFFFAA00), // Fisiológico
    Color(0xFF39FF14), // Segurança
    Color(0xFF00F2FF), // Pertencimento
    Color(0xFF007FFF), // Estima
    Color(0xFFBF00FF), // Autorrealização
  ];
  static const _maslowIcons = [
    Icons.local_fire_department_rounded,
    Icons.shield_rounded,
    Icons.people_rounded,
    Icons.emoji_events_rounded,
    Icons.auto_awesome_rounded,
  ];
  static const _maslowNames = [
    'Fisiológico',
    'Segurança',
    'Pertencimento',
    'Estima',
    'Autorrealização',
  ];

  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: _neonCyan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildStatsSection(),
                    const SizedBox(height: 32),
                    _buildPyramidSection(),
                    // Extra space for bottom nav
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // NO bottomNavigationBar — MainShell handles it
    );
  }

  // ============================================================
  // BACKGROUND
  // ============================================================
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF050510),
            Color(0xFF0A0A1A),
            Color(0xFF0D0B1E),
            Color(0xFF08061A),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: CustomPaint(painter: _GridPainter(), size: Size.infinite),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader() {
    return FadeTransition(
      opacity: _sectionAnimations[0],
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(_sectionAnimations[0]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [_neonPurple, _neonBlue, _neonCyan],
                      ).createShader(bounds),
                      child: Text('Habit Tracker',
                          style: AppTextStyles.heading1.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  color: _neonPurple.withOpacity(0.5),
                                  blurRadius: 20),
                              Shadow(
                                  color: _neonBlue.withOpacity(0.3),
                                  blurRadius: 40),
                            ],
                          )),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sua jornada de crescimento começa com pequenos hábitos.',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.45), fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Avatar
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                            colors: [_neonPurple, _neonCyan]),
                        boxShadow: [
                          BoxShadow(
                              color: _neonPurple.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 1),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 43,
                          height: 43,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1A162B)),
                          child: const Icon(Icons.person_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) {
                          final s = 1.0 + _pulseController.value * 0.3;
                          return Transform.scale(
                            scale: s,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _neonGreen,
                                boxShadow: [
                                  BoxShadow(
                                      color: _neonGreen.withOpacity(
                                          0.6 + _pulseController.value * 0.3),
                                      blurRadius: 6,
                                      spreadRadius: 1),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Bell
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                        color: _neonCyan.withOpacity(0.15), blurRadius: 12),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                        child: Icon(Icons.notifications_none_rounded,
                            color: _neonCyan.withOpacity(0.85), size: 22)),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _neonRed,
                          boxShadow: [
                            BoxShadow(
                                color: _neonRed.withOpacity(0.6),
                                blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================
  Widget _buildStatsSection() {
    return FadeTransition(
      opacity: _sectionAnimations[1],
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(_sectionAnimations[1]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _buildStreakCard()),
              const SizedBox(width: 14),
              Expanded(child: _buildCompletedCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    final currentStreak =
        _habits.fold<int>(0, (m, h) => h.streakCurrent > m ? h.streakCurrent : m);
    final bestStreak =
        _habits.fold<int>(0, (m, h) => h.streakBest > m ? h.streakBest : m);

    return _GlassContainer(
      glowColor: _neonOrange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _glowIcon(Icons.local_fire_department_rounded, _neonOrange),
          const SizedBox(height: 14),
          Text('Sequência atual',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _streakController,
            builder: (_, __) {
              final d = (currentStreak * _streakController.value).round();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                        colors: [_neonOrange, const Color(0xFFFFD700)])
                        .createShader(b),
                    child: Text('$d',
                        style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            height: 1.0)),
                  ),
                  const SizedBox(width: 4),
                  Text('dias',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.55), fontSize: 15)),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text('Melhor sequência: $bestStreak dias',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.35), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildCompletedCard() {
    final completedToday = _stats['completed_today'] ?? 0;
    final totalHabits = _stats['active_habits'] ?? 0;
    final pct =
        totalHabits > 0 ? ((completedToday / totalHabits) * 100).round() : 0;

    return _GlassContainer(
      glowColor: _neonPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _glowIcon(Icons.check_circle_rounded, _neonPurple),
          const SizedBox(height: 14),
          Text('Hábitos concluídos',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _completedController,
            builder: (_, __) {
              final d = (completedToday * _completedController.value).round();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                        colors: [_neonPurple, _neonCyan])
                        .createShader(b),
                    child: Text('$d/$totalHabits',
                        style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            height: 1.0)),
                  ),
                  const SizedBox(width: 4),
                  Text('hoje',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.55), fontSize: 15)),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Text('$pct% da sua meta diária',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.35), fontSize: 11)),
          const SizedBox(height: 12),
          _AnimatedNeonProgress(
            controller: _progressBarController,
            progress: pct / 100.0,
            gradientColors: const [_neonPurple, _neonCyan],
            glowColor: _neonPurple,
          ),
        ],
      ),
    );
  }

  Widget _glowIcon(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  // ============================================================
  // PYRAMID SECTION
  // ============================================================
  Widget _buildPyramidSection() {
    return FadeTransition(
      opacity: _sectionAnimations[2],
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
            .animate(_sectionAnimations[2]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                            colors: [_neonPurple, _neonCyan])),
                  ),
                  const SizedBox(width: 10),
                  Text('Pirâmide de Maslow',
                      style: AppTextStyles.heading2.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 13),
                child: Text('Acompanhe seu progresso em cada nível.',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.35), fontSize: 12)),
              ),
              const SizedBox(height: 20),
              _buildPyramidBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPyramidBody() {
    final progress = _loading ? <int, Map<String, dynamic>>{} : _maslowProgress();
    const defaultPcts = [33, 22, 11, 0, 0];

    return AnimatedBuilder(
      animation: _pyramidController,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final pyramidW = totalWidth * 0.45;
            final cardW = totalWidth - pyramidW - 16;

            return SizedBox(
              height: 420,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Pyramid ──
                  SizedBox(
                    width: pyramidW,
                    height: 420,
                    child: CustomPaint(
                      painter: _MaslowPyramidPainter(
                        colors: _maslowColors,
                        icons: _maslowIcons,
                        progress: _pyramidController.value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ── Level cards ──
                  SizedBox(
                    width: cardW,
                    height: 420,
                    child: Column(
                      children: List.generate(5, (i) {
                        final levelIndex = 4 - i;
                        final levelNum = levelIndex + 1;
                        final pct = _loading
                            ? defaultPcts[levelIndex]
                            : (progress[levelNum]?['pct'] ?? defaultPcts[levelIndex]);
                        final total = _loading
                            ? 0
                            : (progress[levelNum]?['total'] ?? 0);
                        return Expanded(
                          child: _LevelInfoCard(
                            name: _maslowNames[levelIndex],
                            icon: _maslowIcons[levelIndex],
                            color: _maslowColors[levelIndex],
                            percentage: pct,
                            totalHabits: total,
                            animValue: _pyramidController.value,
                            delay: i * 0.1,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ================================================================
// GLASS CONTAINER
// ================================================================
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  const _GlassContainer({required this.child, this.glowColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                  color: glowColor.withOpacity(0.08),
                  blurRadius: 24,
                  spreadRadius: -2),
              BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: -4),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ================================================================
// ANIMATED NEON PROGRESS BAR
// ================================================================
class _AnimatedNeonProgress extends StatelessWidget {
  final AnimationController controller;
  final double progress;
  final List<Color> gradientColors;
  final Color glowColor;

  const _AnimatedNeonProgress({
    required this.controller,
    required this.progress,
    required this.gradientColors,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final ap = progress * controller.value;
        return Column(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white.withOpacity(0.08)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ap,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(colors: gradientColors)),
                ),
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 3,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ap,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                          colors: gradientColors
                              .map((c) => c.withOpacity(0.35))
                              .toList()),
                      boxShadow: [
                        BoxShadow(
                            color: glowColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================================================================
// LEVEL INFO CARD
// ================================================================
class _LevelInfoCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int percentage;
  final int totalHabits;
  final double animValue;
  final double delay;

  const _LevelInfoCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.percentage,
    required this.totalHabits,
    required this.animValue,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final slide = ((animValue - delay).clamp(0.0, 0.6) / 0.6).clamp(0.0, 1.0);
    final opacity =
        ((animValue - delay - 0.05).clamp(0.0, 0.5) / 0.5).clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(20 * (1 - slide), 0),
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(0.05),
              border: Border.all(color: color.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.06), blurRadius: 12),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                    boxShadow: [
                      BoxShadow(
                          color: color.withOpacity(0.25), blurRadius: 6),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      _LevelBar(
                          percentage: percentage,
                          color: color,
                          animValue: slide),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text('$percentage%',
                    style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(color: color.withOpacity(0.5), blurRadius: 6),
                        ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelBar extends StatelessWidget {
  final int percentage;
  final Color color;
  final double animValue;
  const _LevelBar(
      {required this.percentage, required this.color, required this.animValue});

  @override
  Widget build(BuildContext context) {
    final w = (percentage / 100.0) * animValue;
    return Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withOpacity(0.06)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: w,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.6)])),
            ),
          ),
        ),
        if (w > 0)
          Container(
            height: 2,
            margin: const EdgeInsets.only(top: 2),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: w,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    gradient: LinearGradient(colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.05),
                    ])),
              ),
            ),
          ),
      ],
    );
  }
}

// ================================================================
// GRID PAINTER
// ================================================================
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ================================================================
// MASLOW PYRAMID PAINTER — Proper tapered pyramid with neon
// ================================================================
class _MaslowPyramidPainter extends CustomPainter {
  final List<Color> colors;
  final List<IconData> icons;
  final double progress;

  _MaslowPyramidPainter({
    required this.colors,
    required this.icons,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const n = 5;
    const gap = 8.0;
    final totalGap = (n - 1) * gap;
    final levelH = (size.height - totalGap - 20) / n;
    final startY = 20.0;
    final cx = size.width / 2;

    for (int i = 0; i < n; i++) {
      // i=0 = base (widest), i=4 = top (narrowest)
      final color = colors[i];

      // Width fractions: base ~92%, top ~40%
      final topWidthFrac = 0.92 - (i / n) * 0.52;
      final botWidthFrac = 0.92 - ((i + 1) / n) * 0.52;

      final topW = size.width * topWidthFrac;
      final botW = size.width * botWidthFrac;

      final yTop = startY + i * (levelH + gap);
      final yBot = yTop + levelH;

      // Animate: each level fades in with a slight delay
      final lp =
          ((progress - i * 0.08).clamp(0.0, 0.7) / 0.7).clamp(0.0, 1.0);
      if (lp <= 0) continue;

      // Apply animation scale
      final aTopW = topW * lp;
      final aBotW = botW * lp;

      // Trapezoid corners
      final tl = cx - aTopW / 2;
      final tr = cx + aTopW / 2;
      final bl = cx - aBotW / 2;
      final br = cx + aBotW / 2;

      // Build path
      final path = Path()
        ..moveTo(bl, yBot)
        ..lineTo(br, yBot)
        ..lineTo(tr, yTop)
        ..lineTo(tl, yTop)
        ..close();

      // 1) Outer glow
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.15 * lp)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // 2) Fill — dark gradient
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.15 * lp),
              color.withOpacity(0.06 * lp),
              Colors.black.withOpacity(0.20),
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(Rect.fromLTWH(0, yTop, size.width, levelH)),
      );

      // 3) Neon edge stroke
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.55 * lp)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeJoin = StrokeJoin.round,
      );

      // 4) Inner glow
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.20 * lp)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // 5) Top highlight
      if (i > 0 && aTopW > 24) {
        canvas.drawLine(
          Offset(tl + 10, yTop + 1.5),
          Offset(tr - 10, yTop + 1.5),
          Paint()
            ..color = Colors.white.withOpacity(0.25 * lp)
            ..strokeWidth = 1.0
            ..strokeCap = StrokeCap.round,
        );
      }

      // 6) Border
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(0.06 * lp)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // 7) Icon in center
      final cy = (yTop + yBot) / 2;
      _drawGlowIcon(canvas, icons[i], color, cx, cy, lp);

      // 8) Connecting line to cards
      if (lp > 0.5) {
        final lineStart = cx + aBotW / 2 - 2;
        final lineEnd = cx + aBotW / 2 + 22;
        final lineY = cy;

        canvas.drawLine(
          Offset(lineStart, lineY),
          Offset(lineEnd, lineY),
          Paint()
            ..color = color.withOpacity(0.35 * lp)
            ..strokeWidth = 1.5
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          Offset(lineStart, lineY),
          Offset(lineEnd, lineY),
          Paint()
            ..color = color.withOpacity(0.15 * lp)
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  void _drawGlowIcon(
      Canvas canvas, IconData icon, Color color, double cx, double cy, double lp) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: 20,
          color: color.withOpacity(0.5 * lp),
          shadows: [
            Shadow(color: color.withOpacity(0.8 * lp), blurRadius: 12),
            Shadow(color: color.withOpacity(0.4 * lp), blurRadius: 24),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _MaslowPyramidPainter old) =>
      old.progress != progress || old.colors != colors;
}
