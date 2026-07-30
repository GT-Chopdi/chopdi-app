import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

class LoanToggle extends StatelessWidget {

  const LoanToggle({super.key});

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            width: 194,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                SizedBox(width: 8),
                SizedBox(height: 50, width: 50,child: Image.asset('assets/home_cream_loan.png')),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "I Gave Loan",
                      style: GoogleFonts.manrope(
                        color: ChopdiColors.cream,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                
                    Text(
                      "(Receive Interest)",
                      style: GoogleFonts.manrope(
                        color: ChopdiColors.cream,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width:2),

        Expanded(
          child: Container(
            height: 54,
            width: 194,
            decoration: BoxDecoration(
              color: Color(0xFFFFF8F0),
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(15),
            ),

            child: Row(
              children: [
                SizedBox(width: 8),
                SizedBox(height: 50, width: 50,child: Image.asset('assets/home_blue_loan.png')),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "I Took Loan",
                      style: GoogleFonts.manrope(
                        color: ChopdiColors.navy,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                
                    Text(
                      "(Pay Interest)",
                      style: GoogleFonts.manrope(
                        color: ChopdiColors.navy,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}