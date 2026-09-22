import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
import 'package:mychopdi/widgets/took_loan_transaction_row.dart';
import 'package:mychopdi/widgets/transaction_details_bottom_sheet.dart';

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

  // ============================================================
  // DAILY INTEREST ROW
  // ============================================================

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

    // No interest if loan was taken today
    if (!today.isAfter(startDate)) {
      return rows;
    }

    final interest = InterestCalculator.calculate(
      principal: tx.amount,
      rate: tx.interestRate,
      startDate: startDate,
      interestType: tx.interestType,
      frequency: tx.interestFrequency,
      endDate: today,
    );

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

  // ============================================================
  // TRANSACTION ROWS
  // ============================================================

  List<Widget> _buildTransactionRows(
      List<Transaction> sortedTransactions,
      ) {
    final List<Widget> rows = [];

    final balanceTransactions = [...sortedTransactions]
      ..sort(
            (a, b) => a.date.compareTo(b.date),
      );

    final Map<int, double> balanceMap = {};

    double runningBalance = 0;

    for (final tx in balanceTransactions) {
      if (tx.voidedAt != null) continue;

      if (tx.type == TransactionType.took) {
        runningBalance += tx.amount;
      } else if (tx.type == TransactionType.paid) {
        runningBalance -= tx.amount;
      }

      balanceMap[tx.id] = runningBalance;
    }

    for (final tx in sortedTransactions) {
      if (tx.type == TransactionType.took &&
          tx.interestRate > 0) {
        rows.addAll(
          _buildInterestRows(tx),
        );
      }

      rows.add(
        TookLoanTransactionRow(
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
        _tableHeader(context),

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

  Widget _tableHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
        children: [
          TableRow(
            children: [
              _Header(l10n.date),
              _Header(l10n.took),
              _Header(l10n.paid),
              _Header(l10n.balance),
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
  final DateTime startDate;
  final DateTime endDate;
  final double interest;
  final Transaction transaction;
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

  String _localizedFrequency(
      BuildContext context,
      String value,
      ) {
    final l10n = AppLocalizations.of(context);

    switch (value) {
      case 'Daily':
        return l10n.daily;

      case 'Weekly':
        return l10n.weekly;

      case 'Monthly':
        return l10n.monthly;

      case 'Yearly':
        return l10n.yearly;

      default:
        return value;
    }
  }

  String _localizedInterestType(
      BuildContext context,
      String value,
      ) {
    final l10n = AppLocalizations.of(context);

    switch (value) {
      case 'Simple Interest':
        return l10n.simpleInterest;

      case 'Compound Interest':
        return l10n.compoundInterest;

      default:
        return value;
    }
  }

  String _getInterestDescription(
      BuildContext context,
      ) {
    final l10n = AppLocalizations.of(context);

    final locale =
    Localizations.localeOf(context).toLanguageTag();

    final start = DateFormat(
      "dd MMM yyyy",
      locale,
    ).format(startDate);

    final end = DateFormat(
      "dd MMM yyyy",
      locale,
    ).format(endDate);

    final rate =
    transaction.interestRate.toStringAsFixed(0);

    final frequency =
    transaction.interestFrequency.isEmpty
        ? l10n.monthly
        : _localizedFrequency(
      context,
      transaction.interestFrequency,
    );

    final interestType =
    transaction.interestType.isEmpty
        ? l10n.simpleInterest
        : _localizedInterestType(
      context,
      transaction.interestType,
    );

    return "₹${interest.toStringAsFixed(0)} "
        "${l10n.interest} "
        "${l10n.from} $start ${l10n.to} $end "
        "${l10n.ok} $rate% "
        "$frequency $interestType "
        "${l10n.interest}.";
  }

  @override
  Widget build(BuildContext context) {
    final locale =
    Localizations.localeOf(context).toLanguageTag();

    final dateFormat = DateFormat(
      "dd MMM yyyy",
      locale,
    );

    void openTransactionDetails() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: true,
        barrierColor: Colors.black54,
        builder: (_) {
          return TransactionDetailsScreen(
            transaction: transaction,
            customerId: customerId,
            onChanged: onChanged,
            displayAmount: interest,
            isInterestRow: true,
          );
        },
      );
    }

    return GestureDetector(
      onTap: openTransactionDetails,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          border: Border.all(
            color: const Color(0xFFAAB9CF),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            // ==================================
            // DATE + DESCRIPTION
            // ==================================

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
                      fontWeight: FontWeight.w600,
                      color: ChopdiColors.navy,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    _getInterestDescription(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xff8A93A6),
                      decoration:
                      TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================
            // TOOK
            // ==================================

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

            // ==================================
            // PAID
            // ==================================

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

            // ==================================
            // BALANCE / INTEREST
            // ==================================

            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "₹${interest.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Color(0xFF00901B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}