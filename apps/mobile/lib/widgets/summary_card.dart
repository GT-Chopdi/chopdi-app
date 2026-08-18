import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';

class SummaryCard extends StatelessWidget {
  final int chopdiId;
  final bool isGaveLoanSelected;
  const SummaryCard({super.key, required this.chopdiId,required this.isGaveLoanSelected,});

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
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? <Transaction>[];

        final totalLoanGiven = transactions
            .where((tx) => tx.type == TransactionType.gave)
            .fold<double>(0, (sum, tx) => sum + tx.amount);

        final totalReceived = transactions
            .where((tx) => tx.type == TransactionType.received)
            .fold<double>(0, (sum, tx) => sum + tx.amount);

        // final totalInterest = transactions
        //     .where((tx) => tx.type == TransactionType.gave)
        //     .fold<double>(
        //       0,
        //       (sum, tx) => sum + InterestCalculator.calculate(tx),
        //     );

        final totalInterest = transactions
        .where((tx) => tx.type == TransactionType.gave)
        .fold<double>(
          0,
          (sum, tx) =>
              sum +
              InterestCalculator.calculate(
                principal: tx.amount,
                rate: tx.interestRate,
                startDate: tx.date,
                interestType: tx.interestType,
                frequency: tx.interestFrequency,
              ),
        );

        final outstanding =
            totalLoanGiven + totalInterest - totalReceived;

        return Container(
          height: 165,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              /// Decorative Image
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
                    const Text(
                      "Total Outstanding Amount",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Text(
                    //   formatAmount(outstanding),
                    //   style: const TextStyle(
                    //     color: Color(0xff68E04D),
                    //     fontSize: 28,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    Text(
                      formatAmount(outstanding),
                      style: TextStyle(
                        color: isGaveLoanSelected
                            ? Color.fromRGBO(141, 208, 113, 1) // Green for I Gave Loan
                            : Color.fromRGBO(199, 76, 76, 1),             // Red for I Took Loan
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: 140,
                      height: 1,
                      color: Colors.white24,
                    ),

                    const Spacer(),

                    Row(
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
                          // child: _SummaryItem(
                          //   title: "Total Interest Earned",
                          //   value: formatAmount(totalInterest),
                          //   valueColor: const Color(0xff68E04D),
                          // ),
                          child: _SummaryItem(
                            title: "Total Interest Earned",
                            value: formatAmount(totalInterest),
                            valueColor: isGaveLoanSelected
                                ? Color.fromRGBO(141, 208, 113, 1) // Green
                                : Color.fromRGBO(199, 76, 76, 1),             // Red
                          ),
                        ),
                      ],
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
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}