import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/edit_transaction_bottom_sheet.dart';
import 'package:mychopdi/widgets/delete_transactions_bottom_sheet.dart';
import 'package:mychopdi/widgets/edit_transaction_details.dart';
import 'package:mychopdi/data/repository/repositories.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;
  final int customerId;
  final VoidCallback? onChanged;

  // For interest rows, this contains the calculated interest amount.
  final double? displayAmount;

  final bool isInterestRow;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
    required this.customerId,
    required this.onChanged,
    this.displayAmount,
    this.isInterestRow = false,
  });

  // ================================================================
  // TRANSACTION TITLE
  // ================================================================

  String _getTransactionTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isInterestRow) {
      return l10n.interestDetails;
    }

    return l10n.transactionDetails;
  }

  // ================================================================
  // BADGE TEXT
  // ================================================================

  String _getBadgeText(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isInterestRow) {
      return l10n.interest;
    }

    switch (transaction.type) {
      case TransactionType.gave:
        return l10n.loanGiven;
      case TransactionType.received:
        return l10n.paymentReceived;
      case TransactionType.took:
        return l10n.loanTook;
      case TransactionType.paid:
        return l10n.amountPaid;
    }
  }

  // ================================================================
  // BADGE BORDER COLOR
  // ================================================================

  Color _getBadgeBorderColor() {
    if (isInterestRow) {
      return const Color(0xFF21A83A);
    }

    if (transaction.type == TransactionType.received ||
        transaction.type == TransactionType.paid) {
      return const Color(0xFF21A83A);
    }

    return const Color.fromRGBO(199, 76, 76, 1);
  }

  // ================================================================
  // BADGE BACKGROUND COLOR
  // ================================================================

  Color _getBadgeBackgroundColor() {
    if (isInterestRow) {
      return const Color.fromRGBO(60, 180, 80, 0.15);
    }

    if (transaction.type == TransactionType.received ||
        transaction.type == TransactionType.paid) {
      return const Color.fromRGBO(60, 180, 80, 0.15);
    }

    return const Color.fromRGBO(199, 76, 76, 0.19);
  }

  // ================================================================
  // BADGE TEXT COLOR
  // ================================================================

  Color _getBadgeTextColor() {
    if (isInterestRow) {
      return const Color(0xFF159B2D);
    }

    if (transaction.type == TransactionType.received ||
        transaction.type == TransactionType.paid) {
      return const Color(0xFF159B2D);
    }

    return const Color.fromRGBO(199, 76, 76, 1);
  }

  // ================================================================
  // INTEREST COLOR
  // ================================================================

  Color _getInterestColor() {
    // Interest for Loan Given = Green
    if (transaction.type == TransactionType.gave) {
      return const Color(0xFF159B2D);
    }

    // Interest for Took Loan = Red
    if (transaction.type == TransactionType.took) {
      return const Color.fromRGBO(199, 76, 76, 1);
    }

    return const Color(0xFF159B2D);
  }

  // ================================================================
  // INTEREST BACKGROUND COLOR
  // ================================================================

  Color _getInterestBackgroundColor() {
    // Loan Given Interest = Green background
    if (transaction.type == TransactionType.gave) {
      return const Color.fromRGBO(60, 180, 80, 0.15);
    }

    // Took Loan Interest = Red background
    if (transaction.type == TransactionType.took) {
      return const Color.fromRGBO(199, 76, 76, 0.19);
    }

    return const Color.fromRGBO(60, 180, 80, 0.15);
  }

  // ================================================================
  // FULL INTEREST DESCRIPTION
  // ================================================================

  String _localizedFrequency(BuildContext context, String value) {
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

  String _localizedInterestType(BuildContext context, String value) {
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

  String _localizedPaymentMode(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context);

    switch (value) {
      case 'Cash':
        return l10n.cash;
      case 'UPI':
        return l10n.upi;
      case 'Bank':
      case 'Bank Transfer':
        return l10n.bankTransfer;
      case 'Other':
        return l10n.other;
      default:
        return value;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat('dd MMM yyyy', locale).format(date);
  }

  String _getFullDescription(BuildContext context) {
    final startDate = _formatDate(context, transaction.date);
    final endDate = _formatDate(context, DateTime.now());

    final rate = transaction.interestRate.toStringAsFixed(0);

    final rawFrequency = transaction.interestFrequency.isEmpty
        ? 'Monthly'
        : transaction.interestFrequency;

    final rawInterestType = transaction.interestType.isEmpty
        ? 'Simple Interest'
        : transaction.interestType;

    final frequency = _localizedFrequency(context, rawFrequency);
    final interestType = _localizedInterestType(context, rawInterestType);

    return '$startDate → $endDate $rate% $frequency $interestType';
  }

  String _getInterestDescription(BuildContext context) {
    final start = _formatDate(context, transaction.date);
    final end = _formatDate(context, DateTime.now());

    final rate = transaction.interestRate.toStringAsFixed(0);

    final rawFrequency = transaction.interestFrequency.isEmpty
        ? 'Monthly'
        : transaction.interestFrequency;

    final rawInterestType = transaction.interestType.isEmpty
        ? 'Simple Interest'
        : transaction.interestType;

    final frequency = _localizedFrequency(context, rawFrequency);
    final interestType = _localizedInterestType(context, rawInterestType);

    return '$start → $end\n$rate% $frequency $interestType';
  }

  // ================================================================
  // DISPLAY AMOUNT
  // ================================================================

  String _getDisplayAmount() {
    final amount = displayAmount ?? transaction.amount;
    return _formatAmount(amount);
  }

  // ================================================================
  // TRANSACTION DESCRIPTION
  // ================================================================

  String _getTransactionDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Interest row
    if (isInterestRow) {
      final startDate = _formatDate(context, transaction.date);
      final endDate = _formatDate(context, DateTime.now());

      final rate = transaction.interestRate.toStringAsFixed(0);

      final rawFrequency = transaction.interestFrequency.isEmpty
          ? 'Monthly'
          : transaction.interestFrequency;

      final rawInterestType = transaction.interestType.isEmpty
          ? 'Simple Interest'
          : transaction.interestType;

      final frequency = _localizedFrequency(context, rawFrequency);
      final interestType = _localizedInterestType(context, rawInterestType);

      return '₹${displayAmount?.toStringAsFixed(0) ?? '0'} ${l10n.interest} '
          '$startDate → $endDate $rate% $frequency $interestType';
    }

    // Normal transaction row
    if (transaction.description.isNotEmpty) {
      return transaction.description;
    }

    switch (transaction.type) {
      case TransactionType.gave:
        return '${l10n.loanGiven}.';
      case TransactionType.received:
        return '${l10n.paymentReceived}.';
      case TransactionType.took:
        return '${l10n.loanTook}.';
      case TransactionType.paid:
        return '${l10n.amountPaid}.';
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final screenHeight = mediaQuery.size.height;

    // Keep the sheet responsive on short screens.
    final maxSheetHeight = screenHeight * 0.90;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        height: screenHeight,
        child: Stack(
          children: [
            // ==========================================================
            // OUTSIDE AREA
            // Tap anywhere outside the sheet to close it.
            // ==========================================================
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const SizedBox.expand(),
              ),
            ),

            // ==========================================================
            // FULL WIDTH BOTTOM SHEET
            // ==========================================================
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Container(
                  // FULL WIDTH
                  width: double.infinity,

                  constraints: BoxConstraints(
                    maxHeight: maxSheetHeight,
                  ),

                  // No left/right margin.
                  // Only 10px bottom spacing.
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),

                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF9F1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),

                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),

                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        10,
                        24,
                        20,
                      ),

                      child:
                      (transaction.type ==
                          TransactionType.received ||
                          transaction.type ==
                              TransactionType.paid)
                          ? _buildPaymentReceivedDetails(
                        context,
                      )
                          : _buildLoanGivenDetails(
                        context,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SMALL ICON
  // ================================================================

  static Widget _smallIcon(String path) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(
          170,
          185,
          207,
          0.6,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Image.asset(
        path,
        fit: BoxFit.contain,
      ),
    );
  }

  // ================================================================
  // DETAIL ITEM
  // ================================================================

  static Widget _detailItem({
    required String path,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFDCE4EF),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Image.asset(
            path,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF233E67),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================================
  // FORMAT AMOUNT
  // ================================================================

  static String _formatAmount(double amount) {
    return '₹${NumberFormat('#,##0.##').format(amount)}';
  }

  // ================================================================
  // LOAN GIVEN / LOAN TOOK DETAILS
  // ================================================================

  Widget _buildLoanGivenDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Container(
          width: 38,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF85817D),
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        const SizedBox(height: 16),

        // Rupee icon
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

        Text(
          _getTransactionTitle(context),
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: const Color(0xFF233E67),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        // Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isInterestRow
                ? _getInterestBackgroundColor()
                : const Color.fromRGBO(
              199,
              76,
              76,
              0.19,
            ),
            borderRadius:
            BorderRadius.circular(12),
            border: Border.all(
              color: isInterestRow
                  ? _getInterestColor()
                  : const Color.fromRGBO(
                199,
                76,
                76,
                1,
              ),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                isInterestRow &&
                    transaction.type ==
                        TransactionType.gave
                    ? 'assets/arrow_down.png'
                    : 'assets/arrow_up.png',
                height: 14,
                width: 14,
              ),

              const SizedBox(width: 4),

              Text(
                _getBadgeText(context),
                style: GoogleFonts.manrope(
                  color: isInterestRow
                      ? _getInterestColor()
                      : const Color.fromRGBO(
                    199,
                    76,
                    76,
                    1,
                  ),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Date + Amount
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
                _formatDate(context, transaction.date),
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

            Flexible(
              child: Text(
                _getDisplayAmount(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: GoogleFonts.manrope(
                  color: isInterestRow
                      ? _getInterestColor()
                      : const Color.fromRGBO(
                    199,
                    76,
                    76,
                    1,
                  ),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Description
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _getTransactionDescription(context),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: Colors.grey.shade500,
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Interest details row 1
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _detailItem(
                path:
                'assets/calender_check.png',
                title: l10n.enterInterestRate,
                value:
                "${transaction.interestRate}%",
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _detailItem(
                path:
                'assets/calender_check.png',
                title: l10n.interestType,
                value: transaction
                    .interestType
                    .isEmpty
                    ? l10n.notSpecified
                    : _localizedInterestType(context, transaction.interestType),
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        // Interest details row 2
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _detailItem(
                path:
                'assets/calender_check.png',
                title: l10n.interestFrequency,
                value: transaction
                    .interestFrequency
                    .isEmpty
                    ? l10n.notSpecified
                    : _localizedFrequency(context, transaction.interestFrequency),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _detailItem(
                path:
                'assets/calender_check.png',
                title: l10n.paymentMethod,
                value: transaction
                    .paymentMode
                    .isEmpty
                    ? l10n.notSpecified
                    : _localizedPaymentMode(context, transaction.paymentMode),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Edit button
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result =
              await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor:
                Colors.transparent,
                builder: (context) {
                  return EditTransactionBottomSheet(
                    transaction: transaction,
                  );
                },
              );

              if (result == true &&
                  context.mounted) {
                Navigator.pop(context);
                onChanged?.call();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              const Color(0xFF213F68),
              foregroundColor:
              ChopdiColors.cream,
              elevation: 0,
              minimumSize:
              const Size(double.infinity, 40),
              padding: EdgeInsets.zero,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/edit_outline_rounded_transactions.png',
              height: 24,
              width: 24,
            ),
            label: Text(
              l10n.editTransaction,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 9),

        // Delete button
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton.icon(
            onPressed: () async {
              final result =
              await showDeleteTransactionBottomSheet(
                context,
                title: l10n.deleteTransactionQuestion,
                subtitle:
                l10n.thisActionCannotBeUndone,
                onDelete: () async {
                  await Repositories.ledger
                      .voidEntry(
                    transaction,
                    reason: 'Deleted by user',
                  );

                  onChanged?.call();
                },
              );

              if (result == true &&
                  context.mounted) {
                Navigator.pop(context);
              }
            },
            style:
            OutlinedButton.styleFrom(
              foregroundColor:
              const Color.fromRGBO(
                199,
                76,
                76,
                1,
              ),
              minimumSize:
              const Size(double.infinity, 40),
              padding: EdgeInsets.zero,
              side: const BorderSide(
                color: Color.fromRGBO(
                  199,
                  76,
                  76,
                  1,
                ),
                width: 0.8,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/delete_outline_rounded_transactions.png',
              height: 24,
              width: 24,
            ),
            label: Text(
              l10n.deleteTransaction,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // PAYMENT RECEIVED / PAID DETAILS
  // ================================================================

  Widget _buildPaymentReceivedDetails(
      BuildContext context,
      ) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Container(
          width: 38,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF85817D),
            borderRadius:
            BorderRadius.circular(10),
          ),
        ),

        const SizedBox(height: 16),

        // Rupee icon
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

        Text(
          l10n.transactionDetails,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: const Color(0xFF233E67),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        // Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color:
            _getBadgeBackgroundColor(),
            borderRadius:
            BorderRadius.circular(12),
            border: Border.all(
              color:
              _getBadgeBorderColor(),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                (transaction.type ==
                    TransactionType.received ||
                    transaction.type ==
                        TransactionType.paid ||
                    isInterestRow)
                    ? 'assets/arrow_down.png'
                    : 'assets/arrow_up.png',
                height: 14,
                width: 14,
              ),

              const SizedBox(width: 4),

              Text(
                _getBadgeText(context),
                style: GoogleFonts.manrope(
                  color:
                  _getBadgeTextColor(),
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Date + Amount
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
                _formatDate(context, transaction.date),
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: ChopdiColors.navy,
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Flexible(
              child: Text(
                _getDisplayAmount(),
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                textAlign:
                TextAlign.right,
                style: GoogleFonts.manrope(
                  color:
                  const Color(0xFF159B2D),
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Description
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _getTransactionDescription(context),
            maxLines: 4,
            overflow:
            TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: Colors.grey.shade500,
              fontSize: 12,
              height: 1.3,
              fontWeight:
              FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Edit button
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result =
              await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor:
                Colors.transparent,
                builder: (context) {
                  return EditTransactionReceivedBottomSheet(
                    transaction: transaction,
                  );
                },
              );

              if (result == true &&
                  context.mounted) {
                Navigator.pop(context);
                onChanged?.call();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              const Color(0xFF213F68),
              foregroundColor:
              ChopdiColors.cream,
              elevation: 0,
              minimumSize:
              const Size(double.infinity, 40),
              padding: EdgeInsets.zero,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/edit_outline_rounded_transactions.png',
              height: 24,
              width: 24,
            ),
            label: Text(
              l10n.editTransaction,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 9),

        // Delete button
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton.icon(
            onPressed: () async {
              final result =
              await showDeleteTransactionBottomSheet(
                context,
                title:
                "Delete Transaction?",
                subtitle:
                l10n.thisActionCannotBeUndone,
                onDelete: () async {
                  await Repositories.ledger
                      .voidEntry(
                    transaction,
                    reason:
                    'Deleted by user',
                  );

                  onChanged?.call();
                },
              );

              if (result == true &&
                  context.mounted) {
                Navigator.pop(context);
              }
            },
            style:
            OutlinedButton.styleFrom(
              foregroundColor:
              const Color.fromRGBO(
                199,
                76,
                76,
                1,
              ),
              minimumSize:
              const Size(double.infinity, 40),
              padding: EdgeInsets.zero,
              side: const BorderSide(
                color: Color.fromRGBO(
                  199,
                  76,
                  76,
                  1,
                ),
                width: 0.8,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/delete_outline_rounded_transactions.png',
              height: 24,
              width: 24,
            ),
            label: Text(
              l10n.deleteTransaction,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}