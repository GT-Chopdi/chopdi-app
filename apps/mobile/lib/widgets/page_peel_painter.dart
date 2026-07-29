import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'splash_theme.dart';

class PagePeelPainter extends CustomPainter {
  PagePeelPainter({required this.progress});

  final double progress;

  static const double flapWidth = 90;
  static const double shadowWidth = 46;
  static const double creamGap = 160; 
  static double creaseT(Size size, double progress) {
    final double padding = (flapWidth + shadowWidth) * 2;
    final double start = size.height + padding;
    final double end = -size.width - padding;
    return start + (end - start) * progress;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final double tRed = creaseT(size, progress);
    final double tCream = tRed + creamGap;

    final rect = <Offset>[
      const Offset(0, 0),
      Offset(w, 0),
      Offset(w, h),
      Offset(0, h),
    ];

    canvas.drawColor(ChopdiColors.navy, BlendMode.srcOver);

    final creamShadowBand = _clipBand(rect, tCream, tCream + shadowWidth);
    if (creamShadowBand.length >= 3) {
      final shadowPaint = Paint()
        ..shader = ui.Gradient.linear(
          _pointOnDiagonal(tCream),
          _pointOnDiagonal(tCream + shadowWidth),
          [const Color(0x3F000000), const Color(0x00000000)],
        );
      canvas.drawPath(_pathFromPoints(creamShadowBand), shadowPaint);
    }

    final creamRegion = _clipHalfPlane(rect, -1, 1, tCream);
    if (creamRegion.length >= 3) {
      canvas.drawPath(
        _pathFromPoints(creamRegion),
        Paint()..color = SplashColors.cream,
      );
    }

    final redShadowBand = _clipBand(rect, tRed + flapWidth, tRed + flapWidth + shadowWidth);
    if (redShadowBand.length >= 3) {
      final shadowPaint = Paint()
        ..shader = ui.Gradient.linear(
          _pointOnDiagonal(tRed + flapWidth),
          _pointOnDiagonal(tRed + flapWidth + shadowWidth),
          [const Color(0x33000000), const Color(0x00000000)],
        );
      canvas.drawPath(_pathFromPoints(redShadowBand), shadowPaint);
    }

    final redFlapBand = _clipBand(rect, tRed, tRed + flapWidth);
    if (redFlapBand.length >= 3) {
      final flapPaint = Paint()
        ..shader = ui.Gradient.linear(
          _pointOnDiagonal(tRed),
          _pointOnDiagonal(tRed + flapWidth),
          [SplashColors.flapLight, SplashColors.red],
        );
      canvas.drawPath(_pathFromPoints(redFlapBand), flapPaint);
    }

    final redRegion = _clipHalfPlane(rect, -1, 1, tRed);
    if (redRegion.length >= 3) {
      canvas.drawPath(
        _pathFromPoints(redRegion),
        Paint()..color = SplashColors.red,
      );
    }
  }

  Offset _pointOnDiagonal(double t) => Offset(-t / 2, t / 2);

  Path _pathFromPoints(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  List<Offset> _clipBand(List<Offset> poly, double tLow, double tHigh) {
    final upper = _clipHalfPlane(poly, -1, 1, tHigh);
    if (upper.length < 3) return const [];
    return _clipHalfPlane(upper, 1, -1, -tLow);
  }

  List<Offset> _clipHalfPlane(List<Offset> poly, double a, double b, double c) {
    if (poly.isEmpty) return const [];
    final result = <Offset>[];
    for (var i = 0; i < poly.length; i++) {
      final current = poly[i];
      final next = poly[(i + 1) % poly.length];
      final curVal = a * current.dx + b * current.dy - c;
      final nextVal = a * next.dx + b * next.dy - c;
      final curInside = curVal <= 0;
      final nextInside = nextVal <= 0;

      if (curInside) result.add(current);
      if (curInside != nextInside) {
        final tt = curVal / (curVal - nextVal);
        result.add(Offset.lerp(current, next, tt)!);
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant PagePeelPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
