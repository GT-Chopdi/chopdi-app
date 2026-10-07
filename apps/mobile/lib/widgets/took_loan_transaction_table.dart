import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
import 'package:mychopdi/widgets/interest_details_bottom_sheet.dart';
import 'package:mychopdi/widgets/took_loan_transaction_row.dart';

class TookLoanTransactionTable extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onChanged;
  final String lenderUuid;
  final int? highlightTransactionId;

  const TookLoanTransactionTable({
    super.key,
    required this.transactions,
    required this.onChanged,
    required this.lenderUuid,
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
    // ONLY TOOK TRANSACTIONS WITH INTEREST
    // ==========================================================

    final interestTransactions = transactions.where(
          (tx) =>
      tx.type == TransactionType.took &&
          tx.interestRate > 0 &&
          tx.amount > 0 &&
          tx.voidedAt == null,
    );

    // ==========================================================
    // CALCULATE INTEREST FOR EACH LOAN
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

      // No interest on the transaction date itself.
      if (!today.isAfter(startDate)) {
        continue;
      }

      // ========================================================
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
          // Aggregate all loans for this month.
          existing.interest += entry.interest;

          // Avoid duplicate loan transaction.
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
  // TRANSACTION ROWS
  // ============================================================

  List<Widget> _buildTransactionRows(
      BuildContext context,
      List<Transaction> sortedTransactions,
      ) {
    final List<Widget> rows = [];

    // ==========================================================
    // BALANCE
    // OLD → NEW
    // ==========================================================

    final balanceTransactions = [...sortedTransactions]
      ..sort(
            (a, b) => a.date.compareTo(b.date),
      );

    final Map<int, double> balanceMap = {};

    double runningBalance = 0;

    for (final tx in balanceTransactions) {
      if (tx.voidedAt != null) {
        continue;
      }

      if (tx.type == TransactionType.took) {
        runningBalance += tx.amount;
      } else if (tx.type == TransactionType.paid) {
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
    // FIND FIRST LOAN DATE
    //
    // Example:
    //
    // First loan = 10 Feb
    //
    // First period:
    // 10 Feb → 28 Feb
    //
    // Next periods:
    // 01 Mar → 31 Mar
    // 01 Apr → 30 Apr
    // 01 May → 31 May
    // ...
    // ==========================================================

    DateTime? firstLoanDate;

    for (final tx in sortedTransactions) {
      if (tx.voidedAt != null) {
        continue;
      }

      if (tx.type != TransactionType.took) {
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
      if (tx.voidedAt != null) {
        continue;
      }

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
    // DATE FORMATS
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
      // TRANSACTIONS FOR THIS MONTH
      // ========================================================

      final monthTransactions = sortedTransactions
          .where(
            (tx) =>
        tx.voidedAt == null &&
            tx.date.year == year &&
            tx.date.month == month,
      )
          .toList()
        ..sort(
              (a, b) => b.date.compareTo(a.date),
        );

      // ========================================================
      // MONTHLY INTEREST
      //
      // IMPORTANT:
      //
      // Interest MUST come BEFORE Loan Taken.
      //
      // UI:
      //
      // Interest
      // Loan Taken
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
        // IMPORTANT:
        //
        // ONLY THE FIRST INTEREST MONTH USES THE
        // ACTUAL FIRST LOAN DATE.
        //
        // ALL FOLLOWING MONTHS START ON 01.
        // ======================================================

        final DateTime displayStart;

        if (firstLoanDate != null &&
            year == firstLoanDate.year &&
            month == firstLoanDate.month) {
          // FIRST INTEREST PERIOD
          //
          // Example:
          // Loan = 10 Feb
          //
          // 10 Feb → 28 Feb

          displayStart = firstLoanDate;
        } else {
          // ALL FOLLOWING MONTHS
          //
          // 01 Mar → 31 Mar
          // 01 Apr → 30 Apr
          // 01 May → 31 May
          // 01 Jun → 30 Jun
          // 01 Jul → 31 Jul
          // 01 Aug → 31 Aug

          displayStart = monthStart;
        }

        // ======================================================
        // LOAN COUNT
        // ======================================================

        final loanCount =
            summary.transactions.length;

        final loanText =
        loanCount == 1
            ? 'loan'
            : 'loans';

        // ======================================================
        // DESCRIPTION
        // ======================================================

        final String description;

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
        // HIGHLIGHT INTEREST
        // ======================================================

        final isHighlighted =
            highlightTransactionId != null &&
                summary.transactions.any(
                      (tx) =>
                  tx.id ==
                      highlightTransactionId,
                );

        // ======================================================
        // ADD INTEREST ROW FIRST
        // ======================================================

        rows.add(
          _InterestRow(
            transactions: summary.transactions,
            startDate: displayStart,
            endDate: monthEnd,
            interest: summary.interest,
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
      // NORMAL TRANSACTIONS
      //
      // These come AFTER the interest row.
      // ========================================================

      for (final tx in monthTransactions) {
        rows.add(
          TookLoanTransactionRow(
            transaction: tx,
            balance: balanceMap[tx.id] ?? 0,
            onChanged: onChanged,
            lenderUuid: lenderUuid,
            isHighlighted: false,
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
  Widget build(
      BuildContext context,
      ) {
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
              _Header(
                l10n.date,
                verticalOffset: 2,
              ),
              _Header(
                l10n.took,
                verticalOffset: 2,
              ),
              _Header(
                l10n.paid,
                verticalOffset: 0,
              ),
              _Header(
                l10n.balance,
                verticalOffset: 0,
              ),
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

  const _Header(
    this.title, {
    this.verticalOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Center(
        child: Transform.translate(
          offset: Offset(0, verticalOffset),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: ChopdiColors.navy,
              ),
            ),
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

  /// All loans which contributed to this month's interest.
  final List<Transaction> transactions;

  final VoidCallback onChanged;

  final bool isHighlighted;
  final String? descriptionOverride;

  const _InterestRow({
    required this.transactions,
    required this.startDate,
    required this.endDate,
    required this.interest,
    required this.onChanged,
    this.isHighlighted = false,
    this.descriptionOverride,
  });

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

    final loanCount =
        transactions.length;

    final loanText =
    loanCount == 1
        ? 'loan'
        : 'loans';

    return '₹${interest.toStringAsFixed(2)} '
        'Interest '
        'from $start to $end '
        '($loanCount $loanText)';
  }

  // ============================================================
  // OPEN INTEREST DETAILS
  // ============================================================

  void _openInterestDetails(
      BuildContext context,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black54,
      builder: (_) {
        return InterestDetailsBottomSheet(
          transactions: transactions,
          startDate: startDate,
          endDate: endDate,
          totalInterest: interest,
          onChanged: onChanged,
        );
      },
    );
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

    return GestureDetector(
      onTap: () => _openInterestDetails(context),
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
                    overflow:
                    TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 10,
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
                  '-',
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
                  '-',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // ==================================================
            // INTEREST
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