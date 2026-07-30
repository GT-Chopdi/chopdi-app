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
          fit: BoxFit.fill,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: Text(
              'Chopdi',
              style: GoogleFonts.greatVibes(
                fontSize: 96,
                color: Color(0XFF223A5E),
                height: 1,
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
                'assets/badge_seal.png',
                width: 54,
                height: 54,
              ),
              const SizedBox(height: 10),
              const Text(
                'SECURE . SIMPLE',
                style: TextStyle(
                  color: Color(0xFFFFF8F0),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'YOUR LEDGER, ALWAYS SAFE',
                style: TextStyle(
                  color: const Color(0xFFFFF8F0).withValues(alpha: 0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

