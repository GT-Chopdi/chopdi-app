// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:mychopdi/model/customer.dart';
// import 'package:mychopdi/model/transaction.dart';
// import 'package:mychopdi/service/transaction_service.dart';

// class MoneyReceiveBottomSheet extends StatefulWidget {

//   final Customer customer;
//   final VoidCallback onSaved;
//   const MoneyReceiveBottomSheet({super.key, required this.customer, required this.onSaved});

//   @override
//   State<MoneyReceiveBottomSheet> createState() => _MoneyReceiveBottomSheetState();
// }

// class _MoneyReceiveBottomSheetState extends State<MoneyReceiveBottomSheet> {
//   final TextEditingController amountController = TextEditingController();
//   final TextEditingController interestController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();

//   DateTime selectedDate = DateTime.now();

//   // String interestType = "Simple Interest";
//   // String interestFrequency = "Monthly";
//   String paymentMode = "";

//   Future<void> _pickDate() async {
//     final DateTime today = DateTime.now();

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate.isAfter(today) ? today : selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: today, // Future dates disabled
//     );

//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   InputDecoration decoration({
//     String? hint,
//     Widget? suffix,
//     Widget? prefix,
//   }) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(
//         color: Color(0xff8A93A6),
//         fontWeight: FontWeight.w500,
//       ),
//       prefixIcon: prefix,
//       suffixIcon: suffix,
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 16,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Color(0xffC9D2E3),
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Color(0xff29406B),
//           width: 1.3,
//         ),
//       ),
//     );
//   }

//   Widget title(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 15,
//           color: Color(0xff737D8C),
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Container(
//         decoration: const BoxDecoration(
//           color: Color(0xffFFF8F0),
//           borderRadius: BorderRadius.vertical(
//             top: Radius.circular(34),
//           ),
//         ),
//         padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Container(
//                 width: 55,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade500,
//                   borderRadius: BorderRadius.circular(50),
//                 ),
//               ),

//               const SizedBox(height: 22),

//               Container(
//                 height: 72,
//                 width: 72,
//                 decoration: const BoxDecoration(
//                   color: Color.fromRGBO(141, 208, 113, 0.34),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: CircleAvatar(
//                     radius: 18,
//                     backgroundColor: Colors.transparent,
//                     child: Image.asset('assets/you_got.png'),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 10),

//               Text(
//                 "You Got",
//                 style: GoogleFonts.manrope(
//                   color: Color(0xFF00901B),
//                   fontWeight: FontWeight.w700,
//                   fontSize: 22,
//                 ),
//               ),

//               const SizedBox(height: 28),

//               Align(
//                   alignment: Alignment.centerLeft,
//                   child: title("Amount")),

//               TextField(
//                 controller: amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: decoration(
//                   hint: "Enter Amount",
//                   prefix: const Icon(Icons.currency_rupee,
//                       size: 20, color: Color(0xff6D7B94)),
//                 ),
//               ),

//               const SizedBox(height: 18),

//               Align(
//                   alignment: Alignment.centerLeft,
//                   child: title("Date")),

//               TextField(
//                 readOnly: true,
//                 onTap: _pickDate,
//                 decoration: decoration(
//                   hint: DateFormat("dd MMM yyyy").format(selectedDate),
//                   suffix: const Icon(Icons.calendar_today_outlined),
//                 ),
//               ),

//               const SizedBox(height: 18),

//               Align(
//                   alignment: Alignment.centerLeft,
//                   child: title("Payment Mode (Optional)")),

//               DropdownButtonFormField<String>(
//                 initialValue: paymentMode.isEmpty ? null : paymentMode,
//                 decoration: decoration(
//                   hint: "Select Payment Mode",
//                 ),
//                 icon: const Icon(Icons.keyboard_arrow_down),
//                 items: const [
//                   DropdownMenuItem(
//                     value: "Cash",
//                     child: Text("Cash"),
//                   ),
//                   DropdownMenuItem(
//                     value: "UPI",
//                     child: Text("UPI"),
//                   ),
//                   DropdownMenuItem(
//                     value: "Bank",
//                     child: Text("Bank Transfer"),
//                   ),
//                 ],
//                 onChanged: (v) {
//                   setState(() {
//                     paymentMode = v!;
//                   });
//                 },
//               ),

//               const SizedBox(height: 18),

//               Align(
//                   alignment: Alignment.centerLeft,
//                   child: title("Description")),

//               TextField(
//                 controller: descriptionController,
//                 maxLength: 100,
//                 maxLines: 4,
//                 decoration: decoration(
//                   hint: "Enter Description here...",
//                 ).copyWith(counterText: ""),
//                 onChanged: (_) => setState(() {}),
//               ),

//               // Align(
//               //   alignment: Alignment.centerRight,
//               //   child: Text(
//               //     "${descriptionController.text.length}/100",
//               //     style: const TextStyle(
//               //       color: Color(0xff6F7A8C),
//               //       fontWeight: FontWeight.w600,
//               //     ),
//               //   ),
//               // ),

//               const SizedBox(height: 22),

//               Row(
//                 children: [
//                   Expanded(
//                     child: SizedBox(
//                       height: 52,
//                       child: OutlinedButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: OutlinedButton.styleFrom(
//                           side: const BorderSide(
//                             color: Color(0xffC7D0DF),
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           "Cancel",
//                           style: TextStyle(
//                             color: Color(0xff29406B),
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 18),
//                   Expanded(
//                     child: SizedBox(
//                       height: 52,
//                       child: ElevatedButton(
//                         onPressed: () async{
//                           if(amountController.text.isEmpty){
//                             return;
//                           }

