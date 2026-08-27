import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/data/repository/repositories.dart';
import 'package:mychopdi/service/chopdi_service.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/took_loan_customer_details_screen.dart';

class AddNewLenderScreen extends StatefulWidget {
  const AddNewLenderScreen({super.key, required int chopdiId});

  @override
  State<AddNewLenderScreen> createState() =>
      _AddNewCustomerScreenState();
}

class _AddNewCustomerScreenState
    extends State<AddNewLenderScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }


  Future<void> saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    Customer? existingCustomer;

    if (phone.isNotEmpty) {
      existingCustomer = await IsarService.isar.customers
          .filter()
          .nameEqualTo(name)
          .phoneEqualTo(phone)
          .findFirst();
    }

    if (existingCustomer != null) {
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFFF8F0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_off_outlined,
                    color: Colors.orange,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "Lender Already Exists",
                    style: GoogleFonts.manrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: ChopdiColors.navy,
                    ),
                  ),
                ),
              ],
            ),

            content: Text(
              "A lender with the same name and phone number is already added.",
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: const Color(0xff6E7D93),
                height: 1.4,
              ),
            ),

            actionsPadding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              14,
            ),

            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChopdiColors.navy,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );

      return;
    }

    final currentChopdi =
            await ChopdiService.getCurrentChopdi();

    // Created through the repository, not a direct `customers.put`. The
    // repository is what mints the uuid, and a customer without one is refused
    // by LedgerRepository._validateCustomer — so a lender written directly here
    // saves fine and then silently rejects every entry added to it. It is also
    // what enqueues the sync operation.
    final customer = await Repositories.customers.create(
      name: name,
      phone: phone,
      chopdiId: currentChopdi.id,
      loanType: "took",
      status: "Pending",
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return TookLoanCustomerDetailsScreen(
            customer: customer,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;
    return Scaffold(
      backgroundColor: ChopdiColors.cream,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.02),
                Row(
                  children: [

                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: ChopdiColors.navy,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      "Add New Lender",
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ChopdiColors.navy,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                      vertical: height * 0.02,
                  ),                  
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFAAB9CF),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Lender Details",
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff4F5F78),
                        ),
                      ),

                      const SizedBox(height: 14),

                      _label("Name*"),

                      const SizedBox(height: 6),

                      _textField(
                        controller: nameController,
                        hint: "Lender Name",
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return "Enter lender name";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      _label("Phone Number (Optional)"),

                      const SizedBox(height: 6),

                      _textField(
                        controller: phoneController,
                        hint: "Mobile Number",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,

                        validator: (value) {
                          final phone = value?.trim() ?? '';

                          // Phone number is optional
                          if (phone.isEmpty) {
                            return null;
                          }

                          // If user enters something, it must be exactly 10 digits
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                            return "Enter a valid 10-digit phone number";
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                // const Spacer(),

                const SizedBox(height: 60),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: saveCustomer,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: ChopdiColors.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      "Add Lender",
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: ChopdiColors.navy,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ChopdiColors.navy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: const Color(0xff6E7D93),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFFAAB9CF),
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: ChopdiColors.navy,
        width: 1.2,
      ),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,

      style: GoogleFonts.manrope(
        fontSize: 13,
      ),

      decoration: InputDecoration(
        isDense: true,

        hintText: hint,

        hintStyle: GoogleFonts.manrope(
          fontSize: 12,
          color: ChopdiColors.navy,
        ),

        prefixIcon: Icon(
          icon,
          size: 18,
          color: ChopdiColors.navy,
        ),

        filled: true,
        fillColor: const Color(0xFFFFF8F0),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),

        // NORMAL BORDER
        enabledBorder: normalBorder,

        // FOCUSED BORDER
        focusedBorder: focusedBorder,

        // IMPORTANT:
        // Keep the same border even when validation fails.
        errorBorder: normalBorder,

        // IMPORTANT:
        // Keep the same border when field is focused + has error.
        focusedErrorBorder: focusedBorder,

        // Error text only
        errorStyle: GoogleFonts.manrope(
          fontSize: 11,
          color: Colors.red,
          height: 1.2,
        ),
      ),
    );
  }
}