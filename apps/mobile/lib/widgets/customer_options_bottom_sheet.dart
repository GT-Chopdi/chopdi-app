import 'package:flutter/material.dart';
import 'package:mychopdi/utils/app_colors.dart';

class CustomerOptionsBottomSheet extends StatelessWidget {
  const CustomerOptionsBottomSheet({
    super.key,
    required this.onEdit,
    required this.onWhatsapp,
    required this.onExport,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onWhatsapp;
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

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Customer Options",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xff5F6B7A),
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
              image: 'assets/whatsapp_logo.png',
              title: "WhatsApp Customer",
              subtitle: "Chat with customer",
              onTap: onWhatsapp,
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
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xff243B63),
                  fontWeight: FontWeight.w600,
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
    this.titleColor = const Color(0xff243B63),
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
            color: const Color(0xffD6DEE8),
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
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
  const EditCustomerBottomSheet({super.key});

  @override
  State<EditCustomerBottomSheet> createState() =>
      _EditCustomerBottomSheetState();
}

class _EditCustomerBottomSheetState extends State<EditCustomerBottomSheet> {
  final TextEditingController nameController = TextEditingController(text: "Rahul");
  final TextEditingController phoneController = TextEditingController(text: "+91 9867545673");
  final TextEditingController amountController = TextEditingController(text: "15000");
  final TextEditingController interestController = TextEditingController(text: "12");

  String interestType = "Simple Interest";
  String loanDuration = "12 Months";
  String interestFrequency = "Monthly";

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    amountController.dispose();
    interestController.dispose();
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
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .90,
      maxChildSize: .95,
      minChildSize: .70,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 248, 240, 1),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// drag handle
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

                const Center(
                  child: Text(
                    "Edit Customer",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "Customer Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: nameController,
                  decoration: inputDecoration("Customer Name"),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Phone Number",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: inputDecoration("Phone Number"),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Loan Amount",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration:
                                inputDecoration("Loan Amount"),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Interest Rate",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: interestController,
                            keyboardType: TextInputType.number,
                            decoration:
                                inputDecoration("12%"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                                /// Interest Type
                const Text(
                  "Interest Type",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 248, 240, 1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: interestType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: const [
                        DropdownMenuItem(
                          value: "Simple Interest",
                          child: Text("Simple Interest"),
                        ),
                        DropdownMenuItem(
                          value: "Compound Interest",
                          child: Text("Compound Interest"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          interestType = value!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// Loan Duration
                const Text(
                  "Loan Duration",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 248, 240, 1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: loanDuration,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: const [
                        DropdownMenuItem(
                          value: "3 Months",
                          child: Text("3 Months"),
                        ),
                        DropdownMenuItem(
                          value: "6 Months",
                          child: Text("6 Months"),
                        ),
                        DropdownMenuItem(
                          value: "12 Months",
                          child: Text("12 Months"),
                        ),
                        DropdownMenuItem(
                          value: "24 Months",
                          child: Text("24 Months"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          loanDuration = value!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// Interest Frequency
                const Text(
                  "Interest Frequency",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 248, 240, 1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: interestFrequency,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: const [
                        DropdownMenuItem(
                          value: "Daily",
                          child: Text("Daily"),
                        ),
                        DropdownMenuItem(
                          value: "Weekly",
                          child: Text("Weekly"),
                        ),
                        DropdownMenuItem(
                          value: "Monthly",
                          child: Text("Monthly"),
                        ),
                        DropdownMenuItem(
                          value: "Yearly",
                          child: Text("Yearly"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          interestFrequency = value!;
                        });
                      },
                    ),
                  ),
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
                        onPressed: () {

                          // TODO:
                          // Save customer details here

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
        );
      },
    );
  }
}


class ExportPdfBottomSheet extends StatelessWidget {
  const ExportPdfBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .86,
      maxChildSize: .90,
      minChildSize: .70,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 248, 240, 1),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(20),
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
                  radius: 34,
                  backgroundColor: const Color.fromRGBO(170, 185, 207, 0.6),
                  child: Image.asset('assets/export_pdf.png',height: 100, width: 100),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Export PDF",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff29416A),
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Download ledger as PDF",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 25),

                _ledgerPreview(),

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

                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ledgerPreview() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 248, 240, 1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color.fromRGBO(170, 185, 207, 1)),
      ),
      child: Column(
        children: [

          Row(
            children: [

              Image.asset('assets/app_logo.png',height: 50,width: 50),

              SizedBox(width: 10),

              Text(
                "Chopdi",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Spacer(),

              Text(
                "Ledger Summary",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),

          const SizedBox(height: 18),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Customer Details",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Rahul",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 5),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "+91 98675 45673",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 20),

          _row("Loan Amount", "₹15,000"),

          _row("Interest Rate", "12%"),

          _row("Total Received", "₹3000",
              valueColor: Colors.green),

          _row("Outstanding", "₹12,150",
              valueColor: Colors.red),

          const SizedBox(height: 28),

          const Divider(),

          const SizedBox(height: 15),

          const Text(
            "Generated on 27 July 2026",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Thank You for using Chopdi",
            style: TextStyle(
              color: Color(0xff29416A),
            ),
          )
        ],
      ),
    );
  }

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
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .78,
      maxChildSize: .85,
      minChildSize: .65,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 248, 240, 1),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(22),
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2F477A),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "This action cannot be undone",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 28),

                /// Warning Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xffF26C63),
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

                            const Text(
                              "All customer data will be permanently deleted including:",
                              style: TextStyle(
                                color: Color(0xffE4554B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "• Customer Details",
                              style: TextStyle(
                                color: Color(0xffE4554B),
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "• Ledger and Transactions",
                              style: TextStyle(
                                color: Color(0xffE4554B),
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "• Notes and reminders",
                              style: TextStyle(
                                color: Color(0xffE4554B),
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "• Loan information",
                              style: TextStyle(
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: agreed,
                    activeColor: Colors.red,
                    controlAffinity:
                        ListTileControlAffinity.leading,
                    title: const Text(
                      "I understand this action cannot be undone.",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xff2F477A),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        agreed = value!;
                      });
                    },
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
        );
      },
    );
  }
}