import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'splash_theme.dart';

class LedgerLogoPainter extends CustomPainter {
  LedgerLogoPainter({
    this.navy = SplashColors.navy,
    this.red = SplashColors.red,
  });

  final Color navy;
  final Color red;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 * 0.72;
    final strokeWidth = size.shortestSide * 0.13;

    final arcPaint = Paint()
      ..color = navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Open bracket / "C" shape, opening toward the right.
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -125 * math.pi / 180;
    const sweepAngle = 250 * math.pi / 180;
    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

    // Small folded-corner accent, top-right of the bracket.
    final foldCenter = center +
        Offset(math.cos(-40 * math.pi / 180), math.sin(-40 * math.pi / 180)) *
            radius;
    final foldSize = strokeWidth * 0.62;
    final foldPath = Path()
      ..moveTo(foldCenter.dx - foldSize, foldCenter.dy)
      ..lineTo(foldCenter.dx + foldSize * 0.2, foldCenter.dy - foldSize)
      ..lineTo(foldCenter.dx + foldSize * 0.2, foldCenter.dy + foldSize * 0.2)
      ..close();
    canvas.drawPath(foldPath, Paint()..color = navy);

    // Rupee glyph.
    final textPainter = TextPainter(
      text: TextSpan(
        text: '\u20B9',
        style: TextStyle(
          color: red,
          fontSize: size.shortestSide * 0.62,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final textOffset = center -
        Offset(textPainter.width / 2, textPainter.height / 2) +
        Offset(size.shortestSide * 0.03, 0);
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant LedgerLogoPainter oldDelegate) => false;
}
