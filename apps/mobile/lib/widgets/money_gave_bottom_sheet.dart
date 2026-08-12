import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/transaction_service.dart';
import 'package:mychopdi/utils/interest_calculator.dart';

class MoneyGaveBottomSheet extends StatefulWidget {

  final Customer customer;
  final VoidCallback onSaved;
  final bool isEdit;
  final Transaction? transaction;
  
  const MoneyGaveBottomSheet({super.key, required this.customer, required this.onSaved, required this.isEdit, this.transaction});

  @override
  State<MoneyGaveBottomSheet> createState() => _MoneyGaveBottomSheetState();
}

class _MoneyGaveBottomSheetState extends State<MoneyGaveBottomSheet> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  String interestType = "Simple Interest";
  String interestFrequency = "Monthly";
  String paymentMode = "";

  double get interestAmount {
    final amount =
        double.tryParse(amountController.text) ?? 0;

    final percent =
        double.tryParse(interestController.text) ?? 0;

    return amount * percent / 100;
  }

  Future<void> _pickDate() async {
    final DateTime today = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isAfter(today) ? today : selectedDate,
      firstDate: DateTime(2000),
      lastDate: today, // Future dates disabled
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

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

  @override
  void initState() {
    super.initState();
 
    if(widget.transaction!=null){

      amountController.text =
          widget.transaction!.amount.toString();

      interestController.text =
          widget.transaction!.interestRate.toString();

      descriptionController.text =
          widget.transaction!.description;

      paymentMode =
          widget.transaction!.paymentMode;

      selectedDate =
          widget.transaction!.date;

      interestType =
          widget.transaction!.interestType;

      interestFrequency =
          widget.transaction!.interestFrequency;

      }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xffFFF8F0),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(34),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 55,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),

              const SizedBox(height: 22),

              Container(
                height: 72,
                width: 72,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(199, 76, 76, 0.19),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.transparent,
                    child: Image.asset('assets/you_gave.png'),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "You Gave",
                style: GoogleFonts.manrope(
                  color: Color.fromRGBO(199, 76, 76, 1),
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 28),

              Align(
                  alignment: Alignment.centerLeft,
                  child: title("Amount")),

              TextField(
                controller: amountController,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.number,
                decoration: decoration(
                  hint: "Enter Amount",
                  prefix: const Icon(Icons.currency_rupee,
                      size: 20, color: Color(0xff6D7B94)),
                ),
              ),

              const SizedBox(height: 18),

              Align(
                  alignment: Alignment.centerLeft,
                  child: title("Date")),

              TextField(
                readOnly: true,
                onTap: _pickDate,
                decoration: decoration(
                  hint: DateFormat("dd MMM yyyy").format(selectedDate),
                  suffix: const Icon(Icons.calendar_today_outlined),
                ),
              ),

              const SizedBox(height: 18),

              Align(
                  alignment: Alignment.centerLeft,
                  child: title("Interest Rate (%)")),

              TextField(
                controller: interestController,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.number,
                decoration: decoration(
                  hint: "Enter Interest rate",
                ),
              ),

              const SizedBox(height: 18),

              Align(
                  alignment: Alignment.centerLeft,
                  child: title("Interest Type")),

              DropdownButtonFormField<String>(
                initialValue: interestType,
                decoration: decoration(),
                icon: const Icon(Icons.keyboard_arrow_down),
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
                onChanged: (v) {
                  setState(() {
                    interestType = v!;
                  });
                },
              ),

              const SizedBox(height: 18),

              Align(
                  alignment: Alignment.centerLeft,
                  child: title("Interest Frequency")),

              DropdownButtonFormField<String>(
                initialValue: interestFrequency,
                decoration: decoration(),
                icon: const Icon(Icons.keyboard_arrow_down),
                items: const [
                  DropdownMenuItem(
                    value: "Monthly",
                    child: Text("Monthly"),
                  ),
                  DropdownMenuItem(
                    value: "Yearly",
                    child: Text("Yearly"),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    interestFrequency = v!;
                  });
                },
              ),

              const SizedBox(height: 18),

              Align(
                  alignment: Alignment.centerLeft,
                  child: title("Payment Mode (Optional)")),

              DropdownButtonFormField<String>(
                initialValue: paymentMode.isEmpty ? null : paymentMode,
                decoration: decoration(
                  hint: "Select Payment Mode",
                ),
                icon: const Icon(Icons.keyboard_arrow_down),
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
                    child: Text("Bank Transfer"),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    paymentMode = v!;
                  });
                },
              ),

              const SizedBox(height: 18),

              Align(
                  alignment: Alignment.centerLeft,
                  child: title("Description")),

              TextField(
                controller: descriptionController,
                maxLength: 100,
                maxLines: 4,
                decoration: decoration(
                  hint: "Enter Description here...",
                ).copyWith(counterText: ""),
                onChanged: (_) => setState(() {}),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${descriptionController.text.length}/100",
                  style: const TextStyle(
                    color: Color(0xff6F7A8C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xffC7D0DF),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xff29406B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async{
                          if(amountController.text.isEmpty){
                            return;
                          }

                          final amount = double.parse(amountController.text);
                          final rate = double.parse(interestController.text);
                          // final interestAmount = amount * rate / 100;
                          final interestAmount = InterestCalculator.calculate(
                            principal: amount,
                            rate: rate,
                            startDate: selectedDate,
                            interestType: interestType,
                            frequency: interestFrequency,
                          );

                          final tx = Transaction()
                            ..customerId = widget.customer.id
                            ..amount = amount
                            ..interest = interestAmount
                            ..interestRate = rate
                            ..date = selectedDate
                            ..type = TransactionType.gave
                            ..description = descriptionController.text
                            ..paymentMode = paymentMode
                            ..interestType = interestType
                            ..interestFrequency = interestFrequency;

                          await TransactionService.addTransaction(tx);

                          widget.onSaved();

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff29406B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save Entry",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}