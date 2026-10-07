import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';

class InterestDetailsBottomSheet extends StatelessWidget {
  final List<Transaction> transactions;
  final DateTime startDate;
  final DateTime endDate;
  final double totalInterest;
  final VoidCallback onChanged;

  const InterestDetailsBottomSheet({
    super.key,
    required this.transactions,
    required this.startDate,
    required this.endDate,
    required this.totalInterest,
    required this.onChanged,
  });

  // ---------------------------------------------------------------------------
  // DATE FORMAT
  // ---------------------------------------------------------------------------

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();

    return DateFormat(
      'dd MMM yy',
      locale,
    ).format(date);
  }

  // ---------------------------------------------------------------------------
  // SMALL ICON
  // ---------------------------------------------------------------------------

  Widget _smallIcon(String path) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(170, 185, 207, 0.35),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          path,
          width: 18,
          height: 18,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CALCULATE INTEREST FOR ONE LOAN
  // ---------------------------------------------------------------------------

  double _getLoanInterest(Transaction transaction) {
    final loanStart = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );

    final entries = InterestCalculator.calculateMonthlyBreakdown(
      principal: transaction.amount,
      rate: transaction.interestRate,
      startDate: loanStart,
      interestType: transaction.interestType,
      frequency: transaction.interestFrequency,
      endDate: endDate,
      activeLoanCount: 1,
    );

    double interest = 0;

    for (final entry in entries) {
      if (entry.startDate.year == startDate.year &&
          entry.startDate.month == startDate.month) {
        interest += entry.interest;
      }
    }

    return interest;
  }

  // ---------------------------------------------------------------------------
  // INTEREST DESCRIPTION
  // ---------------------------------------------------------------------------

  String _getInterestDescription(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();

    final monthFormat = DateFormat(
      'MMMM',
      locale,
    );

    final dateFormat = DateFormat(
      'dd MMM yy',
      locale,
    );

    final now = DateTime.now();

    final isCurrentMonth =
        startDate.year == now.year &&
            startDate.month == now.month;

    final loanCount = transactions.length;

    final loanText = loanCount == 1 ? 'loan' : 'loans';

    if (isCurrentMonth) {
      return 'Interest for ${monthFormat.format(startDate)} '
          'up to ${dateFormat.format(endDate)} '
          '($loanCount $loanText)';
    }

    return 'Interest for ${monthFormat.format(startDate)} '
        '($loanCount $loanText)';
  }

  // ---------------------------------------------------------------------------
  // SINGLE LOAN ROW
  // ---------------------------------------------------------------------------

  Widget _buildLoanCard(
      BuildContext context,
      Transaction transaction,
      ) {
    final loanInterest = _getLoanInterest(transaction);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E5EA),
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        children: [
          // ---------------------------------------------------------------
          // DATE | RATE | INTEREST
          // ---------------------------------------------------------------

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  _formatDate(
                    context,
                    transaction.date,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ChopdiColors.navy,
                  ),
                ),
              ),

              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    '${transaction.interestRate.toStringAsFixed(1)}%',
                    maxLines: 1,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4E5665),
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '₹${loanInterest.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF159B2D),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ---------------------------------------------------------------
          // LOAN AMOUNT
          // ---------------------------------------------------------------

          Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  '₹${transaction.amount.toStringAsFixed(0)}',
                  style: GoogleFonts.manrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6F7888),
                  ),
                ),
              ),

              const Expanded(
                flex: 3,
                child: SizedBox(),
              ),

              const Expanded(
                flex: 4,
                child: SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOANS TABLE
  // ---------------------------------------------------------------------------

  Widget _buildLoansSection(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD8DEE8),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------------------------------------------
            // SECTION HEADER
            // ---------------------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA),
              ),
              child: Row(
                children: [
                  _smallIcon(
                    'assets/calender_check.png',
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      'Loans in this Interest',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: ChopdiColors.navy,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    '${transactions.length} '
                        '${transactions.length == 1 ? 'Loan' : 'Loans'}',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6F7888),
                    ),
                  ),
                ],
              ),
            ),

            // ---------------------------------------------------------------
            // TABLE HEADER
            // ---------------------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2F7),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFD8DEE8),
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Date',
                      style: GoogleFonts.manrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF687386),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        'Interest Rate',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF687386),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Interest',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.manrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF687386),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------------------------------------------------------------
            // LOAN ROWS
            // ---------------------------------------------------------------

            Column(
              children: List.generate(
                transactions.length,
                    (index) {
                  return _buildLoanCard(
                    context,
                    transactions[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight:
          MediaQuery.of(context).size.height * 0.80,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF9F1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---------------------------------------------------------------
            // DRAG HANDLE
            // ---------------------------------------------------------------

            Container(
              margin: const EdgeInsets.only(
                top: 10,
                bottom: 5,
              ),
              width: 38,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF85817D),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // ---------------------------------------------------------------
            // CONTENT
            // ---------------------------------------------------------------

            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  24,
                  7,
                  24,
                  20,
                ),
                child: Column(
                  children: [
                    // -------------------------------------------------------
                    // RUPEE ICON
                    // -------------------------------------------------------

                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(
                          170,
                          185,
                          207,
                          0.6,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            'assets/currency_rupee_circle.png',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    // -------------------------------------------------------
                    // TITLE
                    // -------------------------------------------------------

                    Text(
                      'Interest Details',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF233E67),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // -------------------------------------------------------
                    // INTEREST BADGE
                    // -------------------------------------------------------

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(
                          60,
                          180,
                          80,
                          0.15,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF21A83A),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/arrow_down.png',
                            height: 14,
                            width: 14,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            'INTEREST',
                            style: GoogleFonts.manrope(
                              color: const Color(0xFF159B2D),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // -------------------------------------------------------
                    // DATE + TOTAL INTEREST
                    // -------------------------------------------------------

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [
                        _smallIcon(
                          'assets/calender_check.png',
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: Text(
                            '${_formatDate(context, startDate)}'
                                ' - '
                                '${_formatDate(context, endDate)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: ChopdiColors.navy,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          '₹${totalInterest.toStringAsFixed(2)}',
                          maxLines: 1,
                          style: GoogleFonts.manrope(
                            color: const Color(0xFF159B2D),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    // -------------------------------------------------------
                    // DESCRIPTION
                    // -------------------------------------------------------

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _getInterestDescription(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF8A93A6),
                          fontSize: 10,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 13),

                    // -------------------------------------------------------
                    // LOANS TABLE
                    // -------------------------------------------------------

                    _buildLoansSection(context),

                    const SizedBox(height: 16),

                    // -------------------------------------------------------
                    // DELETE TRANSACTION
                    // -------------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                          const Color(0xFFC74C4C),
                          minimumSize: const Size(
                            double.infinity,
                            40,
                          ),
                          padding: EdgeInsets.zero,
                          side: const BorderSide(
                            color: Color(0xFFC74C4C),
                            width: 0.8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(6),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/'
                              'delete_outline_rounded_transactions.png',
                          height: 24,
                          width: 24,
                        ),
                        label: Text(
                          'Delete Transaction',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}