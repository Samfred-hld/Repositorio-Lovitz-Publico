import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/habit.dart';

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
  int _selectedLevel = -1; // -1 = none selected
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
      _showSnack('Digite o nome do hábito', _C.neonRed);
      return;
    }
    if (_selectedLevel < 0) {
      _showSnack('Selecione um nível da pirâmide', _C.neonRed);
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
        _showSnack('"$name" criado!', const Color(0xFF6FCF97));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showSnack('Erro: $e', _C.neonRed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: bg));
  }

  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          CustomPaint(
              size: MediaQuery.of(context).size, painter: _GridPainter()),
          SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _C.white80, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Criar Novo Hábito',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _C.neonPink,
                shadows: const [
                  Shadow(color: Color(0xFFBF00FF), blurRadius: 10),
                  Shadow(color: Color(0xBF00FF00), blurRadius: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARD ────────────────────────────────────────────────

  Widget _card() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _C.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _nameInput(),
          const SizedBox(height: 28),
          _frequency(),
          const SizedBox(height: 28),
          _maslow(),
          const SizedBox(height: 32),
          _saveBtn(),
        ],
      ),
    );
  }

  // ─── INPUT ───────────────────────────────────────────────

  Widget _nameInput() {
    return CustomPaint(
      painter: _NeonBorderPainter(
        color: _C.neonPurple,
        radius: 16,
        outerBlur: 10,
        outerOpacity: 0.8,
        insetBlur: 5,
        insetOpacity: 0.5,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _C.inputBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
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
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(height: 12),
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
                  child: active
                      ? CustomPaint(
                          painter: _NeonBorderPainter(
                            color: _C.neonPurple,
                            radius: 100,
                            outerBlur: 8,
                            outerOpacity: 0.7,
                            insetBlur: 4,
                            insetOpacity: 0.4,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _C.cardSolid,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Text(labels[i],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(labels[i],
                                style: const TextStyle(
                                    color: _C.white40,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
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

  // ─── MASLOW ──────────────────────────────────────────────

  Widget _maslow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nível da Pirâmide de Maslow',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(height: 6),
        Text('Toque para selecionar',
            style: TextStyle(
                fontSize: 13, color: Colors.white.withOpacity(0.40))),
        const SizedBox(height: 16),
        // Grid 3+2 layout for better fit
        Column(
          children: [
            Row(
              children: List.generate(3, (i) => Expanded(child: _levelItem(i))),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(flex: 1),
                Expanded(flex: 2, child: _levelItem(3)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _levelItem(4)),
                const Spacer(flex: 1),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _levelItem(int idx) {
    final sel = _selectedLevel == idx;
    final d = _lvls[idx];
    final c = d.color;
    final pct = _levelPcts[idx];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => setState(() => _selectedLevel = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: sel ? c.withOpacity(0.12) : Colors.white.withOpacity(0.03),
            border: Border.all(
              color: sel ? c.withOpacity(0.6) : Colors.white.withOpacity(0.06),
              width: sel ? 2 : 1,
            ),
            boxShadow: sel
                ? [
                    BoxShadow(
                        color: c.withOpacity(0.25), blurRadius: 16, spreadRadius: 1),
                    BoxShadow(
                        color: c.withOpacity(0.10), blurRadius: 32),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with glow when selected
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel
                      ? c.withOpacity(0.15)
                      : Colors.white.withOpacity(0.04),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                              color: c.withOpacity(0.5), blurRadius: 12),
                          BoxShadow(
                              color: c.withOpacity(0.2), blurRadius: 24),
                        ]
                      : [],
                ),
                child: Icon(d.icon,
                    color: sel ? c : c.withOpacity(0.5), size: 24),
              ),
              const SizedBox(height: 8),
              // Label
              Text(
                d.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? c : c.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 2),
              // Percentage
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: sel ? c : c.withOpacity(0.4),
                  shadows: sel
                      ? [
                          Shadow(color: c.withOpacity(0.6), blurRadius: 6),
                        ]
                      : [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── BOTÃO SALVAR ────────────────────────────────────────

  Widget _saveBtn() {
    return GestureDetector(
      onTap: _saving ? null : _save,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: _saving
              ? null
              : LinearGradient(
                  colors: [
                    _C.neonPurple.withOpacity(0.20),
                    _C.neonBlue.withOpacity(0.15),
                  ],
                ),
          border: Border.all(
            color: _saving
                ? _C.neonPurple.withOpacity(0.2)
                : _C.neonPurple.withOpacity(0.7),
            width: 2,
          ),
          boxShadow: _saving
              ? []
              : [
                  BoxShadow(
                      color: _C.neonPurple.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1),
                  BoxShadow(
                      color: _C.neonPurple.withOpacity(0.15),
                      blurRadius: 40),
                ],
        ),
        child: Center(
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _C.neonPurple),
                )
              : const Text(
                  'Salvar Hábito',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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

// ============================================================
// CUSTOM PAINTERS
// ============================================================

class _NeonBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double outerBlur;
  final double outerOpacity;
  final double insetBlur;
  final double insetOpacity;

  _NeonBorderPainter({
    required this.color,
    required this.radius,
    required this.outerBlur,
    required this.outerOpacity,
    required this.insetBlur,
    required this.insetOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    if (outerBlur > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = color.withOpacity(outerOpacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, outerBlur)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withOpacity(outerOpacity),
    );

    if (insetBlur > 0) {
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = color.withOpacity(insetOpacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, insetBlur)
          ..style = PaintingStyle.fill,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _NeonBorderPainter old) =>
      old.color != color || old.outerBlur != outerBlur;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 0.5;
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
