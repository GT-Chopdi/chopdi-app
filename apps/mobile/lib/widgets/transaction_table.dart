// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:mychopdi/model/transaction.dart';
// import 'package:mychopdi/utils/app_colors.dart';
// import 'package:mychopdi/utils/interest_calculator.dart';
// import 'package:mychopdi/widgets/transaction_details_bottom_sheet.dart';
// import 'package:mychopdi/widgets/transaction_raw.dart';

// class TransactionTable extends StatelessWidget {
//   final List<Transaction> transactions;
//   final VoidCallback onChanged;
//   final int customerId;

//   const TransactionTable({
//     super.key,
//     required this.transactions,
//     required this.onChanged,
//     required this.customerId,
//   });


//   List<Widget> _buildInterestRows(Transaction tx) {
//     final List<Widget> rows = [];

//     final now = DateTime.now();

//     final startDate = DateTime(
//       tx.date.year,
//       tx.date.month,
//       tx.date.day,
//     );

//     final today = DateTime(
//       now.year,
//       now.month,
//       now.day,
//     );

//     if (!today.isAfter(startDate)) {
//       return rows;
//     }

//     // ==========================================
//     // CALCULATE CURRENT MONTHLY PERIOD
//     // ==========================================

//     DateTime periodStart = startDate;
//     DateTime periodEnd = _addOneMonth(periodStart);

//     while (!today.isBefore(periodEnd)) {
//       periodStart = periodEnd;
//       periodEnd = _addOneMonth(periodStart);
//     }

//     // ==========================================
//     // INTEREST UP TO TODAY
//     // ==========================================

//     final interest = InterestCalculator.calculate(
//       principal: tx.amount,
//       rate: tx.interestRate,
//       startDate: startDate,
//       interestType: tx.interestType,
//       frequency: tx.interestFrequency,
//       endDate: today,
//     );

//     // ==========================================
//     // ONLY ONE INTEREST ROW
//     // ==========================================

//     rows.add(
//       _InterestRow(
//         transaction: tx,
//         startDate: periodStart,
//         endDate: periodEnd,
//         interest: interest,
//         customerId: customerId,
//         onChanged: onChanged,
//       ),
//     );

//     rows.add(
//       const SizedBox(height: 8),
//     );

//     return rows;
//   }

//   DateTime _addOneYear(DateTime date) {
//     final nextYear = date.year + 1;

//     // Handle Feb 29 safely
//     if (date.month == 2 &&
//         date.day == 29 &&
//         !DateTime(nextYear, 3, 1)
//             .isBefore(DateTime(nextYear, 3, 1))) {
//       return DateTime(nextYear, 2, 28);
//     }

//     return DateTime(
//       nextYear,
//       date.month,
//       date.day,
//     );
//   }


//   List<Widget> _buildTransactionRows(
//     List<Transaction> sortedTransactions,
//   ) {
//     final List<Widget> rows = [];

//     // --------------------------------------------------
//     // 1. Sort OLD → NEW for balance calculation
//     // --------------------------------------------------

//     final balanceTransactions = [...sortedTransactions]
//       ..sort(
//         (a, b) => a.date.compareTo(b.date),
//       );

//     // Transaction balance for each transaction
//     final Map<int, double> balanceMap = {};

//     double runningBalance = 0;

//     for (final tx in balanceTransactions) {
//       if (tx.type == TransactionType.gave) {
//         runningBalance += tx.amount;
//       } else if (tx.type == TransactionType.received) {
//         runningBalance -= tx.amount;
//       }

//       balanceMap[tx.id] = runningBalance;
//     }

//     // --------------------------------------------------
//     // 2. Display NEW → OLD
//     // --------------------------------------------------

//     for (final tx in sortedTransactions) {

//       // -----------------------------------------------
//       // Interest row
//       // -----------------------------------------------

//       if (tx.type == TransactionType.gave &&
//           tx.interestRate > 0) {
//         rows.addAll(
//           _buildInterestRows(tx),
//         );
//       }

//       // -----------------------------------------------
//       // Actual transaction row
//       // -----------------------------------------------

//       rows.add(
//         TransactionRow(
//           transaction: tx,
//           balance: balanceMap[tx.id] ?? 0,
//           onChanged: onChanged,
//           customerId: customerId,
//         ),
//       );

//       rows.add(
//         const SizedBox(height: 8),
//       );
//     }

//     return rows;
//   }

