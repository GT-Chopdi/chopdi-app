import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/transaction_details_bottom_sheet.dart';
import 'package:mychopdi/widgets/transaction_raw.dart';

import '../utils/interest_calculator.dart';

class TransactionTable extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onChanged;
  final String customerUuid;

  const TransactionTable({
    super.key,
    required this.transactions,
    required this.onChanged,
    required this.customerUuid,
  });

  // ============================================================
  // MONTHLY INTEREST CALCULATION
  // ============================================================

  List<Widget> _buildMonthlyInterestRows(
      BuildContext context,
      List<Transaction> transactions,
      ) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final Map<String, _MonthlyInterestSummary> monthly = {};

    // Only transactions that can generate interest.
    final interestTransactions = transactions.where(
          (tx) =>
      tx.type == TransactionType.gave &&
          tx.interestRate > 0 &&
          tx.amount > 0,
    );

    for (final tx in interestTransactions) {
      final startDate = DateTime(
        tx.date.year,
        tx.date.month,
        tx.date.day,
      );

      // Do not calculate interest for a future transaction.
      if (startDate.isAfter(today)) {
        continue;
      }

      // No interest on the transaction date itself.
      if (!today.isAfter(startDate)) {
        continue;
      }

      // Calculate monthly interest for this individual loan.
      final monthlyEntries =
      InterestCalculator.calculateMonthlyBreakdown(
        principal: tx.amount,
        rate: tx.interestRate,
        startDate: startDate,
        interestType: tx.interestType,
        frequency: tx.interestFrequency,
        endDate: today,
        activeLoanCount: 1,
      );

      for (final entry in monthlyEntries) {
        if (entry.interest <= 0) {
          continue;
        }

        // Every year/month combination gets one UI row.
        final monthKey =
            '${entry.startDate.year}-${entry.startDate.month}';

        final existing = monthly[monthKey];

        if (existing == null) {
          monthly[monthKey] = _MonthlyInterestSummary(
            year: entry.startDate.year,
            month: entry.startDate.month,
            interest: entry.interest,
            loanCount: 1,
            transaction: tx,
          );
        } else {
          // Combine this loan's interest with the existing
          // interest for the same month.
          existing.interest += entry.interest;
          existing.loanCount++;
        }
      }
    }

    // Newest month first.
    final summaries = monthly.values.toList()
      ..sort((a, b) {
        final aDate = DateTime(
          a.year,
          a.month,
        );

        final bDate = DateTime(
          b.year,
          b.month,
        );

        return bDate.compareTo(aDate);
      });

    final List<Widget> rows = [];

    final locale = Localizations.localeOf(
      context,
    ).toLanguageTag();

    final monthFormat = DateFormat(
      'MMM yy',
      locale,
    );

    final dayMonthFormat = DateFormat(
      'dd MMM',
      locale,
    );

    for (final summary in summaries) {
      final monthStart = DateTime(
        summary.year,
        summary.month,
        1,
      );

      final isCurrentMonth =
          summary.year == today.year &&
              summary.month == today.month;

      // Past month:
      // 1st -> last day of month.
      //
      // Current month:
      // 1st -> today.
      final monthEnd = isCurrentMonth
          ? today
          : DateTime(
        summary.year,
        summary.month + 1,
        0,
      );

      final monthName = monthFormat.format(
        monthStart,
      );

      final loanText =
      summary.loanCount == 1 ? 'loan' : 'loans';

      final description = isCurrentMonth
          ? 'Interest for $monthName up to '
          '${dayMonthFormat.format(today)} '
          '(${summary.loanCount} $loanText)'
          : 'Interest for $monthName '
          '(${summary.loanCount} $loanText)';

      rows.add(
        _InterestRow(
          transaction: summary.transaction,
          startDate: monthStart,
          endDate: monthEnd,
          interest: summary.interest,
          customerUuid: customerUuid,
          onChanged: onChanged,
          description: description,
        ),
      );

      rows.add(
        const SizedBox(height: 8),
      );
    }

    return rows;
  }

  // ============================================================
  // BALANCE + TRANSACTION ROWS
  // ============================================================

  List<Widget> _buildTransactionRows(
      BuildContext context,
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
    // 2. MONTHLY INTEREST
    //
    //    IMPORTANT:
    //    Interest is generated ONCE per month.
    //
    //    If:
    //      Loan 1 -> August, September, October
    //      Loan 2 -> September, October
    //
    //    UI becomes:
    //
    //      August    -> Loan 1
    //      September -> Loan 1 + Loan 2
    //      October   -> Loan 1 + Loan 2
    //
    //    Instead of creating a separate row for every loan.
    // ------------------------------------------------------------

    final interestRows = _buildMonthlyInterestRows(
      context,
      sortedTransactions,
    );

    if (interestRows.isNotEmpty) {
      rows.addAll(interestRows);

      rows.add(
        const SizedBox(height: 8),
      );
    }

    // ------------------------------------------------------------
    // 3. NEW -> OLD TRANSACTION ROWS
    // ------------------------------------------------------------

    for (final tx in sortedTransactions) {
      rows.add(
        TransactionRow(
          transaction: tx,
          balance: balanceMap[tx.id] ?? 0,
          onChanged: onChanged,
          customerUuid: customerUuid,
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
          context,
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
// MONTHLY INTEREST SUMMARY
// ================================================================

class _MonthlyInterestSummary {
  final int year;
  final int month;

  double interest;
  int loanCount;

  // Original transaction is kept so the interest row can open
  // the transaction details screen.
  final Transaction transaction;

  _MonthlyInterestSummary({
    required this.year,
    required this.month,
    required this.interest,
    required this.loanCount,
    required this.transaction,
  });
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
  final String customerUuid;
  final VoidCallback onChanged;
  final String? description;

  const _InterestRow({
    required this.transaction,
    required this.startDate,
    required this.endDate,
    required this.interest,
    required this.customerUuid,
    required this.onChanged,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final locale =
    Localizations.localeOf(context).toLanguageTag();

    final dateFormat = DateFormat(
      'dd MMM yy',
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
      child: Container(
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
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                    '${dateFormat.format(startDate)} - '
                        '${dateFormat.format(endDate)}',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ChopdiColors.navy,
                    ),
                  ),

                  const SizedBox(height: 3),

                  if (description != null &&
                      description!.isNotEmpty)
                    Text(
                      description!,
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xff8A93A6),
                        decoration:
                        TextDecoration.underline,
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
                  '-',
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
                  '-',
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
                alignment: Alignment.centerRight,
                child: Text(
                  '₹${interest.toStringAsFixed(2)}',
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