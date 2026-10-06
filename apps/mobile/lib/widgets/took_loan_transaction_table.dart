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
  final String lenderUuid;

  // ============================================================
  // HIGHLIGHTED TRANSACTION
  // ============================================================

  final int? highlightTransactionId;

  const TookLoanTransactionTable({
    super.key,
    required this.transactions,
    required this.onChanged,
    required this.lenderUuid,
    this.highlightTransactionId,
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
        lenderUuid: lenderUuid,
        onChanged: onChanged,

        // ======================================================
        // IMPORTANT
        // ======================================================
        // The notification transaction ID belongs to the loan
        // transaction, but we highlight the INTEREST row.
        isHighlighted: tx.id == highlightTransactionId,
      ),
    );

    rows.add(
      const SizedBox(height: 8),
    );

    return rows;
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
  // TRANSACTION ROWS
  // ============================================================

  List<Widget> _buildTransactionRows(
      List<Transaction> sortedTransactions,
      ) {
    final List<Widget> rows = [];

    // ----------------------------------------------------------
    // Calculate balance OLD → NEW
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // Display NEW → OLD
    // ----------------------------------------------------------

    for (final tx in sortedTransactions) {
      // --------------------------------------------------------
      // Interest row
      // --------------------------------------------------------

      if (tx.type == TransactionType.took &&
          tx.interestRate > 0) {
        rows.addAll(
          _buildInterestRows(tx),
        );
      }

      // --------------------------------------------------------
      // Normal transaction row
      // --------------------------------------------------------

      rows.add(
        TookLoanTransactionRow(
          transaction: tx,
          balance: balanceMap[tx.id] ?? 0,
          onChanged: onChanged,
          lenderUuid: lenderUuid,

          // IMPORTANT:
          // Do NOT highlight the normal loan transaction.
          //
          // The notification ID is used above to highlight
          // its corresponding interest row.
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
  final DateTime startDate;
  final DateTime endDate;
  final double interest;
  final Transaction transaction;
  final String lenderUuid;
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
    required this.lenderUuid,
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

  // ============================================================
  // BUILD INTEREST ROW
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final locale =
    Localizations.localeOf(context).toLanguageTag();

    final dateFormat = DateFormat(
      "dd MMM yy",
      locale,
    );

    // ----------------------------------------------------------
    // OPEN TRANSACTION DETAILS
    // ----------------------------------------------------------

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
            lenderUuid: lenderUuid,
            onChanged: onChanged,
            displayAmount: interest,
            isInterestRow: true,
          );
        },
      );
    }

    // ----------------------------------------------------------
    // INTEREST ROW
    // ----------------------------------------------------------

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
            // ==================================================
            // DATE + DESCRIPTION
            // ==================================================

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
                    _getInterestDescription(context),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 10,
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

            // ==================================================
            // TOOK
            // ==================================================

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

            // ==================================================
            // PAID
            // ==================================================

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

            // ==================================================
            // BALANCE / INTEREST
            // ==================================================

            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "₹${interest.toStringAsFixed(0)}",
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