// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mychopdi/service/auth_service.dart';
// import 'package:mychopdi/view/main_screen.dart';
// import 'package:pinput/pinput.dart';

// class OTPScreen extends StatefulWidget {

//   final String phoneNumber;
//   const OTPScreen({super.key,required this.phoneNumber,});

//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {

//   final TextEditingController otpController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {

//     final defaultPinTheme = PinTheme(
//       width: 42,
//       height: 50,
//       textStyle: GoogleFonts.inter(
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//         color: Color(0xff1D3557),
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(
//           color: const Color(0xffCFCFCF),
//         ),
//       ),
//     );

//     return Scaffold(
//       backgroundColor: const Color(0xffFFF3E4),

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 14),
//           child: Column(
//             children: [

//               const SizedBox(height: 8),

//               Row(
//                 children: [

//                   const Icon(
//                     Icons.arrow_back_ios_new,
//                     size: 18,
//                     color: Color(0xff1D3557),
//                   ),

//                   const Spacer(),

//                   Container(
//                     height: 150,
//                     width: 150,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                     ),

//                     child: Image.asset("assets/book.png")
//                   )
//                 ],
//               ),

//               const SizedBox(height: 18),

//               Container(
//                 height: 54,
//                 width: 54,
//                 decoration: const BoxDecoration(
//                   color: Color(0xffB7C3D7),
//                   shape: BoxShape.circle,
//                 ),

//                 child: const Icon(
//                   Icons.lock_outline,
//                   color: Color(0xff1D3557),
//                 ),
//               ),

//               const SizedBox(height: 18),

//               Text(
//                 "Verify your number",
//                 style: GoogleFonts.inter(
//                   fontSize: 30,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xff173A63),
//                 ),
//               ),

//               const SizedBox(height: 8),

//               Text(
//                 "We've sent a 6-digit OTP to",
//                 style: GoogleFonts.inter(
//                   fontSize: 14,
//                   color: Colors.grey[700],
//                 ),
//               ),

//               const SizedBox(height: 6),

//               Text(
//                 "+91 ${widget.phoneNumber}",
//                 style: GoogleFonts.inter(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xff173A63),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               Row(
//                 children: [

//                   Expanded(
//                     child: Divider(
//                       thickness: 1,
//                       color: Colors.grey.shade400,
//                     ),
//                   ),

//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     child: Icon(
//                       Icons.security,
//                       color: Colors.grey.shade500,
//                       size: 16,
//                     ),
//                   ),

//                   Expanded(
//                     child: Divider(
//                       thickness: 1,
//                       color: Colors.grey.shade400,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 35),

//               Pinput(
//                 controller: otpController,
//                 length: 6,
//                 defaultPinTheme: defaultPinTheme,
//                 focusedPinTheme: defaultPinTheme.copyDecorationWith(
//                   border: Border.all(
//                     color: Color(0xff173A63),
//                     width: 1.5,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [

//                   const Icon(
//                     Icons.access_time,
//                     size: 16,
//                     color: Color(0xff173A63),
//                   ),

//                   const SizedBox(width: 6),

//                   Text(
//                     "Resend OTP in ",
//                     style: GoogleFonts.inter(
//                       fontSize: 13,
//                       color: Colors.grey[700],
//                     ),
//                   ),

//                   Text(
//                     "00:26",
//                     style: GoogleFonts.inter(
//                       fontSize: 13,
//                       color: Colors.red,
//                     ),
//                   )
//                 ],
//               ),

//               const Spacer(),

//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(

//                   onPressed: () async{
//                      if (otpController.text == AuthService.validOtp) {

//                       await AuthService.saveLogin();

//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const MainScreen(),
//                         ),
//                         (route) => false,
//                       );

//                     } else {

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Invalid OTP"),
//                         ),
//                       );

//                     }
//                   },

//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xffAEBBD1),
//                     disabledBackgroundColor: const Color(0xffAEBBD1),
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),

//                   child: Text(
//                     "Verify OTP",
//                     style: GoogleFonts.inter(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 18),

//               TextButton(
//                 onPressed: () {},
//                 child: Text(
//                   "Change Mobile Number",
//                   style: GoogleFonts.inter(
//                     color: const Color(0xff173A63),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 12),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/user_session.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/main_screen.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();

  String? otpError;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final defaultPinTheme = PinTheme(
      width: 42,
      height: 50,
      textStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xff1D3557),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffCFCFCF)),
      ),
    );

    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;


    return Scaffold(
      backgroundColor: const Color(0xffFFF3E4),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
            
                  /// Top Row
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_outlined,
                          size: 18,
                          color: Color(0xff1D3557),
                        ),
                      ),
            
                      const Spacer(),
            
                      SizedBox(
                        height: 150,
                        width: 130,
                        child: SizedBox(
                          height: 150,
                          width: 150,
                          child: Image.asset("assets/book.png"),
                        ),
                      ),
            
                    ],
                  ),
            
                  SizedBox(height: 18),
            
                  Container(
                    height: 54,
                    width: 54,
                    decoration: const BoxDecoration(
                      color: Color(0xffB7C3D7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Color(0xff1D3557),
                    ),
                  ),
            
                  const SizedBox(height: 18),
            
                  Text(
                    "Verify your number",
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff173A63),
                    ),
                  ),
            
                  const SizedBox(height: 8),
            
                  Text(
                    "We've sent a 6-digit OTP to",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
            
                  const SizedBox(height: 6),
            
                  Text(
                    "+91 ${widget.phoneNumber}",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff173A63),
                    ),
                  ),
            
                  const SizedBox(height: 24),
            
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.05,
                          vertical: height * 0.02,
                        ),
                        child: Icon(
                          Icons.security,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
            
                  const SizedBox(height: 35),
            
                  Pinput(
                    controller: otpController,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme:
                        defaultPinTheme.copyDecorationWith(
                      border: Border.all(
                        color: const Color(0xff173A63),
                        width: 1.5,
                      ),
                    ),
                    onChanged: (_) {
                      if (otpError != null) {
                        setState(() {
                          otpError = null;
                        });
                      }
                    },
                  ),
            
                  if (otpError != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          otpError!,
                          style: GoogleFonts.manrope(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
            
                  const SizedBox(height: 30),
            
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xff173A63),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Resend OTP in ",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        "00:26",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
            
                  SizedBox(height: 80),
            
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      
                      onPressed: () async {
                        final otp = otpController.text.trim();
            
                        if (otp.isEmpty) {
                          setState(() {
                            otpError = "Please enter OTP";
                          });
                          return;
                        }
            
                        if (otp.length != 6) {
                          setState(() {
                            otpError = "Please enter a valid 6-digit OTP";
                          });
                          return;
                        }
            
                        if (otp != "123456") {
                          setState(() {
                            otpError = "Invalid OTP";
                          });
                          return;
                        }
            
                        setState(() async{
                          otpError = null;
            
                          await IsarService.isar.writeTxn(() async {
                            await IsarService.isar.userSessions.put(
                              UserSession()
                                ..phoneNumber = widget.phoneNumber
                                ..isLoggedIn = true
                                ..loginTime = DateTime.now(),
                            );
                          });
            
                          final users = await IsarService.isar.userSessions.where().findAll();
            
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                            (route) => false,
                          );
                        });
            
                        // Login success
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ChopdiColors.navy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Verify OTP",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
            
                  const SizedBox(height: 18),
            
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Change Mobile Number",
                      style: GoogleFonts.inter(
                        color: const Color(0xff173A63),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
            
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
      ),
    );
  }
}