//                           // final tx = Transaction()
//                           //   ..customerId = widget.customer.id
//                           //   ..amount = double.parse(amountController.text)
//                           //   ..interest = 0
//                           //   ..date = selectedDate
//                           //   ..type = TransactionType.received;

//                           // await TransactionService.addTransaction(tx);

//                           final tx = Transaction()
//                             ..customerId = widget.customer.id
//                             ..amount = double.parse(amountController.text)
//                             ..interestRate = 0
//                             ..date = selectedDate
//                             ..type = TransactionType.received
//                             ..description = descriptionController.text
//                             ..paymentMode = paymentMode
//                             ..interestType = ""
//                             ..interestFrequency = "";

//                           await TransactionService.addTransaction(tx);

//                           widget.onSaved();

//                           Navigator.pop(context);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xff29406B),
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           "Save Entry",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),
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
import 'package:mychopdi/service/transaction_service.dart';
import 'package:mychopdi/utils/money.dart';

class TookLoanMoneyReceivedBottomSheet extends StatefulWidget {
  final Customer customer;
  final VoidCallback onSaved;

  const TookLoanMoneyReceivedBottomSheet({
    super.key,
    required this.customer,
    required this.onSaved,
  });

  @override
  State<TookLoanMoneyReceivedBottomSheet> createState() =>
      _MoneyReceiveBottomSheetState();
}

