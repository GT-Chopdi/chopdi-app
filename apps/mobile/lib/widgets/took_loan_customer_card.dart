import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/lender.dart'; // <-- IMPORT LENDER
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
import 'package:mychopdi/view/took_loan_customer_details_screen.dart';

class TookLoanCustomerCard extends StatelessWidget {
  final Lender lender; // <-- CHANGED TO LENDER

  const TookLoanCustomerCard({
    super.key,
    required this.lender, // <-- CHANGED TO LENDER
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<List<Transaction>>(
      stream: IsarService.isar.transactions
          .filter()
          .customerIdEqualTo(lender.id) // <-- CHANGED TO LENDER
          .voidedAtIsNull()
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? <Transaction>[];

        final double totalLoanTaken = transactions
            .where((tx) => tx.type == TransactionType.took)
            .fold<double>(0, (sum, tx) => sum + tx.amount);

        final double totalPaid = transactions
            .where((tx) => tx.type == TransactionType.paid)
            .fold<double>(0, (sum, tx) => sum + tx.amount);

        final double totalInterest = transactions
            .where((tx) => tx.type == TransactionType.took)
            .fold<double>(0, (sum, tx) {
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
            return sum;
          }
        });

        final double outstanding = (totalLoanTaken + totalInterest - totalPaid)
            .clamp(0.0, double.infinity);

        final Color outstandingColor = outstanding == 0 ? Colors.black : Colors.green;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TookLoanCustomerDetailsScreen(
                  lender: lender, // <-- FIXED: PASS LENDER
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(170, 185, 207, 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color.fromRGBO(170, 185, 207, 1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: ChopdiColors.lightGray,
                  child: Text(
                    lender.name.isNotEmpty ? lender.name[0].toUpperCase() : '?', // <-- CHANGED TO LENDER
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ChopdiColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lender.name, // <-- CHANGED TO LENDER
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: ChopdiColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lender.phone.isEmpty ? l10n.noPhoneNumber : lender.phone, // <-- CHANGED TO LENDER
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xffEEF3FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${l10n.loan}: ₹${totalLoanTaken.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: ChopdiColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${outstanding.toStringAsFixed(0)}',
                      style: GoogleFonts.manrope(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: outstandingColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (totalInterest > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.interest}: ₹${totalInterest.toStringAsFixed(0)}',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFC74C4C),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}