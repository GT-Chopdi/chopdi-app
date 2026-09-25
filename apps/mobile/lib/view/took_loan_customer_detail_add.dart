import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/data/repository/repositories.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/view/took_loan_add_new_lender_screen.dart';
import 'package:mychopdi/view/took_loan_customer_details_screen.dart';

import '../l10n/app_localizations.dart';
import '../model/customer.dart';

class TookLoanCustomerDetailAdd extends StatefulWidget {
  final String contactName;
  final String contactPhone;
  final int chopdiId;

  const TookLoanCustomerDetailAdd({
    super.key,
    required this.contactName,
    required this.contactPhone,
    required this.chopdiId,
  });

  @override
  State<TookLoanCustomerDetailAdd> createState() =>
      _CustomerDetailsAddState();
}

class _CustomerDetailsAddState
    extends State<TookLoanCustomerDetailAdd> {
  static const Color primaryColor = Color(0xFF233B63);
  static const Color backgroundColor = Color(0xFFFDF0DE);

  bool isSaving = false;
  Future<void> addCustomer() async {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AddNewLenderScreen(
          chopdiId: widget.chopdiId,
          initialName: widget.contactName,
          initialPhone: widget.contactPhone,
        ),
      ),
    );
  }

  // Future<void> addCustomer() async {
  //   final l10n = AppLocalizations.of(context);
  //
  //   // ============================================================
  //   // PHONE NUMBER
  //   // ============================================================
  //
  //   final phone = widget.contactPhone.trim();
  //
  //   // Remove spaces, +, -, brackets, etc.
  //   String finalPhone =
  //   phone.replaceAll(RegExp(r'[^0-9]'), '');
  //
  //   // Remove Indian country code +91
  //   if (finalPhone.startsWith('91') &&
  //       finalPhone.length == 12) {
  //     finalPhone = finalPhone.substring(2);
  //   }
  //
  //   // ============================================================
  //   // PHONE IS OPTIONAL
  //   // ============================================================
  //
  //   if (finalPhone.isNotEmpty) {
  //     // If phone exists, it MUST be exactly 10 digits.
  //     if (!RegExp(r'^[0-9]{10}$').hasMatch(finalPhone)) {
  //       if (!mounted) return;
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             l10n.pleaseEnterValidPhoneNumber,
  //           ),
  //         ),
  //       );
  //
  //       return;
  //     }
  //   }
  //
  //   // ============================================================
  //   // START SAVING
  //   // ============================================================
  //
  //   if (mounted) {
  //     setState(() {
  //       isSaving = true;
  //     });
  //   }
  //
  //   try {
  //     // ==========================================================
  //     // DUPLICATE CHECK
  //     // ==========================================================
  //
  //     // Only check when a phone number exists.
  //     // Empty phone numbers are allowed.
  //
  //     if (finalPhone.isNotEmpty) {
  //       final existingCustomer =
  //       await IsarService.isar.customers
  //           .filter()
  //           .phoneEqualTo(finalPhone)
  //           .and()
  //           .chopdiIdEqualTo(widget.chopdiId)
  //           .and()
  //           .deletedAtIsNull()
  //           .findFirst();
  //
  //       if (existingCustomer != null) {
  //         if (!mounted) return;
  //
  //         setState(() {
  //           isSaving = false;
  //         });
  //
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //               l10n.lenderAlreadyExists,
  //             ),
  //           ),
  //         );
  //
  //         return;
  //       }
  //     }
  //
  //     // ==========================================================
  //     // CREATE NEW LENDER
  //     // ==========================================================
  //
  //     final customer =
  //     await Repositories.customers.create(
  //       name: widget.contactName.trim(),
  //       phone: finalPhone,
  //       chopdiId: widget.chopdiId,
  //       loanType: "took",
  //       status: "Pending",
  //     );
  //
  //     if (!mounted) return;
  //
  //     // ==========================================================
  //     // OPEN CUSTOMER DETAILS
  //     // ==========================================================
  //
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) =>
  //             AddNewLenderScreen(
  //               chopdiId: chopdiId,
  //               initialName: contact.name,
  //               initialPhone: contact.phone,
  //             )
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //
  //     setState(() {
  //       isSaving = false;
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           '${l10n.failedToAddLenderWithError}: $e',
  //         ),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // BACK BUTTON
              // ==================================================

              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: primaryColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // PROFILE
              // ==================================================

              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      widget.contactName.isNotEmpty
                          ? widget.contactName[0].toUpperCase()
                          : "?",
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.contactName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          widget.contactPhone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==================================================
              // ADD LENDER
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSaving ? null : addCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    l10n.addLender,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // CANCEL
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: primaryColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}