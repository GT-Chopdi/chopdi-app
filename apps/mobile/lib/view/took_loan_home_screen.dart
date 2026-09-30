import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import 'package:mychopdi/model/lender.dart'; // <-- 1. CHANGED TO LENDER
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/took_loan_customers_screen.dart'; // Ensure this points to the right file for TookLoanCustomerListSection
import 'package:mychopdi/widgets/took_loan_summary_card.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

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
    // Listens to transaction changes to update the summary card
    return StreamBuilder<List<Transaction>>(
      stream: IsarService.isar.transactions
          .filter()
          .chopdiIdEqualTo(chopdiId)
          .typeEqualTo(TransactionType.took)
          .watch(fireImmediately: true),
      builder: (context, transactionSnapshot) {

        // <-- 2. CHANGED STREAM TO LENDERS TABLE
        return StreamBuilder<List<Lender>>(
          stream: IsarService.isar.lenders
              .filter()
              .chopdiIdEqualTo(chopdiId)
              .watch(fireImmediately: true),
          builder: (context, lenderSnapshot) {

            // <-- 3. USING LENDERS (No need to filter by loanType anymore since tables are split!)
            final allLenders = lenderSnapshot.data ?? <Lender>[];

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
                if (allLenders.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    alignment: Alignment.center,
                    child: _buildEmptyState(context),
                  )
                else
                  TookLoanCustomerListSection(
                    lenders: allLenders, // <-- 4. FIXED: PASSING ACTUAL LENDERS INSTEAD OF []
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 390).clamp(0.82, 1.10);

    final titleFontSize = (22 * scale).clamp(18.0, 23.0);
    final descriptionFontSize = (16 * scale).clamp(13.0, 17.0);
    final horizontalPadding = (width * 0.05).clamp(12.0, 28.0);

    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            l10n.homeNoCustomersYet,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: ChopdiColors.navy,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            l10n.homeStartAddingCustomer,
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