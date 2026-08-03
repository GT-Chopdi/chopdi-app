import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/service/auth_service.dart';
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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChopdiColors.navy,
      body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 18),
              child: SizedBox(
                // height: MediaQuery.of(context).size.height,
                 height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
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
              
                    SizedBox(height: 70),
            
                    Container(
                          width: 380,
                          height: 390,
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
              
                                      _PhoneInputField(controller: _phoneController),
              
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

                                           final phone = _phoneController.text.trim();

                                            // Empty mobile number
                                            if (phone.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                    "Please enter mobile number",
                                                    style: GoogleFonts.manrope(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            // Invalid length
                                            if (phone.length != 10) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                    "Please enter a valid 10-digit mobile number",
                                                    style: GoogleFonts.manrope(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            // Check hardcoded number
                                            if (phone != AuthService.validPhone) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                    "Invalid Mobile Number",
                                                    style: GoogleFonts.manrope(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            // Navigate to OTP Screen
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
                  ],
                ),
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

class _PhoneInputField extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ChopdiColors.navy.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          
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
                  color: ChopdiColors.navy.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
          
          Container(
            width: 1,
            height: 24,
            color: ChopdiColors.navy.withValues(alpha: 0.15),
          ),
          
          Expanded(
            child: SizedBox(
              height: 58,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  counterText: '', // hides the default character counter
                  hintText: '98765 23564',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
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
