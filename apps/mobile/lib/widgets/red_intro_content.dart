import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RedIntroContent extends StatelessWidget {
  const RedIntroContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/frame_overlay.png',
          fit: BoxFit.cover,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: Text(
              'Chopdi',
              style: GoogleFonts.styleScript(
                fontSize: 96,
                color: Color(0XFF223A5E),
                height: 1,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/secure.png',
                width: 108,
                height: 114,
              ),
              const SizedBox(height: 10),
              Text(
                'SECURE . SIMPLE',
                style: GoogleFonts.manrope(
                  color: Color(0xFFFDEDD9),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'YOUR LEDGER, ALWAYS SAFE',
                style: GoogleFonts.manrope(
                  color: const Color(0xFFFDEDD9),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

