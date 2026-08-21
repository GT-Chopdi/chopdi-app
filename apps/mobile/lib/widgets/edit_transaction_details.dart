// import 'package:flutter/material.dart';
// import 'package:mychopdi/model/transaction.dart';

// class EditTransactionDetailsBottomSheet extends StatefulWidget {

//   final bool isEdit;
//   final Transaction? transaction;

//   const EditTransactionDetailsBottomSheet({super.key, required this.transaction, required this.isEdit});

//   @override
//   State<EditTransactionDetailsBottomSheet> createState() =>
//       _EditTransactionDetailsBottomSheetState();
// }

// class _EditTransactionDetailsBottomSheetState
//     extends State<EditTransactionDetailsBottomSheet> {

//   final amountController =
//       TextEditingController(text: "₹ 15,000");

//   final dateController =
//       TextEditingController(text: "10 May 2026");

//   final interestController =
//       TextEditingController(text: "12");

//   final descriptionController =
//       TextEditingController(
//           text:
//               "Descriptiondwdqwertyhscsbjsdbcjbdcdjccjdbbdjbdjjdjdjddjdjjdhsc");

//   String interestType = "Simple Interest";
//   String frequency = "Monthly";
//   String paymentMode = "Select Payment Mode";
  

//   @override
//   Widget build(BuildContext context) {

//     final size = MediaQuery.of(context).size;

//     return DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 0.93,
//       minChildSize: 0.7,
//       maxChildSize: 0.95,
//       builder: (_, controller) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Color(0xffFBF5EC),
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(32),
//             ),
//           ),
//           child: Padding(
//             padding: EdgeInsets.only(
//               left: 20,
//               right: 20,
//               top: 10,
//               bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//             ),
//             child: Column(
//               children: [

//                 /// Drag Handle
//                 Container(
//                   width: 60,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade500,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),

//                 const SizedBox(height: 22),

//                 CircleAvatar(
//                   radius: 34,
//                   backgroundColor: const Color(0xffD4DCEB),
//                   child: Icon(
//                     Icons.currency_rupee,
//                     color: const Color(0xff23406B),
//                     size: 34,
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 const Text(
//                   "Edit Transaction Details",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xff1F3966),
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 Expanded(
//                   child: ListView(
//                     controller: controller,
//                     children: [

//                       buildLabel("Amount"),

//                       buildField(
//                         controller: amountController,
//                       ),

//                       const SizedBox(height: 15),

//                       buildLabel("Date"),

//                       buildField(
//                         controller: dateController,
//                         suffix: const Icon(Icons.calendar_today_outlined),
//                       ),

//                       const SizedBox(height: 15),

//                       buildLabel("Interest Rate (%)"),

//                       buildField(
//                         controller: interestController,
//                       ),

//                       const SizedBox(height: 15),

//                       buildLabel("Interest Type"),

//                       buildDropdown(
//                         value: interestType,
//                         items: const [
//                           "Simple Interest",
//                           "Compound Interest"
//                         ],
//                         onChanged: (v) {
//                           setState(() {
//                             interestType = v!;
//                           });
//                         },
//                       ),

//                       const SizedBox(height: 15),

//                       buildLabel("Interest Frequency"),

//                       buildDropdown(
//                         value: frequency,
//                         items: const [
//                           "Monthly",
//                           "Quarterly",
//                           "Yearly",
//                         ],
//                         onChanged: (v) {
//                           setState(() {
//                             frequency = v!;
//                           });
//                         },
//                       ),

//                       const SizedBox(height: 15),

//                       buildLabel("Payment Mode (Optional)"),

//                       buildDropdown(
//                         value: paymentMode,
//                         items: const [
//                           "Select Payment Mode",
//                           "Cash",
//                           "UPI",
//                           "Bank Transfer"
//                         ],
//                         onChanged: (v) {
//                           setState(() {
//                             paymentMode = v!;
//                           });
//                         },
//                       ),

//                       const SizedBox(height: 15),

//                       buildLabel("Description"),

//                       Stack(
//                         children: [
//                           TextField(
//                             controller: descriptionController,
//                             maxLength: 100,
//                             maxLines: 3,
//                             decoration: inputDecoration(
//                               hint: "Description",
//                             ),
//                           ),

//                           Positioned(
//                             right: 14,
//                             bottom: 12,
//                             child: Text(
//                               "${descriptionController.text.length}/100",
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           )
//                         ],
//                       ),

//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),

//                 Row(
//                   children: [

//                     Expanded(
//                       child: OutlinedButton(
//                         style: OutlinedButton.styleFrom(
//                           minimumSize: const Size.fromHeight(52),
//                           side: const BorderSide(
//                             color: Color(0xffBFC7D8),
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text(
//                           "Cancel",
//                           style: TextStyle(
//                             color: Color(0xff1F3966),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(width: 15),

//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: const Size.fromHeight(52),
//                           backgroundColor: const Color(0xff223D69),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () {},
//                         child: const Text(
//                           "Save Changes",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget buildLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Color(0xff6F7A8F),
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   Widget buildField({
//     required TextEditingController controller,
//     Widget? suffix,
//   }) {
//     return TextField(
//       controller: controller,
//       decoration: inputDecoration(
//         suffix: suffix,
//       ),
//     );
//   }

//   Widget buildDropdown({
//     required String value,
//     required List<String> items,
//     required Function(String?) onChanged,
//   }) {
//     return DropdownButtonFormField<String>(
//       initialValue: value,
//       decoration: inputDecoration(),
//       icon: const Icon(Icons.keyboard_arrow_down),
//       items: items
//           .map(
//             (e) => DropdownMenuItem(
//               value: e,
//               child: Text(e),
//             ),
//           )
//           .toList(),
//       onChanged: onChanged,
//     );
//   }

//   InputDecoration inputDecoration({
//     Widget? suffix,
//     String? hint,
//   }) {
//     return InputDecoration(
//       hintText: hint,
//       suffixIcon: suffix,
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding:
//           const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Color(0xffC7D0DF),
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Color(0xff23406B),
//           width: 1.4,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/model/customer.dart';

import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/notification_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        5,
        0,
        5,
        2,
      ),
      padding: const EdgeInsets.only(
                left: 16,
                top: 4,
                bottom: 8,
              ),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 248, 240, 1),
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
                left: 16,
                top: 5,
                bottom: 12,
                right: 18,
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 38,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF85817D),
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 17),

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

            // Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
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
                        foregroundColor:
                            Colors.white,
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
          ],
        ),
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

    if (interestRate == null ||
        interestRate < 0) {
      _showError(
        'Please enter a valid interest rate',
      );
      return;
    }

    // ============================================================
    // EXISTING TRANSACTION
    // ============================================================

    final transaction = widget.transaction;

    // ============================================================
    // UPDATE TRANSACTION VALUES
    // ============================================================

    transaction.amount = amount;

    transaction.interestRate =
        interestRate;

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