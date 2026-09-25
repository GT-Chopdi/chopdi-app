import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/data/repository/repositories.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

import 'customer_details_screen.dart';

class AddNewCustomerScreen extends StatefulWidget {
  final int chopdiId;
  final String? initialName;
  final String? initialPhone;

  const AddNewCustomerScreen({
    super.key,
    required this.chopdiId,
    this.initialName,
    this.initialPhone,

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
  void initState() {
    super.initState();

    nameController.text = widget.initialName ?? '';
    phoneController.text = widget.initialPhone ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAVE CUSTOMER
  // ============================================================

  Future<void> saveCustomer() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    setState(() {
      _isSaving = true;
    });

    try {
      // ==========================================================
      // CHECK DUPLICATE CUSTOMER
      // ==========================================================

      Customer? existingCustomer;

      // ==========================================================
      // PHONE IS OPTIONAL
      // ==========================================================

      if (phone.isEmpty) {
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
        // ========================================================
        // PHONE EXISTS
        // ========================================================

        existingCustomer = await IsarService.isar.customers
            .filter()
            .deletedAtIsNull()
            .chopdiIdEqualTo(widget.chopdiId)
            .nameEqualTo(name)
            .phoneEqualTo(phone)
            .findFirst();
      }

      // ==========================================================
      // CUSTOMER ALREADY EXISTS
      // ==========================================================

      if (existingCustomer != null) {
        if (!mounted) return;

        final l10n = AppLocalizations.of(context);

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
                      l10n.customerAlreadyExists,
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
                l10n.duplicateCustomerMessage,
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
                      l10n.ok,
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

      // ==========================================================
      // CREATE CUSTOMER
      // ==========================================================

      final customer = await Repositories.customers.create(
        name: name,
        phone: phone,
        chopdiId: widget.chopdiId,
        loanType: "gave",
        status: "Pending",
      );

      if (!mounted) return;

      // Navigate to CustomerDetailsScreen and replace the current screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerDetailsScreen(
            customer: customer,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.failedToAddCustomer,
            style: GoogleFonts.manrope(),
          ),
        ),
      );

      setState(() {
        _isSaving = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ChopdiColors.cream,

      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================

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

                        Expanded(
                          child: Text(
                            l10n.addNewCustomer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ChopdiColors.navy,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // CUSTOMER DETAILS
                    // ==================================================

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
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
                          // --------------------------------------------
                          // SECTION TITLE
                          // --------------------------------------------

                          Text(
                            l10n.customerDetails,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff4F5F78),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // --------------------------------------------
                          // NAME
                          // --------------------------------------------

                          _label(l10n.nameRequired),

                          const SizedBox(height: 6),

                          _textField(
                            controller: nameController,
                            hint: l10n.customerName,
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return l10n.enterCustomerName;
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // --------------------------------------------
                          // PHONE
                          // --------------------------------------------

                          _label(l10n.phoneNumberOptional),

                          const SizedBox(height: 6),

                          _textField(
                            controller: phoneController,
                            hint: l10n.mobileNumber,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            validator: (value) {
                              final phone =
                                  value?.trim() ?? '';

                              // Phone is optional.
                              if (phone.isEmpty) {
                                return null;
                              }

                              // If entered, it must contain
                              // exactly 10 digits.
                              if (!RegExp(r'^[0-9]{10}$')
                                  .hasMatch(phone)) {
                                return l10n.enterValid10DigitPhone;
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ==================================================
                    // ADD CUSTOMER BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                        _isSaving ? null : saveCustomer,

                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                          ChopdiColors.navy,

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
                          l10n.addCustomer,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // CANCEL BUTTON
                    // ==================================================

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
                          l10n.cancel,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ChopdiColors.navy,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

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

  // ============================================================
  // TEXT FIELD
  // ============================================================

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

        // Hide character counter for phone field.
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