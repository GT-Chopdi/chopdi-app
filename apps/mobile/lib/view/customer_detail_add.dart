// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:mychopdi/utils/app_colors.dart';

// // class CustomerDetailsScreen extends StatelessWidget {
// //   final String name;
// //   final String phone;

// //   const CustomerDetailsScreen({
// //     super.key,
// //     required this.name,
// //     required this.phone,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: ChopdiColors.cream,
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(18),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               InkWell(
// //                 onTap: () => Navigator.pop(context),
// //                 child: const Icon(
// //                   Icons.arrow_back_ios_new,
// //                   color: Color(0xff223A5E),
// //                 ),
// //               ),

// //               const SizedBox(height: 20),

// //               Row(
// //                 children: [
// //                   CircleAvatar(
// //                     radius: 28,
// //                     backgroundColor: const Color(0xffC6CEDC),
// //                     child: Text(
// //                       name[0],
// //                       style: const TextStyle(
// //                         fontSize: 28,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xff223A5E),
// //                       ),
// //                     ),
// //                   ),

// //                   const SizedBox(width: 16),

// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         name,
// //                         style: const TextStyle(
// //                           fontSize: 22,
// //                           fontWeight: FontWeight.bold,
// //                           color: Color(0xff223A5E),
// //                         ),
// //                       ),
// //                       Text(
// //                         phone,
// //                         style: const TextStyle(
// //                           color: Color(0xff58677D),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),

// //               const SizedBox(height: 24),

// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: Color(0xFFFFF8F0),
// //                   borderRadius: BorderRadius.circular(14),
// //                   border: Border.all(
// //                     color: const Color(0xffC7CFDD),
// //                   ),
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [

// //                     const Text(
// //                       "Loan Details",
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xff223A5E),
// //                       ),
// //                     ),

// //                     const SizedBox(height: 16),

// //                     const Text("Loan Amount (*)"),
// //                     const SizedBox(height: 6),

// //                     TextField(
// //                       decoration: InputDecoration(
// //                         hintText: "Enter Amount",
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         prefixIcon: const Icon(Icons.currency_rupee),
// //                       ),
// //                     ),

// //                     const SizedBox(height: 16),

// //                     const Text("Interest Rate (%)"),
// //                     const SizedBox(height: 6),

// //                     TextField(
// //                       decoration: InputDecoration(
// //                         hintText: "Enter Interest rate",
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         prefixIcon: const Icon(Icons.percent),
// //                       ),
// //                     ),

// //                     const SizedBox(height: 16),

// //                     const Text("Date"),
// //                     const SizedBox(height: 6),

// //                     TextField(
// //                       readOnly: true,
// //                       decoration: InputDecoration(
// //                         hintText: "Select Date",
// //                         suffixIcon: const Icon(Icons.calendar_today_outlined),
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                       ),
// //                     ),

// //                     const SizedBox(height: 16),

// //                     const Text("Note (Optional)"),
// //                     const SizedBox(height: 6),

// //                     TextField(
// //                       maxLines: 3,
// //                       maxLength: 100,
// //                       decoration: InputDecoration(
// //                         hintText: "Add a note",
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               const SizedBox(height: 28),

// //               SizedBox(
// //                 width: double.infinity,
// //                 height: 52,
// //                 child: ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: const Color(0xff223A5E),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                   ),
// //                   onPressed: () {},
// //                   child: Text(
// //                     "Add Customer",
// //                     style: GoogleFonts.manrope(
// //                       color: ChopdiColors.cream,
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold
// //                     ),
// //                   ),
// //                 ),
// //               ),

// //               const SizedBox(height: 14),

// //                SizedBox(
// //                 width: double.infinity,
// //                 height: 52,
// //                 child: ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: ChopdiColors.cream,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       side: BorderSide(color: ChopdiColors.navy)
// //                     ),
// //                   ),
// //                   onPressed: () {
// //                     Navigator.pop(context);
// //                   },
// //                   child: Text(
// //                     "Cancel",
// //                     style: GoogleFonts.manrope(
// //                       color: ChopdiColors.navy,
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mychopdi/model/customer.dart';
// import 'package:mychopdi/view/customer_details_screen.dart';

// class CustomerDetailsAdd extends StatelessWidget {

//   final String contactName;
//   final String contactPhone;

//   // Customer customer = Customer();
//   CustomerDetailsAdd({super.key, required this.contactName, required this.contactPhone});

//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     const Color primaryColor = Color(0xFF233B63);
//     const Color backgroundColor = Color(0xFFFDF0DE);

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               /// Back Button
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

