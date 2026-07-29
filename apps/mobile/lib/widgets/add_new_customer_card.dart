import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_colors.dart';

class AddNewCustomerCard extends StatelessWidget {

  final VoidCallback? onTap;
  const AddNewCustomerCard({super.key,this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xffB7C2D5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            /// Dashed Circle
            SizedBox(
              width: 44,
              height: 44,
              child: CustomPaint(
                painter: DashedCirclePainter(),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Color(0xff223A5E),
                    size: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            /// Text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add New Customer",
                    style: GoogleFonts.manrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: ChopdiColors.navy,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Enter details manually",
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: ChopdiColors.navy,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              size: 28,
              color: Color(0xff223A5E),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------------
/// Dashed Circle Painter
/// ----------------------------
class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashCount = 20;
    const dashLength = 0.18;

    final paint = Paint()
      ..color = const Color(0xff8B99AE)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2 - 1;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < dashCount; i++) {
      final start =
          (2 * 3.141592653589793 / dashCount) * i;
      final sweep =
          (2 * 3.141592653589793 / dashCount) *
              dashLength;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}