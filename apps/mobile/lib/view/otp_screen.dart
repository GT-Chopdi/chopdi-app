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
import 'package:mychopdi/main.dart';
import 'package:mychopdi/model/user_session.dart';
import 'package:mychopdi/service/auth_service.dart';
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

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom > 0;

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

    return Scaffold(
      backgroundColor: const Color(0xffFFF3E4),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            left: 14,
            right: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Color(0xff1D3557),
                      ),
                    ),

                    const Spacer(),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: keyboard
                          ? const SizedBox(width: 60)
                          : SizedBox(
                              key: const ValueKey(1),
                              height: 150,
                              width: 150,
                              child: Image.asset("assets/book.png"),
                            ),
                    ),
                  ],
                ),

                SizedBox(height: keyboard ? 10 : 18),

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
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                ),

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

                SizedBox(height: keyboard ? 40 : 80),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (otpController.text ==
                          AuthService.validOtp) {
                        // await AuthService.saveLogin();
                        await isar.writeTxn(() async {
                          await isar.userSessions.put(
                            UserSession()
                              ..phoneNumber = widget.phoneNumber
                              ..isLoggedIn = true,
                          );
                        });

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainScreen(),
                          ),
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Invalid OTP"),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffAEBBD1),
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