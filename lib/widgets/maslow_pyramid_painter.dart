import 'package:flutter/material.dart';
import 'dart:math' as math;

class MaslowPyramidPainter extends CustomPainter {
  final List<MaslowLevel> levels;
  final double cornerRadius;
  static const double gap = 6.0;

  const MaslowPyramidPainter({
    required this.levels,
    this.cornerRadius = 12.0,
  });

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Creates a rounded trapezoid path.
  /// [topWidth] < [bottomWidth], centered in [totalWidth].
  /// [cornerRadius] rounds all 4 corners.
  Path _roundedTrapezoid({
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
    final h = bottom - top;

    final edgeAngle = math.atan2(h, (bl - tl));
    final sinA = math.sin(edgeAngle);
    final cosA = math.cos(edgeAngle);
    final dx = radius * cosA;
    final dy = radius * sinA;

    final path = Path();

    // Start at bottom-left + radius along bottom edge
    path.moveTo(bl + radius, bottom);

    // Bottom-right corner
    path.lineTo(br - radius, bottom);
    path.arcToPoint(
      Offset(br - radius * cosA, bottom - radius * sinA),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Right edge going up to top-right corner
    path.lineTo(tr + dx, top + dy);
    path.arcToPoint(
      Offset(tr, top),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Top edge
    path.lineTo(tl, top);

    // Top-left corner
    path.arcToPoint(
      Offset(tl - dx, top + dy),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Left edge going down to bottom-left corner
    path.lineTo(bl + dx, bottom - dy);
    path.arcToPoint(
      Offset(bl, bottom),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;
    final n = levels.length;
    final totalGap = (n - 1) * gap;
    final levelHeight = (H - totalGap) / n;

    for (int i = 0; i < n; i++) {
      final level = levels[i];

      // i=0 is base (widest), i=n-1 is top (narrowest)
      final topFrac = i / n;
      final botFrac = (i + 1) / n;
      final topWidth = W * (1.0 - topFrac * 0.55);
      final botWidth = W * (1.0 - botFrac * 0.55);

      final yTop = i * (levelHeight + gap);
      final yBot = yTop + levelHeight;

      final path = _roundedTrapezoid(
        totalWidth: W,
        top: yTop,
        bottom: yBot,
        topWidth: topWidth,
        bottomWidth: botWidth,
        radius: cornerRadius,
      );

      // Glow effect
      const glowStops = [
        (strokeWidth: 20.0, opacity: 0.06),
        (strokeWidth: 12.0, opacity: 0.12),
        (strokeWidth: 5.0, opacity: 0.25),
      ];
      for (final stop in glowStops) {
        canvas.drawPath(
          path,
          Paint()
            ..color = level.color.withOpacity(stop.opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = stop.strokeWidth
            ..strokeJoin = StrokeJoin.round,
        );
      }

      // Fill with gradient
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _lighten(level.color, 0.12),
              level.color,
              _darken(level.color, 0.08),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromLTWH(0, yTop, W, levelHeight)),
      );

      // Subtle top highlight (skip base level)
      if (i > 0) {
        final highlightTl = W / 2 - topWidth / 2 + cornerRadius;
        final highlightTr = W / 2 + topWidth / 2 - cornerRadius;
        if (highlightTr > highlightTl) {
          canvas.drawLine(
            Offset(highlightTl, yTop + 1),
            Offset(highlightTr, yTop + 1),
            Paint()
              ..color = Colors.white.withOpacity(0.25)
              ..strokeWidth = 1.0
              ..strokeCap = StrokeCap.round,
          );
        }
      }

      // Subtle outer border
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MaslowPyramidPainter old) =>
      old.levels != levels || old.cornerRadius != cornerRadius;
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
