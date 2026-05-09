import 'package:flutter/material.dart';

/// Painter customizado para a Pirâmide de Maslow.
/// Desenha 5 níveis: topo = triângulo, os outros 4 = trapézios.
class MaslowPyramidPainter extends CustomPainter {
  final List<MaslowLevel> levels;

  MaslowPyramidPainter({required this.levels});

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
    final totalHeight = size.height;
    final totalWidth = size.width;
    final levelCount = levels.length;

    // Cada nível ocupa 1/5 da altura (com gap)
    const double levelGap = 5.0;
    final adjustedLevelHeight = (totalHeight - (levelGap * (levelCount - 1))) / levelCount;

    // Largura do topo (estreita) e da base (largura total)
    final topWidth = totalWidth * 0.18;
    final bottomWidth = totalWidth * 0.95;

    for (int i = 0; i < levelCount; i++) {
      final level = levels[i];
      final y = i * (adjustedLevelHeight + levelGap);

      // Largura proporcional: topo estreito, base larga
      final currentTopWidth =
          topWidth + (bottomWidth - topWidth) * (i / (levelCount - 1));
      final currentBottomWidth = topWidth +
          (bottomWidth - topWidth) * ((i + 1) / (levelCount - 1));

      final centerX = totalWidth / 2;

      // Pontos do polígono (trapézio ou triângulo no topo)
      final path = Path();
      if (i == 0) {
        // Topo: triângulo
        path.moveTo(centerX, y); // ponta superior
        path.lineTo(centerX + currentBottomWidth / 2, y + adjustedLevelHeight);
        path.lineTo(centerX - currentBottomWidth / 2, y + adjustedLevelHeight);
        path.close();
      } else {
        // Trapézio
        path.moveTo(centerX - currentTopWidth / 2, y);
        path.lineTo(centerX + currentTopWidth / 2, y);
        path.lineTo(centerX + currentBottomWidth / 2, y + adjustedLevelHeight);
        path.lineTo(centerX - currentBottomWidth / 2, y + adjustedLevelHeight);
        path.close();
      }

      // Preencher com gradiente
      final rect = Rect.fromLTWH(0, y, totalWidth, adjustedLevelHeight);
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _lighten(level.color, 0.15),
          level.color,
          _darken(level.color, 0.12),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final fillPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      // Glow 1: interno
      final glowPaint = Paint()
        ..color = level.color.withOpacity(0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0;
      canvas.drawPath(path, glowPaint);

      // Glow 2: halo externo suave
      final outerGlowPaint = Paint()
        ..color = level.color.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12.0;
      canvas.drawPath(path, outerGlowPaint);
      
      canvas.drawPath(path, fillPaint);

      // Highlight sutil no topo de cada trapézio (exceto no triângulo que é um ponto)
      if (i > 0) {
        final highlightPath = Path();
        highlightPath.moveTo(centerX - currentTopWidth / 2, y);
        highlightPath.lineTo(centerX + currentTopWidth / 2, y);
        
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.5;

        canvas.drawPath(highlightPath, highlightPaint);
      }

      // Borda sutil lateral/geral
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
