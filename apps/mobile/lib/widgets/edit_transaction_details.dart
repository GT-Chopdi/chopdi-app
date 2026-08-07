import 'package:flutter/material.dart';
import 'package:mychopdi/model/transaction.dart';

class EditTransactionDetailsBottomSheet extends StatefulWidget {

  final bool isEdit;
  final Transaction? transaction;

  const EditTransactionDetailsBottomSheet({super.key, required this.transaction, required this.isEdit});

  @override
  State<EditTransactionDetailsBottomSheet> createState() =>
      _EditTransactionDetailsBottomSheetState();
}

class _EditTransactionDetailsBottomSheetState
    extends State<EditTransactionDetailsBottomSheet> {

  final amountController =
      TextEditingController(text: "₹ 15,000");

  final dateController =
      TextEditingController(text: "10 May 2026");

  final interestController =
      TextEditingController(text: "12");

  final descriptionController =
      TextEditingController(
          text:
              "Descriptiondwdqwertyhscsbjsdbcjbdcdjccjdbbdjbdjjdjdjddjdjjdhsc");

  String interestType = "Simple Interest";
  String frequency = "Monthly";
  String paymentMode = "Select Payment Mode";
  

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.93,
      minChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xffFBF5EC),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              children: [

                /// Drag Handle
                Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xffD4DCEB),
                  child: Icon(
                    Icons.currency_rupee,
                    color: const Color(0xff23406B),
                    size: 34,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Edit Transaction Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1F3966),
                  ),
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [

                      buildLabel("Amount"),

                      buildField(
                        controller: amountController,
                      ),

                      const SizedBox(height: 15),

                      buildLabel("Date"),

                      buildField(
                        controller: dateController,
                        suffix: const Icon(Icons.calendar_today_outlined),
                      ),

                      const SizedBox(height: 15),

                      buildLabel("Interest Rate (%)"),

                      buildField(
                        controller: interestController,
                      ),

                      const SizedBox(height: 15),

                      buildLabel("Interest Type"),

                      buildDropdown(
                        value: interestType,
                        items: const [
                          "Simple Interest",
                          "Compound Interest"
                        ],
                        onChanged: (v) {
                          setState(() {
                            interestType = v!;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      buildLabel("Interest Frequency"),

                      buildDropdown(
                        value: frequency,
                        items: const [
                          "Monthly",
                          "Quarterly",
                          "Yearly",
                        ],
                        onChanged: (v) {
                          setState(() {
                            frequency = v!;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      buildLabel("Payment Mode (Optional)"),

                      buildDropdown(
                        value: paymentMode,
                        items: const [
                          "Select Payment Mode",
                          "Cash",
                          "UPI",
                          "Bank Transfer"
                        ],
                        onChanged: (v) {
                          setState(() {
                            paymentMode = v!;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      buildLabel("Description"),

                      Stack(
                        children: [
                          TextField(
                            controller: descriptionController,
                            maxLength: 100,
                            maxLines: 3,
                            decoration: inputDecoration(
                              hint: "Description",
                            ),
                          ),

                          Positioned(
                            right: 14,
                            bottom: 12,
                            child: Text(
                              "${descriptionController.text.length}/100",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                Row(
                  children: [

                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          side: const BorderSide(
                            color: Color(0xffBFC7D8),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xff1F3966),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: const Color(0xff223D69),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff6F7A8F),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildField({
    required TextEditingController controller,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      decoration: inputDecoration(
        suffix: suffix,
      ),
    );
  }

  Widget buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: inputDecoration(),
      icon: const Icon(Icons.keyboard_arrow_down),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration inputDecoration({
    Widget? suffix,
    String? hint,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xffC7D0DF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xff23406B),
          width: 1.4,
        ),
      ),
    );
  }
}