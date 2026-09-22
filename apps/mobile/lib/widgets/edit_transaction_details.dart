import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/money.dart';

class EditTransactionReceivedBottomSheet
    extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionReceivedBottomSheet({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionReceivedBottomSheet>
  createState() =>
      _EditTransactionReceivedBottomSheetState();
}

class _EditTransactionReceivedBottomSheetState
    extends State<EditTransactionReceivedBottomSheet> {
  late TextEditingController amountController;
  late TextEditingController descriptionController;

  late DateTime selectedDate;

  String? selectedPaymentMode;

  // IMPORTANT:
  // These are internal/database values.
  // Do NOT translate these values.
  final List<String> paymentModes = [
    'Cash',
    'UPI',
    'Bank Transfer',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    // ============================================================
    // AMOUNT
    // ============================================================

    amountController = TextEditingController(
      text: transaction.amount.toStringAsFixed(0),
    );

    // ============================================================
    // DESCRIPTION
    // ============================================================

    descriptionController =
        TextEditingController(
          text: transaction.description,
        );

    // ============================================================
    // DATE
    // ============================================================

    selectedDate = transaction.date;

    // ============================================================
    // PAYMENT MODE
    // ============================================================

    selectedPaymentMode =
    transaction.paymentMode.isEmpty
        ? null
        : transaction.paymentMode;
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOCALIZED PAYMENT MODE
  // ============================================================

  String _localizedPaymentMode(
      BuildContext context,
      String value,
      ) {
    final l10n = AppLocalizations.of(context);

    switch (value) {
      case 'Cash':
        return l10n.cash;

      case 'UPI':
        return l10n.upi;

      case 'Bank Transfer':
        return l10n.bankTransfer;

      case 'Other':
        return l10n.other;

      default:
        return value;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration:
      const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,

          // Same margin as You Gave edit sheet
          margin: const EdgeInsets.fromLTRB(
            5,
            0,
            5,
            2,
          ),

          // Same height behavior as You Gave edit sheet
          constraints: BoxConstraints(
            maxHeight:
            MediaQuery.of(context).size.height *
                0.90,
          ),

          decoration: const BoxDecoration(
            color: Color.fromRGBO(
              255,
              248,
              240,
              1,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(24),
            ),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ============================================================
              // DRAG HANDLE
              // ============================================================

              Padding(
                padding: const EdgeInsets.only(
                  top: 4,
                ),
                child: Container(
                  width: 38,
                  height: 3,
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFF85817D),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 17),

              // ============================================================
              // SCROLLABLE FORM
              // ============================================================

              Flexible(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
                  padding:
                  const EdgeInsets.only(
                    left: 16,
                    top: 5,
                    bottom: 12,
                    right: 18,
                  ),
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      // ====================================================
                      // RUPEE ICON
                      // ====================================================

                      Container(
                        width: 52,
                        height: 52,
                        decoration:
                        const BoxDecoration(
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
                            width: 30,
                            height: 30,
                            child: Image.asset(
                              'assets/currency_rupee_circle.png',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      // ====================================================
                      // TITLE
                      // ====================================================

                      Text(
                        l10n.editTransactionDetails,
                        style:
                        GoogleFonts.manrope(
                          color:
                          const Color(
                            0xFF233E67,
                          ),
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ====================================================
                      // AMOUNT
                      // ====================================================

                      _buildLabel(
                        l10n.amount,
                      ),

                      const SizedBox(height: 5),

                      _buildTextField(
                        controller:
                        amountController,
                        prefixText: '₹ ',
                        keyboardType:
                        const TextInputType
                            .numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      const SizedBox(height: 9),

                      // ====================================================
                      // DATE
                      // ====================================================

                      _buildLabel(
                        l10n.date,
                      ),

                      const SizedBox(height: 5),

                      _buildDateField(context),

                      const SizedBox(height: 9),

                      // ====================================================
                      // DESCRIPTION
                      // ====================================================

                      _buildLabel(
                        l10n.description,
                      ),

                      const SizedBox(height: 5),

                      _buildDescriptionField(
                        context,
                      ),

                      const SizedBox(height: 9),

                      // ====================================================
                      // PAYMENT MODE
                      // ====================================================

                      _buildLabel(
                        l10n.paymentModeOptional,
                      ),

                      const SizedBox(height: 5),

                      _buildDropdown(
                        context: context,
                        value:
                        selectedPaymentMode,
                        hint:
                        l10n.selectPaymentMode,
                        items: paymentModes,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMode =
                                value;
                          });
                        },
                      ),

                      // Same bottom spacing style
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ============================================================
              // FIXED BUTTONS
              // ============================================================

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  8,
                  18,
                  12,
                ),
                decoration:
                const BoxDecoration(
                  color: Color.fromRGBO(
                    255,
                    248,
                    240,
                    1,
                  ),
                ),
                child: Row(
                  children: [
                    // ======================================================
                    // CANCEL
                    // ======================================================

                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () {
                            FocusScope.of(
                              context,
                            ).unfocus();

                            Navigator.pop(
                              context,
                            );
                          },
                          style:
                          OutlinedButton
                              .styleFrom(
                            foregroundColor:
                            const Color(
                              0xFF233E67,
                            ),
                            side:
                            const BorderSide(
                              color: Color(
                                0xFFBFC7D2,
                              ),
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                6,
                              ),
                            ),
                          ),
                          child: Text(
                            l10n.cancel,
                            style:
                            GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ======================================================
                    // SAVE CHANGES
                    // ======================================================

                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed:
                          _saveChanges,
                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            const Color(
                              0xFF213F68,
                            ),
                            foregroundColor:
                            Colors.white,
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                6,
                              ),
                            ),
                          ),
                          child: Text(
                            l10n.saveChanges,
                            style:
                            GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: const Color(0xFF5D6A7C),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController
    controller,
    TextInputType? keyboardType,
    String? prefixText,
  }) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.manrope(
          color: const Color(0xFF233E67),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixText: prefixText,
          prefixStyle:
          GoogleFonts.manrope(
            color:
            const Color(0xFF233E67),
            fontSize: 10,
            fontWeight:
            FontWeight.w600,
          ),
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 7,
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(6),
            borderSide:
            const BorderSide(
              color: Color.fromRGBO(
                170,
                185,
                207,
                1,
              ),
              width: 0.8,
            ),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(6),
            borderSide:
            const BorderSide(
              color: Color.fromRGBO(
                170,
                185,
                207,
                1,
              ),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField(
      BuildContext context,
      ) {
    final locale =
    Localizations.localeOf(
      context,
    ).toLanguageTag();

    return InkWell(
      onTap: _selectDate,
      child: Container(
        height: 34,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(6),
          border: Border.all(
            color:
            const Color(0xFFBFC7D2),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Text(
              DateFormat(
                'dd MMM yyyy',
                locale,
              ).format(selectedDate),
              style:
              GoogleFonts.manrope(
                color:
                const Color(0xFF233E67),
                fontSize: 10,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const Spacer(),

            const Icon(
              Icons.calendar_month_outlined,
              color:
              Color(0xFF233E67),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> _selectDate() async {
    final picked =
    await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown({
    required BuildContext context,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?>
    onChanged,
  }) {
    return Container(
      height: 34,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(6),
        border: Border.all(
          color:
          const Color(0xFFBFC7D2),
          width: 0.8,
        ),
      ),
      child:
      DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,

          hint: Text(
            hint,
            style:
            GoogleFonts.manrope(
              color:
              const Color(0xFF7D8794),
              fontSize: 10,
            ),
          ),

          isExpanded: true,

          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Color(0xFF233E67),
          ),

          style: GoogleFonts.manrope(
            color:
            const Color(0xFF233E67),
            fontSize: 10,
            fontWeight:
            FontWeight.w600,
          ),

          items: items.map((item) {
            return DropdownMenuItem<String>(
              // IMPORTANT:
              // Keep original value for database.
              value: item,

              // Only display localized value.
              child: Text(
                _localizedPaymentMode(
                  context,
                  item,
                ),
              ),
            );
          }).toList(),

          onChanged: onChanged,
        ),
      ),
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescriptionField(
      BuildContext context,
      ) {
    final l10n =
    AppLocalizations.of(context);

    return SizedBox(
      height: 55,
      child: TextField(
        controller:
        descriptionController,
        maxLines: 3,
        maxLength: 100,
        style: GoogleFonts.manrope(
          color:
          const Color(0xFF233E67),
          fontSize: 9,
          fontWeight:
          FontWeight.w500,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: l10n.description,
          contentPadding:
          const EdgeInsets.all(8),
          hintStyle:
          GoogleFonts.manrope(
            color:
            const Color(0xFF8B929B),
            fontSize: 9,
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(6),
            borderSide:
            const BorderSide(
              color:
              Color(0xFFBFC7D2),
              width: 0.8,
            ),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(6),
            borderSide:
            const BorderSide(
              color:
              Color(0xFF213F68),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SAVE CHANGES
  // ============================================================

  Future<void> _saveChanges() async {
    final l10n =
    AppLocalizations.of(context);

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    // ============================================================
    // AMOUNT VALIDATION
    // ============================================================

    if (amount == null || amount <= 0) {
      _showError(
        l10n.pleaseEnterValidAmount,
      );
      return;
    }

    // ============================================================
    // EXISTING TRANSACTION
    // ============================================================

    final transaction =
        widget.transaction;

    // ============================================================
    // UPDATE AMOUNT
    // ============================================================

    transaction.amountPaise =
        Money.toPaise(amount);

    // ============================================================
    // UPDATE DATE
    // ============================================================

    transaction.date = selectedDate;

    // ============================================================
    // RECEIVED TRANSACTION HAS NO INTEREST
    // ============================================================

    transaction.interestRateBp = 0;
    transaction.interest = 0;
    transaction.interestType = '';
    transaction.interestFrequency = '';

    // ============================================================
    // UPDATE PAYMENT MODE
    // ============================================================

    transaction.paymentMode =
        selectedPaymentMode ?? '';

    // ============================================================
    // UPDATE DESCRIPTION
    // ============================================================

    transaction.description =
        descriptionController.text.trim();

    // ============================================================
    // SAVE TRANSACTION
    // ============================================================

    await IsarService.isar.writeTxn(
          () async {
        await IsarService
            .isar
            .transactions
            .put(transaction);
      },
    );

    // ============================================================
    // CLOSE
    // ============================================================

    if (!mounted) {
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.pop(
      context,
      true,
    );
  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}