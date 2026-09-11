import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/model/customer.dart';

import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/notification_service.dart';
import 'package:mychopdi/utils/interest_calculator.dart';

class EditTransactionReceivedBottomSheet extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionReceivedBottomSheet({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionReceivedBottomSheet> createState() =>
      _EditTransactionBottomSheetState();
}

class _EditTransactionBottomSheetState
    extends State<EditTransactionReceivedBottomSheet> {
  late TextEditingController amountController;
  late TextEditingController interestRateController;
  late TextEditingController descriptionController;

  late DateTime selectedDate;

  String? selectedInterestType;
  String? selectedInterestFrequency;
  String? selectedPaymentMode;

  bool _interestRateError = false;

  final FocusNode _interestRateFocusNode = FocusNode();
  final GlobalKey _interestRateKey = GlobalKey();

  final List<String> interestTypes = [
    'Simple Interest',
    'Compound Interest',
  ];

  final List<String> interestFrequencies = [
    'Monthly',
    'Yearly',
    'Daily',
  ];

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

    amountController = TextEditingController(
      text: transaction.amount
          .toStringAsFixed(0),
    );

    interestRateController = TextEditingController(
      text: transaction.interestRate
          .toStringAsFixed(0),
    );

    descriptionController = TextEditingController(
      text: transaction.description,
    );

    selectedDate = transaction.date;

    selectedInterestType =
    transaction.interestType.isEmpty
        ? null
        : transaction.interestType;

    selectedInterestFrequency =
    transaction.interestFrequency.isEmpty
        ? null
        : transaction.interestFrequency;

    selectedPaymentMode =
    transaction.paymentMode.isEmpty
        ? null
        : transaction.paymentMode;
  }

  @override
  void dispose() {
    amountController.dispose();
    interestRateController.dispose();
    descriptionController.dispose();
    _interestRateFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    // When the keyboard opens, use only the visible space above it.
    final availableHeight = screenHeight - keyboardHeight;

    final sheetHeight = keyboardHeight > 0
        ? availableHeight
        : screenHeight * 0.90;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: double.infinity,
      height: sheetHeight,
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      padding: const EdgeInsets.only(
        left: 16,
        top: 4,
        right: 16,
        bottom: 0,
      ),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 248, 240, 1),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
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

          const SizedBox(height: 12),

          // Scrollable content. The buttons stay fixed above the keyboard.
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(
                left: 0,
                top: 5,
                bottom: 20,
                right: 2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rupee icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
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

                  Text(
                    'Edit Transaction Details',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF233E67),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Amount
                  _buildLabel('Amount'),

                  const SizedBox(height: 5),

                  _buildTextField(
                    controller: amountController,
                    prefixText: '₹ ',
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 9),

                  // Date
                  _buildLabel('Date'),

                  const SizedBox(height: 5),

                  _buildDateField(),

                  const SizedBox(height: 9),

                  // Interest Rate
                  _buildLabel('Interest Rate (%)'),

                  const SizedBox(height: 5),

                  Container(
                    key: _interestRateKey,
                    child: _buildInterestRateField(),
                  ),

                  const SizedBox(height: 9),

                  // Description
                  _buildLabel('Description'),

                  const SizedBox(height: 5),

                  _buildDescriptionField(),

                  const SizedBox(height: 9),

                  // Payment Mode
                  _buildLabel('Payment Mode (Optional)'),

                  const SizedBox(height: 5),

                  _buildDropdown(
                    value: selectedPaymentMode,
                    hint: 'Select Payment Mode',
                    items: paymentModes,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMode = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // // Contact support
                  // _buildContactBox(),
                  //
                  // const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Fixed buttons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 12,
            ),
            color: const Color.fromRGBO(
              255,
              248,
              240,
              1,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                        const Color(0xFF233E67),
                        side: const BorderSide(
                          color: Color(0xFFBFC7D2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF213F68),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildInterestRateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: interestRateController,
          focusNode: _interestRateFocusNode,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          style: GoogleFonts.manrope(
            color: const Color(0xFF233E67),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (value) {
            if (_interestRateError &&
                value.trim().isNotEmpty) {
              setState(() {
                _interestRateError = false;
              });
            }
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 7,
            ),
            hintText: 'Enter Interest Rate',
            hintStyle: GoogleFonts.manrope(
              color: const Color(0xFF8B929B),
              fontSize: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: _interestRateError
                    ? Colors.red
                    : const Color(0xFFBFC7D2),
                width: 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: _interestRateError
                    ? Colors.red
                    : const Color(0xFF213F68),
                width: 1,
              ),
            ),
          ),
        ),

        if (_interestRateError)
          Padding(
            padding: const EdgeInsets.only(
              left: 4,
              top: 4,
            ),
            child: Text(
              'Interest rate is required',
              style: GoogleFonts.manrope(
                color: Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContactBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE0C9),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color.fromRGBO(
            177,
            95,
            39,
            0.23,
          ),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 15,
            color: Color(0xFFC74C4C),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'If you have any questions, feel free to contact us at',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF223A5E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'chopdi@geloratech.com',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC74C4C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildTextField({
    required TextEditingController controller,
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
          prefixStyle: GoogleFonts.manrope(
            color: const Color(0xFF233E67),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 7,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: Color.fromRGBO(170, 185, 207, 1),
              width: 0.8,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: Color.fromRGBO(170, 185, 207, 1),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFFBFC7D2),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Text(
              DateFormat('dd MMM yyyy')
                  .format(selectedDate),
              style: GoogleFonts.manrope(
                color: const Color(0xFF233E67),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            const Icon(
              Icons.calendar_month_outlined,
              color: Color(0xFF233E67),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
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


  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFBFC7D2),
          width: 0.8,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.manrope(
              color: const Color(0xFF7D8794),
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
            color: const Color(0xFF233E67),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 55,
          child: TextField(
            controller: descriptionController,
            maxLines: 3,
            maxLength: 100,
            onChanged: (_) {
              setState(() {});
            },
            style: GoogleFonts.manrope(
              color: const Color(0xFF233E67),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Description',
              contentPadding:
              const EdgeInsets.all(8),
              hintStyle: GoogleFonts.manrope(
                color: const Color(0xFF8B929B),
                fontSize: 9,
              ),
              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(6),
                borderSide:
                const BorderSide(
                  color: Color(0xFFBFC7D2),
                  width: 0.8,
                ),
              ),
              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(6),
                borderSide:
                const BorderSide(
                  color: Color(0xFF213F68),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    final amount = double.tryParse(
      amountController.text.trim(),
    );

    final interestRate = double.tryParse(
      interestRateController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _showError(
        'Please enter a valid amount',
      );
      return;
    }

    if (interestRateController.text.trim().isEmpty) {
      setState(() {
        _interestRateError = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _interestRateFocusNode.requestFocus();

        final fieldContext =
            _interestRateKey.currentContext;

        if (fieldContext != null) {
          Scrollable.ensureVisible(
            fieldContext,
            duration:
            const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            alignment: 0.25,
          );
        }
      });

      return;
    }

    if (interestRate == null ||
        interestRate < 0) {
      setState(() {
        _interestRateError = true;
      });

      return;
    }

    // ============================================================
    // EXISTING TRANSACTION
    // ============================================================

    final transaction = widget.transaction;

    // ============================================================
    // UPDATE TRANSACTION VALUES
    // ============================================================

    // Transaction stores amount in paise.
    // Example: ₹1000 = 100000 paise.
    transaction.amountPaise = (amount * 100).round();
    transaction.interestRateBp = (interestRate * 100).round();

    transaction.date =
        selectedDate;

    transaction.interestType =
        selectedInterestType ?? '';

    transaction.interestFrequency =
        selectedInterestFrequency ?? '';

    transaction.paymentMode =
        selectedPaymentMode ?? '';

    transaction.description =
        descriptionController.text.trim();

    // ============================================================
    // CALCULATE UPDATED INTEREST
    // ============================================================

    double calculatedInterest = 0;

    final interestType =
        selectedInterestType ?? '';

    final interestFrequency =
        selectedInterestFrequency ?? '';

    if (interestType.isNotEmpty &&
        interestFrequency.isNotEmpty &&
        interestRate > 0) {
      calculatedInterest =
          InterestCalculator.calculate(
            principal: amount,
            rate: interestRate,
            startDate: selectedDate,
            interestType: interestType,
            frequency: interestFrequency,
          );
    }

    // Save recalculated interest
    transaction.interest =
        calculatedInterest;

    // ============================================================
    // SAVE TRANSACTION
    // ============================================================

    await IsarService.isar.writeTxn(
          () async {
        await IsarService.isar.transactions.put(
          transaction,
        );
      },
    );

    // ============================================================
    // GET CUSTOMER
    // ============================================================

    final customer =
    await IsarService.isar.customers.get(
      transaction.customerId,
    );

    final customerName =
        customer?.name ?? "Customer";

    // ============================================================
    // CREATE INTEREST UPDATED NOTIFICATION
    // ============================================================

    if (calculatedInterest > 0 &&
        interestFrequency.isNotEmpty) {
      final interestPeriod =
      InterestCalculator.getInterestPeriod(
        startDate: selectedDate,
        frequency: interestFrequency,
      );

      final notificationService =
      NotificationService(
        IsarService.isar,
      );

      await notificationService
          .createInterestUpdatedNotification(
        chopdiId: transaction.chopdiId,
        customerName: customerName,
        interestAmount: calculatedInterest,
        interestPeriod: interestPeriod,
        customerId: transaction.customerId,
      );
    }

    // ============================================================
    // CLOSE
    // ============================================================

    if (!mounted) {
      return;
    }

    Navigator.pop(
      context,
      true,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}