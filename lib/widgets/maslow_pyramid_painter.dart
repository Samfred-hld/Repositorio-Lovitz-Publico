import 'package:flutter/material.dart';

/// Painter customizado para a Pirâmide de Maslow.
/// Desenha 5 níveis: topo = triângulo, os outros 4 = trapézios.
class MaslowPyramidPainter extends CustomPainter {
  final List<MaslowLevel> levels;

  MaslowPyramidPainter({required this.levels});

  @override
  void paint(Canvas canvas, Size size) {
    final totalHeight = size.height;
    final totalWidth = size.width;
    final levelCount = levels.length;

    // Cada nível ocupa 1/5 da altura
    final levelHeight = totalHeight / levelCount;

    // Largura do topo (estreita) e da base (largura total)
    final topWidth = totalWidth * 0.18;
    final bottomWidth = totalWidth * 0.95;

    for (int i = 0; i < levelCount; i++) {
      final level = levels[i];
      final y = i * levelHeight;

      // Largura proporcional: topo estreito, base larga
      final t = i / (levelCount - 1); // 0 no topo, 1 na base
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
        path.lineTo(centerX + currentBottomWidth / 2, y + levelHeight);
        path.lineTo(centerX - currentBottomWidth / 2, y + levelHeight);
        path.close();
      } else {
        // Trapézio
        path.moveTo(centerX - currentTopWidth / 2, y);
        path.lineTo(centerX + currentTopWidth / 2, y);
        path.lineTo(centerX + currentBottomWidth / 2, y + levelHeight);
        path.lineTo(centerX - currentBottomWidth / 2, y + levelHeight);
        path.close();
      }

      // Preencher com gradiente
      final rect = Rect.fromLTWH(0, y, totalWidth, levelHeight);
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          level.color,
          level.color.withOpacity(0.5),
        ],
      );

      final fillPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      // Sombra para dar efeito 3D (glassmorphism/camadas)
      canvas.drawShadow(path, Colors.black, 8.0, true);
      
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
