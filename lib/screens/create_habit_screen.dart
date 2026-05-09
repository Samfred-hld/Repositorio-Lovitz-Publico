import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/habit.dart';
import '../utils/constants.dart';

// ============================================================
// CORES EXATAS DO HTML
// ============================================================
class _C {
  static const bg = Color(0xFF0C0A18);
  static const card = Color(0xCC1A162B);
  static const cardSolid = Color(0xFF1A162B);
  static const inputBg = Color(0x33000000);
  static const toggleBg = Color(0xFF120E24);
  static const neonPurple = Color(0xFFBF00FF);
  static const neonPink = Color(0xFFD946EF);
  static const neonRed = Color(0xFFFF4D4D);
  static const neonOrange = Color(0xFFFFAA00);
  static const neonCyan = Color(0xFF00F2FF);
  static const neonBlue = Color(0xFF007FFF);
  static const white08 = Color(0x14FFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const white40 = Color(0x66FFFFFF);
  static const white60 = Color(0x99FFFFFF);
  static const white80 = Color(0xCCFFFFFF);
}

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _nameController = TextEditingController();
  final _api = ApiService();
  int _selectedFrequency = 0;
  int _selectedLevel = 0;
  bool _saving = false;
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
          final lh = habits.where((h) => h.maslowLevel == level).toList();
          final t = lh.length;
          final w = lh.where((h) => h.streakCurrent > 0).length;
          _levelPcts[level - 1] = t > 0 ? ((w / t) * 100).round() : 0;
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _freqVal => ['daily', 'weekly', 'monthly'][_selectedFrequency];

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome do hábito'), backgroundColor: _C.neonRed),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _api.createHabit(Habit(
        name: name,
        maslowLevel: _selectedLevel + 1,
        habitType: 'qualitative',
        frequency: _freqVal,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$name" criado!'), backgroundColor: const Color(0xFF6FCF97)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: _C.neonRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          CustomPaint(size: MediaQuery.of(context).size, painter: _GridPainter()),
          SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _card(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: _C.white80, size: 28),
          ),
          // Título com glow neon forte (3 layers)
          Text(
            'Criar Novo Hábito',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _C.neonPink,
              shadows: [
                Shadow(color: const Color(0xFFBF00FF), blurRadius: 10),
                Shadow(color: const Color(0xBF00FF00), blurRadius: 20),
                Shadow(color: const Color(0x99BF00FF), blurRadius: 30),
                // Halos extras para intensidade
                Shadow(color: const Color(0xFFBF00FF), blurRadius: 4),
                Shadow(color: const Color(0xFFBF00FF), blurRadius: 40),
              ],
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  // ─── CARD ────────────────────────────────────────────────

  Widget _card() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: _C.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _nameInput(),
          const SizedBox(height: 32),
          _frequency(),
          const SizedBox(height: 32),
          _maslow(),
          const SizedBox(height: 40),
          _saveBtn(),
        ],
      ),
    );
  }

  // ─── INPUT (neon-border-purple EXATO) ────────────────────
  // CSS: box-shadow: 0 0 10px rgba(191,0,255,0.8), inset 0 0 5px rgba(191,0,255,0.5)
  // border-color: rgba(191,0,255,0.8)

  Widget _nameInput() {
    return Container(
      decoration: BoxDecoration(
        color: _C.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.neonPurple.withOpacity(0.8), width: 2),
        // Outer glow
        boxShadow: [
          BoxShadow(color: _C.neonPurple.withOpacity(0.8), blurRadius: 10),
          BoxShadow(color: _C.neonPurple.withOpacity(0.6), blurRadius: 20),
        ],
      ),
      child: Stack(
        children: [
          // Inset glow simulado com container interno
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: RadialGradient(
                colors: [
                  _C.neonPurple.withOpacity(0.15),
                  _C.neonPurple.withOpacity(0.0),
                ],
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: _C.white60, fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: 'Nome do Hábito',
                    hintStyle: TextStyle(color: _C.white40, fontSize: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.edit_rounded, color: _C.white40, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── FREQUÊNCIA ──────────────────────────────────────────

  Widget _frequency() {
    const labels = ['Diário', 'Semanal', 'Personalizado'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequência',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 16),
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
                      color: active ? _C.cardSolid : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      border: active
                          ? Border.all(color: _C.neonPurple.withOpacity(0.8), width: 1.5)
                          : null,
                      boxShadow: active
                          ? [
                              BoxShadow(color: _C.neonPurple.withOpacity(0.8), blurRadius: 10),
                              BoxShadow(color: _C.neonPurple.withOpacity(0.5), blurRadius: 20),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(labels[i],
                          style: TextStyle(
                            color: active ? Colors.white : _C.white40,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )),
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

  // ─── MASLOW (glow-* EXATO do CSS) ───────────────────────
  // glow-red: box-shadow: 0 0 20px rgba(255,77,77,0.6), inset 0 0 10px rgba(255,77,77,0.4)

  Widget _maslow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nível da Pirâmide de Maslow',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 24),
        Row(
          children: List.generate(5, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                child: _levelItem(i),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _levelItem(int idx) {
    final sel = _selectedLevel == idx;
    final d = _lvls[idx];
    final c = d.color;
    final pct = _levelPcts[idx];

    return GestureDetector(
      onTap: () => setState(() => _selectedLevel = idx),
      child: Column(
        children: [
          // Container com glow forte + inset simulado
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _C.inputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c, width: 2),
              // OUTER GLOW (blur 20, opacity 0.6)
              boxShadow: [
                BoxShadow(color: c.withOpacity(0.6), blurRadius: 20),
                BoxShadow(color: c.withOpacity(0.4), blurRadius: 30),
                BoxShadow(color: c.withOpacity(0.8), blurRadius: 6),
              ],
            ),
            child: Stack(
              children: [
                // INSET GLOW simulado
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: RadialGradient(
                      colors: [
                        c.withOpacity(0.25),
                        c.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      center: Alignment.center,
                      radius: 0.9,
                    ),
                  ),
                ),
                Center(child: Icon(d.icon, color: c, size: 28)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Label com cor vibrante
          Text(
            '${d.label}\n($pct%)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: c,
              height: 1.3,
              // Text glow para labels
              shadows: [
                Shadow(color: c.withOpacity(0.8), blurRadius: 6),
                Shadow(color: c.withOpacity(0.4), blurRadius: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── BOTÃO SALVAR ────────────────────────────────────────
  // CSS: border-neon-purple, btn-save-glow (0 0 25px 0.9, 0 0 40px 0.5)
  // + shadow-[0_0_20px_#bf00ff,inset_0_0_10px_#bf00ff]

  Widget _saveBtn() {
    return GestureDetector(
      onTap: _saving ? null : _save,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: _saving ? _C.neonPurple.withOpacity(0.3) : _C.neonPurple.withOpacity(0.8),
            width: 2,
          ),
          boxShadow: _saving
              ? null
              : [
                  // btn-save-glow: 0 0 25px 0.9
                  BoxShadow(color: _C.neonPurple.withOpacity(0.9), blurRadius: 25),
                  // btn-save-glow: 0 0 40px 0.5
                  BoxShadow(color: _C.neonPurple.withOpacity(0.5), blurRadius: 40),
                  // shadow: 0 0 20px #bf00ff
                  BoxShadow(color: _C.neonPurple.withOpacity(0.7), blurRadius: 20),
                  // Halo externo
                  BoxShadow(color: _C.neonPurple.withOpacity(0.3), blurRadius: 60),
                ],
        ),
        child: Stack(
          children: [
            // Inset glow no botão
            if (!_saving)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: RadialGradient(
                    colors: [
                      _C.neonPurple.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    center: Alignment.center,
                    radius: 1.5,
                  ),
                ),
              ),
            Center(
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _C.neonPurple),
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
          ],
        ),
      ),
    );
  }

  // ─── DADOS ───────────────────────────────────────────────

  static const _lvls = [
    _Lv('Fisiológico', Icons.restaurant_rounded, _C.neonRed),
    _Lv('Segurança', Icons.shield_rounded, _C.neonOrange),
    _Lv('Pertencimento', Icons.people_rounded, _C.neonCyan),
    _Lv('Estima', Icons.favorite_rounded, _C.neonBlue),
    _Lv('Autorrealização', Icons.star_rounded, _C.neonPurple),
  ];
}

class _Lv {
  final String label;
  final IconData icon;
  final Color color;
  const _Lv(this.label, this.icon, this.color);
}

// ─── GRID BACKGROUND ──────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.08)..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
