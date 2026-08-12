import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/summary_tile.dart';

class CustomerOptionsBottomSheet extends StatelessWidget {
  const CustomerOptionsBottomSheet({
    super.key,
    required this.onEdit,
    required this.onSummary,
    required this.onExport,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onSummary;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 55,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Customer Options",
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: Color.fromRGBO(34, 58, 94, 0.62),
                ),
              ),
            ),

            const SizedBox(height: 12),

            _OptionTile(
              image: 'assets/edit_customer_logo.png',
              title: "Edit Customer",
              subtitle: "Edit name, phone or loan details",
              onTap: onEdit,
            ),

            const SizedBox(height: 10),

            _OptionTile(
              image: 'assets/summary.png',
              title: "Account Summary",
              subtitle: "Overview and summary",
              onTap: onSummary,
            ),

            const SizedBox(height: 10),

            _OptionTile(
              image: 'assets/export_pdf.png',
              title: "Export PDF",
              subtitle: "Download ledger as PDF",
              onTap: onExport,
            ),

            const SizedBox(height: 10),

            _OptionTile(
              image: 'assets/delete_logo.png',
              title: "Delete Customer",
              subtitle: "Delete this customer permanently",
              titleColor: Colors.red,
              onTap: onDelete,
            ),

            const SizedBox(height: 18),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.manrope(
                  color: ChopdiColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 248, 240, 1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color.fromRGBO(170, 185, 207, 1),
          ),
        ),
        child: Row(
          children: [

            // Image instead of Icon
            Container(
              height: 34,
              width: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(255, 248, 240, 1),
              ),
              child: Center(
                child: Image.asset(
                  image,
                  height: 18,
                  width: 18,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Color.fromRGBO(34, 58, 94, 0.86),
                    ),
                  ),
                ],
              ),
            ),

            Image.asset(
              "assets/right_arrow.png",
              width: 18,
              height: 18,
            ),
          ],
        ),
      ),
    );
  }
}


class EditCustomerBottomSheet extends StatefulWidget {

  final Customer customer;
  final VoidCallback onSaved;
  const EditCustomerBottomSheet({super.key, required this.customer, required this.onSaved});

  @override
  State<EditCustomerBottomSheet> createState() =>
      _EditCustomerBottomSheetState();
}

