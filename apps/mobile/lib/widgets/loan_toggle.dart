import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

class LoanToggle extends StatelessWidget {
  final bool isGaveLoanSelected;
  final ValueChanged<bool> onChanged;

  const LoanToggle({
    super.key,
    required this.isGaveLoanSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ================= I GAVE LOAN =================
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(true),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: isGaveLoanSelected
                    ? AppColors.primary
                    : const Color(0xFFFFF8F0),
                border: Border.all(
                  color: isGaveLoanSelected
                      ? AppColors.primary
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),

                  SizedBox(
                    height: 32,
                    width: 32,
                    child: Image.asset(
                      isGaveLoanSelected
                          ? 'assets/home_cream_loan_new.png'
                          : 'assets/home_blue_loan_new.png',
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "I Gave Loan",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: isGaveLoanSelected
                                ? ChopdiColors.cream
                                : ChopdiColors.navy,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "(Receive Interest)",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: isGaveLoanSelected
                                ? ChopdiColors.cream
                                : ChopdiColors.navy,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 2),

        // ================= I TOOK LOAN =================
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(false),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: !isGaveLoanSelected
                    ? AppColors.primary
                    : const Color(0xFFFFF8F0),
                border: Border.all(
                  color: !isGaveLoanSelected
                      ? AppColors.primary
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),

                  SizedBox(
                    height: 32,
                    width: 32,
                    child: Image.asset(
                      !isGaveLoanSelected
                          ? 'assets/home_cream_loan_new.png'
                          : 'assets/home_blue_loan_new.png',
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "I Took Loan",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: !isGaveLoanSelected
                                ? ChopdiColors.cream
                                : ChopdiColors.navy,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "(Pay Interest)",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: !isGaveLoanSelected
                                ? ChopdiColors.cream
                                : ChopdiColors.navy,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}