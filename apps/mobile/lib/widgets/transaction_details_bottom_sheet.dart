import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// import 'package:mychopdi/service/transaction_service.dart';
// import 'package:mychopdi/widgets/delete_transaction_bottom_sheet.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
import 'package:mychopdi/view/edit_transaction_bottom_sheet.dart';
import 'package:mychopdi/widgets/delete_transactions_bottom_sheet.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;
  final int customerId;
   final VoidCallback? onChanged;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
    required this.customerId,
    required this.onChanged,
  });

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

  String _getTransactionDescription() {
    final startDate =
        DateFormat("dd MMM yyyy").format(transaction.date);

    final endDate =
        DateFormat("dd MMM yyyy").format(DateTime.now());

    // PAYMENT RECEIVED

    if (transaction.type == TransactionType.received) {
      return "Payment received from $startDate to $endDate.";
    }

    // LOAN GIVEN

    final days = DateTime.now()
        .difference(transaction.date)
        .inDays;

    if (days <= 0) {
      return transaction.description.isEmpty
          ? "Loan given."
          : transaction.description;
    }

    final interest = InterestCalculator.calculate(
      principal: transaction.amount,
      rate: transaction.interestRate,
      startDate: transaction.date,
      interestType: transaction.interestType,
      frequency: transaction.interestFrequency,
    );

    final rate =
        transaction.interestRate.toStringAsFixed(0);

    final frequency =
        transaction.interestFrequency.toLowerCase();

    final interestType =
        transaction.interestType
            .replaceAll(" Interest", "")
            .toLowerCase();

    return "₹${interest.toStringAsFixed(0)} interest "
        "from $startDate to $endDate at $rate% "
        "$frequency $interestType interest.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF393536),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                top: 4,
                bottom: 8,
              ),
              child: Text(
                "Transaction Details",
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.53,
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  padding: const EdgeInsets.fromLTRB(
                    30,
                    10,
                    30,
                    20,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF9F1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(24),
                    ),
                  ),
                  child: transaction.type == TransactionType.received
                    ? _buildPaymentReceivedDetails(context)
                    : _buildLoanGivenDetails(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _transactionType() {
    final bool isGiven =
        transaction.type == TransactionType.gave;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(
          199,
          76,
          76,
          0.19,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromRGBO(
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
            isGiven
                ? 'assets/arrow_up.png'
                : 'assets/arrow_down.png',
            height: 14,
            width: 14,
          ),

          const SizedBox(width: 4),

          Text(
            isGiven
                ? "Loan Given"
                : "Payment Received",
            style: GoogleFonts.manrope(
              color: const Color.fromRGBO(
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
    );
  }


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
                maxLines: 1,
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

  static String _formatAmount(double amount) {
    return '₹${NumberFormat('#,##0.##').format(amount)}';
  }

  Widget _buildLoanGivenDetails(BuildContext context) {
    return Column(
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
            color: Color.fromRGBO(170, 185, 207, 0.6),
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
          style: GoogleFonts.manrope(
            color: const Color(0xFF233E67),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        // Loan Given
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(
              199,
              76,
              76,
              0.19,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromRGBO(
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
                'assets/arrow_up.png',
                height: 14,
                width: 14,
              ),

              const SizedBox(width: 4),

              Text(
                "Loan Given",
                style: GoogleFonts.manrope(
                  color: const Color.fromRGBO(
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
          children: [
            _smallIcon(
              'assets/calender_check.png',
            ),

            const SizedBox(width: 6),

            Text(
              DateFormat(
                'dd MMM yyyy',
              ).format(transaction.date),
              style: GoogleFonts.manrope(
                color: ChopdiColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),

            const Spacer(),

            Text(
              _formatAmount(transaction.amount),
              style: GoogleFonts.manrope(
                color: const Color.fromRGBO(
                  199,
                  76,
                  76,
                  1,
                ),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Description
        Align(
          alignment: Alignment.centerLeft,
          child:Text(
            _getTransactionDescription(),
            maxLines: 3,
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

        // Interest details
        Row(
          children: [
            Expanded(
              child: _detailItem(
                path: 'assets/calender_check.png',
                title: "Interest Rate",
                value: "${transaction.interestRate}%",
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: _detailItem(
                path: 'assets/calender_check.png',
                title: "Interest Type",
                value: transaction.interestType.isEmpty
                    ? "Not specified"
                    : transaction.interestType,
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        Row(
          children: [
            Expanded(
              child: _detailItem(
                path: 'assets/calender_check.png',
                title: "Interest Frequency",
                value: transaction.interestFrequency.isEmpty
                    ? "Not specified"
                    : transaction.interestFrequency,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: _detailItem(
                path: 'assets/calender_check.png',
                title: "Payment Method",
                value: transaction.paymentMode.isEmpty
                    ? "Not specified"
                    : transaction.paymentMode,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Edit
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () {
              // Edit transaction
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return EditTransactionBottomSheet(
                    transaction: transaction,
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF213F68),
              foregroundColor: ChopdiColors.cream,
              elevation: 0,
              minimumSize: const Size(
                double.infinity,
                40,
              ),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/edit_outline_rounded_transactions.png',
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

        // Delete
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton.icon(
            onPressed: () async {
              final result = await showDeleteTransactionBottomSheet(
                context,
                title: "Delete Transaction?",
                subtitle: "This action cannot be undone",
                onDelete: () async {
                  await IsarService.isar.writeTxn(() async {
                    await IsarService.isar.transactions.delete(
                      transaction.id,
                    );
                  });

                  onChanged?.call();
                },
              );

              if (result == true && context.mounted) {
                Navigator.pop(context);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color.fromRGBO(
                199,
                76,
                76,
                1,
              ),
              minimumSize: const Size(
                double.infinity,
                40,
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/delete_outline_rounded_transactions.png',
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

  Widget _buildPaymentReceivedDetails(BuildContext context) {
    return Column(
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
            color: Color.fromRGBO(170, 185, 207, 0.6),
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

        // Transaction Details
        Text(
          "Transaction Details",
          style: GoogleFonts.manrope(
            color: const Color(0xFF233E67),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        // Payment Received badge
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
                "Payment Received",
                style: GoogleFonts.manrope(
                  color: const Color(0xFF159B2D),
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
          children: [
            _smallIcon(
              'assets/calender_check.png',
            ),

            const SizedBox(width: 6),

            Text(
              DateFormat(
                'dd MMM yyyy',
              ).format(transaction.date),
              style: GoogleFonts.manrope(
                color: ChopdiColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),

            const Spacer(),

            Text(
              _formatAmount(transaction.amount),
              style: GoogleFonts.manrope(
                color: const Color(0xFF159B2D),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
          _getTransactionDescription(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            color: Colors.grey.shade500,
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
        ),

        const SizedBox(height: 60),

        // Edit button
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () {
              // Edit transaction
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF213F68),
              foregroundColor: ChopdiColors.cream,
              elevation: 0,
              minimumSize: const Size(
                double.infinity,
                40,
              ),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/edit_outline_rounded_transactions.png',
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
            final result = await showDeleteTransactionBottomSheet(
              context,
              title: "Delete Transaction?",
              subtitle: "This action cannot be undone",
              onDelete: () async {
                await IsarService.isar.writeTxn(() async {
                  await IsarService.isar.transactions.delete(
                    transaction.id,
                  );
                });

                onChanged?.call();
              },
            );

            if (result == true && context.mounted) {
              Navigator.pop(context);
            }
          },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color.fromRGBO(
                199,
                76,
                76,
                1,
              ),
              minimumSize: const Size(
                double.infinity,
                40,
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/delete_outline_rounded_transactions.png',
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
}

