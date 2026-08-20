import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
import 'package:mychopdi/widgets/transaction_details_bottom_sheet.dart';
import 'package:mychopdi/widgets/transaction_raw.dart';

class TransactionTable extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onChanged;
  final int customerId;

  const TransactionTable({
    super.key,
    required this.transactions,
    required this.onChanged,
    required this.customerId,
  });


  // List<Widget> _buildInterestRows(Transaction tx) {
  //   final List<Widget> rows = [];

  //   final now = DateTime.now();

  //   final startDate = DateTime(
  //     tx.date.year,
  //     tx.date.month,
  //     tx.date.day,
  //   );

  //   final today = DateTime(
  //     now.year,
  //     now.month,
  //     now.day,
  //   );

  //   if (!today.isAfter(startDate)) {
  //     return rows;
  //   }

  //   // ==========================================
  //   // CALCULATE CURRENT MONTHLY PERIOD
  //   // ==========================================

  //   DateTime periodStart = startDate;
  //   DateTime periodEnd = _addOneMonth(periodStart);

  //   while (!today.isBefore(periodEnd)) {
  //     periodStart = periodEnd;
  //     periodEnd = _addOneMonth(periodStart);
  //   }

  //   // ==========================================
  //   // INTEREST UP TO TODAY
  //   // ==========================================

  //   final interest = InterestCalculator.calculate(
  //     principal: tx.amount,
  //     rate: tx.interestRate,
  //     startDate: startDate,
  //     interestType: tx.interestType,
  //     frequency: tx.interestFrequency,
  //     endDate: today,
  //   );

  //   // ==========================================
  //   // ONLY ONE INTEREST ROW
  //   // ==========================================

  //   rows.add(
  //     _InterestRow(
  //       startDate: periodStart,
  //       endDate: periodEnd,
  //       interest: interest,
  //     ),
  //   );

  //   rows.add(
  //     const SizedBox(height: 8),
  //   );

  //   return rows;
  // }

  List<Widget> _buildInterestRows(Transaction tx) {
    final List<Widget> rows = [];

    final now = DateTime.now();

    final startDate = DateTime(
      tx.date.year,
      tx.date.month,
      tx.date.day,
    );

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    // No interest if transaction is today
    if (!today.isAfter(startDate)) {
      return rows;
    }

    // ==========================================================
    // FIND INTEREST FREQUENCY
    // ==========================================================

    final frequency = tx.interestFrequency
        .trim()
        .toLowerCase();

    DateTime periodStart = startDate;
    DateTime periodEnd;

    // ==========================================================
    // YEARLY
    // ==========================================================

    if (frequency.contains("year")) {
      periodEnd = _addOneYear(periodStart);

      // Move to the current yearly period
      while (!today.isBefore(periodEnd)) {
        periodStart = periodEnd;
        periodEnd = _addOneYear(periodStart);
      }
    }

    // ==========================================================
    // MONTHLY
    // ==========================================================

    else {
      periodEnd = _addOneMonth(periodStart);

      // Move to the current monthly period
      while (!today.isBefore(periodEnd)) {
        periodStart = periodEnd;
        periodEnd = _addOneMonth(periodStart);
      }
    }

    // ==========================================================
    // CALCULATE INTEREST UP TO TODAY
    // ==========================================================

    final interest = InterestCalculator.calculate(
      principal: tx.amount,
      rate: tx.interestRate,
      startDate: startDate,
      interestType: tx.interestType,
      frequency: tx.interestFrequency,
      endDate: today,
    );

    // ==========================================================
    // ONE INTEREST ROW
    // ==========================================================

    rows.add(
      _InterestRow(
        transaction: tx,
        startDate: periodStart,
        endDate: periodEnd,
        interest: interest,
        customerId: customerId,
        onChanged: onChanged,
      ),
    );

    rows.add(
      const SizedBox(height: 8),
    );

    return rows;
  }

  DateTime _addOneYear(DateTime date) {
    final nextYear = date.year + 1;

    // Handle Feb 29 safely
    if (date.month == 2 &&
        date.day == 29 &&
        !DateTime(nextYear, 3, 1)
            .isBefore(DateTime(nextYear, 3, 1))) {
      return DateTime(nextYear, 2, 28);
    }

    return DateTime(
      nextYear,
      date.month,
      date.day,
    );
  }

  List<Widget> _buildTransactionRows(
    List<Transaction> sortedTransactions,
    ) {
    final List<Widget> rows = [];

    double runningBalance = 0;

    for (final tx in sortedTransactions) {
      // Calculate normal transaction balance
      if (tx.type == TransactionType.gave) {
        runningBalance += tx.amount;
      } else {
        runningBalance -= tx.amount;
      }

      // DEBUG
      debugPrint(
        "Transaction: ${tx.date} | "
        "Type: ${tx.type} | "
        "Interest Rate: ${tx.interestRate} | "
        "Interest Frequency: '${tx.interestFrequency}'",
      );

      if (tx.type == TransactionType.gave &&
          tx.interestRate > 0) {
        rows.addAll(
          _buildInterestRows(tx),
        );
      }
      // ==========================================
      // ACTUAL TRANSACTION
      // ==========================================

      rows.add(
        TransactionRow(
          transaction: tx,
          balance: runningBalance,
          onChanged: onChanged,
          customerId: customerId,
        ),
      );

      rows.add(
        const SizedBox(height: 8),
      );
    }

    return rows;
  }

  List<Widget> _buildDailyInterestRows(Transaction tx) {
    final List<Widget> rows = [];

    final today = DateTime.now();

    final startDate = DateTime(
      tx.date.year,
      tx.date.month,
      tx.date.day,
    );

    final todayDate = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final totalDays = todayDate.difference(startDate).inDays;

    if (totalDays <= 0) {
      return rows;
    }

    // Show latest day first
    for (int day = totalDays; day >= 1; day--) {
      final endDate = startDate.add(
        Duration(days: day),
      );

      // Calculate cumulative interest up to this day
      final interest = InterestCalculator.calculate(
        principal: tx.amount,
        rate: tx.interestRate,
        startDate: startDate,
        interestType: tx.interestType,
        frequency: tx.interestFrequency,
        endDate: endDate,
      );

      // rows.add(
      //  _InterestRow(
      //     transaction: tx,
      //     startDate: periodStart,
      //     endDate: periodEnd,
      //     interest: interest,
      //     customerId: customerId,
      //     onChanged: onChanged,
      //   ),
      // );

      rows.add(
        const SizedBox(height: 8),
      );
    }

    return rows;
  }

  List<Widget> _buildMonthlyInterestRows(Transaction tx) {
    final List<Widget> rows = [];

    DateTime periodStart = tx.date;
    final today = DateTime.now();

    while (true) {
      final periodEnd = _addOneMonth(periodStart);

      if (periodEnd.isAfter(today)) {
        break;
      }

      final interest =
          tx.amount * tx.interestRate / 100;

      // rows.add(
      //   _InterestRow(
      //     startDate: periodStart,
      //     endDate: periodEnd,
      //     interest: interest, 
      //     // transaction: null, customerId: null, onChanged: () {  },
      //   ),
      // );

      rows.add(
        const SizedBox(height: 8),
      );

      periodStart = periodEnd;
    }

    return rows;
  }

  DateTime _addOneMonth(DateTime date) {
    final nextMonth = DateTime(
      date.year,
      date.month + 1,
      1,
    );

    final lastDayOfNextMonth = DateTime(
      nextMonth.year,
      nextMonth.month + 1,
      0,
    ).day;

    final day = date.day > lastDayOfNextMonth
        ? lastDayOfNextMonth
        : date.day;

    return DateTime(
      nextMonth.year,
      nextMonth.month,
      day,
    );
  }

  @override
  Widget build(BuildContext context) {
    double runningBalance = 0;
    final sortedTransactions = [...transactions]
      ..sort(
        (a, b) => b.date.compareTo(a.date),
      );

    return Column(
      children: [
        _tableHeader(),
        const SizedBox(height: 8),

        ..._buildTransactionRows(
          sortedTransactions,
        ),
      ],
    );
  }

  Widget _tableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        border: Border.all(
          color: const Color(0xFFAAB9CF),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(
            color: Color(0xffC8D6E8),
          ),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.8),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.2),
        },
        children: const [
          TableRow(
            children: [
              _Header("Date"),
              _Header("Given"),
              _Header("Received"),
              _Header("Balance"),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: ChopdiColors.navy,
          ),
        ),
      ),
    );
  }
}

