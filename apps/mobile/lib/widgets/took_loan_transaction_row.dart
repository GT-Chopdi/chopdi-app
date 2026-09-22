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
  final int customerId;

  const TookLoanTransactionRow({
    super.key,
    required this.transaction,
    required this.balance,
    this.onChanged,
    required this.customerId,
  });

  // USER DESCRIPTION

  String _getDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // If user entered a description, show it.
    if (transaction.description.trim().isNotEmpty) {
      return _shortenDescription(
        transaction.description.trim(),
      );
    }

    // Default description when user has not entered one.
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

  String _shortenDescription(String description) {
    const maxCharacters = 25;

    if (description.length <= maxCharacters) {
      return description;
    }

    return "${description.substring(0, maxCharacters).trim()}...";
  }

  // TRANSACTION TYPE

  String _getGivenDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n.loanTook;
  }

  String _getReceivedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n.amountPaid;
  }

  String _getRowDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final startDate = transaction.date;

    // Currently using today's date as the end date
    final endDate = DateTime.now();

    final locale =
    Localizations.localeOf(context).toLanguageTag();

    final formattedStart = DateFormat(
      "dd MMM yyyy",
      locale,
    ).format(startDate);

    final formattedEnd = DateFormat(
      "dd MMM yyyy",
      locale,
    ).format(endDate);

    final rate =
    transaction.interestRate.toStringAsFixed(0);

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

    return "$formattedStart → $formattedEnd "
        "$rate% $frequency $interestType";
  }

  String _localizedFrequency(
      BuildContext context,
      String value,
      ) {
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

  String _localizedInterestType(
      BuildContext context,
      String value,
      ) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final bool isGiven =
        transaction.type == TransactionType.took;

    final bool isReceived =
        transaction.type == TransactionType.paid;

    final locale =
    Localizations.localeOf(context).toLanguageTag();

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
              customerId: customerId,
              onChanged: onChanged,
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFAAB9CF),
          ),
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            // ==================================
            // DATE + USER DESCRIPTION
            // ==================================
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat(
                      "dd MMM yyyy",
                      locale,
                    ).format(transaction.date),
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    _getDescription(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: const Color(0xff8A93A6),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================
            // GIVEN
            // ==================================
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
                    l10n.loanGiven,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
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
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // ==================================
            // RECEIVED / PAID
            // ==================================
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
                      color:
                      const Color(0xFF00901B),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    l10n.paymentReceived,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
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
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // ==================================
            // BALANCE
            // ==================================
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