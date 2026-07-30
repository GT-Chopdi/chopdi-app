import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                const Text(
                  "Total Outstanding Amount",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "₹0",
                  style: TextStyle(
                    color: Color(0xff68E04D),
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),

                const SizedBox(height: 4),

                Container(
                  width: 120,
                  height: 1,
                  color: Colors.white24,
                ),

                const SizedBox(height: 14),

                Row(
                  children: [

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [

                        Text(
                          "Total Loan Given",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),

                        SizedBox(height: 3),

                        Text(
                          "₹0",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),

                    const SizedBox(width: 28),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [

                        Text(
                          "Total Interest Earned",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),

                        SizedBox(height: 3),

                        Text(
                          "₹0",
                          style: TextStyle(
                            color: Color(0xff68E04D),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),

          Positioned(
            right: -12,
            top: -8,
            child: Image.asset(
              "assets/book.png",
              height: 110,
            ),
          ),
        ],
      ),
    );
  }
}