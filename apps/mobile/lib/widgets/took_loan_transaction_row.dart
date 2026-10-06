import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/widgets/transaction_details_bottom_sheet.dart';

class TookLoanTransactionRow extends StatelessWidget {
  final Transaction transaction;
  final double balance;
  final VoidCallback? onChanged;
  final String lenderUuid;

  const TookLoanTransactionRow({
    super.key,
    required this.transaction,
    required this.balance,
    this.onChanged,
    required this.lenderUuid,
  });

  String _getDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (transaction.description.trim().isNotEmpty) {
      return transaction.description.trim();
    }

    switch (transaction.type) {
      case TransactionType.took:
        return l10n.loanTook;
      case TransactionType.paid:
        return l10n.amountPaid;
      case TransactionType.gave:
        return l10n.loanGiven;
      case TransactionType.received:
        return l10n.paymentReceived;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isGiven = transaction.type == TransactionType.took;
    final isReceived = transaction.type == TransactionType.paid;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return GestureDetector(
      onTap: () {
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
              lenderUuid: lenderUuid,
              onChanged: onChanged,
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFAAB9CF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat("dd MMM yy", locale).format(transaction.date),
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _getDescription(context),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: const Color(0xff8A93A6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: isGiven
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "₹${transaction.amount.toStringAsFixed(0)}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFC74C4C),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.loanTook,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                  ),
                ],
              )
                  : Center(
                child: Text(
                  "-",
                  style: GoogleFonts.manrope(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: isReceived
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "₹${transaction.amount.toStringAsFixed(0)}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF00901B),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.amountPaid,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      color: Colors.black87,
                    ),
                  ),
                ],
              )
                  : Center(
                child: Text(
                  "-",
                  style: GoogleFonts.manrope(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "₹${balance.toStringAsFixed(0)}",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
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