class _EditCustomerBottomSheetState extends State<EditCustomerBottomSheet> {
  late TextEditingController nameController = TextEditingController();
  late TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.customer.name,
    );

    phoneController = TextEditingController(
      text: widget.customer.phone,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Color.fromRGBO(255, 248, 240, 1),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xff2F477A),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child :Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 248, 240, 1),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
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

                /// edit icon
                Center(
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xffEAF2FF),
                    child: Icon(
                      Icons.edit,
                      size: 32,
                      color: Color(0xff2F477A),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Center(
                  child: Text(
                    "Edit Customer Details",
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Text(
                    "Edit name, phone or loan details",
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  "Name",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(34, 58, 94, 0.62),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: nameController,
                  decoration: inputDecoration("Customer Name"),
                ),

                const SizedBox(height: 18),

                Text(
                  "Phone Number",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(34, 58, 94, 0.62),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: inputDecoration("Phone Number"),
                ),

                const SizedBox(height: 34),

                Row(
                  children: [

                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(55),
                          side: const BorderSide(
                            color: Color(0xff2F477A),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancel",
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
                          backgroundColor: ChopdiColors.navy,
                          minimumSize: const Size.fromHeight(55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async{
                          widget.customer
                              ..name = nameController.text
                              ..phone = phoneController.text;

                            await IsarService.isar.writeTxn(() async {
                              await IsarService.isar.customers.put(widget.customer);
                            });

                            widget.onSaved();

                          Navigator.pop(context);
                        },
                        child: Text(
                          "Save Changes",
                          style: TextStyle(
                            color: ChopdiColors.cream,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
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
  
  const AccountSummaryBottomSheet({
    super.key,
    required this.totalGiven,
    required this.totalOutstanding,
    required this.totalInterest,
    required this.lastPayment,
    required this.firstLoan,
  });

  @override
  Widget build(BuildContext context) {
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
              "Account Summary",
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xff223A5E),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Overview of this customer's account",
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: const Color(0xff6E7A8A),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 28),

            SummaryTile(
              icon: Icons.account_balance_wallet_outlined,
              title: "Total Amount Given",
              value: "₹${totalGiven.toStringAsFixed(0)}",
              valueColor: const Color(0xff223A5E),
            ),

            SummaryTile(
              icon: Icons.location_on_outlined,
              title: "Current Outstanding",
              value: "₹${totalOutstanding.toStringAsFixed(0)}",
              valueColor: Colors.red,
            ),

            SummaryTile(
              icon: Icons.percent,
              title: "Total Interest",
              value: "₹${totalInterest.toStringAsFixed(0)}",
              valueColor: Colors.green,
            ),

            SummaryTile(
              icon: Icons.calendar_month_outlined,
              title: "Last Payment",
              value: lastPayment == null
                ? "-"
                : DateFormat("dd MMM yyyy").format(lastPayment!.date),

              subtitle: lastPayment == null
                  ? null
                  : "(₹${lastPayment!.amount.toStringAsFixed(0)} received)",
              valueColor: const Color(0xff223A5E),
            ),

            SummaryTile(
              icon: Icons.calendar_today_outlined,
              title: "Loan Given On",
              value: firstLoan == null
                ? "-"
                : DateFormat("dd MMM yyyy").format(firstLoan!.date),
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
    } else {
      return tx.amount *
          (pow(1 + tx.interestRate / 100, time) - 1);
    }
  }

  final Customer customer;
  final List<Transaction> transactions;
  const ExportPdfBottomSheet({
    super.key,
    required this.customer,
    required this.transactions,
  });

  Future<void> generatePdf() async {

    final totalGiven = transactions
        .where((e) => e.type == TransactionType.gave)
        .fold<double>(0, (sum, e) => sum + e.amount);

    final totalReceived = transactions
        .where((e) => e.type == TransactionType.received)
        .fold<double>(0, (sum, e) => sum + e.amount);

    final totalInterest = transactions.fold<double>(
        0, (sum, e) => sum + calculateInterest(e));

    final outstanding =
        totalGiven + totalInterest - totalReceived;

    // Use these values in your PDF

    print(customer.name);
    print(customer.phone);
    print(totalGiven);
    print(totalReceived);
    print(totalInterest);
    print(outstanding);

    for (final tx in transactions) {
      print(tx.amount);
      print(tx.date);
      print(tx.paymentMode);
    }

    // Generate pdf...
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child : Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 248, 240, 1),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [

                /// drag handle
                Container(
                  width: 55,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 24),

                /// icon
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color.fromRGBO(170, 185, 207, 0.6),
                  child: Image.asset('assets/export_pdf.png',height: 150, width: 150),
                ),

                const SizedBox(height: 14),

                Text(
                  "Export PDF",
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ChopdiColors.navy,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Download this customer's chopdi as PDF",
                  style: GoogleFonts.manrope(
                    color: ChopdiColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700
                  ),
                ),

                const SizedBox(height: 25),

                // _ledgerPreview(),

                Center(
                  child: Row(
                    children: [
                      SizedBox(width: 95),
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: Image.asset("assets/app_logo.png")
                      ),

                      // const SizedBox(width: 5),

                      Text(
                        "Chopdi",
                        style: GoogleFonts.manrope(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: ChopdiColors.navy
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(253, 237, 217, 1),
                    border: Border.all(
                      color: Color.fromRGBO(177, 95, 39, 0.23),
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Image.asset("assets/download_warning.png"),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              "This will export all transactions and details of this\ncustomer’s chopdi.",
                              style: GoogleFonts.manrope(
                                color: Color.fromRGBO(34, 58, 94, 1),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChopdiColors.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.download,color: ChopdiColors.cream),
                    label: const Text(
                      "Download PDF",
                      style: TextStyle(
                        color: ChopdiColors.cream,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {

                      /// generate pdf here
                      generatePdf();

                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
    );
  }

  // Widget _ledgerPreview() {
  //   return Container(
  //     padding: const EdgeInsets.all(18),
  //     decoration: BoxDecoration(
  //       color: Color.fromRGBO(255, 248, 240, 1),
  //       borderRadius: BorderRadius.circular(18),
  //       border: Border.all(color: Color.fromRGBO(170, 185, 207, 1)),
  //     ),
  //     child: Column(
  //       children: [

  //         Row(
  //           children: [

  //             Image.asset('assets/app_logo.png',height: 50,width: 50),

  //             SizedBox(width: 10),

  //             Text(
  //               "Chopdi",
  //               style: TextStyle(
  //                 fontSize: 28,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),

  //             Spacer(),

  //             Text(
  //               "Ledger Summary",
  //               style: TextStyle(
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             )
  //           ],
  //         ),

  //         const SizedBox(height: 18),

  //         const Align(
  //           alignment: Alignment.centerLeft,
  //           child: Text(
  //             "Customer Details",
  //             style: TextStyle(
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),

  //         const SizedBox(height: 8),

  //         const Align(
  //           alignment: Alignment.centerLeft,
  //           child: Text(
  //             "Rahul",
  //             style: TextStyle(
  //               fontSize: 26,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),

  //         const SizedBox(height: 5),

  //         const Align(
  //           alignment: Alignment.centerLeft,
  //           child: Text(
  //             "+91 98675 45673",
  //             style: TextStyle(color: Colors.grey),
  //           ),
  //         ),

  //         const SizedBox(height: 20),

  //         _row("Loan Amount", "₹15,000"),

  //         _row("Interest Rate", "12%"),

  //         _row("Total Received", "₹3000",
  //             valueColor: Colors.green),

  //         _row("Outstanding", "₹12,150",
  //             valueColor: Colors.red),

  //         const SizedBox(height: 28),

  //         const Divider(),

  //         const SizedBox(height: 15),

  //         const Text(
  //           "Generated on 27 July 2026",
  //           style: TextStyle(
  //             fontSize: 11,
  //             color: Colors.grey,
  //           ),
  //         ),

  //         const SizedBox(height: 6),

  //         const Text(
  //           "Thank You for using Chopdi",
  //           style: TextStyle(
  //             color: Color(0xff29416A),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget _row(
    String title,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [

          Expanded(
            child: Text(title),
          ),

          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}

class DeleteCustomerBottomSheet extends StatefulWidget {
  final String customerName;
  final VoidCallback onDelete;

  const DeleteCustomerBottomSheet({
    super.key,
    required this.customerName,
    required this.onDelete,
  });

  @override
  State<DeleteCustomerBottomSheet> createState() =>  _DeleteCustomerBottomSheetState();
}

class _DeleteCustomerBottomSheetState extends State<DeleteCustomerBottomSheet> {
  bool agreed = false;

  @override
  Widget build(BuildContext context) {
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
                  "Delete ${widget.customerName}?",
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ChopdiColors.navy,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "This action cannot be undone",
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
                              "All customer data will be permanently deleted including:",
                              style: GoogleFonts.manrope(
                                color: Color(0xffE4554B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "• Customer Details",
                              style: GoogleFonts.manrope(
                                color: Color(0xffE4554B),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "• Ledger and Transactions",
                              style: GoogleFonts.manrope(
                                color: Color(0xffE4554B),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "• Notes and reminders",
                              style: GoogleFonts.manrope(
                                color: Color(0xffE4554B),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "• Loan information",
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
                        "I understand this action cannot be undone.",
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
                        child: const Text(
                          "Cancel",
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
                        child: const Text(
                          "Delete Customer",
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