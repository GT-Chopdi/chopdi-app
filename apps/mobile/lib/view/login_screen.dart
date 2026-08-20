import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/otp_screen.dart';

class ChopdiOnboardingScreen extends StatefulWidget {
  const ChopdiOnboardingScreen({super.key});

  @override
  State<ChopdiOnboardingScreen> createState() =>
      _ChopdiOnboardingScreenState();
}

class _ChopdiOnboardingScreenState extends State<ChopdiOnboardingScreen> {
  // Controller for the phone number text field
  final TextEditingController _phoneController = TextEditingController();
  String? errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _phoneController.addListener(() {
      if (errorText != null) {
        setState(() {
          errorText = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChopdiColors.navy,
       resizeToAvoidBottomInset: false,
      body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 18),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                //  height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsetsGeometry.only(left: 24, right: 24, top:10),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -18,
                            right: -48,
                            child: Image.asset(
                              'assets/book.png',
                              width: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                
                          // Logo + heading + subtitle, in front of the book image
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo row: app icon (from assets) + "Chopdi" wordmark
                              const _ChopdiLogo(),
              
                              // const SizedBox(height: 2),
              
                              Text(
                                'Chopdi',
                                style: GoogleFonts.manrope(
                                  color: ChopdiColors.cream,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
              
                              const SizedBox(height: 52),
                
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.manrope(
                                    fontSize: 28,
                                    height: 1.25,
                                    fontWeight: FontWeight.w700,
                                    color: ChopdiColors.cream,
                                  ),
                                  children: [
                                    TextSpan(text: 'Your lending records,\n'),
                                    TextSpan(
                                      text: 'digitally organized.',
                                      style: GoogleFonts.manrope(color: Color(0xFF83A2CE),fontSize: 28),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                
                              // Subtitle
                              Text(
                                'Track loans, interest and payments\nwith clarity and confidence.',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  height: 1.35,
                                  fontWeight: FontWeight.w400,
                                  color: ChopdiColors.cream,
                                  // height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              
                    SizedBox(height: 40),
            
                    Expanded(
                      child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    color: const Color(0xFFF4F4F4),
                                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFAAB9CF),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Image.asset('assets/mobile.png')
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Let's get started",
                                                    style: GoogleFonts.manrope(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600,
                                                      color: ChopdiColors.navy,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Enter your mobile number to\ncontinue to Chopdi",
                                                    style: GoogleFonts.manrope(
                                                      fontSize: 14,
                                                      height: 1.4,
                                                      color: ChopdiColors.navy,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                    
                                        const SizedBox(height: 24),
                                    
                                        _PhoneInputField(controller: _phoneController, errorText: errorText),
                                    
                                        const SizedBox(height: 22),
                                    
                                        _ContinueButton(
                                          onPressed: () {
                                            // if (_phoneController.text == AuthService.validPhone) {
                                  
                                            //   Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //       builder: (_) => OTPScreen(
                                            //         phoneNumber: _phoneController.text,
                                            //       ),
                                            //     ),
                                            //   );
                                  
                                            // } else {
                                  
                                            //   ScaffoldMessenger.of(context).showSnackBar(
                                            //     SnackBar(backgroundColor: Colors.red, content: Text("Invalid Mobile Number",style: GoogleFonts.manrope(fontSize: 14, color: Colors.white,fontWeight: FontWeight.bold),)),
                                            //   );
                                  
                                            // }
                      
                                            //  final phone = _phoneController.text.trim();
                      
                                            //   // Empty mobile number
                                            //   if (phone.isEmpty) {
                                            //     ScaffoldMessenger.of(context).showSnackBar(
                                            //       SnackBar(
                                            //         backgroundColor: Colors.red,
                                            //         content: Text(
                                            //           "Please enter mobile number",
                                            //           style: GoogleFonts.manrope(
                                            //             color: Colors.white,
                                            //             fontWeight: FontWeight.bold,
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     );
                                            //     return;
                                            //   }
                      
                                            //   // Invalid length
                                            //   if (phone.length != 10) {
                                            //     ScaffoldMessenger.of(context).showSnackBar(
                                            //       SnackBar(
                                            //         backgroundColor: Colors.red,
                                            //         content: Text(
                                            //           "Please enter a valid 10-digit mobile number",
                                            //           style: GoogleFonts.manrope(
                                            //             color: Colors.white,
                                            //             fontWeight: FontWeight.bold,
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     );
                                            //     return;
                                            //   }
                      
                                              // Check hardcoded number
                                              // if (phone != AuthService.validPhone) {
                                              //   ScaffoldMessenger.of(context).showSnackBar(
                                              //     SnackBar(
                                              //       backgroundColor: Colors.red,
                                              //       content: Text(
                                              //         "Invalid Mobile Number",
                                              //         style: GoogleFonts.manrope(
                                              //           color: Colors.white,
                                              //           fontWeight: FontWeight.bold,
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   );
                                              //   return;
                                              // }
                      
                                              final phone = _phoneController.text.trim();
                      
                                              setState(() {
                                                if (phone.isEmpty) {
                                                  errorText = "Please enter your mobile number";
                                                  return;
                                                }
                      
                                                if (phone.length < 10) {
                                                  errorText = "Please enter a valid 10-digit mobile number";
                                                  return;
                                                }
                      
                                                errorText = null;
                                              });
                      
                                              if (phone.isEmpty || phone.length < 10) return;
                      
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => OTPScreen(
                                                    phoneNumber: phone,
                                                  ),
                                                ),
                                              );
                                          },
                                        ),
                                    
                                        const SizedBox(height: 24),
                                    
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFAAB9CF),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Image.asset('assets/secured_logo.png',height: 20,width:20)
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Your data is secure with us",
                                              style: GoogleFonts.manrope(
                                                color: ChopdiColors.navy.withValues(alpha: .7),
                                                fontWeight: FontWeight.w300
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                    
                                Container(
                                  width: double.infinity,
                                  color: const Color(0xFFB7C6E0),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 20,
                                  ),
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF33496F),
                                        height: 1.5,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "By continuing, you agree to our\n",
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                          )
                                        ),
                                        TextSpan(
                                          text: "Terms of Service",
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12
                                          ),
                                        ),
                                        TextSpan(text: " and "),
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
}

class _ChopdiLogo extends StatelessWidget {
  const _ChopdiLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo mark image asset
        Image.asset(
          'assets/applogo.png',
          width: 66,
          height: 83,
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}

// class _PhoneInputField extends StatelessWidget {
//   final TextEditingController controller;
//   final String? errorText;

//   const _PhoneInputField({required this.controller, this.errorText});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: ChopdiColors.navy.withValues(alpha: 0.15)),
//       ),
//       child: Row(
//         children: [
          
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//             child: Row(
//               children: [
//                 Text(
//                   '+91',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: ChopdiColors.navy,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 Icon(
//                   Icons.keyboard_arrow_down,
//                   size: 18,
//                   color: ChopdiColors.navy.withValues(alpha: 0.7),
//                 ),
//               ],
//             ),
//           ),
          
//           Container(
//             width: 1,
//             height: 24,
//             color: ChopdiColors.navy.withValues(alpha: 0.15),
//           ),
          
//           Expanded(
//             child: SizedBox(
//               height: 58,
//               child: TextField(
//                 controller: controller,
//                 keyboardType: TextInputType.phone,
//                 maxLength: 10,
//                 style: const TextStyle(fontSize: 15),
//                 decoration: InputDecoration(
//                   counterText: '', // hides the default character counter
//                   hintText: '98765 23564',
//                   hintStyle: TextStyle(color: Colors.grey),
//                   border: InputBorder.none,
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//                 ),
//               ),
//             ),
//           ),
//           if (errorText != null) ...[
//           const SizedBox(height: 6),
//           Padding(
//             padding: const EdgeInsets.only(left: 12),
//             child: Text(
//               errorText!,
//               style: const TextStyle(
//                 color: Colors.red,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//         ],
//       ),
//     );
//   }
// }

class _PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const _PhoneInputField({
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: errorText != null
                  ? Colors.red
                  : ChopdiColors.navy.withValues(alpha: .15),
            ),
          ),
          child: Row(
            children: [
              // +91 section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Text(
                      '+91',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ChopdiColors.navy,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: ChopdiColors.navy.withValues(alpha: .7),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: TextField(
                  controller: controller,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '98765 23564',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ContinueButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ChopdiColors.navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize:20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mychopdi/utils/app_colors.dart';
// import 'package:mychopdi/view/otp_screen.dart';

// class ChopdiOnboardingScreen extends StatefulWidget {
//   const ChopdiOnboardingScreen({super.key});

//   @override
//   State<ChopdiOnboardingScreen> createState() =>
//       _ChopdiOnboardingScreenState();
// }

// class _ChopdiOnboardingScreenState extends State<ChopdiOnboardingScreen> {
//   final TextEditingController _phoneController = TextEditingController();

//   String? errorText;

//   @override
//   void initState() {
//     super.initState();

//     _phoneController.addListener(() {
//       if (errorText != null) {
//         setState(() {
//           errorText = null;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ChopdiColors.navy,
//       resizeToAvoidBottomInset: true,
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final width = constraints.maxWidth;
//             final height = constraints.maxHeight;

//             // Responsive horizontal padding
//             final horizontalPadding = width < 360
//                 ? 12.0
//                 : width < 600
//                     ? 16.0
//                     : 24.0;

//             // Responsive heading sizes
//             final chopdiFontSize = width < 360
//                 ? 30.0
//                 : width < 600
//                     ? 34.0
//                     : 36.0;

//             final headingFontSize = width < 360
//                 ? 23.0
//                 : width < 600
//                     ? 26.0
//                     : 28.0;

//             final subtitleFontSize = width < 360 ? 14.0 : 16.0;

//             // Responsive book size
//             final bookWidth = width < 360
//                 ? 125.0
//                 : width < 600
//                     ? 155.0
//                     : 180.0;

//             // Responsive spacing
//             final topSpacing = height < 650
//                 ? 4.0
//                 : height < 750
//                     ? 8.0
//                     : 12.0;

//             final headerBottomSpacing = height < 650
//                 ? 18.0
//                 : height < 750
//                     ? 28.0
//                     : 40.0;

//             return SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: constraints.maxHeight,
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: horizontalPadding,
//                     vertical: 18,
//                   ),
//                   child: Column(
//                     children: [
//                       SizedBox(height: topSpacing),

//                       // =====================================================
//                       // HEADER SECTION
//                       // =====================================================

//                       Padding(
//                         padding: EdgeInsets.only(
//                           left: width < 360 ? 12 : 24,
//                           right: width < 360 ? 12 : 24,
//                           top: 10,
//                         ),
//                         child: SizedBox(
//                           width: double.infinity,
//                           child: Stack(
//                             clipBehavior: Clip.none,
//                             children: [
//                               // Book image
//                               Positioned(
//                                 top: -18,
//                                 right: width < 360 ? -18 : -35,
//                                 child: Image.asset(
//                                   'assets/book.png',
//                                   width: bookWidth,
//                                   fit: BoxFit.contain,
//                                 ),
//                               ),

//                               // Logo + Heading + Subtitle
//                               Padding(
//                                 padding: EdgeInsets.only(
//                                   right: width < 360 ? 80 : 100,
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                   children: [
//                                     const _ChopdiLogo(),

//                                     Text(
//                                       'Chopdi',
//                                       style: GoogleFonts.manrope(
//                                         color: ChopdiColors.cream,
//                                         fontSize: chopdiFontSize,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),

//                                     SizedBox(
//                                       height: height < 650 ? 28 : 40,
//                                     ),

//                                     RichText(
//                                       text: TextSpan(
//                                         style: GoogleFonts.manrope(
//                                           fontSize: headingFontSize,
//                                           height: 1.25,
//                                           fontWeight: FontWeight.w700,
//                                           color: ChopdiColors.cream,
//                                         ),
//                                         children: [
//                                           const TextSpan(
//                                             text: 'Your lending records,\n',
//                                           ),
//                                           TextSpan(
//                                             text: 'digitally organized.',
//                                             style: GoogleFonts.manrope(
//                                               color: const Color(0xFF83A2CE),
//                                               fontSize: headingFontSize,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),

//                                     const SizedBox(height: 12),

//                                     Text(
//                                       'Track loans, interest and payments\n'
//                                       'with clarity and confidence.',
//                                       style: GoogleFonts.manrope(
//                                         fontSize: subtitleFontSize,
//                                         height: 1.35,
//                                         fontWeight: FontWeight.w400,
//                                         color: ChopdiColors.cream,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       SizedBox(height: headerBottomSpacing),

//                       // =====================================================
//                       // MAIN WHITE CARD
//                       // =====================================================

//                       Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(32),
//                         ),
//                         clipBehavior: Clip.antiAlias,
//                         child: Column(
//                           children: [
//                             // =================================================
//                             // FORM SECTION
//                             // =================================================

//                             Container(
//                               width: double.infinity,
//                               color: const Color(0xFFF4F4F4),
//                               padding: EdgeInsets.fromLTRB(
//                                 width < 360 ? 16 : 20,
//                                 width < 360 ? 18 : 22,
//                                 width < 360 ? 16 : 20,
//                                 18,
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // -----------------------------------------
//                                   // STARTED ROW
//                                   // -----------------------------------------

//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Container(
//                                         width: width < 360 ? 50 : 56,
//                                         height: width < 360 ? 50 : 56,
//                                         decoration: const BoxDecoration(
//                                           color: Color(0xFFAAB9CF),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         padding: const EdgeInsets.all(8),
//                                         child: Image.asset(
//                                           'assets/mobile.png',
//                                           fit: BoxFit.contain,
//                                         ),
//                                       ),

//                                       SizedBox(
//                                         width: width < 360 ? 10 : 14,
//                                       ),

//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "Let's get started",
//                                               style: GoogleFonts.manrope(
//                                                 fontSize:
//                                                     width < 360 ? 16 : 18,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: ChopdiColors.navy,
//                                               ),
//                                             ),

//                                             const SizedBox(height: 4),

//                                             Text(
//                                               "Enter your mobile number to\n"
//                                               "continue to Chopdi",
//                                               style: GoogleFonts.manrope(
//                                                 fontSize:
//                                                     width < 360 ? 13 : 14,
//                                                 height: 1.4,
//                                                 color: ChopdiColors.navy,
//                                                 fontWeight: FontWeight.w400,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),

//                                   const SizedBox(height: 24),

//                                   // -----------------------------------------
//                                   // PHONE INPUT
//                                   // -----------------------------------------

//                                   _PhoneInputField(
//                                     controller: _phoneController,
//                                     errorText: errorText,
//                                   ),

//                                   const SizedBox(height: 22),

//                                   // -----------------------------------------
//                                   // CONTINUE BUTTON
//                                   // -----------------------------------------

//                                   _ContinueButton(
//                                     onPressed: _handleContinue,
//                                   ),

//                                   const SizedBox(height: 24),

//                                   // -----------------------------------------
//                                   // SECURITY MESSAGE
//                                   // -----------------------------------------

//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Container(
//                                         width: 30,
//                                         height: 30,
//                                         decoration: const BoxDecoration(
//                                           color: Color(0xFFAAB9CF),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         padding: const EdgeInsets.all(5),
//                                         child: Image.asset(
//                                           'assets/secured_logo.png',
//                                           height: 20,
//                                           width: 20,
//                                           fit: BoxFit.contain,
//                                         ),
//                                       ),

//                                       const SizedBox(width: 5),

//                                       Flexible(
//                                         child: Text(
//                                           "Your data is secure with us",
//                                           textAlign: TextAlign.center,
//                                           style: GoogleFonts.manrope(
//                                             color: ChopdiColors.navy
//                                                 .withValues(alpha: .7),
//                                             fontSize: width < 360 ? 12 : 13,
//                                             fontWeight: FontWeight.w300,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // =================================================
//                             // TERMS SECTION
//                             // =================================================

//                             Container(
//                               width: double.infinity,
//                               color: const Color(0xFFB7C6E0),
//                               padding: EdgeInsets.symmetric(
//                                 vertical: 18,
//                                 horizontal: width < 360 ? 12 : 20,
//                               ),
//                               child: RichText(
//                                 textAlign: TextAlign.center,
//                                 text: TextSpan(
//                                   style: GoogleFonts.manrope(
//                                     fontSize: width < 360 ? 10 : 12,
//                                     color: const Color(0xFF33496F),
//                                     height: 1.5,
//                                   ),
//                                   children: [
//                                     TextSpan(
//                                       text: "By continuing, you agree to our\n",
//                                       style: GoogleFonts.manrope(
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: width < 360 ? 10 : 12,
//                                       ),
//                                     ),
//                                     TextSpan(
//                                       text: "Terms of Service",
//                                       style: GoogleFonts.manrope(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: width < 360 ? 10 : 12,
//                                       ),
//                                     ),
//                                     const TextSpan(text: " and "),
//                                     TextSpan(
//                                       text: "Privacy Policy",
//                                       style: GoogleFonts.manrope(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: width < 360 ? 10 : 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Small bottom spacing
//                       const SizedBox(height: 12),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ===============================================================
//   // CONTINUE BUTTON LOGIC
//   // ===============================================================

//   void _handleContinue() {
//     final phone = _phoneController.text.trim();

//     setState(() {
//       if (phone.isEmpty) {
//         errorText = "Please enter your mobile number";
//         return;
//       }

//       if (phone.length < 10) {
//         errorText = "Please enter a valid 10-digit mobile number";
//         return;
//       }

//       errorText = null;
//     });

//     if (phone.isEmpty || phone.length < 10) {
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => OTPScreen(
//           phoneNumber: phone,
//         ),
//       ),
//     );
//   }
// }

// // =====================================================================
// // CHOPDI LOGO
// // =====================================================================

// class _ChopdiLogo extends StatelessWidget {
//   const _ChopdiLogo();

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;

//     final logoWidth = width < 360
//         ? 52.0
//         : width < 600
//             ? 60.0
//             : 66.0;

//     final logoHeight = logoWidth * 1.25;

//     return Image.asset(
//       'assets/applogo.png',
//       width: logoWidth,
//       height: logoHeight,
//       fit: BoxFit.contain,
//     );
//   }
// }

// // =====================================================================
// // PHONE INPUT FIELD
// // =====================================================================

// class _PhoneInputField extends StatelessWidget {
//   final TextEditingController controller;
//   final String? errorText;

//   const _PhoneInputField({
//     required this.controller,
//     this.errorText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;

//     final countryCodePadding = width < 360 ? 10.0 : 14.0;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(
//               color: errorText != null
//                   ? Colors.red
//                   : ChopdiColors.navy.withValues(alpha: .15),
//             ),
//           ),
//           child: Row(
//             children: [
//               // ============================================================
//               // COUNTRY CODE
//               // ============================================================

//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: countryCodePadding,
//                   vertical: 14,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       '+91',
//                       style: GoogleFonts.manrope(
//                         fontSize: width < 360 ? 14 : 15,
//                         fontWeight: FontWeight.w600,
//                         color: ChopdiColors.navy,
//                       ),
//                     ),

//                     const SizedBox(width: 4),

//                     Icon(
//                       Icons.keyboard_arrow_down,
//                       size: 18,
//                       color: ChopdiColors.navy.withValues(alpha: .7),
//                     ),
//                   ],
//                 ),
//               ),

//               // ============================================================
//               // DIVIDER
//               // ============================================================

//               Container(
//                 width: 1,
//                 height: 28,
//                 color: ChopdiColors.navy.withValues(alpha: .15),
//               ),

//               // ============================================================
//               // PHONE NUMBER
//               // ============================================================

//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   maxLength: 10,
//                   keyboardType: TextInputType.phone,
//                   style: GoogleFonts.manrope(
//                     fontSize: width < 360 ? 14 : 15,
//                     color: ChopdiColors.navy,
//                   ),
//                   decoration: InputDecoration(
//                     counterText: '',
//                     hintText: '98765 23564',
//                     hintStyle: GoogleFonts.manrope(
//                       color: Colors.grey,
//                       fontSize: width < 360 ? 14 : 15,
//                     ),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 14,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // ================================================================
//         // ERROR MESSAGE
//         // ================================================================

//         if (errorText != null) ...[
//           const SizedBox(height: 6),

//           Padding(
//             padding: const EdgeInsets.only(left: 12),
//             child: Text(
//               errorText!,
//               style: GoogleFonts.manrope(
//                 color: Colors.red,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }

// // =====================================================================
// // CONTINUE BUTTON
// // =====================================================================

// class _ContinueButton extends StatelessWidget {
//   final VoidCallback onPressed;

//   const _ContinueButton({
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;

//     final buttonHeight = width < 360 ? 46.0 : 48.0;

//     final fontSize = width < 360 ? 18.0 : 20.0;

//     return SizedBox(
//       width: double.infinity,
//       height: buttonHeight,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: ChopdiColors.navy,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           elevation: 0,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Continue',
//               style: GoogleFonts.manrope(
//                 color: Colors.white,
//                 fontSize: fontSize,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),

//             const SizedBox(width: 8),

//             const Icon(
//               Icons.arrow_forward_rounded,
//               color: Colors.white,
//               size: 18,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }