import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_colors.dart';

class AddNewCustomerScreen extends StatefulWidget {
  const AddNewCustomerScreen({super.key});

  @override
  State<AddNewCustomerScreen> createState() =>
      _AddNewCustomerScreenState();
}

class _AddNewCustomerScreenState
    extends State<AddNewCustomerScreen> {
  final customerNameController = TextEditingController();
  final mobileController = TextEditingController();
  final amountController = TextEditingController();
  final interestController = TextEditingController();
  final noteController = TextEditingController();

  DateTime? selectedDate;

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChopdiColors.cream,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: ChopdiColors.navy,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "Add New Customer",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ChopdiColors.navy,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(0xFFAAB9CF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Customer Details",
                      style: TextStyle(
                        color: ChopdiColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    buildLabel("Name*"),

                    buildField(
                      controller: customerNameController,
                      hint: "Customer Name",
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 12),

                    buildLabel("Phone Number*"),

                    buildField(
                      controller: mobileController,
                      hint: "Mobile Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Loan Details",
                      style: TextStyle(
                        color: ChopdiColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    buildLabel("Loan Amount (*)"),

                    buildField(
                      controller: amountController,
                      hint: "Enter Amount",
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 12),

                    buildLabel("Interest Rate (%)"),

                    buildField(
                      controller: interestController,
                      hint: "Enter Interest rate",
                      icon: Icons.percent,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 12),

                    buildLabel("Date*"),

                    InkWell(
                      onTap: pickDate,
                      child: IgnorePointer(
                        child: buildField(
                          hint: selectedDate == null
                              ? "Select Date"
                              : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          suffixIcon:
                              Icons.calendar_today_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    buildLabel("Note (Optional)"),

                    TextField(
                      controller: noteController,
                      maxLines: 4,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: "Add a note",
                        counterText:
                            "${noteController.text.length}/100",
                        filled: true,
                        fillColor: Color(0xFFFFF8F0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFAAB9CF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: ChopdiColors.navy),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChopdiColors.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Add Customer",
                    style: GoogleFonts.manrope(
                      color: ChopdiColors.cream,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: ChopdiColors.navy),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.manrope(
                      color: ChopdiColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff6D7C93),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget buildField({
    TextEditingController? controller,
    String? hint,
    IconData? icon,
    IconData? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            icon != null ? Icon(icon, size: 18) : null,
        suffixIcon:
            suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
        filled: true,
        fillColor: Color(0xFFFFF8F0),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xffCDD5E2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xff223A5E)),
        ),
      ),
    );
  }
}