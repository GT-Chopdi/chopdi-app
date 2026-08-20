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
      // Get ONLY took-loan transactions
      stream: IsarService.isar.transactions
          .filter()
          .chopdiIdEqualTo(chopdiId)
          .typeEqualTo(TransactionType.took)
          .watch(fireImmediately: true),

      builder: (context, transactionSnapshot) {
        final tookTransactions =
            transactionSnapshot.data ?? <Transaction>[];

        // Customer IDs that have a Took Loan transaction
        final tookLoanCustomerIds = tookTransactions
            .map((tx) => tx.customerId)
            .toSet();

        return StreamBuilder<List<Customer>>(
          stream: IsarService.isar.customers
              .filter()
              .chopdiIdEqualTo(chopdiId)
              .watch(fireImmediately: true),

          builder: (context, customerSnapshot) {
            final allCustomers =
                customerSnapshot.data ?? <Customer>[];

            // Only customers who have Took Loan transactions
            // final tookLoanCustomers = allCustomers
            //     .where(
            //       (customer) =>
            //           tookLoanCustomerIds.contains(customer.id),
            //     )
            //     .toList();
            final tookLoanCustomers = allCustomers
              .where(
                (customer) => customer.loanType == "took",
              )
              .toList();

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                TookLoanSummaryCard(
                  chopdiId: chopdiId,
                  // isGaveLoanSelected: isGaveLoanSelected,
                ),

                const SizedBox(height: 18),

                if (tookLoanCustomers.isEmpty)
                  SizedBox(
                    height: 350,
                    child: _buildEmptyState(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 74,
            width: 82,
            child: Image.asset(
              'assets/home_screen_book.png',
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'No loans yet!',
            style: GoogleFonts.manrope(
              color: ChopdiColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            'Start by adding a loan to\n'
            'keep track of your borrowings easily',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: ChopdiColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Image.asset(
            'assets/line_home.png',
          ),
        ],
      ),
    );
  }
}