// class _InterestRow extends StatelessWidget {
//   final DateTime startDate;
//   final DateTime endDate;
//   final double interest;

//   const _InterestRow({
//     required this.startDate,
//     required this.endDate,
//     required this.interest,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final dateFormat = DateFormat("dd MMM yyyy");

//     return Container(
//       decoration: BoxDecoration(
//         color: Color.fromRGBO(255, 248, 240, 1),
//         border: Border.all(
//           color: Color.fromRGBO(170, 185, 207, 1),
//         ),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Table(
//         columnWidths: const {
//           0: FlexColumnWidth(1.8),
//           1: FlexColumnWidth(1.2),
//           2: FlexColumnWidth(1.2),
//           3: FlexColumnWidth(1.2),
//         },
//         children: [
//           TableRow(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 8,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "${dateFormat.format(startDate)} - "
//                       "${dateFormat.format(endDate)}",
//                       style: GoogleFonts.manrope(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                         color: ChopdiColors.navy,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     const Text(
//                       "Interest Added",
//                       style: TextStyle(
//                         fontSize: 9,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Given
//               const Center(
//                 child: Text(
//                   "-",
//                   style: TextStyle(
//                     color: Colors.black,
//                   ),
//                 ),
//               ),

//               // Received
//               const Center(
//                 child: Text(
//                   "-",
//                   style: TextStyle(
//                     color: Colors.black,
//                   ),
//                 ),
//               ),

