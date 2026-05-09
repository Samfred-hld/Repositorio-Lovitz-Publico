import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/habit.dart';
import '../utils/constants.dart';

// ============================================================
// CORES EXATAS DO HTML (tailwind.config + CSS)
// ============================================================
class _C {
  static const bg = Color(0xFF0C0A18);        // body background
  static const card = Color(0xCC1A162B);       // bg-app-card/80
  static const cardSolid = Color(0xFF1A162B);  // bg-app-card (nav)
  static const inputBg = Color(0x33000000);    // bg-black/20
  static const toggleBg = Color(0xFF120E24);   // bg-[#120e24]
  static const neonPurple = Color(0xFFBF00FF);
  static const neonPink = Color(0xFFD946EF);   // text-[#d946ef]
  static const neonRed = Color(0xFFFF4D4D);
  static const neonOrange = Color(0xFFFFAA00);
  static const neonCyan = Color(0xFF00F2FF);
  static const neonBlue = Color(0xFF007FFF);
  static const white08 = Color(0x14FFFFFF);    // border-white/10
  static const white40 = Color(0x66FFFFFF);    // text-white/40
  static const white60 = Color(0x99FFFFFF);    // text-white/60
  static const white80 = Color(0xCCFFFFFF);    // text-white/80
}

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _nameController = TextEditingController();
  final _api = ApiService();
  int _selectedFrequency = 0; // 0=Diário, 1=Semanal, 2=Personalizado
  int _selectedLevel = 0;     // 0-4 (index), representa nível 1-5
  bool _saving = false;

  // Percentuais reais por nível (carregados do banco)
  final _levelPcts = [0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _loadPcts();
  }

  Future<void> _loadPcts() async {
    try {
      final habits = await _api.getHabits();
      if (!mounted) return;
      setState(() {
        for (int level = 1; level <= 5; level++) {
          final levelHabits =
              habits.where((h) => h.maslowLevel == level).toList();
          final total = levelHabits.length;
          final withProgress =
              levelHabits.where((h) => h.streakCurrent > 0).length;
          _levelPcts[level - 1] =
              total > 0 ? ((withProgress / total) * 100).round() : 0;
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Frequência selecionada → valor do banco
  String get _frequencyValue {
    switch (_selectedFrequency) {
      case 0:
        return 'daily';
      case 1:
        return 'weekly';
      default:
        return 'monthly';
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o nome do hábito'),
          backgroundColor: _C.neonRed,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _api.createHabit(Habit(
        name: name,
        maslowLevel: _selectedLevel + 1,
        habitType: 'qualitative',
        frequency: _frequencyValue,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$name" criado!'),
            backgroundColor: const Color(0xFF6FCF97),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: _C.neonRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─── BUILD ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          // Fundo com grid (igual ao HTML)
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _GridPainter(),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                    child: _buildCard(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER (px-6 pt-12 pb-6) ────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (text-white/80)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _C.white80,
              size: 28,
            ),
          ),

          // Título com neon glow (neon-text-purple + text-[#d946ef])
          Text(
            'Criar Novo Hábito',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _C.neonPink,
              shadows: [
                Shadow(color: _C.neonPurple.withOpacity(1.0), blurRadius: 10),
                Shadow(color: _C.neonPurple.withOpacity(0.8), blurRadius: 20),
                Shadow(color: _C.neonPurple.withOpacity(0.6), blurRadius: 30),
              ],
            ),
          ),

          // Spacer (w-7) para centralizar
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  // ─── CARD PRINCIPAL (bg-app-card/80, rounded-[40px], p-6) ──

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: _C.white08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameInput(),           // mb-8
          const SizedBox(height: 32),
          _buildFrequencySection(),    // mb-8
          const SizedBox(height: 32),
          _buildMaslowSection(),       // mb-10
          const SizedBox(height: 40),
          _buildSaveButton(),          // mt-6
        ],
      ),
    );
  }

  // ─── NOME DO HÁBITO (neon-border-purple, rounded-2xl) ────

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: _C.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _C.neonPurple.withOpacity(0.8),
          width: 2,
        ),
        // neon-border-purple: outer + inset glow
        boxShadow: [
          BoxShadow(
            color: _C.neonPurple.withOpacity(0.8),
            blurRadius: 10,
          ),
          BoxShadow(
            color: _C.neonPurple.withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: -2, // inset effect
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              style: const TextStyle(
                color: _C.white60,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: 'Nome do Hábito',
                hintStyle: const TextStyle(
                  color: _C.white40,
                  fontSize: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          // Ícone de editar (pencil)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.edit_rounded,
              color: _C.white40,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ─── FREQUÊNCIA (rounded-full toggle) ─────────────────────

  Widget _buildFrequencySection() {
    final labels = ['Diário', 'Semanal', 'Personalizado'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título (text-xl, bold, white, mb-4)
        const Text(
          'Frequência',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Container do toggle (bg-[#120e24], border-white/10, rounded-full, p-1)
        Container(
          decoration: BoxDecoration(
            color: _C.toggleBg,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: _C.white08),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(3, (i) {
              final active = _selectedFrequency == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFrequency = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? _C.cardSolid   // bg-[#1a162b]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      border: active
                          ? Border.all(
                              color: _C.neonPurple.withOpacity(0.8),
                              width: 1.5,
                            )
                          : null,
                      // neon-border-purple glow (só ativo)
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: _C.neonPurple.withOpacity(0.8),
                                blurRadius: 10,
                              ),
                              BoxShadow(
                                color: _C.neonPurple.withOpacity(0.5),
                                blurRadius: 5,
                                spreadRadius: -2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          color: active ? Colors.white : _C.white40,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ─── NÍVEIS MASLOW (grid-cols-5, gap-2, glow colors) ─────

  Widget _buildMaslowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título (text-xl, bold, white, mb-6)
        const Text(
          'Nível da Pirâmide de Maslow',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),

        // Grid 5 colunas, gap 8px
        Row(
          children: List.generate(5, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                child: _buildLevelItem(i),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLevelItem(int index) {
    final selected = _selectedLevel == index;
    final data = _levels[index];
    final color = data.color;
    final pct = _levelPcts[index];

    return GestureDetector(
      onTap: () => setState(() => _selectedLevel = index),
      child: Column(
        children: [
          // Container do ícone (w-[52px] h-[52px], rounded-xl, border-2, bg-black/20)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _C.inputBg, // bg-black/20
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color,
                width: 2,
              ),
              // glow-* CSS: outer + inset
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 20,
                ),
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: -4, // inset
                ),
              ],
            ),
            child: Icon(data.icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),

          // Label (text-[10px], center, neon color, leading-tight, semibold)
          Text(
            '${data.label}\n($pct%)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── BOTÃO SALVAR ────────────────────────────────────────

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saving ? null : _save,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: _saving
                ? _C.neonPurple.withOpacity(0.3)
                : _C.neonPurple.withOpacity(0.8),
            width: 2,
          ),
          // btn-save-glow + shadow-[0_0_20px_#bf00ff,inset_0_0_10px_#bf00ff]
          boxShadow: _saving
              ? null
              : [
                  BoxShadow(
                    color: _C.neonPurple.withOpacity(0.9),
                    blurRadius: 25,
                  ),
                  BoxShadow(
                    color: _C.neonPurple.withOpacity(0.5),
                    blurRadius: 40,
                  ),
                  // inset
                  BoxShadow(
                    color: _C.neonPurple.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: -4,
                  ),
                ],
        ),
        child: Center(
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _C.neonPurple,
                  ),
                )
              : const Text(
                  'Salvar Hábito',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  // ─── DADOS DOS NÍVEIS ─────────────────────────────────────

  static const _levels = [
    _LevelData('Fisiológico', Icons.restaurant_rounded, _C.neonRed),
    _LevelData('Segurança', Icons.shield_rounded, _C.neonOrange),
    _LevelData('Pertencimento', Icons.people_rounded, _C.neonCyan),
    _LevelData('Estima', Icons.favorite_rounded, _C.neonBlue),
    _LevelData('Autorrealização', Icons.star_rounded, _C.neonPurple),
  ];
}

class _LevelData {
  final String label;
  final IconData icon;
  final Color color;
  const _LevelData(this.label, this.icon, this.color);
}

// ─── FUNDO COM GRID (igual ao CSS do HTML) ──────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;

    const gridSize = 40.0;

    // Linhas horizontais
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Linhas verticais
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
