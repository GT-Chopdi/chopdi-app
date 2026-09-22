import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/utils/app_colors.dart';

class RecordPaymentBottomSheet extends StatefulWidget {
  const RecordPaymentBottomSheet({super.key});

  @override
  State<RecordPaymentBottomSheet> createState() =>
      _RecordPaymentBottomSheetState();
}

class _RecordPaymentBottomSheetState
    extends State<RecordPaymentBottomSheet> {
  bool isReceived = true;

  final amountController = TextEditingController();

  String? paymentMode;

  final List<String> paymentModes = [
    "Cash",
    "UPI",
    "Bank Transfer",
    "Cheque",
  ];

  String _localizedPaymentMode(
      BuildContext context,
      String value,
      ) {
    final l10n = AppLocalizations.of(context);

    switch (value) {
      case "Cash":
        return l10n.cash;

      case "UPI":
        return l10n.upi;

      case "Bank Transfer":
        return l10n.bankTransfer;

      case "Cheque":
        return l10n.cheque;

      default:
        return value;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final locale =
    Localizations.localeOf(context).toLanguageTag();

    final currentDate = DateTime.now();

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xffFFF8F1),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 18),

            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xffDCE5F8),
              child: Icon(
                Icons.currency_rupee,
                color: ChopdiColors.navy,
                size: 28,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              l10n.recordPayment,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ChopdiColors.navy,
              ),
            ),

            Text(
              l10n.addMoneyGivenOrReceived,
              style: GoogleFonts.roboto(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.type,
                style: GoogleFonts.roboto(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Container(
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isReceived = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isReceived
                              ? ChopdiColors.navy
                              : Colors.white,
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.moneyReceived,
                          style: TextStyle(
                            fontSize: 12,
                            color: isReceived
                                ? Colors.white
                                : ChopdiColors.navy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isReceived = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isReceived
                              ? ChopdiColors.navy
                              : Colors.white,
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.moneyGiven,
                          style: TextStyle(
                            fontSize: 12,
                            color: !isReceived
                                ? Colors.white
                                : ChopdiColors.navy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.amount),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: l10n.enterAmount,
                prefixIcon:
                const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.date),
            ),

            const SizedBox(height: 8),

            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: DateFormat(
                  "dd MMM yyyy",
                  locale,
                ).format(currentDate),
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.paymentModeOptional,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: paymentMode,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              hint: Text(
                l10n.selectPaymentMode,
              ),
              items: paymentModes.map(
                    (e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      _localizedPaymentMode(
                        context,
                        e,
                      ),
                    ),
                  );
                },
              ).toList(),
              onChanged: (value) {
                setState(() {
                  paymentMode = value;
                });
              },
            ),

            const SizedBox(height: 180),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(l10n.cancel),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      ChopdiColors.navy,
                    ),
                    onPressed: () {},
                    child: Text(
                      l10n.saveEntry,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}