//               // Balance = Interest
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                 ),
//                 child: Text(
//                   "₹${interest.toStringAsFixed(0)}",
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: Color(0xFF00901B),
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

class _InterestRow extends StatelessWidget {
  final Transaction transaction;
  final DateTime startDate;
  final DateTime endDate;
  final double interest;
  final int customerId;
  final VoidCallback onChanged;

  const _InterestRow({
    required this.transaction,
    required this.startDate,
    required this.endDate,
    required this.interest,
    required this.customerId,
    required this.onChanged,
  });

  void _openTransactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TransactionDetailsScreen(
          transaction: transaction,
          customerId: customerId,
          onChanged: onChanged,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd MMM yyyy");

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 248, 240, 1),
        border: Border.all(
          color: const Color.fromRGBO(170, 185, 207, 1),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.8),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.2),
        },
        children: [
          TableRow(
            children: [
              // ==================================================
              // DATE + DESCRIPTION
              // ==================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${dateFormat.format(startDate)} - "
                      "${dateFormat.format(endDate)}",
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: ChopdiColors.navy,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // CLICKABLE DESCRIPTION
                    GestureDetector(
                      onTap: () {
                        _openTransactionDetails(context);
                      },
                      child: Text(
                        "Interest Added",
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // GIVEN
              // ==================================================

              const Center(
                child: Text(
                  "-",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),

              // ==================================================
              // RECEIVED
              // ==================================================

              const Center(
                child: Text(
                  "-",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),

              // ==================================================
              // BALANCE / INTEREST
              // ==================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Text(
                  "₹${interest.toStringAsFixed(0)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF00901B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}