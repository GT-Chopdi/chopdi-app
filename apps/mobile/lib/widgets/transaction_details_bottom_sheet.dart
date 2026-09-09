import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

  String _getTransactionTitle() {
    if (isInterestRow) {
      return "Interest Details";
    }

    switch (transaction.type) {
      case TransactionType.gave:
        return "Transaction Details";

      case TransactionType.received:
        return "Transaction Details";

      case TransactionType.took:
        return "Transaction Details";

      case TransactionType.paid:
        return "Transaction Details";
    }
  }

  // ================================================================
  // BADGE TEXT
  // ================================================================

  String _getBadgeText() {
    if (isInterestRow) {
      return "Interest";
    }

    switch (transaction.type) {
      case TransactionType.gave:
        return "Loan Given";

      case TransactionType.received:
        return "Payment Received";

      case TransactionType.took:
        return "Loan Took";

      case TransactionType.paid:
        return "Amount Paid";
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

  String _getFullDescription() {
    final startDate =
        DateFormat("dd MMM yyyy").format(transaction.date);

    final endDate =
        DateFormat("dd MMM yyyy").format(DateTime.now());

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

    return "$startDate → $endDate "
        "$rate% $frequency $interestType";
  }

  // ================================================================
  // INTEREST DESCRIPTION
  // ================================================================

  String _getInterestDescription() {
    final startDate = transaction.date;
    final endDate = DateTime.now();

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

    return "$start → $end\n"
        "$rate% $frequency $interestType";
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

  String _getTransactionDescription() {
    // Interest row
    if (isInterestRow) {
      final startDate = DateFormat("dd MMM yyyy")
          .format(transaction.date);

      final endDate = DateFormat("dd MMM yyyy")
          .format(DateTime.now());

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

      return "₹${displayAmount?.toStringAsFixed(0) ?? '0'} interest "
          "from $startDate to $endDate at $rate% "
          "$frequency $interestType interest.";
    }

    // Normal transaction row
    if (transaction.description.isNotEmpty) {
      return transaction.description;
    }

    switch (transaction.type) {
      case TransactionType.gave:
        return "Loan given.";

      case TransactionType.received:
        return "Payment received.";

      case TransactionType.took:
        return "Loan taken.";

      case TransactionType.paid:
        return "Amount paid.";
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
          _getTransactionTitle(),
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
                _getBadgeText(),
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
                DateFormat(
                  'dd MMM yyyy',
                ).format(transaction.date),
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
            _getTransactionDescription(),
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
                title: "Interest Rate",
                value:
                    "${transaction.interestRate}%",
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _detailItem(
                path:
                    'assets/calender_check.png',
                title: "Interest Type",
                value: transaction
                        .interestType
                        .isEmpty
                    ? "Not specified"
                    : transaction.interestType,
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
                title: "Interest Frequency",
                value: transaction
                        .interestFrequency
                        .isEmpty
                    ? "Not specified"
                    : transaction.interestFrequency,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _detailItem(
                path:
                    'assets/calender_check.png',
                title: "Payment Method",
                value: transaction
                        .paymentMode
                        .isEmpty
                    ? "Not specified"
                    : transaction.paymentMode,
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
              "Edit Transaction",
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
                title: "Delete Transaction?",
                subtitle:
                    "This action cannot be undone",
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
              "Delete Transaction",
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
          "Transaction Details",
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
                _getBadgeText(),
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
                DateFormat(
                  'dd MMM yyyy',
                ).format(transaction.date),
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
            _getTransactionDescription(),
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
              "Edit Transaction",
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
                    "This action cannot be undone",
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
              "Delete Transaction",
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