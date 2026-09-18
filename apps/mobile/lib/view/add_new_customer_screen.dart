import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/data/repository/repositories.dart';

class AddNewCustomerScreen extends StatefulWidget {
  final int chopdiId;

  const AddNewCustomerScreen({
    super.key,
    required this.chopdiId,
  });

  @override
  State<AddNewCustomerScreen> createState() =>
      _AddNewCustomerScreenState();
}

class _AddNewCustomerScreenState
    extends State<AddNewCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> saveCustomer() async {
    // Prevent multiple taps while saving.
    if (_isSaving) return;

    // Validate name and phone.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    setState(() {
      _isSaving = true;
    });

    try {
      // ------------------------------------------------------------
      // CHECK DUPLICATE CUSTOMER
      // ------------------------------------------------------------
      //
      // Customer uniqueness is based on:
      //
      //     name + phone + chopdiId
      //
      // Phone is optional.
      //
      // Examples:
      //
      // Existing: john + ""
      // New:      john + ""
      // RESULT:   DUPLICATE
      //
      // Existing: john + ""
      // New:      john + "98765"
      // RESULT:   CREATE NEW
      //
      // Existing: john + "98765"
      // New:      john + "98765"
      // RESULT:   DUPLICATE
      //
      // Existing: john + "98765"
      // New:      john + "12345"
      // RESULT:   CREATE NEW
      //
      // Existing: john + "98765"
      // New:      alex + "98765"
      // RESULT:   CREATE NEW
      //
      // Deleted customers are ignored.
      // ------------------------------------------------------------

      Customer? existingCustomer;

      // ------------------------------------------------------------
      // PHONE IS OPTIONAL
      // ------------------------------------------------------------
      //
      // We MUST perform the duplicate check even when the phone
      // number is empty.
      //
      // This fixes:
      //
      // john + no phone
      // john + no phone
      //
      // previously creating duplicate customers.
      // ------------------------------------------------------------

      if (phone.isEmpty) {
        // Isar does not need phoneEqualTo() here because we are
        // specifically checking customers whose phone is empty.
        //
        // First get active customers in this Chopdi with the same
        // name, then verify that their phone is also empty.

        final customers = await IsarService.isar.customers
            .filter()
            .deletedAtIsNull()
            .chopdiIdEqualTo(widget.chopdiId)
            .nameEqualTo(name)
            .findAll();

        for (final customer in customers) {
          if (customer.phone.trim().isEmpty) {
            existingCustomer = customer;
            break;
          }
        }
      } else {
        // ----------------------------------------------------------
        // PHONE EXISTS
        // ----------------------------------------------------------
        //
        // Match name + phone + chopdiId.
        // ----------------------------------------------------------

        existingCustomer = await IsarService.isar.customers
            .filter()
            .deletedAtIsNull()
            .chopdiIdEqualTo(widget.chopdiId)
            .nameEqualTo(name)
            .phoneEqualTo(phone)
            .findFirst();
      }

      // ------------------------------------------------------------
      // CUSTOMER ALREADY EXISTS
      // ------------------------------------------------------------

      if (existingCustomer != null) {
        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (dialogContext) {
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
                      "Customer Already Exists",
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
                "A customer with the same name and phone number is already added.",
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: const Color(0xff6E7D93),
                  height: 1.4,
                ),
              ),
              actionsPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 14),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
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

        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }

        return;
      }

      // ------------------------------------------------------------
      // CREATE CUSTOMER
      // ------------------------------------------------------------

      final customer = await Repositories.customers.create(
        name: name,
        phone: phone,
        chopdiId: widget.chopdiId,
        loanType: "gave",
        status: "Pending",
      );

      if (!mounted) return;

      // IMPORTANT:
      // Do NOT push CustomerDetailsScreen here.
      //
      // Remove Add Customer from the navigation stack and return
      // directly to the screen that opened it (Home).
      Navigator.pop(context, customer);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to add customer. Please try again.",
            style: GoogleFonts.manrope(),
          ),
        ),
      );

      setState(() {
        _isSaving = false;
      });
    }
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

                // --------------------------------------------------
                // HEADER
                // --------------------------------------------------

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
                      "Add New Customer",
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ChopdiColors.navy,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // --------------------------------------------------
                // CUSTOMER DETAILS
                // --------------------------------------------------

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
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customer Details",
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
                        hint: "Customer Name",
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return "Enter customer name";
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
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        validator: (value) {
                          final phone =
                              value?.trim() ?? '';

                          // Phone is optional.
                          if (phone.isEmpty) {
                            return null;
                          }

                          // If entered, it MUST contain exactly
                          // 10 digits.
                          if (!RegExp(r'^[0-9]{10}$')
                              .hasMatch(phone)) {
                            return "Enter a valid 10-digit phone number";
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // --------------------------------------------------
                // ADD CUSTOMER
                // --------------------------------------------------

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                    _isSaving ? null : saveCustomer,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: ChopdiColors.navy,
                      disabledBackgroundColor:
                      ChopdiColors.navy.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(6),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      "Add Customer",
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // --------------------------------------------------
                // CANCEL
                // --------------------------------------------------

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.pop(context),
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

  // ------------------------------------------------------------------
  // LABEL
  // ------------------------------------------------------------------

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

  // ------------------------------------------------------------------
  // TEXT FIELD
  // ------------------------------------------------------------------

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
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
      maxLength: maxLength,
      style: GoogleFonts.manrope(
        fontSize: 13,
      ),
      decoration: InputDecoration(
        isDense: true,
        counterText: "",
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
        enabledBorder: normalBorder,
        focusedBorder: focusedBorder,
        errorBorder: normalBorder,
        focusedErrorBorder: focusedBorder,
        errorStyle: GoogleFonts.manrope(
          fontSize: 11,
          color: Colors.red,
          height: 1.2,
        ),
      ),
    );
  }
}