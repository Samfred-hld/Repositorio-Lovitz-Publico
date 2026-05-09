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
                SizedBox(
                    height: MediaQuery.of(context).padding.bottom +
                        80), // espaço para o bottom nav
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
          // Título + subtítulo
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
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6040C0),
                  Color(0xFF8B70E8),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Sino de notificação
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
        _buildMaslowPyramid(),
      ],
    );
  }

  Widget _buildMaslowPyramid() {
    final reversedLevels = _maslowLevels.reversed.toList(); // topo → base
    const pyramidHeight = 320.0;
    const levelCount = 5;
    const gap = MaslowPyramidPainter.gap;
    final levelDrawH = (pyramidHeight - (levelCount - 1) * gap) / levelCount;

    return SizedBox(
      height: pyramidHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          // Pirâmide ocupa 65% da largura total
          final pyramidWidth = totalWidth * 0.65;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // ── 1. PIRÂMIDE ──────────────────────────────────────────
              Positioned(
                left: 0,
                top: 0,
                width: pyramidWidth,
                height: pyramidHeight,
                child: CustomPaint(
                  painter: MaslowPyramidPainter(levels: reversedLevels),
                ),
              ),

              // ── 2. LABELS — cada uma começa na borda direita do SEU nível ─
              ...List.generate(levelCount, (i) {
                final level = reversedLevels[i];
                final yTop = i * (levelDrawH + gap);

                // Borda direita do nível i na sua posição dentro de pyramidWidth:
                // right_edge = (pyramidWidth / 2) * (1 + (i + 0.5) / levelCount)
                // Pequena sobreposição de 6px para ancorar no trapézio
                final tMid = (i + 0.5) / levelCount;
                final labelLeft = (pyramidWidth / 2) * (1 + tMid) - 6;

                return Positioned(
                  left: labelLeft,
                  right: 0,
                  top: yTop + 5,
                  height: levelDrawH - 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12122A).withOpacity(0.88),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.07),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          level.label,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.80),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          level.percentage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // ── 3. ÍCONES — centrados em cada nível da pirâmide ──────
              ...List.generate(levelCount, (i) {
                final level = reversedLevels[i];
                final yTop = i * (levelDrawH + gap);
                // Centro exato do nível (sem offset arbitrário)
                final yCenter = yTop + levelDrawH / 2;
                final xCenter = pyramidWidth / 2;

                return Positioned(
                  left: xCenter - 18,
                  top: yCenter - 18,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MaslowDetailScreen(level: level),
                      ),
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: level.color.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: level.color.withOpacity(0.70),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: level.color.withOpacity(0.45),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(level.icon, color: Colors.white, size: 20),
                    ),
                  ),
                );
              }),
            ],
          );
        },
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
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
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
