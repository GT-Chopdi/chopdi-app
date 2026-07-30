import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final dateController =
      TextEditingController(text: "24 July 2026");

  String? paymentMode;

  final List<String> paymentModes = [
    "Cash",
    "UPI",
    "Bank Transfer",
    "Cheque",
  ];

  @override
  Widget build(BuildContext context) {
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
              "Record Payment",
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ChopdiColors.navy,
              ),
            ),

            Text(
              "Add money given or received",
              style: GoogleFonts.roboto(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Type",
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
                border: Border.all(color: Colors.grey.shade300),
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Money Received",
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
                        alignment: Alignment.center,
                        child: Text(
                          "Money Given",
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
              child: Text("Amount"),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Amount",
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Date"),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Payment Mode (Optional)"),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: paymentMode,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              hint: const Text("Select Payment Mode"),
              items: paymentModes
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
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
                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChopdiColors.navy,
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Save Entry",
                      style: TextStyle(color: Colors.white),
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