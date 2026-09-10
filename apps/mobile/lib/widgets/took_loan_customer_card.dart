import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
import 'package:mychopdi/view/took_loan_customer_details_screen.dart';

class TookLoanCustomerCard extends StatelessWidget {
  final Customer customer;

  const TookLoanCustomerCard({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: IsarService.isar.transactions
          .filter()
          .customerIdEqualTo(customer.id)
          .voidedAtIsNull()
          .watch(
        fireImmediately: true,
      ),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? <Transaction>[];

        // ============================================================
        // TOTAL LOAN TAKEN
        // ============================================================

        final double totalLoanTaken = transactions
            .where(
              (tx) => tx.type == TransactionType.took,
        )
            .fold<double>(
          0,
              (sum, tx) => sum + tx.amount,
        );

        // ============================================================
        // TOTAL PAID
        // ============================================================

        final double totalPaid = transactions
            .where(
              (tx) => tx.type == TransactionType.paid,
        )
            .fold<double>(
          0,
              (sum, tx) => sum + tx.amount,
        );

        // ============================================================
        // TOTAL INTEREST
        // Same calculation as TookLoanCustomerDetailsScreen
        // ============================================================

        final double totalInterest = transactions
            .where(
              (tx) => tx.type == TransactionType.took,
        )
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
                '[TookLoanCustomerCard] '
                    'Interest calculation failed '
                    'transaction=${tx.id}: $e',
              );

              return sum;
            }
          },
        );

        // ============================================================
        // OUTSTANDING / PENDING
        //
        // Total Taken
        // + Interest
        // - Paid
        // = Outstanding
        // ============================================================

        final double outstanding =
        (totalLoanTaken + totalInterest - totalPaid)
            .clamp(
          0.0,
          double.infinity,
        );

        // ============================================================
        // DEBUG
        // ============================================================

        debugPrint(
          '[TookLoanCustomerCard] '
              'customer=${customer.name}, '
              'customerId=${customer.id}, '
              'totalLoanTaken=$totalLoanTaken, '
              'totalInterest=$totalInterest, '
              'totalPaid=$totalPaid, '
              'outstanding=$outstanding',
        );

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TookLoanCustomerDetailsScreen(
                  customer: customer,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(
                170,
                185,
                207,
                0.2,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color.fromRGBO(
                  170,
                  185,
                  207,
                  1,
                ),
              ),
            ),
            child: Row(
              children: [
                // ====================================================
                // CUSTOMER AVATAR
                // ====================================================

                CircleAvatar(
                  radius: 22,
                  backgroundColor: ChopdiColors.lightGray,
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ChopdiColors.navy,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ====================================================
                // CUSTOMER INFORMATION
                // ====================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: ChopdiColors.navy,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        customer.phone.isEmpty
                            ? "No phone number"
                            : customer.phone,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ==================================================
                      // TOTAL LOAN TAKEN
                      // ==================================================

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffEEF3FA),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Loan: ₹${totalLoanTaken.toStringAsFixed(0)}",
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

                // ====================================================
                // OUTSTANDING + INTEREST + STATUS
                // ====================================================

                Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    // OUTSTANDING INCLUDING INTEREST
                    Text(
                      "₹${outstanding.toStringAsFixed(0)}",
                      style: GoogleFonts.manrope(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: outstanding > 0
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // INTEREST
                    Text(
                      "Interest: ₹${totalInterest.toStringAsFixed(0)}",
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFC74C4C),
                      ),
                    ),

                    const SizedBox(height: 3),

                    // STATUS
                    Text(
                      outstanding > 0
                          ? "Pending"
                          : "Settled",
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: outstanding > 0
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
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