// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mychopdi/model/customer.dart';
// import 'package:mychopdi/utils/app_colors.dart';
// import 'package:mychopdi/service/isar_service.dart';

// class AddNewCustomerScreen extends StatefulWidget {
//   const AddNewCustomerScreen({super.key});

//   @override
//   State<AddNewCustomerScreen> createState() =>
//       _AddNewCustomerScreenState();
// }

// class _AddNewCustomerScreenState
//     extends State<AddNewCustomerScreen> {
//   final customerNameController = TextEditingController();
//   final mobileController = TextEditingController();
//   final amountController = TextEditingController();
//   final interestController = TextEditingController();
//   final noteController = TextEditingController();

//   DateTime? selectedDate;

//   Future<void> pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2024),
//       lastDate: DateTime(2100),
//     );

//     if (date != null) {
//       setState(() {
//         selectedDate = date;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ChopdiColors.cream,

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(18),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               Row(
//                 children: [

//                   InkWell(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(
//                       Icons.arrow_back_ios_new,
//                       size: 18,
//                       color: ChopdiColors.navy,
//                     ),
//                   ),

//                   const SizedBox(width: 10),

//                   const Text(
//                     "Add New Customer",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: ChopdiColors.navy,
//                     ),
//                   )
//                 ],
//               ),

//               const SizedBox(height: 18),

//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: Color(0xFFFFF8F0),
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(color: Color(0xFFAAB9CF)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [

//                     const Text(
//                       "Customer Details",
//                       style: TextStyle(
//                         color: ChopdiColors.navy,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 14),

//                     buildLabel("Name*"),

//                     buildField(
//                       controller: customerNameController,
//                       hint: "Customer Name",
//                       icon: Icons.person_outline,
//                     ),

//                     const SizedBox(height: 12),

//                     buildLabel("Phone Number*"),

//                     buildField(
//                       controller: mobileController,
//                       hint: "Mobile Number",
//                       icon: Icons.phone_outlined,
//                       keyboardType: TextInputType.phone,
//                     ),

//                     const SizedBox(height: 18),

//                     const Text(
//                       "Loan Details",
//                       style: TextStyle(
//                         color: ChopdiColors.navy,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 14),

//                     buildLabel("Loan Amount (*)"),

//                     buildField(
//                       controller: amountController,
//                       hint: "Enter Amount",
//                       icon: Icons.currency_rupee,
//                       keyboardType: TextInputType.number,
//                     ),

//                     const SizedBox(height: 12),

//                     buildLabel("Interest Rate (%)"),

//                     buildField(
//                       controller: interestController,
//                       hint: "Enter Interest rate",
//                       icon: Icons.percent,
//                       keyboardType: TextInputType.number,
//                     ),

//                     const SizedBox(height: 12),

//                     buildLabel("Date*"),

//                     InkWell(
//                       onTap: pickDate,
//                       child: IgnorePointer(
//                         child: buildField(
//                           hint: selectedDate == null
//                               ? "Select Date"
//                               : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
//                           suffixIcon:
//                               Icons.calendar_today_outlined,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     buildLabel("Note (Optional)"),

//                     TextField(
//                       controller: noteController,
//                       maxLines: 4,
//                       maxLength: 100,
//                       decoration: InputDecoration(
//                         hintText: "Add a note",
//                         counterText:
//                             "${noteController.text.length}/100",
//                         filled: true,
//                         fillColor: Color(0xFFFFF8F0),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius:
//                               BorderRadius.circular(8),
//                           borderSide:
//                               const BorderSide(color: Color(0xFFAAB9CF)),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius:
//                               BorderRadius.circular(8),
//                           borderSide:
//                               const BorderSide(color: ChopdiColors.navy),
//                         ),
//                       ),
//                       onChanged: (_) {
//                         setState(() {});
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 18),

//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: ChopdiColors.navy,
//                     shape: RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(8),
//                     ),
//                   ),

//                   onPressed: () async {
//                     if (customerNameController.text.trim().isEmpty ||
//                         mobileController.text.trim().isEmpty ||
//                         amountController.text.trim().isEmpty ||
//                         interestController.text.trim().isEmpty) {

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Please fill all required fields"),
//                         ),
//                       );

//                       return;
//                     }
//                     final customer = Customer()
//                       ..name = customerNameController.text.trim()
//                       ..phone = mobileController.text.trim()
//                       // ..amount = double.parse(amountController.text.trim())
//                       // ..interest = double.parse(interestController.text.trim())
//                       // ..loan = amountController.text.trim()
//                       ..status = "Pending"
//                       ..received = false;

//                     await IsarService.isar.writeTxn(() async {
//                       await IsarService.isar.customers.put(customer);
//                     });

//                     Navigator.pop(context);
//                   },
            
//                   child: Text(
//                     "Add Customer",
//                     style: GoogleFonts.manrope(
//                       color: ChopdiColors.cream,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 10),

//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: ChopdiColors.navy),
//                     shape: RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                   child: Text(
//                     "Cancel",
//                     style: GoogleFonts.manrope(
//                       color: ChopdiColors.navy,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
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

//   Widget buildLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Color(0xff6D7C93),
//           fontWeight: FontWeight.w600,
//           fontSize: 13,
//         ),
//       ),
//     );
//   }

//   Widget buildField({
//     TextEditingController? controller,
//     String? hint,
//     IconData? icon,
//     IconData? suffixIcon,
//     TextInputType? keyboardType,
//   }) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         hintText: hint,
//         prefixIcon:
//             icon != null ? Icon(icon, size: 18) : null,
//         suffixIcon:
//             suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
//         filled: true,
//         fillColor: Color(0xFFFFF8F0),
//         contentPadding: const EdgeInsets.symmetric(
//           vertical: 12,
//           horizontal: 12,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide:
//               const BorderSide(color: Color(0xffCDD5E2)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide:
//               const BorderSide(color: Color(0xff223A5E)),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/customer_details_screen.dart';
import 'package:mychopdi/data/repository/repositories.dart';

class AddNewCustomerScreen extends StatefulWidget {
  const AddNewCustomerScreen({super.key});

  @override
  State<AddNewCustomerScreen> createState() =>
      _AddNewCustomerScreenState();
}

class _AddNewCustomerScreenState
    extends State<AddNewCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // Future<void> saveCustomer() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final customer = Customer()
  //     ..name = nameController.text.trim()
  //     ..phone = phoneController.text.trim()
  //     ..status = "Pending"
  //     ..received = false;
  //     // ..amount = ""
  //     // ..interest = ""
  //     // ..loan = "";

  //   await IsarService.isar.writeTxn(() async {
  //     await IsarService.isar.customers.put(customer);
  //   });

  //   if (mounted) {
  //     Navigator.pushReplacement(
  //       context, 
  //       MaterialPageRoute(
  //         builder: (context) {
  //           return CustomerDetailsScreen(
  //             customer: customer,
  //           );
  //         }
  //       ),
  //     );   
  //   }
  // }

  // Future<void> saveCustomer() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final name = nameController.text.trim();
  //   final phone = phoneController.text.trim();

  //   // Check if customer already exists
  //   final existingCustomer = await IsarService.isar.customers
  //       .filter()
  //       .nameEqualTo(name)
  //       .phoneEqualTo(phone)
  //       .findFirst();

  //   if (existingCustomer != null) {
  //     if (!mounted) return;

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //           "Customer with the same name and phone number already exists.",
  //         ),
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );

  //     return;
  //   }

  //   // Create new customer
  //   final customer = Customer()
  //     ..name = name
  //     ..phone = phone
  //     ..status = "Pending"
  //     ..received = false;

  //   // Save customer
  //   await IsarService.isar.writeTxn(() async {
  //     await IsarService.isar.customers.put(customer);
  //   });

  //   if (!mounted) return;

  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) {
  //         return CustomerDetailsScreen(
  //           customer: customer,
  //         );
  //       },
  //     ),
  //   );
  // }

  Future<void> saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    // Check for duplicate customer
    // final existingCustomer = await IsarService.isar.customers
    //     .filter()
    //     .nameEqualTo(name)
    //     .phoneEqualTo(phone)
    //     .findFirst();

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
    // written in one transaction. A direct put would save the customer locally
    // and never queue it — invisible until the phone is lost.
    final customer = await Repositories.customers.create(
      name: name,
      phone: phone,
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

                      // _label("Phone Number (Optional)"),

                      // const SizedBox(height: 6),

                      // _textField(
                      //   controller: phoneController,
                      //   hint: "Mobile Number",
                      //   icon: Icons.phone_outlined,
                      //   keyboardType: TextInputType.phone,
                      // ),

                      // _label("Phone Number*"),

                      // const SizedBox(height: 6),

                      // _textField(
                      //   controller: phoneController,
                      //   hint: "Mobile Number",
                      //   icon: Icons.phone_outlined,
                      //   keyboardType: TextInputType.phone,
                      //   // validator: (value) {
                      //   //   if (value == null || value.trim().isEmpty) {
                      //   //     return "Enter phone number";
                      //   //   }

                      //   //   final phone = value.trim();

                      //   //   if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                      //   //     return "Enter a valid 10-digit phone number";
                      //   //   }

                      //   //   return null;
                      //   // },
                      //   validator: (value) {
                      //     if (value == null || value.trim().isEmpty) {
                      //       return "Enter phone number";
                      //     }

                      //     final phone = value.trim();

                      //     if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                      //       return "Enter a valid 10-digit phone number";
                      //     }

                      //     return null;
                      //   },
                      // ),

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

  // Widget _textField({
  //   required TextEditingController controller,
  //   required String hint,
  //   required IconData icon,
  //   TextInputType? keyboardType,
  //   String? Function(String?)? validator,
  // }) {
  //   return TextFormField(
  //     controller: controller,
  //     keyboardType: keyboardType,
  //     validator: validator,
  //     style: GoogleFonts.manrope(
  //       fontSize: 13,
  //     ),
  //     decoration: InputDecoration(
  //       isDense: true,
  //       hintText: hint,
  //       hintStyle: GoogleFonts.manrope(
  //         fontSize: 12,
  //         color: ChopdiColors.navy,
  //       ),
  //       prefixIcon: Icon(
  //         icon,
  //         size: 18,
  //         color: ChopdiColors.navy,
  //       ),
  //       filled: true,
  //       fillColor: Color(0xFFFFF8F0),
  //       contentPadding: const EdgeInsets.symmetric(
  //         vertical: 12,
  //         horizontal: 12,
  //       ),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: const BorderSide(
  //           color: Color(0xFFAAB9CF),
  //         ),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: const BorderSide(
  //           color: ChopdiColors.navy,
  //           width: 1.2,
  //         ),
  //       ),
  //     ),
  //   );
  // }

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