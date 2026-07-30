import 'package:flutter/material.dart';
import 'splash_theme.dart';

class PaperBackground extends StatelessWidget {
  const PaperBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SplashColors.cream,
      child: CustomPaint(
        size: Size.infinite,
        painter: _PaperPainter(),
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  static const double lineSpacing = 34;
  static const double marginX = 46;

  @override
  void paint(Canvas canvas, Size size) {
    final rulePaint = Paint()
      ..color = SplashColors.ruleLine
      ..strokeWidth = 1;

    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rulePaint);
    }

    final marginPaint = Paint()
      ..color = SplashColors.marginLine
      ..strokeWidth = 1.4;
    canvas.drawLine(
      const Offset(marginX, 0),
      Offset(marginX, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PaperPainter oldDelegate) => false;
}