//   List<Widget> _buildDailyInterestRows(Transaction tx) {
//     final List<Widget> rows = [];

//     final today = DateTime.now();

//     final startDate = DateTime(
//       tx.date.year,
//       tx.date.month,
//       tx.date.day,
//     );

//     final todayDate = DateTime(
//       today.year,
//       today.month,
//       today.day,
//     );

//     final totalDays = todayDate.difference(startDate).inDays;

//     if (totalDays <= 0) {
//       return rows;
//     }

//     // Show latest day first
//     for (int day = totalDays; day >= 1; day--) {
//       final endDate = startDate.add(
//         Duration(days: day),
//       );

//       // Calculate cumulative interest up to this day
//       final interest = InterestCalculator.calculate(
//         principal: tx.amount,
//         rate: tx.interestRate,
//         startDate: startDate,
//         interestType: tx.interestType,
//         frequency: tx.interestFrequency,
//         endDate: endDate,
//       );

//       // rows.add(
//       //  _InterestRow(
//       //     transaction: tx,
//       //     startDate: periodStart,
//       //     endDate: periodEnd,
//       //     interest: interest,
//       //     customerId: customerId,
//       //     onChanged: onChanged,
//       //   ),
//       // );

//       rows.add(
//         const SizedBox(height: 8),
//       );
//     }

//     return rows;
//   }

//   List<Widget> _buildMonthlyInterestRows(Transaction tx) {
//     final List<Widget> rows = [];

//     DateTime periodStart = tx.date;
//     final today = DateTime.now();

//     while (true) {
//       final periodEnd = _addOneMonth(periodStart);

//       if (periodEnd.isAfter(today)) {
//         break;
//       }

//       final interest =
//           tx.amount * tx.interestRate / 100;

//       // rows.add(
//       //   _InterestRow(
//       //     startDate: periodStart,
//       //     endDate: periodEnd,
//       //     interest: interest, 
//       //     // transaction: null, customerId: null, onChanged: () {  },
//       //   ),
//       // );

//       rows.add(
//         const SizedBox(height: 8),
//       );

//       periodStart = periodEnd;
//     }

//     return rows;
//   }

//   DateTime _addOneMonth(DateTime date) {
//     final nextMonth = DateTime(
//       date.year,
//       date.month + 1,
//       1,
//     );

//     final lastDayOfNextMonth = DateTime(
//       nextMonth.year,
//       nextMonth.month + 1,
//       0,
//     ).day;

//     final day = date.day > lastDayOfNextMonth
//         ? lastDayOfNextMonth
//         : date.day;

//     return DateTime(
//       nextMonth.year,
//       nextMonth.month,
//       day,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double runningBalance = 0;
//     final sortedTransactions = [...transactions]
//       ..sort(
//         (a, b) => b.date.compareTo(a.date),
//       );

//     return Column(
//       children: [
//         _tableHeader(),
//         const SizedBox(height: 8),

//         ..._buildTransactionRows(
//           sortedTransactions,
//         ),
//       ],
//     );
//   }

//   Widget _tableHeader() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFF8F0),
//         border: Border.all(
//           color: const Color(0xFFAAB9CF),
//         ),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Table(
//         border: TableBorder.symmetric(
//           inside: const BorderSide(
//             color: Color(0xffC8D6E8),
//           ),
//         ),
//         columnWidths: const {
//           0: FlexColumnWidth(1.8),
//           1: FlexColumnWidth(1.2),
//           2: FlexColumnWidth(1.2),
//           3: FlexColumnWidth(1.2),
//         },
//         children: const [
//           TableRow(
//             children: [
//               _Header("Date"),
//               _Header("Given"),
//               _Header("Received"),
//               _Header("Balance"),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _Header extends StatelessWidget {
//   final String title;

//   const _Header(this.title);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Center(
//         child: Text(
//           title,
//           style: GoogleFonts.manrope(
//             fontWeight: FontWeight.bold,
//             fontSize: 13,
//             color: ChopdiColors.navy,
//           ),
//         ),
//       ),
//     );
//   }
// }


// class _InterestRow extends StatelessWidget {
//   final Transaction transaction;
//   final DateTime startDate;
//   final DateTime endDate;
//   final double interest;
//   final int customerId;
//   final VoidCallback onChanged;

//   const _InterestRow({
//     required this.transaction,
//     required this.startDate,
//     required this.endDate,
//     required this.interest,
//     required this.customerId,
//     required this.onChanged,

//   });


