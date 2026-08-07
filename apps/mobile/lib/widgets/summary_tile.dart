import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SummaryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color valueColor;

  const SummaryTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: const Color(0xffDCE4F2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xff3564A8),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xff7A869A),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),

              if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}