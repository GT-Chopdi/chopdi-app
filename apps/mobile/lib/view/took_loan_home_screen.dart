import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/took_loan_customers_screen.dart';
import 'package:mychopdi/widgets/took_loan_summary_card.dart';

class TookLoanHomeContent extends StatelessWidget {
  final int chopdiId;
  final bool isGaveLoanSelected;

  const TookLoanHomeContent({
    super.key,
    required this.chopdiId,
    required this.isGaveLoanSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: IsarService.isar.transactions
          .filter()
          .chopdiIdEqualTo(chopdiId)
          .typeEqualTo(TransactionType.took)
          .watch(fireImmediately: true),
      builder: (context, transactionSnapshot) {
        return StreamBuilder<List<Customer>>(
          stream: IsarService.isar.customers
              .filter()
              .chopdiIdEqualTo(chopdiId)
              .watch(fireImmediately: true),
          builder: (context, customerSnapshot) {
            final allCustomers = customerSnapshot.data ?? <Customer>[];

            final tookLoanCustomers = allCustomers
                .where((customer) => customer.loanType == "took")
                .toList();

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                TookLoanSummaryCard(
                  chopdiId: chopdiId,
                ),
                const SizedBox(height: 18),

                // ==========================================
                // CLEAN EMPTY STATE
                // ==========================================
                if (tookLoanCustomers.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 40), // Gives spacing below the card
                    alignment: Alignment.center,
                    child: _buildEmptyState(context),
                  )
                else
                  TookLoanCustomerListSection(
                    customers: tookLoanCustomers,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // Safely get screen width without LayoutBuilder
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 390).clamp(0.82, 1.10);

    final titleFontSize = (22 * scale).clamp(18.0, 23.0);
    final descriptionFontSize = (16 * scale).clamp(13.0, 17.0);
    final horizontalPadding = (width * 0.05).clamp(12.0, 28.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Prevents infinite height issues
        children: [
          SizedBox(
            width: 120,
            height: 100,
            child: Image.asset(
              'assets/home_screen_book.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No customers yet!',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: ChopdiColors.navy,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Start by adding a customer and\n'
                'keep track of your loans easily',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: ChopdiColors.navy,
              fontSize: descriptionFontSize,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: width * 0.65,
            ),
            child: Image.asset(
              'assets/line_home.png',
              height: 105,
              width: 65,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}