//   String _getInterestDescription() {
//   final start = DateFormat("dd MMM yyyy").format(startDate);
//   final end = DateFormat("dd MMM yyyy").format(endDate);

//   final rate = transaction.interestRate.toStringAsFixed(0);

//   final frequency = transaction.interestFrequency.isEmpty
//       ? "Monthly"
//       : transaction.interestFrequency;

//   final interestType = transaction.interestType.isEmpty
//       ? "Simple Interest"
//       : transaction.interestType;

//   return "₹${interest.toStringAsFixed(0)} interest "
//       "from $start to $end at $rate% "
//       "$frequency $interestType interest.";
// }

//   @override
//   Widget build(BuildContext context) {
//     final dateFormat = DateFormat("dd MMM yyyy");

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 8,
//       ),
//       decoration: BoxDecoration(
//         // Same background as normal transaction row
//         color: const Color(0xFFFFF8F0),

//         // Same border as normal transaction row
//         border: Border.all(
//           color: const Color(0xFFAAB9CF),
//         ),

//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // ==================================
//           // DATE + DESCRIPTION
//           // ==================================

//           Expanded(
//             flex: 3,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "${dateFormat.format(startDate)} - "
//                   "${dateFormat.format(endDate)}",
//                   style: GoogleFonts.manrope(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: ChopdiColors.navy,
//                   ),
//                 ),

//                 const SizedBox(height: 3),

//                 GestureDetector(
//                   onTap: () {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       backgroundColor: Colors.transparent,
//                       builder: (_) {
//                         return TransactionDetailsScreen(
//                           transaction: transaction,
//                           customerId: customerId,
//                           onChanged: onChanged,
//                         );
//                       },
//                     );
//                   },
//                   child: Text(
//                     _getInterestDescription(),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Color(0xff8A93A6),
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ==================================
//           // GIVEN
//           // ==================================

//           const Expanded(
//             flex: 2,
//             child: Center(
//               child: Text(
//                 "-",
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//           ),

//           // ==================================
//           // RECEIVED
//           // ==================================

//           const Expanded(
//             flex: 2,
//             child: Center(
//               child: Text(
//                 "-",
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//           ),

//           // ==================================
//           // BALANCE / INTEREST
//           // ==================================

