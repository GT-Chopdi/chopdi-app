// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mychopdi/service/isar_service.dart';
// import 'package:mychopdi/view/customer_details_screen.dart';
// import 'package:mychopdi/data/repository/repositories.dart';

// class CustomerDetailsAdd extends StatefulWidget {
//   final String contactName;
//   final String contactPhone;
//   final int chopdiId;

//   const CustomerDetailsAdd({
//     super.key,
//     required this.contactName,
//     required this.contactPhone,
//     required this.chopdiId,
//   });

//   @override
//   State<CustomerDetailsAdd> createState() => _CustomerDetailsAddState();
// }

// class _CustomerDetailsAddState extends State<CustomerDetailsAdd> {
//   static const Color primaryColor = Color(0xFF233B63);
//   static const Color backgroundColor = Color(0xFFFDF0DE);

//   bool isSaving = false;

//   Future<void> addCustomer() async {
//     final phone = widget.contactPhone.trim();

//     if (phone.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please enter phone number"),
//         ),
//       );
//       return;
//     }

//     // Remove +91, spaces, -, etc.
//     final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

//     String finalPhone = cleanedPhone;

//     // Remove Indian country code
//     if (finalPhone.startsWith('91') && finalPhone.length == 12) {
//       finalPhone = finalPhone.substring(2);
//     }

//     // Validate 10 digit number
//     if (!RegExp(r'^[0-9]{10}$').hasMatch(finalPhone)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             "Please enter a valid 10-digit phone number",
//           ),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       isSaving = true;
//     });

//     try {
//       // Check duplicate again
//       final existingCustomer =
//           await IsarService.getCustomerByPhone(finalPhone);

//       if (existingCustomer != null) {
//         if (!mounted) return;

//         setState(() {
//           isSaving = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("This customer already exists"),
//           ),
//         );

//         return;
//       }

//       // See add_new_customer_screen.dart: the repository is the only write
//       // path, so the create is queued for sync in the same transaction.
//       final customer = await Repositories.customers.create(
//         name: widget.contactName.trim(),
//         phone: finalPhone,
//         chopdiId: widget.chopdiId,
//         loanType: "gave",
//         status: "Pending",
//       );

//       if (!mounted) return;

//       // Go directly to CustomerDetailsScreen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => CustomerDetailsScreen(
//             customer: customer,
//           ),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         isSaving = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to add customer: $e"),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 14,
//             vertical: 12,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               // Back button
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(
//                   Icons.arrow_back,
//                   color: primaryColor,
//                 ),
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),

//               const SizedBox(height: 18),

//               // Profile
//               Row(
//                 children: [

//                   CircleAvatar(
//                     radius: 24,
//                     backgroundColor: Colors.grey.shade300,
//                     child: Text(
//                       widget.contactName.isNotEmpty
//                           ? widget.contactName[0].toUpperCase()
//                           : "?",
//                       style: GoogleFonts.manrope(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: primaryColor,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [

//                         Text(
//                           widget.contactName,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: primaryColor,
//                           ),
//                         ),

//                         const SizedBox(height: 3),

//                         Text(
//                           widget.contactPhone,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.black54,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   IconButton(
//                     onPressed: () {},
//                     icon: const Icon(
//                       Icons.edit_outlined,
//                       color: primaryColor,
//                       size: 20,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 28),

//               // Add Customer
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed:  isSaving ? null : addCustomer,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                   child: isSaving
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text(
//                           "Add Customer",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Cancel
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: OutlinedButton(
//                   onPressed: isSaving
//                       ? null
//                       : () => Navigator.pop(context),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(
//                       color: primaryColor,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                   child: const Text(
//                     "Cancel",
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
  State<CustomerDetailsAdd> createState() => _CustomerDetailsAddState();
}

class _CustomerDetailsAddState extends State<CustomerDetailsAdd> {
  static const Color primaryColor = Color(0xFF233B63);
  static const Color backgroundColor = Color(0xFFFDF0DE);

  bool isSaving = false;

  Future<void> addCustomer() async {
    final phone = widget.contactPhone.trim();

    // Phone number is optional.
    // Do not validate length for contacts coming from the device.
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

    if (!mounted) return;

    setState(() {
      isSaving = true;
    });

    try {
      // ----------------------------------------------------------
      // CHECK DUPLICATE ONLY WHEN PHONE EXISTS
      // ----------------------------------------------------------
      if (finalPhone.isNotEmpty) {
        final existingCustomer =
            await IsarService.getCustomerByPhone(finalPhone);

        if (existingCustomer != null) {
          if (!mounted) return;

          setState(() {
            isSaving = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "This customer already exists",
              ),
            ),
          );

          return;
        }
      }

      // ----------------------------------------------------------
      // CREATE CUSTOMER
      // Phone can be empty and does not have to be 10 digits.
      // ----------------------------------------------------------
      final customer = await Repositories.customers.create(
        name: widget.contactName.trim(),
        phone: finalPhone,
        chopdiId: widget.chopdiId,
        loanType: "gave",
        status: "Pending",
      );

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
              // --------------------------------------------------
              // BACK BUTTON
              // --------------------------------------------------
              IconButton(
                onPressed: isSaving
                    ? null
                    : () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: primaryColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(height: 18),

              // --------------------------------------------------
              // PROFILE
              // --------------------------------------------------
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

              // --------------------------------------------------
              // ADD CUSTOMER
              // --------------------------------------------------
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

              // --------------------------------------------------
              // CANCEL
              // --------------------------------------------------
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