import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';

import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';

class SummaryCard extends StatelessWidget {
  final int chopdiId;
  final bool isGaveLoanSelected;

  const SummaryCard({
    super.key,
    required this.chopdiId,
    required this.isGaveLoanSelected,
  });

  String formatAmount(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: IsarService.isar.transactions
          .filter()
          .voidedAtIsNull()
          .chopdiIdEqualTo(chopdiId)
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? <Transaction>[];

        // ------------------------------------------------------------
        // TOTAL LOAN GIVEN
        // ------------------------------------------------------------
        final totalLoanGiven = transactions
            .where((tx) => tx.type == TransactionType.gave)
            .fold<double>(
          0,
              (sum, tx) => sum + tx.amount,
        );

        // ------------------------------------------------------------
        // TOTAL RECEIVED
        // ------------------------------------------------------------
        final totalReceived = transactions
            .where((tx) => tx.type == TransactionType.received)
            .fold<double>(
          0,
              (sum, tx) => sum + tx.amount,
        );

        // ------------------------------------------------------------
        // TOTAL INTEREST
        // ------------------------------------------------------------
        final totalInterest = transactions
            .where((tx) => tx.type == TransactionType.gave)
            .fold<double>(
          0,
              (sum, tx) {
            try {
              return sum +
                  InterestCalculator.calculate(
                    principal: tx.amount,
                    rate: tx.interestRate,
                    startDate: tx.date,
                    interestType: tx.interestType,
                    frequency: tx.interestFrequency,
                  );
            } catch (e) {
              debugPrint(
                '[SummaryCard] Interest calculation failed '
                    'for transaction ${tx.id}: $e',
              );
              return sum;
            }
          },
        );

        // ------------------------------------------------------------
        // OUTSTANDING
        // ------------------------------------------------------------
        final outstanding = totalLoanGiven + totalInterest - totalReceived;

        final amountColor = isGaveLoanSelected
            ? const Color.fromRGBO(141, 208, 113, 1)
            : const Color.fromRGBO(199, 76, 76, 1);

        return Container(
          height: 165,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              // --------------------------------------------------------
              // DECORATIVE IMAGE
              // --------------------------------------------------------
              Positioned(
                right: -12,
                top: -8,
                child: IgnorePointer(
                  child: Image.asset(
                    "assets/book.png",
                    height: 110,
                  ),
                ),
              ),

              // --------------------------------------------------------
              // CONTENT
              // --------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --------------------------------------------------
                    // TITLE
                    // --------------------------------------------------
                    Text(
                      "Total Outstanding Amount",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // --------------------------------------------------
                    // OUTSTANDING AMOUNT
                    // --------------------------------------------------
                    Text(
                      formatAmount(outstanding),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: amountColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --------------------------------------------------
                    // DIVIDER
                    // --------------------------------------------------
                    Container(
                      width: 140,
                      height: 1,
                      color: Colors.white24,
                    ),
                    const Spacer(),

                    // --------------------------------------------------
                    // BOTTOM SUMMARY
                    // --------------------------------------------------
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch, // CRITICAL FIX
                        children: [
                          Expanded(
                            child: _SummaryItem(
                              title: "Total Loan Given",
                              value: formatAmount(totalLoanGiven),
                              valueColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _SummaryItem(
                              title: "Total Interest Earned",
                              value: formatAmount(totalInterest),
                              valueColor: amountColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max, // CRITICAL FIX
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // CRITICAL FIX
      children: [
        Text(
          title,
          maxLines: 2, // CRITICAL FIX
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            color: Colors.white70,
            fontSize: 12,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown, // CRITICAL FIX
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: GoogleFonts.manrope(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}