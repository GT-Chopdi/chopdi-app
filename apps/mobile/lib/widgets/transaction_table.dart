import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/transaction_details_bottom_sheet.dart';
import 'package:mychopdi/widgets/transaction_raw.dart';

class TransactionTable extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onChanged;
  final String customerUuid;

  final int? highlightTransactionId;

  const TransactionTable({
    super.key,
    required this.transactions,
    required this.onChanged,
    required this.customerUuid,
    this.highlightTransactionId,
  });

  // ============================================================
  // DAILY INTEREST CALCULATION
  // ============================================================

  double _calculateDailyInterest({
    required Transaction tx,
    required int days,
  }) {
    if (days <= 0 ||
        tx.amount <= 0 ||
        tx.interestRate <= 0) {
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
    final periodInterest = tx.amount * rate / 100;

    // Interest accumulated one day at a time.
    final dailyInterest = periodInterest / periodDays;

    // Simple Interest
    if (tx.interestType.toLowerCase() == "simple interest") {
      return dailyInterest * days;
    }

    // Compound Interest
    final periods = days / periodDays;

    return tx.amount *
        (pow(
          1 + rate / 100,
          periods,
        ) -
            1);
  }

  // ============================================================
  // ADD ONE YEAR
  // ============================================================

  DateTime _addOneYear(DateTime date) {
    final nextYear = date.year + 1;

    // Handle Feb 29 safely.
    if (date.month == 2 && date.day == 29) {
      return DateTime(nextYear, 2, 28);
    }

    return DateTime(
      nextYear,
      date.month,
      date.day,
    );
  }

  // ============================================================
  // ADD ONE MONTH
  // ============================================================

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
  // INTEREST ROW
  // ============================================================

  List<Widget> _buildInterestRows(
      Transaction tx,
      ) {
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

    // No interest on the transaction date.
    if (!today.isAfter(startDate)) {
      return rows;
    }

    // ==========================================================
    // KEEP EXISTING AMOUNT LOGIC
    // ==========================================================

    final totalDays = today.difference(startDate).inDays;

    final dailyInterest = _calculateDailyInterest(
      tx: tx,
      days: 1,
    );

    final totalInterest = dailyInterest * totalDays;

    // ==========================================================
    // DISPLAY DATE BASED ON SELECTED FREQUENCY
    // ==========================================================

    DateTime displayEndDate;

    switch (tx.interestFrequency.toLowerCase()) {
      case "daily":
        displayEndDate = startDate.add(
          const Duration(days: 1),
        );
        break;

      case "weekly":
        displayEndDate = startDate.add(
          const Duration(days: 7),
        );
        break;

      case "monthly":
        displayEndDate = _addOneMonth(startDate);
        break;

      case "yearly":
        displayEndDate = _addOneYear(startDate);
        break;

      default:
        displayEndDate = _addOneMonth(startDate);
        break;
    }

    rows.add(
      _InterestRow(
        transaction: tx,
        startDate: startDate,
        endDate: displayEndDate,
        interest: totalInterest,
        customerUuid: customerUuid,
        onChanged: onChanged,

        // ======================================================
        // IMPORTANT
        // ======================================================
        // The notification transaction ID belongs to the loan
        // transaction, but visually we highlight the INTEREST row.
        isHighlighted: tx.id == highlightTransactionId,
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

    // ----------------------------------------------------------
    // OLD -> NEW
    // Used only for balance calculation.
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // NEW -> OLD
    // ----------------------------------------------------------

    for (final tx in sortedTransactions) {
      // --------------------------------------------------------
      // INTEREST ROW
      // --------------------------------------------------------

      if (tx.type == TransactionType.gave &&
          tx.interestRate > 0) {
        rows.addAll(
          _buildInterestRows(tx),
        );
      }

      // --------------------------------------------------------
      // NORMAL TRANSACTION ROW
      // --------------------------------------------------------

      rows.add(
        TransactionRow(
          transaction: tx,
          balance: balanceMap[tx.id] ?? 0,
          onChanged: onChanged,
          customerUuid: customerUuid,

          // IMPORTANT:
          // Do NOT highlight the normal transaction here.
          //
          // The notification transaction ID is used above
          // to highlight the corresponding interest row.
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

  Widget _tableHeader(
      BuildContext context,
      ) {
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
              _Header(l10n.given),
              _Header(l10n.received),
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
  Widget build(
      BuildContext context,
      ) {
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
  final String customerUuid;
  final VoidCallback onChanged;

  // ============================================================
  // HIGHLIGHT
  // ============================================================

  final bool isHighlighted;

  const _InterestRow({
    required this.transaction,
    required this.startDate,
    required this.endDate,
    required this.interest,
    required this.customerUuid,
    required this.onChanged,
    this.isHighlighted = false,
  });

  // ============================================================
  // LOCALIZED FREQUENCY
  // ============================================================

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

  // ============================================================
  // LOCALIZED INTEREST TYPE
  // ============================================================

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

  // ============================================================
  // INTEREST DESCRIPTION
  // ============================================================

  String _getInterestDescription(
      BuildContext context,
      ) {
    final l10n = AppLocalizations.of(context);

    final locale = Localizations.localeOf(context)
        .toLanguageTag();

    final start = DateFormat(
      "dd MMM yyyy",
      locale,
    ).format(startDate);

    final end = DateFormat(
      "dd MMM yyyy",
      locale,
    ).format(endDate);

    final rate = transaction.interestRate
        .toStringAsFixed(0);

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

    return "₹${interest.toStringAsFixed(2)} "
        "${l10n.interest.toLowerCase()} "
        "${l10n.from} $start ${l10n.to} $end "
        "${l10n.at} $rate% "
        "$frequency $interestType "
        "${l10n.interest.toLowerCase()}.";
  }

  // ============================================================
  // BUILD INTEREST ROW
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final locale = Localizations.localeOf(context)
        .toLanguageTag();

    final dateFormat = DateFormat(
      "dd MMM yy",
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
            customerUuid: customerUuid,
            onChanged: onChanged,
            displayAmount: interest,
            isInterestRow: true,
          );
        },
      );
    }

    return GestureDetector(
      onTap: openTransactionDetails,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          // ======================================================
          // INTEREST HIGHLIGHT
          // ======================================================

          color: isHighlighted
              ? const Color(0xFFE4EAF2)
              : const Color(0xFFFFFBF6),

          borderRadius: BorderRadius.circular(10),

          // ======================================================
          // BLUE / NAVY BORDER
          // ======================================================

          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF243B67)
                : const Color(0xFFD4D9E2),
            width: isHighlighted ? 1.6 : 1,
          ),

          // ======================================================
          // SOFT SHADOW
          // ======================================================

          boxShadow: isHighlighted
              ? [
            BoxShadow(
              color: const Color(0xFF243B67).withValues(
                alpha: 0.14,
              ),
              blurRadius: 8,
              spreadRadius: 0.5,
              offset: const Offset(0, 2),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.025,
              ),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
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
                      fontWeight: isHighlighted
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: ChopdiColors.navy,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    _getInterestDescription(
                      context,
                    ),
                    maxLines: 3,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isHighlighted
                          ? Colors.black87
                          : const Color(0xff8A93A6),
                      fontWeight: isHighlighted
                          ? FontWeight.w600
                          : FontWeight.normal,
                      decoration:
                      TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

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

            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "₹${interest.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: const Color(0xFF00901B),
                    fontWeight: isHighlighted
                        ? FontWeight.w900
                        : FontWeight.bold,
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