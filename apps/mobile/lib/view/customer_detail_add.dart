import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/view/customer_details_screen.dart';
import 'package:mychopdi/data/repository/repositories.dart';

class CustomerDetailsAdd extends StatefulWidget {
  final String contactName;
  final String contactPhone;
  final int chopdiId;

  const CustomerDetailsAdd({
    super.key,
    required this.contactName,
    required this.contactPhone,
    required this.chopdiId,
  });

  @override
  State<CustomerDetailsAdd> createState() =>
      _CustomerDetailsAddState();
}

class _CustomerDetailsAddState extends State<CustomerDetailsAdd> {
  static const Color primaryColor = Color(0xFF233B63);
  static const Color backgroundColor = Color(0xFFFDF0DE);

  bool isSaving = false;

  // -------------------------------------------------------------------
  // ADD CUSTOMER
  // -------------------------------------------------------------------

  Future<void> addCustomer() async {
    final phone = widget.contactPhone.trim();

    // ---------------------------------------------------------------
    // NORMALIZE PHONE
    // ---------------------------------------------------------------

    String finalPhone = '';

    if (phone.isNotEmpty) {
      // Remove spaces, +, -, brackets, etc.
      finalPhone = phone.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      // Remove Indian country code when present.
      if (finalPhone.startsWith('91') &&
          finalPhone.length == 12) {
        finalPhone = finalPhone.substring(2);
      }
    }

    // ---------------------------------------------------------------
    // NORMALIZE NAME
    // ---------------------------------------------------------------

    final customerName = widget.contactName.trim();

    // Name is required.
    if (customerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Customer name is required"),
        ),
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      isSaving = true;
    });

    try {
      // -------------------------------------------------------------
      // CHECK DUPLICATE
      // -------------------------------------------------------------
      //
      // Match:
      //
      //     name + phone + chopdiId
      //
      // Examples:
      //
      // john + empty       => john + empty
      // DUPLICATE
      //
      // john + empty       => john + 98765
      // NEW
      //
      // john + 98765       => john + 98765
      // DUPLICATE
      //
      // john + 98765       => john + 12345
      // NEW
      //
      // JOHN + 98765       => john + 98765
      // DUPLICATE
      //
      // -------------------------------------------------------------

      final existingCustomer =
      await IsarService.getCustomerByNameAndPhone(
        customerName,
        finalPhone,
        widget.chopdiId,
      );

      if (existingCustomer != null) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Customer already exists"),
          ),
        );

        return;
      }

      // -------------------------------------------------------------
      // CREATE CUSTOMER
      // -------------------------------------------------------------

      final customer = await Repositories.customers.create(
        name: customerName,
        phone: finalPhone,
        chopdiId: widget.chopdiId,
        loanType: "gave",
        status: "Pending",
      );

      // -------------------------------------------------------------
      // OPEN CUSTOMER DETAILS
      // -------------------------------------------------------------

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerDetailsScreen(
            customer: customer,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to add customer: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneDisplay = widget.contactPhone.trim();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------------------------------------
              // BACK BUTTON
              // -----------------------------------------------------

              IconButton(
                onPressed: isSaving
                    ? null
                    : () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: primaryColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(height: 18),

              // -----------------------------------------------------
              // PROFILE
              // -----------------------------------------------------

              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      widget.contactName.isNotEmpty
                          ? widget.contactName[0].toUpperCase()
                          : "?",
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.contactName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          phoneDisplay.isEmpty
                              ? "No phone number"
                              : phoneDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            color: phoneDisplay.isEmpty
                                ? Colors.black45
                                : Colors.black54,
                            fontStyle: phoneDisplay.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // -----------------------------------------------------
              // ADD CUSTOMER BUTTON
              // -----------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSaving ? null : addCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor:
                    primaryColor.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Add Customer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // -----------------------------------------------------
              // CANCEL
              // -----------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: primaryColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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
}