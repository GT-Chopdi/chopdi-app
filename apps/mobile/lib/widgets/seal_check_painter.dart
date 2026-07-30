import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'splash_theme.dart';

class SealCheckPainter extends CustomPainter {
  SealCheckPainter({this.color = SplashColors.navy});

  final Color color;
  static const int bumps = 14;
  static const double bumpDepth = 0.07;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 * 0.86;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scalloped seal outline.
    final path = Path();
    const steps = 200;
    for (var i = 0; i <= steps; i++) {
      final theta = (i / steps) * 2 * math.pi;
      final r = radius * (1 + bumpDepth * math.cos(bumps * theta));
      final p = center + Offset(math.cos(theta), math.sin(theta)) * r;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, strokePaint);

    // Checkmark.
    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path()
      ..moveTo(center.dx - radius * 0.38, center.dy + radius * 0.02)
      ..lineTo(center.dx - radius * 0.08, center.dy + radius * 0.32)
      ..lineTo(center.dx + radius * 0.42, center.dy - radius * 0.30);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant SealCheckPainter oldDelegate) =>
      oldDelegate.color != color;
}
