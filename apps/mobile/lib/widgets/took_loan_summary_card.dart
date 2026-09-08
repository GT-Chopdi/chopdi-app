import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';

import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';

class TookLoanSummaryCard extends StatelessWidget {
  final int chopdiId;

  const TookLoanSummaryCard({
    super.key,
    required this.chopdiId,
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
          .chopdiIdEqualTo(chopdiId)
          .voidedAtIsNull()
          .watch(
        fireImmediately: true,
      ),
      builder: (context, snapshot) {
        // ------------------------------------------------------------
        // Handle stream state
        // ------------------------------------------------------------
        if (snapshot.hasError) {
          debugPrint(
            '[TookLoanSummaryCard] Isar error: ${snapshot.error}',
          );
          return _buildCard(
            outstanding: 0,
            totalLoanTaken: 0,
            totalInterestDue: 0,
          );
        }

        final transactions = snapshot.data ?? <Transaction>[];

        // ------------------------------------------------------------
        // Debug
        // ------------------------------------------------------------
        debugPrint(
          '[TookLoanSummaryCard] chopdiId=$chopdiId transactions=${transactions.length}',
        );

        for (final tx in transactions) {
          debugPrint(
            '[TookLoanSummaryCard] id=${tx.id}, uuid=${tx.uuid}, '
                'customerUuid=${tx.customerUuid}, chopdiId=${tx.chopdiId}, '
                'type=${tx.type}, amount=${tx.amount}, amountPaise=${tx.amountPaise}',
          );
        }

        // ------------------------------------------------------------
        // TOTAL LOAN TAKEN
        // ------------------------------------------------------------
        final totalLoanTaken = transactions
            .where((tx) => tx.type == TransactionType.took)
            .fold<double>(
          0,
              (sum, tx) => sum + tx.amount,
        );

        // ------------------------------------------------------------
        // TOTAL PAID
        // ------------------------------------------------------------
        final totalPaid = transactions
            .where((tx) => tx.type == TransactionType.paid)
            .fold<double>(
          0,
              (sum, tx) => sum + tx.amount,
        );

        // ------------------------------------------------------------
        // TOTAL INTEREST DUE
        // ------------------------------------------------------------
        final totalInterestDue = transactions
            .where((tx) => tx.type == TransactionType.took)
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
                '[TookLoanSummaryCard] Interest calculation failed for '
                    'transaction ${tx.id}: $e',
              );
              return sum;
            }
          },
        );

        // ------------------------------------------------------------
        // OUTSTANDING
        // ------------------------------------------------------------
        final outstanding = (totalLoanTaken + totalInterestDue - totalPaid).clamp(
          0.0,
          double.infinity,
        );

        return _buildCard(
          outstanding: outstanding,
          totalLoanTaken: totalLoanTaken,
          totalInterestDue: totalInterestDue,
        );
      },
    );
  }

  Widget _buildCard({
    required double outstanding,
    required double totalLoanTaken,
    required double totalInterestDue,
  }) {
    return Container(
      height: 165,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          // ----------------------------------------------------------
          // Decorative Image
          // ----------------------------------------------------------
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

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------------------------------------
                // TITLE
                // ----------------------------------------------------
                Text(
                  "Total Outstanding Amount",
                  style: GoogleFonts.manrope(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),

                // ----------------------------------------------------
                // OUTSTANDING
                // ----------------------------------------------------
                Text(
                  formatAmount(outstanding),
                  style: GoogleFonts.manrope(
                    color: const Color.fromRGBO(199, 76, 76, 1),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  width: 140,
                  height: 1,
                  color: Colors.white24,
                ),
                const Spacer(),

                // ----------------------------------------------------
                // BOTTOM SUMMARY
                // ----------------------------------------------------
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // CRITICAL FIX
                    children: [
                      Expanded(
                        child: _SummaryItem(
                          title: "Total Loan Taken",
                          value: formatAmount(totalLoanTaken),
                          valueColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _SummaryItem(
                          title: "Total Interest Due",
                          value: formatAmount(totalInterestDue),
                          valueColor: const Color.fromRGBO(199, 76, 76, 1),
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