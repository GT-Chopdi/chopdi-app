import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/transaction_details_bottom_sheet.dart';
import 'package:mychopdi/widgets/transaction_raw.dart';
import 'package:mychopdi/widgets/interest_details_bottom_sheet.dart';
import '../utils/interest_calculator.dart';

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
  // MONTHLY INTEREST CALCULATION
  // ============================================================

  List<_MonthlyInterestSummary> _buildMonthlyInterestSummaries(
      List<Transaction> transactions,
      ) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final Map<String, _MonthlyInterestSummary> monthly = {};

    // ==========================================================
    // ONLY GIVEN TRANSACTIONS WITH INTEREST
    // ==========================================================

    final interestTransactions = transactions.where(
          (tx) =>
      tx.type == TransactionType.gave &&
          tx.interestRate > 0 &&
          tx.amount > 0,
    );

    // ==========================================================
    // CALCULATE EACH LOAN
    // ==========================================================

    for (final tx in interestTransactions) {
      final startDate = DateTime(
        tx.date.year,
        tx.date.month,
        tx.date.day,
      );

      // Ignore future loans.
      if (startDate.isAfter(today)) {
        continue;
      }

      // No interest on transaction date itself.
      if (!today.isAfter(startDate)) {
        continue;
      }

      // ========================================================
      // IMPORTANT:
      // InterestCalculator remains the single source of truth.
      // ========================================================

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

      // ========================================================
      // ADD INTEREST TO MONTH
      // ========================================================

      for (final entry in monthlyEntries) {
        if (entry.interest <= 0) {
          continue;
        }

        final monthKey =
            '${entry.startDate.year}-${entry.startDate.month}';

        final existing = monthly[monthKey];

        if (existing == null) {
          monthly[monthKey] = _MonthlyInterestSummary(
            year: entry.startDate.year,
            month: entry.startDate.month,
            interest: entry.interest,
            transactions: [tx],
          );
        } else {
          existing.interest += entry.interest;

          // Avoid duplicate transaction.
          if (!existing.transactions.any(
                (item) => item.id == tx.id,
          )) {
            existing.transactions.add(tx);
          }
        }
      }
    }

    // ==========================================================
    // SORT MONTHS NEWEST → OLDEST
    // ==========================================================

    final summaries = monthly.values.toList()
      ..sort(
            (a, b) {
          final aDate = DateTime(
            a.year,
            a.month,
          );

          final bDate = DateTime(
            b.year,
            b.month,
          );

          return bDate.compareTo(aDate);
        },
      );

    return summaries;
  }

  // ============================================================
  // BALANCE + TRANSACTION ROWS
  // ============================================================

  List<Widget> _buildTransactionRows(
      BuildContext context,
      List<Transaction> sortedTransactions,
      ) {
    final List<Widget> rows = [];

    // ==========================================================
    // OLD → NEW
    //
    // Only used for balance calculation.
    // ==========================================================

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

    // ==========================================================
    // MONTHLY INTEREST
    // ==========================================================

    final interestSummaries =
    _buildMonthlyInterestSummaries(
      sortedTransactions,
    );

    final Map<String, _MonthlyInterestSummary>
    interestByMonth = {};

    for (final summary in interestSummaries) {
      interestByMonth[
      '${summary.year}-${summary.month}'
      ] = summary;
    }

    // ==========================================================
    // FIND FIRST LOAN / FIRST INTEREST START DATE
    //
    // Example:
    //
    // Loan 1 = 10 Feb
    //
    // First period:
    // 10 Feb → 28 Feb
    //
    // All following months:
    // 01 Mar → 31 Mar
    // 01 Apr → 30 Apr
    // 01 May → 31 May
    // ==========================================================

    DateTime? firstLoanDate;

    for (final tx in sortedTransactions) {
      if (tx.type != TransactionType.gave) {
        continue;
      }

      if (tx.interestRate <= 0) {
        continue;
      }

      if (tx.amount <= 0) {
        continue;
      }

      final loanDate = DateTime(
        tx.date.year,
        tx.date.month,
        tx.date.day,
      );

      if (firstLoanDate == null ||
          loanDate.isBefore(firstLoanDate)) {
        firstLoanDate = loanDate;
      }
    }

    // ==========================================================
    // ALL MONTHS
    // ==========================================================

    final Set<String> monthKeys = {};

    for (final tx in sortedTransactions) {
      monthKeys.add(
        '${tx.date.year}-${tx.date.month}',
      );
    }

    monthKeys.addAll(
      interestByMonth.keys,
    );

    final sortedMonthKeys = monthKeys.toList()
      ..sort(
            (a, b) {
          final aParts = a.split('-');
          final bParts = b.split('-');

          final aDate = DateTime(
            int.parse(aParts[0]),
            int.parse(aParts[1]),
          );

          final bDate = DateTime(
            int.parse(bParts[0]),
            int.parse(bParts[1]),
          );

          return bDate.compareTo(aDate);
        },
      );

    // ==========================================================
    // LOCALE
    // ==========================================================

    final locale =
    Localizations.localeOf(context).toLanguageTag();

    final dateFormat = DateFormat(
      'dd MMM yy',
      locale,
    );

    final monthFormat = DateFormat(
      'MMMM',
      locale,
    );

    final now = DateTime.now();

    // ==========================================================
    // BUILD TIMELINE
    // ==========================================================

    for (final monthKey in sortedMonthKeys) {
      final parts = monthKey.split('-');

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      // ========================================================
      // TRANSACTIONS OF THIS MONTH
      // ========================================================

      final monthTransactions = sortedTransactions
          .where(
            (tx) =>
        tx.date.year == year &&
            tx.date.month == month,
      )
          .toList()
        ..sort(
              (a, b) => b.date.compareTo(a.date),
        );

      // ========================================================
      // 1. MONTHLY INTEREST
      //
      // ALWAYS BEFORE NORMAL TRANSACTIONS.
      // ========================================================

      final summary =
      interestByMonth[monthKey];

      if (summary != null) {
        // ======================================================
        // MONTH START
        // ======================================================

        final monthStart = DateTime(
          year,
          month,
          1,
        );

        // ======================================================
        // LAST DAY OF MONTH
        // ======================================================

        final lastDayOfMonth = DateTime(
          year,
          month + 1,
          0,
        );

        // ======================================================
        // CURRENT MONTH
        // ======================================================

        final isCurrentMonth =
            year == now.year &&
                month == now.month;

        final monthEnd = isCurrentMonth
            ? DateTime(
          now.year,
          now.month,
          now.day,
        )
            : lastDayOfMonth;

        // ======================================================
        // IMPORTANT FIX
        //
        // FIRST INTEREST MONTH:
        //
        // Loan = 10 Feb
        // 10 Feb → 28 Feb
        //
        // ALL NEXT MONTHS:
        //
        // 01 Mar → 31 Mar
        // 01 Apr → 30 Apr
        // 01 May → 31 May
        // 01 Jun → 30 Jun
        // 01 Jul → 31 Jul
        // 01 Aug → 31 Aug
        //
        // Even if another loan is added on 12 Aug,
        // August still displays:
        //
        // 01 Aug → 31 Aug
        // ======================================================

        DateTime displayStart;

        if (firstLoanDate != null &&
            year == firstLoanDate.year &&
            month == firstLoanDate.month) {
          // FIRST INTEREST PERIOD

          displayStart = firstLoanDate;
        } else {
          // ALL FOLLOWING MONTHS

          displayStart = monthStart;
        }

        // ======================================================
        // LOAN COUNT
        //
        // Number of loans contributing to this month.
        // ======================================================

        final loanCount =
            summary.transactions.length;

        final loanText =
        loanCount == 1 ? 'loan' : 'loans';

        // ======================================================
        // DESCRIPTION
        // ======================================================

        String description;

        if (isCurrentMonth) {
          description =
          'Interest for '
              '${monthFormat.format(monthStart)} '
              'up to '
              '${dateFormat.format(monthEnd)} '
              '($loanCount $loanText)';
        } else {
          description =
          'Interest for '
              '${monthFormat.format(monthStart)} '
              '($loanCount $loanText)';
        }

        // ======================================================
        // HIGHLIGHT
        // ======================================================

        final isHighlighted =
            highlightTransactionId != null &&
                summary.transactions.any(
                      (tx) =>
                  tx.id ==
                      highlightTransactionId,
                );

        // ======================================================
        // INTEREST ROW
        //
        // Interest
        // Loan
        // ======================================================

        rows.add(
          _InterestRow(
            transaction:
            summary.transactions.first,
            startDate: displayStart,
            endDate: monthEnd,
            interest: summary.interest,
            customerUuid: customerUuid,
            onChanged: onChanged,
            isHighlighted: isHighlighted,
            descriptionOverride: description,
          ),
        );

        rows.add(
          const SizedBox(
            height: 8,
          ),
        );
      }

      // ========================================================
      // 2. NORMAL TRANSACTIONS
      //
      // Interest is above these rows.
      // ========================================================

      for (final tx in monthTransactions) {
        rows.add(
          TransactionRow(
            transaction: tx,
            balance: balanceMap[tx.id] ?? 0,
            onChanged: onChanged,
            customerUuid: customerUuid,
            isHighlighted:false,
            // tx.id == highlightTransactionId,
          ),
        );

        rows.add(
          const SizedBox(
            height: 8,
          ),
        );
      }
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

        const SizedBox(
          height: 8,
        ),

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

  Widget _tableHeader(
      BuildContext context,
      ) {
    final l10n =
    AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        border: Border.all(
          color: const Color(0xFFAAB9CF),
        ),
        borderRadius:
        BorderRadius.circular(10),
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
              _Header(l10n.date, verticalOffset: 2),
              _Header(l10n.given, verticalOffset: 2),
              _Header(l10n.received, verticalOffset: 0),
              _Header(l10n.balance, verticalOffset: 0),
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

  final List<Transaction> transactions;

  _MonthlyInterestSummary({
    required this.year,
    required this.month,
    required this.interest,
    required this.transactions,
  });
}

// ================================================================
// HEADER
// ================================================================

class _Header extends StatelessWidget {
  final String title;
  final double verticalOffset;
  const _Header(this.title, {this.verticalOffset = 0});

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

  final bool isHighlighted;
  final String? descriptionOverride;

  const _InterestRow({
    required this.transaction,
    required this.startDate,
    required this.endDate,
    required this.interest,
    required this.customerUuid,
    required this.onChanged,
    this.isHighlighted = false,
    this.descriptionOverride,
  });

  // ============================================================
  // LOCALIZED FREQUENCY
  // ============================================================

  String _localizedFrequency(
      BuildContext context,
      String value,
      ) {
    final l10n =
    AppLocalizations.of(context);

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
    final l10n =
    AppLocalizations.of(context);

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
    if (descriptionOverride != null &&
        descriptionOverride!.isNotEmpty) {
      return descriptionOverride!;
    }

    final l10n =
    AppLocalizations.of(context);

    final locale =
    Localizations.localeOf(context)
        .toLanguageTag();

    final start = DateFormat(
      'dd MMM yyyy',
      locale,
    ).format(startDate);

    final end = DateFormat(
      'dd MMM yyyy',
      locale,
    ).format(endDate);

    final rate =
    transaction.interestRate
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

    return '₹${interest.toStringAsFixed(2)} '
        '${l10n.interest.toLowerCase()} '
        '${l10n.from} $start ${l10n.to} $end '
        '${l10n.at} $rate% '
        '$frequency $interestType '
        '${l10n.interest.toLowerCase()}.';
  }

  // ============================================================
  // BUILD INTEREST ROW
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final locale =
    Localizations.localeOf(context)
        .toLanguageTag();

    final dateFormat = DateFormat(
      'dd MMM yy',
      locale,
    );

    // ==========================================================
    // OPEN TRANSACTION DETAILS
    // ==========================================================

    void openTransactionDetails() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor:
        Colors.transparent,
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

    // ==========================================================
    // INTEREST ROW
    // ==========================================================

    return GestureDetector(
      onTap: openTransactionDetails,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 400,
        ),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFFE4EAF2)
              : const Color(0xFFFFFBF6),
          borderRadius:
          BorderRadius.circular(10),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF243B67)
                : const Color(0xFFD4D9E2),
            width:
            isHighlighted ? 1.6 : 1,
          ),
          boxShadow: isHighlighted
              ? [
            BoxShadow(
              color: const Color(
                0xFF243B67,
              ).withValues(
                alpha: 0.14,
              ),
              blurRadius: 8,
              spreadRadius: 0.5,
              offset: const Offset(
                0,
                2,
              ),
            ),
          ]
              : [
            BoxShadow(
              color:
              Colors.black.withValues(
                alpha: 0.025,
              ),
              blurRadius: 3,
              offset: const Offset(
                0,
                1,
              ),
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
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    '${dateFormat.format(startDate)} - '
                        '${dateFormat.format(endDate)}',
                    style:
                    GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight:
                      isHighlighted
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color:
                      ChopdiColors.navy,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    _getInterestDescription(
                      context,
                    ),
                    maxLines: 3,
                    softWrap: true,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isHighlighted
                          ? Colors.black87
                          : const Color(
                        0xff8A93A6,
                      ),
                      fontWeight:
                      isHighlighted
                          ? FontWeight.w600
                          : FontWeight.normal,
                      decoration:
                      TextDecoration
                          .underline,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // GIVEN
            // ==================================================

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

            // ==================================================
            // RECEIVED
            // ==================================================

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

            // ==================================================
            // BALANCE / INTEREST
            // ==================================================

            Expanded(
              flex: 2,
              child: Align(
                alignment:
                Alignment.centerRight,
                child: Text(
                  '₹${interest.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: const Color(
                      0xFF00901B,
                    ),
                    fontWeight:
                    isHighlighted
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