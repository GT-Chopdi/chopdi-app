  import 'dart:math';
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:intl/intl.dart';
  import 'package:mychopdi/model/customer.dart';
  import 'package:mychopdi/model/transaction.dart';
  import 'package:mychopdi/utils/app_colors.dart';
  import 'package:mychopdi/widgets/summary_tile.dart';
  import 'package:mychopdi/data/repository/repositories.dart';
  import 'dart:typed_data';
  import 'package:pdf/pdf.dart';
  import 'package:pdf/widgets.dart' as pw;
  import 'package:flutter/services.dart'
      show rootBundle, SystemUiOverlayStyle, FilteringTextInputFormatter;
  import 'package:printing/printing.dart';
  import 'package:mychopdi/l10n/app_localizations.dart';
  
  class CustomerOptionsBottomSheet extends StatelessWidget {
    const CustomerOptionsBottomSheet({
      super.key,
      required this.onEdit,
      required this.onSummary,
      required this.onExport,
      required this.onDelete,
      required this.isTookLoan,
    });

    final VoidCallback onEdit;
    final VoidCallback onSummary;
    final VoidCallback onExport;
    final VoidCallback onDelete;
    final bool isTookLoan;

    @override
    Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context);
      final screenWidth = MediaQuery.sizeOf(context).width;

      final horizontalPadding = screenWidth < 360
          ? 14.0
          : screenWidth < 600
              ? 18.0
              : 24.0;

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            12,
            horizontalPadding,
            18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row
              SizedBox(
                width: double.infinity,
                height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Drag handle
                    Container(
                      width: screenWidth < 360 ? 45 : 55,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    // Close icon
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          splashColor: ChopdiColors.navy.withOpacity(0.15),
                          highlightColor: ChopdiColors.navy.withOpacity(0.08),
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Icon(
                              Icons.close_rounded,
                              size: screenWidth < 360 ? 22 : 24,
                              color: ChopdiColors.navy,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: screenWidth < 360 ? 12 : 16,
              ),

              // Edit
              _OptionTile(
                image: 'assets/edit_customer_logo.png',
                title: isTookLoan
                    ? l10n.editLender
                    : l10n.editCustomer,
                subtitle: l10n.editNamePhoneOrLoanDetails,
                onTap: onEdit,
              ),

              SizedBox(
                height: screenWidth < 360 ? 8 : 10,
              ),

              // Account Summary
              _OptionTile(
                image: 'assets/summary.png',
                title: isTookLoan
                    ? l10n.lenderAccountSummary
                    : l10n.accountSummary,
                subtitle: l10n.overviewAndSummary,
                onTap: onSummary,
              ),

              SizedBox(
                height: screenWidth < 360 ? 8 : 10,
              ),

              // Export PDF
              _OptionTile(
                image: 'assets/export_pdf.png',
                title: l10n.exportPdf,
                subtitle: isTookLoan
                    ? l10n.downloadLenderLedgerAsPdf
                    : l10n.downloadLedgerAsPdf,
                onTap: onExport,
              ),

              SizedBox(
                height: screenWidth < 360 ? 8 : 10,
              ),

              // Delete
              _OptionTile(
                image: 'assets/delete_logo.png',
                title: isTookLoan
                    ? l10n.deleteLender
                    : l10n.deleteCustomer,
                subtitle: isTookLoan
                    ? l10n.deleteLenderPermanently
                    : l10n.deleteCustomerPermanently,
                titleColor: Colors.red,
                onTap: onDelete,
              ),

              SizedBox(
                height: screenWidth < 360 ? 4 : 8,
              ),
            ],
          ),
        ),
      );
    }
  }
  
  class _OptionTile extends StatelessWidget {
    const _OptionTile({
      required this.image,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.titleColor = ChopdiColors.navy,
    });

    final String image;
    final String title;
    final String subtitle;
    final Color titleColor;
    final VoidCallback onTap;

    @override
    Widget build(BuildContext context) {
      final screenWidth = MediaQuery.sizeOf(context).width;

      final iconContainerSize = screenWidth < 360 ? 32.0 : 36.0;
      final imageSize = screenWidth < 360 ? 17.0 : 19.0;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 62,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 360 ? 10 : 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 248, 240, 1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromRGBO(170, 185, 207, 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  height: iconContainerSize,
                  width: iconContainerSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(255, 248, 240, 1),
                  ),
                  child: Center(
                    child: Image.asset(
                      image,
                      height: imageSize,
                      width: imageSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(
                  width: screenWidth < 360 ? 9 : 12,
                ),

                // Text
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: screenWidth < 360 ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: screenWidth < 360 ? 11 : 12,
                          height: 1.2,
                          color: const Color.fromRGBO(
                            34,
                            58,
                            94,
                            0.86,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Arrow
                Image.asset(
                  "assets/right_arrow.png",
                  width: screenWidth < 360 ? 16 : 18,
                  height: screenWidth < 360 ? 16 : 18,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  
  
  
  class EditCustomerBottomSheet extends StatefulWidget {
    final Customer customer;
    final VoidCallback onSaved;
    final bool isTookLoan;
  
    const EditCustomerBottomSheet({
      super.key,
      required this.customer,
      required this.onSaved,
      required this.isTookLoan,
    });
  
    @override
    State<EditCustomerBottomSheet> createState() =>
        _EditCustomerBottomSheetState();
  }
  
  class _EditCustomerBottomSheetState
      extends State<EditCustomerBottomSheet> {
    late TextEditingController nameController;
    late TextEditingController phoneController;
  
    final _formKey = GlobalKey<FormState>();
  
    bool _isSaving = false;
  
    @override
    void initState() {
      super.initState();
  
      nameController = TextEditingController(
        text: widget.customer.name,
      );
  
      // Existing value may already be stored as:
      // +91XXXXXXXXXX
      //
      // Show only the 10 digits inside the editable field.
      final existingPhone = widget.customer.phone.trim();
  
      String phoneDigits = existingPhone;
  
      if (phoneDigits.startsWith('+91')) {
        phoneDigits = phoneDigits.substring(3);
      } else if (phoneDigits.startsWith('91') &&
          phoneDigits.length == 12) {
        phoneDigits = phoneDigits.substring(2);
      }
  
      phoneController = TextEditingController(
        text: phoneDigits,
      );
  
      phoneController.addListener(_phoneChanged);
    }
  
    void _phoneChanged() {
      // Keep only numeric characters.
      final digitsOnly = phoneController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
  
      // Limit to 10 digits.
      final limitedDigits = digitsOnly.length > 10
          ? digitsOnly.substring(0, 10)
          : digitsOnly;
  
      if (phoneController.text != limitedDigits) {
        phoneController.value = TextEditingValue(
          text: limitedDigits,
          selection: TextSelection.collapsed(
            offset: limitedDigits.length,
          ),
        );
      }
  
      setState(() {});
    }
  
    @override
    void dispose() {
      phoneController.removeListener(_phoneChanged);
  
      nameController.dispose();
      phoneController.dispose();
  
      super.dispose();
    }
  
    InputDecoration inputDecoration(String hint) {
      return InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color.fromRGBO(255, 248, 240, 1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xff2F477A),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        errorStyle: GoogleFonts.manrope(
          fontSize: 11,
          color: Colors.red,
        ),
      );
    }

    String? _phoneValidator(String? value) {
      final l10n = AppLocalizations.of(context);
      final phone = value?.trim() ?? '';

      if (phone.isEmpty) {
        return l10n.phoneNumberRequired;
      }

      if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
        return l10n.onlyNumbersAllowed;
      }

      if (phone.length != 10) {
        return l10n.enterValid10DigitPhone;
      }

      return null;
    }
    bool get _isPhoneValid {
      final phone = phoneController.text.trim();
  
      return RegExp(r'^[0-9]{10}$').hasMatch(phone);
    }
  
    Future<void> _saveChanges() async {
      if (_isSaving) return;
  
      // Validate before saving.
      if (!_formKey.currentState!.validate()) {
        return;
      }
  
      if (!_isPhoneValid) {
        return;
      }
  
      setState(() {
        _isSaving = true;
      });
  
      try {
        final phone = phoneController.text.trim();
  
        // Store the complete number with +91.
        final fullPhoneNumber = '+91$phone';
  
        await Repositories.customers.update(
          widget.customer,
          name: nameController.text.trim(),
          phone: fullPhoneNumber,
        );
  
        if (!mounted) return;
  
        widget.onSaved();
  
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
  
        setState(() {
          _isSaving = false;
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       l10n.unableToSaveChangesPleaseTryAgain,
        //       style: GoogleFonts.manrope(),
        //     ),
        //   ),
        // );
      }
    }
  
    @override
    Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context);
      return SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 248, 240, 1),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(20),
  
          // Keyboard-aware scroll.
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 55,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 24),
  
                  Center(
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: const Color(0xffEAF2FF),
                      child: const Icon(
                        Icons.edit,
                        size: 32,
                        color: Color(0xff2F477A),
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 14),
  
                  Center(
                    child: Text(
                      widget.isTookLoan
                        ? l10n.editLenderDetails
                        : l10n.editCustomerDetails,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
  
                  Text(
                    l10n.name,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: const Color.fromRGBO(
                        34,
                        58,
                        94,
                        0.62,
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 8),
  
                  TextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: inputDecoration(
                      widget.isTookLoan
                        ? l10n.lenderName
                        : l10n.customerName,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return widget.isTookLoan
                          ? l10n.lenderNameRequired
                          : l10n.customerNameRequired;
                      }
  
                      return null;
                    },
                  ),
  
                  const SizedBox(height: 18),
  
                  Text(
                    l10n.mobileNumber,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: const Color.fromRGBO(
                        34,
                        58,
                        94,
                        0.62,
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 8),
  
                  // +91 is outside the editable field.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(
                            255,
                            248,
                            240,
                            1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          "+91",
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: ChopdiColors.navy,
                          ),
                        ),
                      ),
  
                      const SizedBox(width: 8),
  
                      Expanded(
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: 10,
                          inputFormatters:  [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: inputDecoration(
                            l10n.mobileNumber,
                          ).copyWith(
                            counterText: "",
                          ),
                          validator: _phoneValidator,
                        ),
                      ),
                    ],
                  ),
  
                  const SizedBox(height: 34),
  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize:
                            const Size.fromHeight(55),
                            side: const BorderSide(
                              color: Color(0xff2F477A),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isSaving
                              ? null
                              : () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              color: Color(0xff2F477A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
  
                      const SizedBox(width: 14),
  
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            ChopdiColors.navy,
                            disabledBackgroundColor:
                            Colors.grey.shade400,
                            minimumSize:
                            const Size.fromHeight(55),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          onPressed:
                          (_isPhoneValid && !_isSaving)
                              ? _saveChanges
                              : null,
                          child: _isSaving
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            l10n.saveChanges,
                            style: TextStyle(
                              color: ChopdiColors.cream,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
  
  
  
  class AccountSummaryBottomSheet extends StatelessWidget {
  
    final double totalGiven;
    final double totalOutstanding;
    final double totalInterest;
    final Transaction? lastPayment;
    final Transaction? firstLoan;
    final bool isTookLoan;
    
    const AccountSummaryBottomSheet({
      super.key,
      required this.totalGiven,
      required this.totalOutstanding,
      required this.totalInterest,
      required this.lastPayment,
      required this.firstLoan,
      required this.isTookLoan,
    });
  
    @override
    Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context);
      return SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xffFFF8F0),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
  
              /// Drag Handle
              Container(
                width: 55,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
  
              const SizedBox(height: 24),
  
              /// Icon
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xffDCE4F2),
                child: const Icon(
                  Icons.fact_check_outlined,
                  size: 30,
                  color: Color(0xff3564A8),
                ),
              ),
  
              const SizedBox(height: 14),
  
              Text(
                isTookLoan
                  ? l10n.lenderAccountSummary
                  : l10n.accountSummary,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xff223A5E),
                ),
              ),
  
              const SizedBox(height: 4),
  
              Text(
                  isTookLoan
                    ? l10n.overviewOfLenderAccount
                    : l10n.overviewOfCustomerAccount,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: const Color(0xff6E7A8A),
                  fontWeight: FontWeight.w500,
                ),
              ),
  
              const SizedBox(height: 28),
  
              SummaryTile(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.totalAmountGiven,
                value: "₹${totalGiven.toStringAsFixed(0)}",
                valueColor: const Color(0xff223A5E),
              ),
  
              SummaryTile(
                icon: Icons.location_on_outlined,
                title: l10n.currentOutstanding,
                value: "₹${totalOutstanding.toStringAsFixed(0)}",
                valueColor: Colors.red,
              ),
  
              SummaryTile(
                icon: Icons.percent,
                title: l10n.totalInterest,
                value: "₹${totalInterest.toStringAsFixed(0)}",
                valueColor: Colors.green,
              ),
  
              SummaryTile(
                icon: Icons.calendar_month_outlined,
                title: l10n.lastPayment,
                value: lastPayment == null
                  ? "-"
                  : DateFormat("dd MMM yy",l10n.locale.languageCode).format(lastPayment!.date),
  
                subtitle: lastPayment == null
                    ? null
                    : "(₹${lastPayment!.amount.toStringAsFixed(0)} ${l10n.paymentReceived})",
                valueColor: const Color(0xff223A5E),
              ),
  
              SummaryTile(
                icon: Icons.calendar_today_outlined,
                title: l10n.loanGivenOn,
                value: firstLoan == null
                    ? "-"
                    : DateFormat(
                        "dd MMM yy",
                        l10n.locale.languageCode,
                      ).format(firstLoan!.date),
                valueColor: const Color(0xff223A5E),
              ),
  
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }
  }
  
  class ExportPdfBottomSheet extends StatelessWidget {
    final Customer customer;
    final List<Transaction> transactions;
    /// true = Took Loan tab
    /// false = Gave Loan tab
    final bool isTookLoan;
  
    const ExportPdfBottomSheet({
      super.key,
      required this.customer,
      required this.transactions,
      this.isTookLoan = false,
    });

    String personType(AppLocalizations l10n) {
      return isTookLoan ? l10n.lender : l10n.customer;
    }
  
    // ============================================================
    // INTEREST CALCULATION
    // ============================================================
  
    double calculateInterest(Transaction tx) {
      final days = DateTime.now().difference(tx.date).inDays;
  
      double time;
  
      if (tx.interestFrequency == "Monthly") {
        time = days / 30;
      } else {
        time = days / 365;
      }
  
      if (tx.interestType == "Simple Interest") {
        return tx.amount * tx.interestRate * time / 100;
      }
  
      return tx.amount *
          (pow(1 + tx.interestRate / 100, time) - 1);
    }
  
    // ============================================================
    // TRANSACTION TYPE
    // ============================================================
  
    String transactionTypeText(
      TransactionType type,
      AppLocalizations l10n,
    ) {
      switch (type) {
        case TransactionType.gave:
          return l10n.transactionTypeGiven;

        case TransactionType.received:
          return l10n.transactionTypeReceived;

        case TransactionType.took:
          return l10n.transactionTypeTook;

        case TransactionType.paid:
          return l10n.transactionTypePaid;
      }
    }
  
    // ============================================================
    // TOTAL GIVEN
    // ============================================================
  
    double get totalGiven {
      return transactions
          .where(
            (tx) => tx.type == TransactionType.gave,
          )
          .fold<double>(
            0,
            (sum, tx) => sum + tx.amount,
          );
    }
  
    // ============================================================
    // TOTAL RECEIVED
    // ============================================================
  
    double get totalReceived {
      return transactions
          .where(
            (tx) => tx.type == TransactionType.received,
          )
          .fold<double>(
            0,
            (sum, tx) => sum + tx.amount,
          );
    }
  
    // ============================================================
    // TOTAL TOOK
    // ============================================================
  
    double get totalTook {
      return transactions
          .where((tx) => tx.type == TransactionType.took)
          .fold<double>(
            0,
            (sum, tx) => sum + tx.amount,
          );
    }
  
  
    // ============================================================
    // TOTAL PAID
    // ============================================================
  
    double get totalPaid {
      return transactions
          .where(
            (tx) => tx.type == TransactionType.paid,
          )
          .fold<double>(
            0,
            (sum, tx) => sum + tx.amount,
          );
    }
  
    // ============================================================
    // TOTAL INTEREST
    // ============================================================
  
    double get totalInterest {
      final interestTransactions = isTookLoan
          ? transactions.where(
              (tx) => tx.type == TransactionType.took,
            )
          : transactions.where(
              (tx) => tx.type == TransactionType.gave,
            );
  
      return interestTransactions.fold<double>(
        0,
        (sum, tx) => sum + calculateInterest(tx),
      );
    }
  
    // ============================================================
    // OUTSTANDING
    // ============================================================
  
    // double get outstanding {
    //   return totalGiven +
    //       totalInterest -
    //       totalReceived;
    // }
    double get pdfPrincipal {
      return isTookLoan ? totalTook : totalGiven;
    }
  
    double get pdfPaid {
      return isTookLoan ? totalPaid : totalReceived;
    }
  
    double get pdfOutstanding {
      return (pdfPrincipal + totalInterest - pdfPaid)
          .clamp(0.0, double.infinity);
    }
    double get outstanding => pdfOutstanding;
  
    // ============================================================
    // MONEY FORMAT
    // ============================================================
  
    String money(double value) {
      final formatter = NumberFormat("#,##0.00");
  
      // Unicode U+20B9 = Indian Rupee symbol
      return "\u20B9${formatter.format(value)}";
    }
  
    // ============================================================
    // LOAD LOGO
    // ============================================================
  
    Future<pw.MemoryImage> loadLogo() async {
      final logoData = await rootBundle.load(
        "assets/app_logo.png",
      );
  
      return pw.MemoryImage(
        logoData.buffer.asUint8List(),
      );
    }
  
    List<Transaction> get pdfTransactions {
      return transactions.where((tx) {
        if (isTookLoan) {
          return tx.type == TransactionType.took ||
              tx.type == TransactionType.paid;
        }
  
        return tx.type == TransactionType.gave ||
            tx.type == TransactionType.received;
      }).toList();
    }
  
    // ============================================================
    // GENERATE PDF
    // ============================================================
  
    Future<Uint8List> generatePdf(AppLocalizations l10n) async {
      final pdf = pw.Document();
  
      // ==========================================================
      // LOAD UNICODE FONTS
      // ==========================================================
  
      // These fonts support:
      // ₹
      // Devanagari
      // English
      // Numbers
      //
      // printing package provides these fonts directly.
      final regularFont =
          await PdfGoogleFonts.notoSansDevanagariRegular();
  
      final boldFont =
          await PdfGoogleFonts.notoSansDevanagariBold();
  
      // ==========================================================
      // LOAD LOGO
      // ==========================================================
  
      final logo = await loadLogo();
  
      // ==========================================================
      // SORT TRANSACTIONS
      // ==========================================================
  
      final sortedTransactions = [...pdfTransactions]
        ..sort(
          (a, b) => b.date.compareTo(a.date),
        );
  
      // ==========================================================
      // GENERATED DATE
      // ==========================================================
  
      // final generatedDate = DateFormat(
      //   "dd MMM yyyy, hh:mm a",
      // ).format(DateTime.now());
      final generatedDate = DateFormat(
        "dd MMM yy, hh:mm a",
        l10n.locale.languageCode,
      ).format(DateTime.now());
  
      // ==========================================================
      // COLORS
      // ==========================================================
  
      const navy = PdfColor.fromInt(
        0xff223A5E,
      );
  
      const blue = PdfColor.fromInt(
        0xff2F5D9F,
      );
  
      const lightBlue = PdfColor.fromInt(
        0xffEEF5FC,
      );
  
      const cream = PdfColor.fromInt(
        0xffFFF8F0,
      );
  
      // ==========================================================
      // PDF PAGE
      // ==========================================================
  
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
  
          // ======================================================
          // ⭐ IMPORTANT FONT FIX
          // ======================================================
  
          theme: pw.ThemeData.withFont(
            base: regularFont,
            bold: boldFont,
          ),
  
          margin: const pw.EdgeInsets.fromLTRB(
            38,
            30,
            38,
            38,
          ),
  
          // ======================================================
          // HEADER
          // ======================================================
  
          header: (context) {
            return pw.Column(
              children: [
                pw.Row(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.center,
                  children: [
                    // LOGO
                    pw.Container(
                      width: 40,
                      height: 40,
                      decoration: pw.BoxDecoration(
                        color: lightBlue,
                        borderRadius:
                            pw.BorderRadius.circular(10),
                      ),
                      padding:
                          const pw.EdgeInsets.all(5),
                      child: pw.Image(
                        logo,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
  
                    pw.SizedBox(width: 10),
  
                    // BRAND
                    pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Chopdi",
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight:
                                pw.FontWeight.bold,
                            color: navy,
                          ),
                        ),
  
                        pw.SizedBox(height: 2),
  
                        pw.Text(
                          l10n.yourTrustedDigitalLedger,
                          style: const pw.TextStyle(
                            fontSize: 7.5,
                            color:
                                PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
  
                    pw.Spacer(),
  
                    // STATEMENT LABEL
                    pw.Container(
                      padding:
                          const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration:
                          pw.BoxDecoration(
                        color: lightBlue,
                        borderRadius:
                            pw.BorderRadius.circular(7),
                      ),
                      child: pw.Text(
                        l10n.accountStatement,
                        style: pw.TextStyle(
                          fontSize: 7.5,
                          fontWeight:
                              pw.FontWeight.bold,
                          color: navy,
                        ),
                      ),
                    ),
                  ],
                ),
  
                pw.SizedBox(height: 12),
  
                pw.Container(
                  height: 2,
                  width: double.infinity,
                  color: blue,
                ),
              ],
            );
          },
  
          // ======================================================
          // FOOTER
          // ======================================================
  
          footer: (context) {
            return pw.Container(
              padding:
                  const pw.EdgeInsets.only(
                top: 10,
              ),
              decoration:
                  const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                    color: PdfColors.grey300,
                  ),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    l10n.generatedByChopdi,
                    style:
                        const pw.TextStyle(
                      fontSize: 7.5,
                      color:
                          PdfColors.grey600,
                    ),
                  ),
  
                  pw.SizedBox(width: 5),
  
                  pw.Text(
                    "•",
                    style:
                        const pw.TextStyle(
                      fontSize: 7.5,
                      color:
                          PdfColors.grey400,
                    ),
                  ),
  
                  pw.SizedBox(width: 5),
  
                  pw.Text(
                    generatedDate,
                    style:
                        const pw.TextStyle(
                      fontSize: 7.5,
                      color:
                          PdfColors.grey600,
                    ),
                  ),
  
                  pw.Spacer(),
  
                  pw.Text(
                    l10n.pageOf(
                      context.pageNumber,
                      context.pagesCount,
                    ),
                    style:
                        const pw.TextStyle(
                      fontSize: 7.5,
                      color:
                          PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            );
          },
  
          // ======================================================
          // PAGE CONTENT
          // ======================================================
  
          build: (context) {
            return [
              pw.SizedBox(height: 20),
  
              // ==================================================
              // TITLE
              // ==================================================
  
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      isTookLoan
                        ? l10n.lenderStatement
                        : l10n.customerStatement,
                      style: pw.TextStyle(
                        fontSize: 21,
                        fontWeight:
                            pw.FontWeight.bold,
                        color: navy,
                      ),
                    ),
  
                    pw.SizedBox(height: 5),
  
                    pw.Text(
                      isTookLoan
                          ? l10n.lenderLoanSummaryAndRepaymentHistory
                          : l10n.accountSummaryAndTransactionHistory,
                      style:
                          const pw.TextStyle(
                        fontSize: 9,
                        color:
                            PdfColors.blueGrey500,
                      ),
                    ),
  
                    pw.SizedBox(height: 4),
  
                    pw.Text(
                      l10n.asOf(
                        DateFormat(
                          "dd MMM yyyy, hh:mm a",
                          l10n.locale.languageCode,
                        ).format(DateTime.now()),
                      ),
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                        color:
                            PdfColors.blueGrey500,
                      ),
                    ),
                  ],
                ),
              ),
  
              pw.SizedBox(height: 22),
  
              // ==================================================
              // CUSTOMER CARD
              // ==================================================
  
              pw.Container(
                width: double.infinity,
                padding:
                    const pw.EdgeInsets.all(18),
  
                decoration:
                    pw.BoxDecoration(
                  color: lightBlue,
                  borderRadius:
                      pw.BorderRadius.circular(14),
                  border: pw.Border.all(
                    color:
                        const PdfColor.fromInt(
                      0xffD6E5F5,
                    ),
                  ),
                ),
  
                child: pw.Row(
                  children: [
                    // CUSTOMER INITIAL
                    pw.Container(
                      width: 52,
                      height: 52,
  
                      decoration:
                          pw.BoxDecoration(
                        color: navy,
                        borderRadius:
                            pw.BorderRadius.circular(
                          26,
                        ),
                      ),
  
                      child: pw.Center(
                        child: pw.Text(
                          customer.name.isNotEmpty
                              ? customer.name[0]
                                  .toUpperCase()
                              : "?",
                          style:
                              pw.TextStyle(
                            fontSize: 21,
                            fontWeight:
                                pw.FontWeight.bold,
                            color:
                                PdfColors.white,
                          ),
                        ),
                      ),
                    ),
  
                    pw.SizedBox(width: 14),
  
                    // CUSTOMER DETAILS
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment
                                .start,
                        children: [
                          pw.Text(
                            personType(l10n),
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey600,
                            ),
                          ),

                          pw.SizedBox(height: 3),

                          pw.Text(
                            customer.name,
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  pw.FontWeight.bold,
                              color: navy,
                            ),
                          ),
  
                          pw.SizedBox(height: 5),
  
                          pw.Text(
                            customer.phone,
                            style:
                                const pw.TextStyle(
                              fontSize: 9,
                              color:
                                  PdfColors.grey700,
                            ),
                          ),
  
                          pw.SizedBox(height: 5),
  
                          pw.Text(
                            l10n.transactionCount(transactions.length),
                            style:
                                const pw.TextStyle(
                              fontSize: 8,
                              color:
                                  PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
  
                    // CURRENT BALANCE
                    pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          l10n.currentBalance,
                          style:
                              pw.TextStyle(
                            fontSize: 7.5,
                            fontWeight:
                                pw.FontWeight.bold,
                            color:
                                PdfColors.grey600,
                          ),
                        ),
  
                        pw.SizedBox(height: 5),
  
                        pw.Text(
                          money(outstanding),
                          style:
                              pw.TextStyle(
                            fontSize: 17,
                            fontWeight:
                                pw.FontWeight.bold,
                            color: outstanding > 0
                                ? PdfColors.red800
                                : PdfColors.green800,
                          ),
                        ),
  
                        pw.SizedBox(height: 3),
  
                        pw.Text(
                          outstanding > 0
                            ? l10n.outstanding
                            : l10n.settled,
                          style:
                              const pw.TextStyle(
                            fontSize: 8,
                            color:
                                PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
  
              pw.SizedBox(height: 22),
  
              // ==================================================
              // ACCOUNT OVERVIEW
              // ==================================================
  
              pw.Text(
                l10n.accountOverview,
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight:
                      pw.FontWeight.bold,
                  color: navy,
                ),
              ),
  
              pw.SizedBox(height: 10),
  
              pw.Row(
                children: [
                  summaryCard(
                    title: isTookLoan ? l10n.youTook : l10n.youGave,
                    value: money(pdfPrincipal),
                    subtitle: isTookLoan
                        ? l10n.totalLoanTaken
                        : l10n.totalGiven,
                    valueColor: navy,
                  ),
  
                  pw.SizedBox(width: 9),
  
                  summaryCard(
                    title: isTookLoan ? l10n.youPaid : l10n.youReceived,
                    value: money(pdfPaid),
                    subtitle: isTookLoan
                        ? l10n.totalRepaid
                        : l10n.totalReceived,
                    valueColor: PdfColors.green800,
                  ),
  
                  pw.SizedBox(width: 9),
  
                  summaryCard(
                    title: l10n.interest,
                    value: money(totalInterest),
                    subtitle: l10n.calculatedInterest,
                    valueColor: PdfColors.orange800,
                  ),
                ],
              ),
  
              pw.SizedBox(height: 24),
  
              // ==================================================
              // TRANSACTION HISTORY
              // ==================================================
  
              pw.Row(
                children: [
                  pw.Text(
                    l10n.transactionHistory,
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight:
                          pw.FontWeight.bold,
                      color: navy,
                    ),
                  ),
  
                  pw.Spacer(),
  
                  pw.Text(
                    l10n.recordsCount(transactions.length),
                    style:
                        const pw.TextStyle(
                      fontSize: 8,
                      color:
                          PdfColors.grey600,
                    ),
                  ),
                ],
              ),
  
              pw.SizedBox(height: 10),
  
              // TRANSACTION TABLE
              sortedTransactions.isEmpty
                  ? emptyTransactions(l10n)
                  : transactionTable(
                      sortedTransactions,
                       l10n,
                    ),
  
              pw.SizedBox(height: 22),
  
              // ==================================================
              // ACCOUNT SUMMARY
              // ==================================================
  
              pw.Container(
                width: double.infinity,
  
                padding:
                    const pw.EdgeInsets.all(17),
  
                decoration:
                    pw.BoxDecoration(
                  color: cream,
                  borderRadius:
                      pw.BorderRadius.circular(12),
                  border: pw.Border.all(
                    color:
                        const PdfColor.fromInt(
                      0xffE9D8C5,
                    ),
                  ),
                ),
  
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Text(
                          l10n.accountSummary,
                          style:
                              pw.TextStyle(
                            fontSize: 12,
                            fontWeight:
                                pw.FontWeight.bold,
                            color: navy,
                          ),
                        ),
  
                        pw.Spacer(),
  
                        pw.Text(
                          l10n.finalBalance,
                          style:
                              const pw.TextStyle(
                            fontSize: 7,
                            color:
                                PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
  
                    pw.SizedBox(height: 12),
  
                    finalSummaryRow(
                      isTookLoan ? l10n.totalTaken : l10n.totalGiven,
                      money(pdfPrincipal),
                    ),
  
                    finalSummaryRow(
                      isTookLoan ? l10n.totalPaid : l10n.totalReceived,
                      money(pdfPaid),
                    ),
  
                    finalSummaryRow(
                      l10n.totalInterest,
                      money(totalInterest),
                    ),
  
                    pw.SizedBox(height: 6),
  
                    pw.Container(
                      padding:
                          const pw.EdgeInsets.only(
                        top: 11,
                      ),
  
                      decoration:
                          const pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(
                            color:
                                PdfColors.grey300,
                          ),
                        ),
                      ),
  
                      child: pw.Row(
                        children: [
                          pw.Text(
                            l10n.outstandingBalance,
                            style:
                                pw.TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  pw.FontWeight.bold,
                              color: navy,
                            ),
                          ),
  
                          pw.Spacer(),
  
                          pw.Text(
                            money(pdfOutstanding),
                            style:
                                pw.TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  pw.FontWeight.bold,
                              color: pdfOutstanding > 0
                                  ? PdfColors.red800
                                  : PdfColors.green800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
  
              pw.SizedBox(height: 25),
  
              // ==================================================
              // THANK YOU
              // ==================================================
  
              pw.Container(
                width: double.infinity,
  
                padding:
                    const pw.EdgeInsets.symmetric(
                  vertical: 15,
                ),
  
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: 30,
                      height: 30,
                      padding:
                          const pw.EdgeInsets.all(4),
  
                      decoration:
                          pw.BoxDecoration(
                        color: lightBlue,
                        borderRadius:
                            pw.BorderRadius.circular(8),
                      ),
  
                      child: pw.Image(
                        logo,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
  
                    pw.SizedBox(height: 7),
  
                    pw.Text(
                      l10n.thankYouForUsingChopdi,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight:
                            pw.FontWeight.bold,
                        color: navy,
                      ),
                    ),
  
                    pw.SizedBox(height: 3),
  
                    pw.Text(
                      l10n.keepRecordsSimple,
                      style:
                          const pw.TextStyle(
                        fontSize: 7.5,
                        color:
                            PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );
  
      return pdf.save();
    }
  
    // ============================================================
    // SUMMARY CARD
    // ============================================================
  
    pw.Widget summaryCard({
      required String title,
      required String value,
      required String subtitle,
      required PdfColor valueColor,
    }) {
      return pw.Expanded(
        child: pw.Container(
          padding:
              const pw.EdgeInsets.all(12),
  
          decoration:
              pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius:
                pw.BorderRadius.circular(10),
            border: pw.Border.all(
              color: PdfColors.grey300,
            ),
          ),
  
          child: pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight:
                      pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
  
              pw.SizedBox(height: 7),
  
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight:
                      pw.FontWeight.bold,
                  color: valueColor,
                ),
              ),
  
              pw.SizedBox(height: 3),
  
              pw.Text(
                subtitle,
                style:
                    const pw.TextStyle(
                  fontSize: 7,
                  color:
                      PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  
    // ============================================================
    // TRANSACTION TABLE
    // ============================================================
  
    pw.Widget transactionTable(
      List<Transaction> sortedTransactions,
       AppLocalizations l10n,
    ) {
      return pw.Table(
        border: pw.TableBorder(
          top: const pw.BorderSide(
            color: PdfColors.grey300,
          ),
          bottom: const pw.BorderSide(
            color: PdfColors.grey300,
          ),
          horizontalInside:
              const pw.BorderSide(
            color: PdfColors.grey200,
          ),
        ),
  
        columnWidths: {
          0: const pw.FlexColumnWidth(1.35),
          1: const pw.FlexColumnWidth(1.15),
          2: const pw.FlexColumnWidth(1.35),
          3: const pw.FlexColumnWidth(1.2),
          4: const pw.FlexColumnWidth(2.0),
        },
  
        children: [
          // HEADER
          pw.TableRow(
            decoration:
                const pw.BoxDecoration(
              color: PdfColors.grey100,
            ),
  
            children: [
              tableHeader(l10n.date),
              tableHeader(l10n.type),
              tableHeader(
                l10n.amount,
                align: pw.TextAlign.right,
              ),
              tableHeader(l10n.mode),
              tableHeader(l10n.description),
            ],
          ),
  
          // TRANSACTION ROWS
          ...sortedTransactions.map(
            (tx) {
              return pw.TableRow(
                children: [
                  tableCell(
                    DateFormat(
                      "dd MMM yyyy",
                      l10n.locale.languageCode,
                    ).format(tx.date),
                  ),
  
                  transactionTypeCell(
                    tx.type,
                    l10n
                  ),
  
                  tableCell(
                    money(tx.amount),
                    align:
                        pw.TextAlign.right,
                    bold: true,
                  ),
  
                  tableCell(
                    tx.paymentMode.isEmpty
                        ? "-"
                        : tx.paymentMode,
                  ),
  
                  tableCell(
                    tx.description.isEmpty
                        ? "-"
                        : tx.description,
                  ),
                ],
              );
            },
          ),
        ],
      );
    }
  
    // ============================================================
    // EMPTY TRANSACTIONS
    // ============================================================
  
    pw.Widget emptyTransactions(AppLocalizations l10n) {
      return pw.Container(
        width: double.infinity,
  
        padding:
            const pw.EdgeInsets.symmetric(
          vertical: 30,
        ),
  
        decoration:
            pw.BoxDecoration(
          border: pw.Border.all(
            color: PdfColors.grey300,
          ),
          borderRadius:
              pw.BorderRadius.circular(10),
        ),
  
        child: pw.Center(
          child: pw.Text(
            l10n.noTransactionsAvailable,
            style:
                const pw.TextStyle(
              fontSize: 9,
              color:
                  PdfColors.grey600,
            ),
          ),
        ),
      );
    }
  
    // ============================================================
    // TABLE HEADER
    // ============================================================
  
    pw.Widget tableHeader(
      String text, {
      pw.TextAlign align =
          pw.TextAlign.left,
    }) {
      return pw.Padding(
        padding:
            const pw.EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 10,
        ),
  
        child: pw.Text(
          text,
          textAlign: align,
  
          style: pw.TextStyle(
            fontSize: 7.5,
            fontWeight:
                pw.FontWeight.bold,
            color:
                PdfColors.grey700,
          ),
        ),
      );
    }
  
    // ============================================================
    // TABLE CELL
    // ============================================================
  
    pw.Widget tableCell(
      String text, {
      pw.TextAlign align =
          pw.TextAlign.left,
      bool bold = false,
    }) {
      return pw.Padding(
        padding:
            const pw.EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 11,
        ),
  
        child: pw.Text(
          text,
          textAlign: align,
  
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: bold
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
            color:
                PdfColors.grey900,
          ),
        ),
      );
    }
  
    // ============================================================
    // TRANSACTION TYPE CELL
    // ============================================================
  
    pw.Widget transactionTypeCell(
      TransactionType type,
      AppLocalizations l10n,
    ) {
      PdfColor background;
      PdfColor textColor;
  
      switch (type) {
        case TransactionType.gave:
          background = PdfColors.blue50;
          textColor = PdfColors.blue900;
          break;
  
        case TransactionType.received:
          background = PdfColors.green50;
          textColor = PdfColors.green800;
          break;
  
        case TransactionType.took:
          background = PdfColors.orange50;
          textColor = PdfColors.orange800;
          break;
  
        case TransactionType.paid:
          background = PdfColors.red50;
          textColor = PdfColors.red800;
          break;
      }
  
      return pw.Padding(
        padding:
            const pw.EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 7,
        ),
  
        child: pw.Container(
          padding:
              const pw.EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 4,
          ),
  
          decoration:
              pw.BoxDecoration(
            color: background,
            borderRadius:
                pw.BorderRadius.circular(5),
          ),
  
          child: pw.Text(
            transactionTypeText(type, l10n),
            textAlign:
                pw.TextAlign.center,
  
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight:
                  pw.FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      );
    }
  
    // ============================================================
    // FINAL SUMMARY ROW
    // ============================================================
  
    pw.Widget finalSummaryRow(
      String title,
      String value,
    ) {
      return pw.Padding(
        padding:
            const pw.EdgeInsets.symmetric(
          vertical: 5,
        ),
  
        child: pw.Row(
          children: [
            pw.Text(
              title,
              style:
                  const pw.TextStyle(
                fontSize: 8.5,
                color:
                    PdfColors.grey700,
              ),
            ),
  
            pw.Spacer(),
  
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight:
                    pw.FontWeight.bold,
                color:
                    PdfColors.grey900,
              ),
            ),
          ],
        ),
      );
    }
  
    // ============================================================
    // VIEW PDF
    // ============================================================
  
    // Future<void> viewPdf(
    //     BuildContext context,
    //     final l10n = AppLocalizations.of(context);
    //   ) async {
    //     try {
    //       final bytes = await generatePdf(l10n);
  
    //       if (!context.mounted) return;
  
    //       const previewColor = Color(0xff223A5E);
  
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (_) => Scaffold(
    //             // ==================================================
    //             // TOP APP BAR
    //             // ==================================================
    //             appBar: AppBar(
    //               title: const Text(
    //                 "PDF Preview",
    //                 style: TextStyle(
    //                   color: Colors.white,
    //                   fontWeight: FontWeight.w500,
    //                 ),
    //               ),
  
    //               backgroundColor: previewColor,
    //               foregroundColor: Colors.white,
  
    //               elevation: 0,
  
    //               // Makes the status-bar area use the same color
    //               systemOverlayStyle:
    //                   const SystemUiOverlayStyle(
    //                 statusBarColor: previewColor,
    //                 statusBarIconBrightness:
    //                     Brightness.light,
    //                 statusBarBrightness:
    //                     Brightness.dark,
    //               ),
    //             ),
  
    //             // ==================================================
    //             // PDF PREVIEW
    //             // ==================================================
    //             body: PdfPreview(
    //               build: (format) async {
    //                 return bytes;
    //               },
  
    //               // Show only Print and Share
    //               allowPrinting: true,
    //               allowSharing: true,
  
    //               // Hide page format and orientation controls
    //               canChangePageFormat: false,
    //               canChangeOrientation: false,
  
    //               // Hide the Debug toggle
    //               canDebug: false,
  
    //               pdfFileName: "${customer.name}_Chopdi.pdf",
  
    //               // Bottom action bar
    //               actionBarTheme: const PdfActionBarTheme(
    //                 backgroundColor: previewColor,
    //                 iconColor: Colors.white,
    //                 elevation: 0,
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     } catch (e) {
    //       if (!context.mounted) return;
  
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text(
    //             l10n.unableToGeneratePdf(e.toString()),
    //           ),
    //         ),
    //       );
    //     }
    //   }

    Future<void> viewPdf(
      BuildContext context,
    ) async {
      final l10n = AppLocalizations.of(context);

      try {
        final bytes = await generatePdf(l10n);

        if (!context.mounted) return;

        const previewColor = Color(0xff223A5E);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                title: Text(
                  l10n.pdfPreview,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: previewColor,
                foregroundColor: Colors.white,
                elevation: 0,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: previewColor,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              ),
              body: PdfPreview(
                build: (format) async {
                  return bytes;
                },
                allowPrinting: true,
                allowSharing: true,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                pdfFileName: "${customer.name}_Chopdi.pdf",
                actionBarTheme: const PdfActionBarTheme(
                  backgroundColor: previewColor,
                  iconColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.unableToGeneratePdf(e.toString()),
            ),
          ),
        );
      }
    }
  
    // ============================================================
    // DOWNLOAD PDF
    // ============================================================
  
    Future<void> downloadPdf(
      BuildContext context,
    ) async {
      final l10n = AppLocalizations.of(context);
      try {
        final bytes = await generatePdf(l10n);
  
        final safeName = customer.name
            .replaceAll(
              RegExp(r'[^\w\s-]'),
              '',
            )
            .trim()
            .replaceAll(
              ' ',
              '_',
            );
  
        await Printing.sharePdf(
          bytes: bytes,
          filename:
              "${safeName.isEmpty ? 'Customer' : safeName}_Chopdi.pdf",
        );
      } catch (e) {
        if (!context.mounted) return;
  
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              l10n.unableToExportPdf(e.toString()),
            ),
          ),
        );
      }
    }
  
    // ============================================================
    // BOTTOM SHEET UI
    // ============================================================
  
    @override
    Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context);
      return SafeArea(
        child: Container(
          decoration:
              const BoxDecoration(
            color: Color.fromRGBO(
              255,
              248,
              240,
              1,
            ),
  
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
  
          padding:
              const EdgeInsets.all(20),
  
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ==================================================
                // DRAG HANDLE
                // ==================================================
  
                Container(
                  width: 55,
                  height: 5,
  
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey.shade400,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                ),
  
                const SizedBox(height: 24),
  
                // ==================================================
                // PDF ICON
                // ==================================================
  
                CircleAvatar(
                  radius: 30,
  
                  backgroundColor:
                      const Color(
                    0xffDCE4F2,
                  ),
  
                  child: Image.asset(
                    "assets/export_pdf.png",
                    width: 32,
                    height: 32,
                  ),
                ),
  
                const SizedBox(height: 14),
  
                // ==================================================
                // TITLE
                // ==================================================
  
                Text(
                  l10n.exportPdf,
                  style:
                      GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        ChopdiColors.navy,
                  ),
                ),
  
                const SizedBox(height: 6),
  
                Text(
                  l10n.createProfessionalStatement(customer.name),
                  textAlign:
                      TextAlign.center,
  
                  style:
                      GoogleFonts.manrope(
                    fontSize: 12,
                    color:
                        ChopdiColors.navy,
                  ),
                ),
  
                const SizedBox(height: 24),
  
                // ==================================================
                // INFO CARD
                // ==================================================
  
                Container(
                  width: double.infinity,
  
                  padding:
                      const EdgeInsets.all(16),
  
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xffFDEDD9,
                    ),
  
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
  
                    border:
                        Border.all(
                      color:
                          const Color.fromRGBO(
                        177,
                        95,
                        39,
                        0.25,
                      ),
                    ),
                  ),
  
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
  
                    children: [
                      Image.asset(
                        "assets/download_warning.png",
                        width: 26,
                        height: 26,
                      ),
  
                      const SizedBox(width: 12),
  
                      Expanded(
                        child: Text(
                          l10n.pdfIncludesCustomerDetails(customer.name),
  
                          style:
                              GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                ChopdiColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
  
                const SizedBox(height: 28),
  
                // ==================================================
                // VIEW PDF
                // ==================================================
  
                SizedBox(
                  width: double.infinity,
                  height: 55,
  
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      viewPdf(context);
                    },
  
                    icon:
                        const Icon(
                      Icons.visibility_outlined,
                      color:
                          ChopdiColors.navy,
                    ),
  
                    label: Text(
                      l10n.viewPdf,
                      style:
                          GoogleFonts.manrope(
                        color:
                            ChopdiColors.navy,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
  
                    style:
                        OutlinedButton.styleFrom(
                      side:
                          const BorderSide(
                        color:
                            ChopdiColors.navy,
                      ),
  
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),
  
                const SizedBox(height: 14),
  
                // ==================================================
                // DOWNLOAD PDF
                // ==================================================
  
                SizedBox(
                  width: double.infinity,
                  height: 55,
  
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      downloadPdf(context);
                    },
  
                    icon:
                        const Icon(
                      Icons.download_outlined,
                      color:
                          ChopdiColors.cream,
                    ),
  
                    label: Text(
                      l10n.downloadPdf,
                      style:
                          GoogleFonts.manrope(
                        color:
                            ChopdiColors.cream,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
  
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          ChopdiColors.navy,
  
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),
  
                const SizedBox(height: 10),
  
                // ==================================================
                // CANCEL
                // ==================================================
  
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
  
                  child: Text(
                    l10n.cancel,
                    style:
                        GoogleFonts.manrope(
                      color:
                          ChopdiColors.navy,
                      fontWeight:
                          FontWeight.w600,
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
  
  class DeleteCustomerBottomSheet extends StatefulWidget {
    final String customerName;
    final VoidCallback onDelete;
    final bool isTookLoan;
  
    const DeleteCustomerBottomSheet({
      super.key,
      required this.customerName,
      required this.onDelete,
      required this.isTookLoan,
    });
  
    @override
    State<DeleteCustomerBottomSheet> createState() =>  _DeleteCustomerBottomSheetState();
  }
  
  class _DeleteCustomerBottomSheetState extends State<DeleteCustomerBottomSheet> {
    bool agreed = false;
  
    @override
    Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context);
      return SafeArea(
          child :Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 248, 240, 1),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                children: [
  
                  /// Drag Handle
                  Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
  
                  const SizedBox(height: 26),
  
                  /// Delete Icon
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xffFFE7E3),
                    child: Icon(
                      Icons.delete_outline,
                      size: 34,
                      color: Colors.red.shade400,
                    ),
                  ),
  
                  const SizedBox(height: 18),
  
                  Text(
                      widget.isTookLoan
                        ? l10n.deleteLenderConfirmation(widget.customerName)
                        : l10n.deleteCustomerConfirmation(widget.customerName),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ChopdiColors.navy,
                    ),
                  ),
  
                  const SizedBox(height: 6),
  
                  Text(
                    l10n.thisActionCannotBeUndone,
                    style: GoogleFonts.manrope(
                      color: ChopdiColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
  
                  const SizedBox(height: 28),
  
                  /// Warning Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 248, 240, 1),
                      border: Border.all(
                        color: const Color(0xFFC74C4C),
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
  
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xffFFE7E3),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red.shade400,
                          ),
                        ),
  
                        const SizedBox(width: 14),
  
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
  
                              Text(
                                l10n.allCustomerDataWillBePermanentlyDeletedIncluding,
                                style: GoogleFonts.manrope(
                                  color: Color(0xffE4554B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
  
                              const SizedBox(height: 10),
  
                              Text(
                                '• ${widget.isTookLoan ? l10n.lenderDetails : l10n.customerDetails}',
                                style: GoogleFonts.manrope(
                                  color: Color(0xffE4554B),
                                ),
                              ),
  
                              const SizedBox(height: 5),
  
                              Text(
                                '• ${l10n.ledgerAndTransactions}',
                                style: GoogleFonts.manrope(
                                  color: Color(0xffE4554B),
                                ),
                              ),
  
                              const SizedBox(height: 5),
  
                              Text(
                                '• ${l10n.notesAndReminders}',
                                style: GoogleFonts.manrope(
                                  color: Color(0xffE4554B),
                                ),
                              ),
  
                              const SizedBox(height: 5),
  
                              Text(
                                '• ${l10n.loanInformation}',
                                style: GoogleFonts.manrope(
                                  color: Color(0xffE4554B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
  
                  const SizedBox(height: 22),
  
                  /// Checkbox
                  Material(
                    color: const Color.fromRGBO(255, 248, 240, 1),
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: agreed,
                        activeColor: Colors.red,
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        title: Text(
                          l10n.iUnderstandThisActionCannotBeUndone,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            color: ChopdiColors.navy,
                            fontSize: 14
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            agreed = value ?? false;
                          });
                        },
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 28),
  
                  Row(
                    children: [
  
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize:
                                const Size.fromHeight(54),
                            side: const BorderSide(
                              color: Color(0xffF26C63),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              color: Color(0xff2F477A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
  
                      const SizedBox(width: 14),
  
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xffD5544D),
                            minimumSize:
                                const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: agreed
                              ? widget.onDelete
                              : null,
                          child: Text(
                            widget.isTookLoan
                              ? l10n.deleteLender
                              : l10n.deleteCustomer,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
      );
    }
  }