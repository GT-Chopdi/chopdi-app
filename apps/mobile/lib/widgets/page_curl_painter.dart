import 'dart:ui';
import 'package:flutter/material.dart';

class PageCurlPainter extends CustomPainter {

  final double progress;

  PageCurlPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final foldWidth =
        lerpDouble(size.width * 0.85, 30, progress)!;

    final foldHeight =
        lerpDouble(size.height, 0, progress)!;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: .55);

    final shadow = Path();

    shadow.moveTo(size.width, 0);

    shadow.lineTo(
      foldWidth,
      foldHeight,
    );

    shadow.lineTo(
      size.width,
      size.height,
    );

    shadow.close();

    canvas.drawPath(shadow, shadowPaint);

    final pagePaint = Paint()
      ..color = const Color(0xffF6E5CB);

    final page = Path();

    page.moveTo(size.width, 0);

    page.lineTo(
      foldWidth - 20,
      foldHeight,
    );

    page.lineTo(
      foldWidth + 20,
      size.height,
    );

    page.close();

    canvas.drawPath(page, pagePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}