//           Expanded(
//             flex: 2,
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 "₹${interest.toStringAsFixed(0)}",
//                 style: const TextStyle(
//                   color: Color(0xFF00901B),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:math';

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

  // ============================================================
  // DAILY INTEREST CALCULATION
  // ============================================================

  double _calculateDailyInterest({
    required Transaction tx,
    required int days,
  }) {
    if (days <= 0 || tx.amount <= 0 || tx.interestRate <= 0) {
      return 0;
    }

    final rate = tx.interestRate;

    /*
      The selected frequency defines the period for the entered rate.

      Daily   -> rate is for 1 day
      Weekly  -> rate is for 7 days
      Monthly -> rate is for 30 days
      Yearly  -> rate is for 365 days

      We then accrue that interest DAILY.
    */

    double periodDays;

    switch (tx.interestFrequency.toLowerCase()) {
      case "daily":
        periodDays = 1;
        break;

      case "weekly":
        periodDays = 7;
        break;

      case "monthly":
        periodDays = 30;
        break;

      case "yearly":
        periodDays = 365;
        break;

      default:
        periodDays = 30;
    }

    // Interest for the selected period.
    final periodInterest =
        tx.amount * rate / 100;

    // Interest accumulated one day at a time.
    final dailyInterest =
        periodInterest / periodDays;

    // Simple Interest
    if (tx.interestType.toLowerCase() == "simple interest") {
      return dailyInterest * days;
    }

    // Compound Interest
    //
    // Compound according to the selected frequency,
    // while still calculating the elapsed time daily.
    final periods = days / periodDays;

    return tx.amount *
        (pow(1 + rate / 100, periods) - 1);
  }

  // ============================================================
  // INTEREST ROW
  // ============================================================

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

  //   final totalDays =
  //       today.difference(startDate).inDays;

  //   // No interest if transaction is today or future.
  //   if (totalDays <= 0) {
  //     return rows;
  //   }

  //   // ------------------------------------------------------------
  //   // IMPORTANT:
  //   // Interest is ALWAYS calculated up to TODAY.
  //   // Frequency only determines the rate period.
  //   // ------------------------------------------------------------

  //   final interest = _calculateDailyInterest(
  //     tx: tx,
  //     days: totalDays,
  //   );

  //   rows.add(
  //     _InterestRow(
  //       transaction: tx,
  //       startDate: startDate,
  //       endDate: today,
  //       interest: interest,
  //       customerId: customerId,
  //       onChanged: onChanged,
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

  if (!today.isAfter(startDate)) {
    return rows;
  }

  // ============================================================
  // CALCULATE INTEREST UP TO TODAY
  // ============================================================

  final interest =
      InterestCalculator.calculate(
    principal: tx.amount,
    rate: tx.interestRate,
    startDate: startDate,
    interestType: tx.interestType,
    frequency: tx.interestFrequency,
    endDate: today,
  );

  // ============================================================
  // ONE CURRENT INTEREST ROW
  // ============================================================

  rows.add(
    _InterestRow(
      transaction: tx,
      startDate: startDate,
      endDate: today,
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



  // ============================================================
  // BALANCE + TRANSACTION ROWS
  // ============================================================

  List<Widget> _buildTransactionRows(
    List<Transaction> sortedTransactions,
  ) {
    final List<Widget> rows = [];

    // ------------------------------------------------------------
    // 1. OLD -> NEW
    //    Used only for balance calculation.
    // ------------------------------------------------------------

    final balanceTransactions = [...sortedTransactions]
      ..sort(
        (a, b) => a.date.compareTo(b.date),
      );

    final Map<int, double> balanceMap = {};

    double runningBalance = 0;

    for (final tx in balanceTransactions) {
      if (tx.type == TransactionType.gave) {
        runningBalance += tx.amount;
      } else if (tx.type == TransactionType.received) {
        runningBalance -= tx.amount;
      }

      balanceMap[tx.id] = runningBalance;
    }

    // ------------------------------------------------------------
    // 2. NEW -> OLD
    // ------------------------------------------------------------

    for (final tx in sortedTransactions) {
      // ----------------------------------------------------------
      // INTEREST ROW
      // ----------------------------------------------------------

      if (tx.type == TransactionType.gave &&
          tx.interestRate > 0) {
        rows.addAll(
          _buildInterestRows(tx),
        );
      }

      // ----------------------------------------------------------
      // TRANSACTION ROW
      // ----------------------------------------------------------

      rows.add(
        TransactionRow(
          transaction: tx,
          balance: balanceMap[tx.id] ?? 0,
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
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

  // ============================================================
  // TABLE HEADER
  // ============================================================

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

// ================================================================
// HEADER
// ================================================================

class _Header extends StatelessWidget {
  final String title;

  const _Header(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
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

// ================================================================
// INTEREST ROW
// ================================================================

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

  String _getInterestDescription() {
    final start =
        DateFormat("dd MMM yyyy").format(startDate);

    final end =
        DateFormat("dd MMM yyyy").format(endDate);

    final rate =
        transaction.interestRate.toStringAsFixed(0);

    final frequency =
        transaction.interestFrequency.isEmpty
            ? "Monthly"
            : transaction.interestFrequency;

    final interestType =
        transaction.interestType.isEmpty
            ? "Simple Interest"
            : transaction.interestType;

    return "₹${interest.toStringAsFixed(2)} interest "
        "from $start to $end at $rate% "
        "$frequency $interestType interest.";
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat =
        DateFormat("dd MMM yyyy");

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        border: Border.all(
          color: const Color(0xFFAAB9CF),
        ),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          // ========================================================
          // DATE + DESCRIPTION
          // ========================================================

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${dateFormat.format(startDate)} - "
                  "${dateFormat.format(endDate)}",
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        ChopdiColors.navy,
                  ),
                ),

                const SizedBox(height: 3),

                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor:
                          Colors.transparent,
                      builder: (_) {
                        return TransactionDetailsScreen(
                          transaction:
                              transaction,
                          customerId:
                              customerId,
                          onChanged:
                              onChanged,
                        );
                      },
                    );
                  },
                  child: Text(
                    _getInterestDescription(),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Color(0xff8A93A6),
                      decoration:
                          TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ========================================================
          // GIVEN
          // ========================================================

          const Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "-",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // ========================================================
          // RECEIVED
          // ========================================================

          const Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "-",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // ========================================================
          // INTEREST
          // ========================================================

          Expanded(
            flex: 2,
            child: Align(
              alignment:
                  Alignment.centerRight,
              child: Text(
                "₹${interest.toStringAsFixed(2)}",
                style: const TextStyle(
                  color:
                      Color(0xFF00901B),
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