//               /// Profile Row
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [

//                   /// Avatar
//                   // CircleAvatar(
//                   //   radius: 24,
//                   //   backgroundColor: Colors.grey.shade300,
//                   //   child: Text(
//                   //     "R",
//                   //     style: GoogleFonts.manrope(
//                   //       fontSize: 26,
//                   //       fontWeight: FontWeight.bold,
//                   //       color: primaryColor,
//                   //     ),
//                   //   ),
//                   // ),

//                   CircleAvatar(
//                     radius: 24,
//                     backgroundColor: Colors.grey.shade300,
//                     child: Text(
//                       contactName.isNotEmpty
//                           ? contactName[0].toUpperCase()
//                           : "?",
//                       style: GoogleFonts.manrope(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: primaryColor,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   /// Name & Phone
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           contactName,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: primaryColor,
//                           ),
//                         ),
//                         const SizedBox(height: 3),
//                         Text(
//                           contactPhone,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.black54,
//                           ),
//                         ),
                        
//                       ],
//                     ),
//                   ),

//                   /// Edit Button
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

//               /// Add Customer Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     final phone = contactPhone.trim();

//                     if (phone.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Please enter phone number"),
//                         ),
//                       );
//                       return;
//                     }

//                     // Remove spaces, +91, etc.
//                     final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

//                     String finalPhone = cleanedPhone;

//                     // If number contains country code +91
//                     if (finalPhone.startsWith('91') && finalPhone.length == 12) {
//                       finalPhone = finalPhone.substring(2);
//                     }

//                     if (!RegExp(r'^[0-9]{10}$').hasMatch(finalPhone)) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text(
//                             "Please enter a valid 10-digit phone number",
//                           ),
//                         ),
//                       );
//                       return;
//                     }

//                     final customer = Customer()
//                       ..name = contactName.trim()
//                       ..phone = finalPhone
//                       ..status = "Pending"
//                       ..received = false;

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             CustomerDetailsScreen(customer: customer),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                   child: const Text(
//                     "Add Customer",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               /// Cancel Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
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
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/view/customer_details_screen.dart';

class CustomerDetailsAdd extends StatefulWidget {
  final String contactName;
  final String contactPhone;

  const CustomerDetailsAdd({
    super.key,
    required this.contactName,
    required this.contactPhone,
  });

  @override
  State<CustomerDetailsAdd> createState() => _CustomerDetailsAddState();
}

class _CustomerDetailsAddState extends State<CustomerDetailsAdd> {
  static const Color primaryColor = Color(0xFF233B63);
  static const Color backgroundColor = Color(0xFFFDF0DE);

  bool isSaving = false;

  // Future<void> addCustomer() async {
  //   final phone = widget.contactPhone.trim();

  //   if (phone.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Please enter phone number"),
  //       ),
  //     );
  //     return;
  //   }

  //   // Remove +91, spaces, -, etc.
  //   final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

  //   String finalPhone = cleanedPhone;

  //   // Remove Indian country code
  //   if (finalPhone.startsWith('91') &&
  //       finalPhone.length == 12) {
  //     finalPhone = finalPhone.substring(2);
  //   }

  //   // Validate 10 digit number
  //   if (!RegExp(r'^[0-9]{10}$').hasMatch(finalPhone)) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //           "Please enter a valid 10-digit phone number",
  //         ),
  //       ),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     isSaving = true;
  //   });

  //   try {
  //     // Check duplicate again
  //     final existingCustomer =
  //         await IsarService.getCustomerByPhone(finalPhone);

  //     if (existingCustomer != null) {
  //       if (!mounted) return;

  //       setState(() {
  //         isSaving = false;
  //       });

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text(
  //             "This customer already exists",
  //           ),
  //         ),
  //       );

  //       return;
  //     }

  //     // Create customer
  //     final customer = Customer()
  //       ..name = widget.contactName.trim()
  //       ..phone = finalPhone
  //       ..status = "Pending"
  //       ..received = false;

  //     // SAVE CUSTOMER TO ISAR
  //     await IsarService.isar.writeTxn(() async {
  //       await IsarService.isar.customers.put(customer);
  //     });

  //     if (!mounted) return;

  //     // Tell previous screen that customer was added
  //     Navigator.pop(context, true);
  //   } catch (e) {
  //     if (!mounted) return;

  //     setState(() {
  //       isSaving = false;
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           "Failed to add customer: $e",
  //         ),
  //       ),
  //     );
  //   }
  // }

  Future<void> addCustomer() async {
    final phone = widget.contactPhone.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter phone number"),
        ),
      );
      return;
    }

    // Remove +91, spaces, -, etc.
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    String finalPhone = cleanedPhone;

    // Remove Indian country code
    if (finalPhone.startsWith('91') && finalPhone.length == 12) {
      finalPhone = finalPhone.substring(2);
    }

    // Validate 10 digit number
    if (!RegExp(r'^[0-9]{10}$').hasMatch(finalPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a valid 10-digit phone number",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Check duplicate again
      final existingCustomer =
          await IsarService.getCustomerByPhone(finalPhone);

      if (existingCustomer != null) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This customer already exists"),
          ),
        );

        return;
      }

      // Create customer
      final customer = Customer()
        ..name = widget.contactName.trim()
        ..phone = finalPhone
        ..status = "Pending"
        ..received = false;

      // SAVE CUSTOMER TO ISAR
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.customers.put(customer);
      });

      if (!mounted) return;

      // Go directly to CustomerDetailsScreen
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
          content: Text("Failed to add customer: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: primaryColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(height: 18),

              // Profile
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          widget.contactPhone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
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

              // Add Customer
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:  isSaving ? null : addCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
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

              // Cancel
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