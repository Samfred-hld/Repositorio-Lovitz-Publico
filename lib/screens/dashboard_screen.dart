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

  // Animation controllers
  late final AnimationController _fadeController;
  late final AnimationController _streakController;
  late final AnimationController _completedController;
  late final AnimationController _progressBarController;
  late final AnimationController _pyramidController;
  late final AnimationController _pulseController;

  // Staggered section animations
  late final List<Animation<double>> _sectionAnimations;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _completedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pyramidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Staggered animations for each section
    _sectionAnimations = List.generate(5, (i) {
      return CurvedAnimation(
        parent: _fadeController,
        curve: Interval(
          i * 0.12,
          (i * 0.12 + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
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
      // Start animated counters
      _streakController.forward();
      _completedController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _progressBarController.forward();
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _pyramidController.forward();
      });
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
      final levelHabits =
          _habits.where((h) => h.maslowLevel == level).toList();
      final total = levelHabits.length;
      final withProgress =
          levelHabits.where((h) => h.streakCurrent > 0).length;
      final pct = total > 0 ? ((withProgress / total) * 100).round() : 0;
      result[level] = {'total': total, 'pct': pct};
    }
    return result;
  }

  // ─── Neon color palette ───────────────────────────────────
  static const _neonPurple = Color(0xFFBF00FF);
  static const _neonPink = Color(0xFFD946EF);
  static const _neonRed = Color(0xFFFF4D4D);
  static const _neonOrange = Color(0xFFFFAA00);
  static const _neonCyan = Color(0xFF00F2FF);
  static const _neonBlue = Color(0xFF007FFF);
  static const _neonGreen = Color(0xFF39FF14);

  static const _maslowColors = [
    Color(0xFFFFAA00), // Fisiológico — orange
    Color(0xFF39FF14), // Segurança — green
    Color(0xFF00F2FF), // Pertencimento — cyan
    Color(0xFF007FFF), // Estima — blue
    Color(0xFFBF00FF), // Autorrealização — purple
  ];

  // ─── Maslow icons (outline style) ─────────────────────────
  static const _maslowIcons = [
    Icons.local_fire_department_rounded, // Fisiológico
    Icons.shield_rounded, // Segurança
    Icons.people_rounded, // Pertencimento
    Icons.emoji_events_rounded, // Estima
    Icons.auto_awesome_rounded, // Autorrealização
  ];

  static const _maslowNames = [
    'Fisiológico',
    'Segurança',
    'Pertencimento',
    'Estima',
    'Autorrealização',
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Deep background gradient
          _buildBackground(),
          // Content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: _neonCyan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildStatsSection(),
                    const SizedBox(height: 32),
                    _buildPyramidSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildNeonBottomNav(),
    );
  }

  // ============================================================
  // BACKGROUND — Deep blue-black with spatial gradient + grid
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
      child: CustomPaint(
        painter: _GridBackgroundPainter(),
        size: Size.infinite,
      ),
    );
  }

  // ============================================================
  // HEADER — Title gradient + avatar + bell
  // ============================================================

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _sectionAnimations[0],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(_sectionAnimations[0]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gradient title with glow
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFBF00FF), // purple
                          Color(0xFF007FFF), // blue
                          Color(0xFF00F2FF), // cyan
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'Habit Tracker',
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: _neonPurple.withOpacity(0.5),
                              blurRadius: 20,
                            ),
                            Shadow(
                              color: _neonBlue.withOpacity(0.3),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sua jornada de crescimento começa com pequenos hábitos.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar with neon gradient border + online indicator
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  children: [
                    // Neon gradient border
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_neonPurple, _neonCyan],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _neonPurple.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 43,
                          height: 43,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1A162B),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    // Pulsing online indicator
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale =
                              1.0 + (_pulseController.value * 0.3);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _neonGreen,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        _neonGreen.withOpacity(0.6 + _pulseController.value * 0.3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
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
              // Bell icon with cyan glow
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _neonCyan.withOpacity(0.15),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: _neonCyan.withOpacity(0.85),
                        size: 22,
                      ),
                    ),
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
                              blurRadius: 4,
                            ),
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
  // STATS SECTION — Two glassmorphism cards
  // ============================================================

  Widget _buildStatsSection() {
    return FadeTransition(
      opacity: _sectionAnimations[1],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(_sectionAnimations[1]),
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

  // ─── Streak Card ──────────────────────────────────────────

  Widget _buildStreakCard() {
    final currentStreak = _habits.fold<int>(
      0,
      (max, h) => h.streakCurrent > max ? h.streakCurrent : max,
    );
    final bestStreak = _habits.fold<int>(
      0,
      (max, h) => h.streakBest > max ? h.streakBest : max,
    );

    return _GlassContainer(
      glowColor: _neonOrange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fire icon with glow
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _neonOrange.withOpacity(0.12),
              boxShadow: [
                BoxShadow(
                  color: _neonOrange.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: _neonOrange,
              size: 20,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Sequência atual',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          // Animated counter value
          AnimatedBuilder(
            animation: _streakController,
            builder: (context, _) {
              final display =
                  (currentStreak * _streakController.value).round();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [_neonOrange, const Color(0xFFFFD700)],
                    ).createShader(bounds),
                    child: Text(
                      '$display',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'dias',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Melhor sequência: $bestStreak dias',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Completed Card ───────────────────────────────────────

  Widget _buildCompletedCard() {
    final completedToday = _stats['completed_today'] ?? 0;
    final totalHabits = _stats['active_habits'] ?? 0;
    final pct = totalHabits > 0
        ? ((completedToday / totalHabits) * 100).round()
        : 0;

    return _GlassContainer(
      glowColor: _neonPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Check icon with glow
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _neonPurple.withOpacity(0.12),
              boxShadow: [
                BoxShadow(
                  color: _neonPurple.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: _neonPurple,
              size: 20,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Hábitos concluídos',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          // Animated counter
          AnimatedBuilder(
            animation: _completedController,
            builder: (context, _) {
              final displayC =
                  (completedToday * _completedController.value).round();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [_neonPurple, _neonCyan],
                    ).createShader(bounds),
                    child: Text(
                      '$displayC/$totalHabits',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'hoje',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            '$pct% da sua meta diária',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          // Animated neon progress bar
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

  // ============================================================
  // PYRAMID SECTION — 3D isometric Maslow pyramid
  // ============================================================

  Widget _buildPyramidSection() {
    return FadeTransition(
      opacity: _sectionAnimations[2],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(_sectionAnimations[2]),
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
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_neonPurple, _neonCyan],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pirâmide de Maslow',
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 13),
                child: Text(
                  'Acompanhe seu progresso em cada nível.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildPyramidWithLevels(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPyramidWithLevels() {
    final progress = _loading ? <int, Map<String, dynamic>>{} : _maslowProgress();
    // Default values when no data
    final defaultPcts = [33, 22, 11, 0, 0];

    return AnimatedBuilder(
      animation: _pyramidController,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final pyramidWidth = totalWidth * 0.42;
            final cardAreaWidth = totalWidth - pyramidWidth - 16;

            return SizedBox(
              height: 400,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pyramid canvas
                  SizedBox(
                    width: pyramidWidth,
                    height: 400,
                    child: CustomPaint(
                      painter: _NeonPyramidPainter(
                        colors: _maslowColors,
                        icons: _maslowIcons,
                        progress: _pyramidController.value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Level info cards
                  SizedBox(
                    width: cardAreaWidth,
                    height: 400,
                    child: Column(
                      children: List.generate(5, (i) {
                        final levelIndex = 4 - i; // top to bottom
                        final levelNum = levelIndex + 1;
                        final pct = _loading
                            ? defaultPcts[levelIndex]
                            : (progress[levelNum]?['pct'] ??
                                defaultPcts[levelIndex]);
                        final total = _loading
                            ? 0
                            : (progress[levelNum]?['total'] ?? 0);
                        final color = _maslowColors[levelIndex];
                        final icon = _maslowIcons[levelIndex];
                        final name = _maslowNames[levelIndex];

                        return Expanded(
                          child: _LevelInfoCard(
                            name: name,
                            icon: icon,
                            color: color,
                            percentage: pct,
                            totalHabits: total,
                            animationValue: _pyramidController.value,
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

  // ============================================================
  // BOTTOM NAV — Neon themed
  // ============================================================

  Widget _buildNeonBottomNav() {
    return FadeTransition(
      opacity: _sectionAnimations[3],
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A1A).withOpacity(0.92),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home', isActive: true),
                _buildNavItem(
                    1, Icons.check_circle_outline_rounded, 'Hábitos'),
                _buildNavItem(2, Icons.trending_up_rounded, 'Stats'),
                _buildNavItem(3, Icons.person_outline_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label,
      {bool isActive = false}) {
    final color = isActive ? _neonCyan : Colors.white.withOpacity(0.35);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Luminous line above active tab
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 28 : 0,
              height: 2,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: _neonCyan,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: _neonCyan.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
            if (isActive)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _neonCyan,
                  boxShadow: [
                    BoxShadow(
                      color: _neonCyan.withOpacity(0.6),
                      blurRadius: 4,
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

// ================================================================
// GLASS CONTAINER — Glassmorphism effect
// ================================================================

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;

  const _GlassContainer({required this.child, this.glowColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
      ),
      child: ClipRRect(
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
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: [
                // Outer glow
                BoxShadow(
                  color: glowColor.withOpacity(0.08),
                  blurRadius: 24,
                  spreadRadius: -2,
                ),
                // Inner shadow simulation
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: child,
          ),
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
      builder: (context, _) {
        final animatedProgress = progress * controller.value;
        return Column(
          children: [
            // Main bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white.withOpacity(0.08),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: animatedProgress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Glow underneath
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 3,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: gradientColors
                            .map((c) => c.withOpacity(0.35))
                            .toList(),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
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
// LEVEL INFO CARD — Connected to pyramid level
// ================================================================

class _LevelInfoCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int percentage;
  final int totalHabits;
  final double animationValue;
  final double delay;

  const _LevelInfoCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.percentage,
    required this.totalHabits,
    required this.animationValue,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnim =
        ((animationValue - delay).clamp(0.0, 0.6) / 0.6).clamp(0.0, 1.0);
    final opacityAnim =
        ((animationValue - delay - 0.05).clamp(0.0, 0.5) / 0.5)
            .clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(20 * (1 - slideAnim), 0),
      child: Opacity(
        opacity: opacityAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(0.05),
              border: Border.all(
                color: color.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon with glow
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const SizedBox(width: 10),
                // Name and progress bar
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Neon progress bar
                      _LevelProgressBar(
                        percentage: percentage,
                        color: color,
                        animationValue: slideAnim,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Percentage
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelProgressBar extends StatelessWidget {
  final int percentage;
  final Color color;
  final double animationValue;

  const _LevelProgressBar({
    required this.percentage,
    required this.color,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    final animatedWidth = (percentage / 100.0) * animationValue;

    return Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.white.withOpacity(0.06),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: animatedWidth,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.6)],
                ),
              ),
            ),
          ),
        ),
        // Glow line
        if (animatedWidth > 0)
          Container(
            height: 2,
            margin: const EdgeInsets.only(top: 2),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: animatedWidth,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ================================================================
// GRID BACKGROUND PAINTER — Subtle grid pattern
// ================================================================

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.5;

    const gridSize = 40.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ================================================================
// NEON PYRAMID PAINTER — 3D isometric with glow effects
// ================================================================

class _NeonPyramidPainter extends CustomPainter {
  final List<Color> colors;
  final List<IconData> icons;
  final double progress;

  _NeonPyramidPainter({
    required this.colors,
    required this.icons,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;
    const n = 5;
    const gap = 8.0;
    final totalGap = (n - 1) * gap;
    final levelHeight = (H - totalGap - 30) / n; // leave space at top
    final startY = 30.0; // offset from top

    for (int i = 0; i < n; i++) {
      // i=0 is base (widest), i=n-1 is top (narrowest)
      final color = colors[i];
      final icon = icons[i];

      final topFrac = i / n;
      final botFrac = (i + 1) / n;
      final topWidth = W * (0.92 - topFrac * 0.52);
      final botWidth = W * (0.92 - botFrac * 0.52);

      final yTop = startY + i * (levelHeight + gap);
      final yBot = yTop + levelHeight;

      // Animate with progress
      final levelProgress =
          ((progress - i * 0.08).clamp(0.0, 0.7) / 0.7).clamp(0.0, 1.0);
      if (levelProgress <= 0) continue;

      final path = _trapezoid(
        totalWidth: W,
        top: yTop,
        bottom: yBot,
        topWidth: topWidth * levelProgress,
        bottomWidth: botWidth * levelProgress,
        radius: 12,
      );

      // Layer 1: Outer glow — bright neon
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.15 * levelProgress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Layer 2: Fill — dark with subtle gradient
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.12 * levelProgress),
              color.withOpacity(0.06 * levelProgress),
              Colors.black.withOpacity(0.20),
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(Rect.fromLTWH(0, yTop, W, levelHeight)),
      );

      // Layer 3: Neon edge stroke — bright
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.55 * levelProgress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeJoin = StrokeJoin.round,
      );

      // Layer 4: Inner glow on edges
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.20 * levelProgress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Layer 5: Top highlight line
      if (i > 0) {
        final hl = W / 2 - topWidth / 2 + 12;
        final hr = W / 2 + topWidth / 2 - 12;
        if (hr > hl) {
          canvas.drawLine(
            Offset(hl, yTop + 1.5),
            Offset(hr, yTop + 1.5),
            Paint()
              ..color = Colors.white.withOpacity(0.25 * levelProgress)
              ..strokeWidth = 1.0
              ..strokeCap = StrokeCap.round,
          );
        }
      }

      // Layer 6: Subtle border
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(0.06 * levelProgress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Icon in center with glow
      final cx = W / 2;
      final cy = (yTop + yBot) / 2;

      // Icon glow
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontFamily: icon.fontFamily,
            fontSize: 22,
            color: color.withOpacity(0.30 * levelProgress),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Draw glow (blurred shadow)
      canvas.save();
      canvas.translate(cx - iconPainter.width / 2, cy - iconPainter.height / 2);
      final glowPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontFamily: icon.fontFamily,
            fontSize: 22,
            color: color.withOpacity(0.5 * levelProgress),
            shadows: [
              Shadow(
                color: color.withOpacity(0.8 * levelProgress),
                blurRadius: 12,
              ),
              Shadow(
                color: color.withOpacity(0.4 * levelProgress),
                blurRadius: 24,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      glowPainter.paint(canvas, Offset.zero);
      canvas.restore();

      // Draw icon on top
      iconPainter.paint(
        canvas,
        Offset(cx - iconPainter.width / 2, cy - iconPainter.height / 2),
      );

      // Draw connecting line from right edge to card area
      if (levelProgress > 0.5) {
        final lineStartX = W / 2 + botWidth / 2 * levelProgress - 4;
        final lineEndX = W / 2 + botWidth / 2 * levelProgress + 20;
        final lineY = cy;

        // Neon connecting line
        canvas.drawLine(
          Offset(lineStartX, lineY),
          Offset(lineEndX, lineY),
          Paint()
            ..color = color.withOpacity(0.35 * levelProgress)
            ..strokeWidth = 1.5
            ..strokeCap = StrokeCap.round,
        );

        // Glow on line
        canvas.drawLine(
          Offset(lineStartX, lineY),
          Offset(lineEndX, lineY),
          Paint()
            ..color = color.withOpacity(0.15 * levelProgress)
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  Path _trapezoid({
    required double totalWidth,
    required double top,
    required double bottom,
    required double topWidth,
    required double bottomWidth,
    required double radius,
  }) {
    final cx = totalWidth / 2;
    final tl = cx - topWidth / 2;
    final tr = cx + topWidth / 2;
    final bl = cx - bottomWidth / 2;
    final br = cx + bottomWidth / 2;

    final path = Path();
    path.moveTo(bl + radius, bottom);
    path.lineTo(br - radius, bottom);
    path.arcToPoint(
      Offset(br, bottom - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(tr, top + radius);
    path.arcToPoint(
      Offset(tr - radius, top),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(tl + radius, top);
    path.arcToPoint(
      Offset(tl, top + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(bl, bottom - radius);
    path.arcToPoint(
      Offset(bl + radius, bottom),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _NeonPyramidPainter old) =>
      old.progress != progress || old.colors != colors;
}
