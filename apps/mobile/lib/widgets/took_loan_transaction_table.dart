import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/transaction_raw.dart';

class TookLoanTransactionTable extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onChanged;
  final int customerId;

  const TookLoanTransactionTable({
    super.key,
    required this.transactions,
    required this.onChanged,
    required this.customerId,
  });

 List<Widget> _buildTransactionRows(
  List<Transaction> sortedTransactions,
) {
  final List<Widget> rows = [];

  double runningBalance = 0;

  for (final tx in sortedTransactions) {
    // Calculate normal transaction balance
    if (tx.type == TransactionType.took) {
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

    // ==========================================
    // MONTHLY INTEREST
    // ==========================================

    if (tx.type == TransactionType.took &&
        tx.interestRate > 0) {
      
      rows.addAll(
        _buildMonthlyInterestRows(tx),
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

      rows.add(
        _InterestRow(
          startDate: periodStart,
          endDate: periodEnd,
          interest: interest,
        ),
      );

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

        // ...transactions.map((tx) {
        //   for (final tx in transactions) {

        //     if (tx.type == TransactionType.gave) {
        //       runningBalance += tx.amount;
        //     } else {
        //       runningBalance -= tx.amount;
        //     }

        //   }

        //   return TransactionRow(
        //     transaction: tx,
        //     balance: runningBalance,
        //     onChanged: onChanged, customerId: customerId,
        //   );
        // }),

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

class _InterestRow extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final double interest;

  const _InterestRow({
    required this.startDate,
    required this.endDate,
    required this.interest,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd MMM");

    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 248, 240, 1),
        border: Border.all(
          color: Color.fromRGBO(170, 185, 207, 1),
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                    const Text(
                      "Interest Added",
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Center(
                child: Text(
                  "-",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),

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

              const Center(
                child: Text(
                  "-",
                  style: TextStyle(
                    color: Colors.black,
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