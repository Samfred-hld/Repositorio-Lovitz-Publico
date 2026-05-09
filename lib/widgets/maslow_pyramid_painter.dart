import 'package:flutter/material.dart';

class MaslowPyramidPainter extends CustomPainter {
  final List<MaslowLevel> levels;
  static const double gap = 5.0;

  const MaslowPyramidPainter({required this.levels});

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;
    final n = levels.length;

    // Altura de cada nível com gaps
    final lh = (H - (n - 1) * gap) / n;

    for (int i = 0; i < n; i++) {
      final level = levels[i];

      // Y de desenho (com gaps)
      final yTop = i * (lh + gap);
      final yBot = yTop + lh;

      // Larguras via geometria de pirâmide simétrica:
      // apex = (W/2, 0), base corners = (0, H) e (W, H)
      // Largura em y proporcional = W * (y / H)
      final leftTop  = W / 2 * (1.0 - i.toDouble() / n);
      final rightTop = W / 2 * (1.0 + i.toDouble() / n);
      final leftBot  = W / 2 * (1.0 - (i + 1).toDouble() / n);
      final rightBot = W / 2 * (1.0 + (i + 1).toDouble() / n);

      final path = Path();
      if (i == 0) {
        // Triângulo: apex na ponta superior central
        path.moveTo(W / 2, yTop);
        path.lineTo(rightBot, yBot);
        path.lineTo(leftBot, yBot);
      } else {
        // Trapézio
        path.moveTo(leftTop, yTop);
        path.lineTo(rightTop, yTop);
        path.lineTo(rightBot, yBot);
        path.lineTo(leftBot, yBot);
      }
      path.close();

      // Gradiente: claro no topo, cor base, levemente escuro na base
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lighten(level.color, 0.18),
            level.color,
            _darken(level.color, 0.10),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, yTop, W, lh))
        ..style = PaintingStyle.fill;

      // Glow simulado com múltiplos strokes (funciona em Flutter Web HTML renderer)
      const glowStops = [
        (strokeWidth: 18.0, opacity: 0.07),
        (strokeWidth: 12.0, opacity: 0.14),
        (strokeWidth:  6.0, opacity: 0.28),
        (strokeWidth:  2.0, opacity: 0.65),
      ];
      for (final stop in glowStops) {
        canvas.drawPath(path, Paint()
          ..color = level.color.withOpacity(stop.opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stop.strokeWidth
          ..strokeJoin = StrokeJoin.round);
      }

      // Fill principal
      canvas.drawPath(path, fillPaint);

      // Highlight na borda superior (exceto no triângulo, onde é só um ponto)
      if (i > 0) {
        canvas.drawLine(
          Offset(leftTop, yTop),
          Offset(rightTop, yTop),
          Paint()
            ..color = Colors.white.withOpacity(0.35)
            ..strokeWidth = 1.5
            ..strokeCap = StrokeCap.round,
        );
      }

      // Borda lateral suave
      canvas.drawPath(path, Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0);
    }
  }

  @override
  bool shouldRepaint(covariant MaslowPyramidPainter old) =>
      old.levels != levels;
}

class MaslowLevel {
  final String label;
  final String percentage;
  final IconData icon;
  final Color color;

  const MaslowLevel({
    required this.label,
    required this.percentage,
    required this.icon,
    required this.color,
  });
}
