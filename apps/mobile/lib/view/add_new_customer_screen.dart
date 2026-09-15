import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/customer_details_screen.dart';
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
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    // Check for duplicate customer only
    // when phone number is provided.
    Customer? existingCustomer;

    if (phone.isNotEmpty) {
      existingCustomer = await IsarService.isar.customers
          .filter()
          .deletedAtIsNull()
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

    // Created through the repository so the row and its sync operation are
    // written in one transaction.
    //
    // Keep the existing repository create flow, but pass the current
    // Chopdi ID and loan type so HomeScreen can find this customer.
    final customer = await Repositories.customers.create(
      name: name,
      phone: phone,
      chopdiId: widget.chopdiId,
      loanType: "gave",
      status: "Pending",
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CustomerDetailsScreen(
            customer: customer,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChopdiColors.cream,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = width < 360
                ? 14.0
                : width < 600
                    ? 18.0
                    : 24.0;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ============================================
                        // HEADER
                        // ============================================

                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Navigator.pop(context);
                              },
                              borderRadius:
                                  BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
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
                                "Add New Customer",
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize:
                                      width < 360 ? 17 : 18,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      ChopdiColors.navy,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ============================================
                        // CUSTOMER DETAILS CARD
                        // ============================================

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                width < 360 ? 14 : 18,
                            vertical:
                                width < 360 ? 14 : 18,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFFF8F0),
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  const Color(0xFFAAB9CF),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Customer Details",
                                style:
                                    GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      const Color(
                                    0xff4F5F78,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // NAME
                              _label("Name*"),

                              const SizedBox(height: 6),

                              _textField(
                                controller:
                                    nameController,
                                hint: "Customer Name",
                                icon:
                                    Icons.person_outline,
                                textInputAction:
                                    TextInputAction.next,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return "Enter customer name";
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // PHONE
                              _label(
                                "Phone Number (Optional)",
                              ),

                              const SizedBox(height: 6),

                              _textField(
                                controller:
                                    phoneController,
                                hint: "Mobile Number",
                                icon:
                                    Icons.phone_outlined,
                                keyboardType:
                                    TextInputType.phone,
                                textInputAction:
                                    TextInputAction.done,
                                validator: (value) {
                                  final phone =
                                      value?.trim() ?? '';

                                  if (phone.isEmpty) {
                                    return null;
                                  }

                                  if (!RegExp(
                                    r'^[0-9]{10}$',
                                  ).hasMatch(phone)) {
                                    return "Enter a valid 10-digit phone number";
                                  }

                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        // ============================================
                        // BUTTONS
                        // ============================================

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed:
                                _isSaving ? null : saveCustomer,
                            style:
                                ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  ChopdiColors.navy,
                              disabledBackgroundColor:
                                  ChopdiColors.navy
                                      .withValues(alpha: 0.6),
                              shape:
                                  RoundedRectangleBorder(
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
                                    style:
                                        GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w700,
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
                            onPressed: _isSaving
                                ? null
                                : () {
                                    FocusScope.of(context)
                                        .unfocus();

                                    Navigator.pop(context);
                                  },
                            style:
                                OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color:
                                    ChopdiColors.navy,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style:
                                  GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    ChopdiColors.navy,
                              ),
                            ),
                          ),
                        ),

                        // Safe bottom spacing.
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
  TextInputAction? textInputAction,
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
    textInputAction: textInputAction,
    validator: validator,

    // Important when keyboard is visible.
    scrollPadding: const EdgeInsets.only(
      bottom: 120,
      top: 80,
    ),

    style: GoogleFonts.manrope(
      fontSize: 13,
      color: Colors.black87,
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

      prefixIconConstraints:
          const BoxConstraints(
        minWidth: 44,
        minHeight: 44,
      ),

      filled: true,
      fillColor:
          const Color(0xFFFFF8F0),

      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 13,
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