class _MoneyReceiveBottomSheetState
    extends State<TookLoanMoneyReceivedBottomSheet> {

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController interestController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  // Scroll controller
  final ScrollController _scrollController =
      ScrollController();

  // Focus nodes
  final FocusNode _amountFocusNode =
      FocusNode();

  final FocusNode _descriptionFocusNode =
      FocusNode();

  DateTime selectedDate = DateTime.now();

  String paymentMode = "";

  @override
  void initState() {
    super.initState();

    // Automatically move Amount field above keyboard
    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        _scrollToAmount();
      }
    });

    // Automatically move Description field above keyboard
    _descriptionFocusNode.addListener(() {
      if (_descriptionFocusNode.hasFocus) {
        _scrollToDescription();
      }
    });
  }

  // ============================================================
  // SCROLL TO AMOUNT
  // ============================================================

  void _scrollToAmount() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // SCROLL TO DESCRIPTION
  // ============================================================

  void _scrollToDescription() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _pickDate() async {
    final DateTime today = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate.isAfter(today)
              ? today
              : selectedDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration decoration({
    String? hint,
    Widget? suffix,
    Widget? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xff8A93A6),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xffC9D2E3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xff29406B),
          width: 1.3,
        ),
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xff737D8C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // SAVE TRANSACTION
  // ============================================================

  Future<void> _saveTransaction() async {
    if (amountController.text.trim().isEmpty) {
      return;
    }

    final amount =
        double.tryParse(amountController.text.trim());

    if (amount == null) {
      return;
    }

    final tx = Transaction()
      ..customerId = widget.customer.id
      ..chopdiId = widget.customer.chopdiId
      // Money is stored as integer paise; `amount` is now a read-only rupee
      // view of it.
      ..amountPaise = Money.toPaise(amount)
      ..interestRateBp = 0
      ..date = selectedDate
      ..type = TransactionType.paid
      ..description =
          descriptionController.text.trim()
      ..paymentMode = paymentMode
      ..interestType = ""
      ..interestFrequency = "";

    await TransactionService.addTransaction(tx);

    final notificationService =
        NotificationService(IsarService.isar);

    await notificationService.createLoanNotification(
      chopdiId: widget.customer.chopdiId,
      loanType: "paid",
      customerName: widget.customer.name,
      amount: amount,
      customerId: widget.customer.id,
    );

    widget.onSaved();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    amountController.dispose();
    interestController.dispose();
    descriptionController.dispose();

    _scrollController.dispose();

    _amountFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height:
              MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Color(0xffFFF8F0),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(34),
            ),
          ),
          child: Column(
            children: [

              // ==================================================
              // HANDLE
              // ==================================================

              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 55,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius:
                        BorderRadius.circular(50),
                  ),
                ),
              ),

              // ==================================================
              // SCROLLABLE FORM
              // ==================================================

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,

                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior
                          .onDrag,

                  padding: const EdgeInsets.fromLTRB(
                    22,
                    10,
                    22,
                    25,
                  ),

                  child: Column(
                    children: [

                      const SizedBox(height: 12),

                      // ==================================================
                      // ICON
                      // ==================================================

                      Container(
                        height: 72,
                        width: 72,
                        decoration:
                            const BoxDecoration(
                          color: Color.fromRGBO(
                            141,
                            208,
                            113,
                            0.34,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                Colors.transparent,
                            child: Image.asset(
                              'assets/you_got.png',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "You Paid",
                        style: GoogleFonts.manrope(
                          color:
                              const Color(0xFF00901B),
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // AMOUNT
                      // ==================================================

                      Align(
                        alignment:
                            Alignment.centerLeft,
                        child: title("Amount"),
                      ),

                      TextField(
                        controller:
                            amountController,
                        focusNode:
                            _amountFocusNode,
                        keyboardType:
                            TextInputType.number,
                        decoration: decoration(
                          hint: "Enter Amount",
                          prefix: const Icon(
                            Icons.currency_rupee,
                            size: 20,
                            color:
                                Color(0xff6D7B94),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================================================
                      // DATE
                      // ==================================================

                      Align(
                        alignment:
                            Alignment.centerLeft,
                        child: title("Date"),
                      ),

                      TextField(
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: decoration(
                          suffix: const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.black,
                          ),
                        ).copyWith(
                          hintText: DateFormat("dd MMM yyyy").format(selectedDate),
                          hintStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Align(
                        alignment:
                            Alignment.centerLeft,
                        child: title("Description"),
                      ),

                      TextField(
                        controller:
                            descriptionController,
                        focusNode:
                            _descriptionFocusNode,
                        maxLength: 100,
                        maxLines: 4,
                        decoration: decoration(
                          hint:
                              "Enter Description here...",
                        ).copyWith(
                          counterText: "",
                        ),
                        onChanged: (_) =>
                            setState(() {}),
                      ),

                      const SizedBox(height: 18),
                      
                      // ==================================================
                      // PAYMENT MODE
                      // ==================================================

                      Align(
                        alignment:
                            Alignment.centerLeft,
                        child: title(
                          "Payment Mode (Optional)",
                        ),
                      ),

                      DropdownButtonFormField<String>(
                        initialValue:
                            paymentMode.isEmpty
                                ? null
                                : paymentMode,
                        decoration: decoration(
                          hint:
                              "Select Payment Mode",
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Cash",
                            child: Text("Cash"),
                          ),
                          DropdownMenuItem(
                            value: "UPI",
                            child: Text("UPI"),
                          ),
                          DropdownMenuItem(
                            value: "Bank",
                            child:
                                Text("Bank Transfer"),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            paymentMode = v!;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      // ==================================================
                      // DESCRIPTION
                      // ==================================================

                      // Align(
                      //   alignment:
                      //       Alignment.centerLeft,
                      //   child: title("Description"),
                      // ),

                      // TextField(
                      //   controller:
                      //       descriptionController,
                      //   focusNode:
                      //       _descriptionFocusNode,
                      //   maxLength: 100,
                      //   maxLines: 4,
                      //   decoration: decoration(
                      //     hint:
                      //         "Enter Description here...",
                      //   ).copyWith(
                      //     counterText: "",
                      //   ),
                      //   onChanged: (_) =>
                      //       setState(() {}),
                      // ),

                      // Extra space at bottom of scroll
                      // so Description can move above keyboard
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // FIXED BUTTONS
              // ==================================================

              Container(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  20,
                ),
                color: const Color(0xffFFF8F0),
                child: Row(
                  children: [

                    // ==================================================
                    // CANCEL
                    // ==================================================

                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            FocusScope.of(context)
                                .unfocus();

                            Navigator.pop(context);
                          },
                          style:
                              OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color:
                                  Color(0xffC7D0DF),
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color:
                                  Color(0xff29406B),
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 18),

                    // ==================================================
                    // SAVE ENTRY
                    // ==================================================

                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              _saveTransaction,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                              0xff29406B,
                            ),
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          child: const Text(
                            "Save Entry",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.w700,
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
}