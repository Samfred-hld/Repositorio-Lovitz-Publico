import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/maslow_pyramid_painter.dart';
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

  // Níveis da pirâmide de Maslow (base → topo)
  static const List<MaslowLevel> _maslowLevels = [
    MaslowLevel(
      label: 'Fisiológico',
      percentage: '33%',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.maslowFisiologico,
    ),
    MaslowLevel(
      label: 'Segurança',
      percentage: '22%',
      icon: Icons.shield_rounded,
      color: AppColors.maslowSeguranca,
    ),
    MaslowLevel(
      label: 'Pertencimento',
      percentage: '11%',
      icon: Icons.people_rounded,
      color: AppColors.maslowPertencimento,
    ),
    MaslowLevel(
      label: 'Estima',
      percentage: '0%',
      icon: Icons.emoji_emotions_rounded,
      color: AppColors.maslowEstima,
    ),
    MaslowLevel(
      label: 'Autorrealização',
      percentage: '0%',
      icon: Icons.auto_awesome_rounded,
      color: AppColors.maslowAutorealizacao,
    ),
  ];

  static const List<String> _maslowEmojis = ['🔥', '🛡️', '❤️', '⭐', '🌟'];

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSummaryCards(),
                const SizedBox(height: 32),
                _buildMaslowSection(),
                const SizedBox(height: 24),
                _buildContinueJourney(),
                SizedBox(
                  height:
                      MediaQuery.of(context).padding.bottom + 80,
                ),
              ],
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

  // ─── CARDS DE RESUMO ──────────────────────────────────────────
  Widget _buildSummaryCards() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppColors.accentOrange,
              label: 'Sequência atual',
              value: '12',
              subtext: 'dias',
              valueColor: Color(0xFFE040FB),
              footer: 'Melhor sequência: 28 dias',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.primary,
              label: 'Hábitos concluídos',
              value: '7/9',
              subtext: 'hoje',
              valueColor: AppColors.primary,
              footer: '78% da sua meta diária',
            ),
          ),
        ],
      ),
    );
  }

  // ─── SEÇÃO PIRÂMIDE DE MASLOW ────────────────────────────────
  Widget _buildMaslowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pirâmide de Maslow',
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Acompanhe seu progresso em cada nível.',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildMaslowPyramid(),
        ),
      ],
    );
  }

  Widget _buildMaslowPyramid() {
    const pyramidHeight = 340.0;

    return SizedBox(
      height: pyramidHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final pyramidWidth = totalWidth * 0.55;
          final labelsWidth = totalWidth - pyramidWidth - 16;

          // Levels from top (narrow) to base (wide) for the painter
          final reversedLevels = _maslowLevels.reversed.toList();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PIRÂMIDE ──
              SizedBox(
                width: pyramidWidth,
                height: pyramidHeight,
                child: CustomPaint(
                  painter: MaslowPyramidPainter(levels: reversedLevels),
                ),
              ),

              const SizedBox(width: 16),

              // ── LABELS + CÍRCULOS DE PROGRESSO ──
              SizedBox(
                width: labelsWidth,
                height: pyramidHeight,
                child: Column(
                  children: List.generate(5, (i) {
                    // Match pyramid level order (base=0 to top=4 in painter)
                    final level = _maslowLevels[4 - i];
                    final emoji = _maslowEmojis[4 - i];
                    final pctValue =
                        int.tryParse(level.percentage.replaceAll('%', '')) ?? 0;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MaslowDetailScreen(level: level),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              // Emoji
                              Text(emoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),

                              // Label
                              Expanded(
                                child: Text(
                                  level.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Circular progress
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
    );
  }

  // ─── CONTINUE SUA JORNADA ────────────────────────────────────
  Widget _buildContinueJourney() {
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
            // Large circular progress
            _ProgressCircle(
              percentage: 78,
              color: AppColors.accentSuccess,
              size: 64,
              strokeWidth: 6,
              showLabel: true,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue sua jornada',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '7 de 9 hábitos concluídos hoje. Faltam apenas 2!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Meta badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: AppColors.primaryLight,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Meta: 9/9 hábitos',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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

// ─── WIDGET: CARD DE RESUMO ─────────────────────────────────────
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
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subtext,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            footer,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── WIDGET: CÍRCULO DE PROGRESSO ───────────────────────────────
class _ProgressCircle extends StatelessWidget {
  final int percentage;
  final Color color;
  final double size;
  final double strokeWidth;
  final bool showLabel;

  const _ProgressCircle({
    required this.percentage,
    required this.color,
    this.size = 40,
    this.strokeWidth = 4,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          // Progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressCirclePainter(
              percentage: percentage,
              color: color,
              strokeWidth: strokeWidth,
            ),
          ),
          // Label
          Text(
            '$percentage%',
            style: TextStyle(
              color: Colors.white,
              fontSize: showLabel ? 14 : 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    if (percentage > 0) {
      final sweepAngle = 2 * 3.14159265 * (percentage / 100);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159265 / 2, // start from top
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
