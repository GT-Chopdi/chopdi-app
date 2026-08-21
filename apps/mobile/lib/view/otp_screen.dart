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
  final TextEditingController otpController =
      TextEditingController();

  final FocusNode otpFocusNode = FocusNode();

  String? otpError;

  @override
  void initState() {
    super.initState();

    otpFocusNode.addListener(() {
      if (otpFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final context = otpFocusNode.context;

          if (context != null) {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignment: 0.35,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;

    final defaultPinTheme = PinTheme(
      width: width < 360 ? 40 : 42,
      height: width < 360 ? 48 : 50,

      textStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xff1D3557),
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xffCFCFCF),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xffFFF3E4),

      // IMPORTANT:
      // Allows the screen to resize when keyboard opens.
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,

              physics: const BouncingScrollPhysics(),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 18,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,

                    children: [
                      const SizedBox(height: 8),

                      // =====================================================
                      // TOP ROW
                      // =====================================================

                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              // Hide keyboard before going back.
                              FocusScope.of(context).unfocus();

                              Navigator.pop(context);
                            },

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

                            child: Image.asset(
                              "assets/book.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // =====================================================
                      // LOCK ICON
                      // =====================================================

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

                      // =====================================================
                      // TITLE
                      // =====================================================

                      Text(
                        "Verify your number",

                        textAlign: TextAlign.center,

                        style: GoogleFonts.inter(
                          fontSize: width < 360 ? 26 : 30,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff173A63),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // =====================================================
                      // SUBTITLE
                      // =====================================================

                      Text(
                        "We've sent a 6-digit OTP to",

                        textAlign: TextAlign.center,

                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // =====================================================
                      // PHONE NUMBER
                      // =====================================================

                      Text(
                        "+91 ${widget.phoneNumber}",

                        textAlign: TextAlign.center,

                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff173A63),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // =====================================================
                      // SECURITY DIVIDER
                      // =====================================================

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

                      // =====================================================
                      // OTP INPUT
                      // =====================================================

                      Pinput(
                        controller: otpController,

                        focusNode: otpFocusNode,

                        length: 6,

                        defaultPinTheme:
                            defaultPinTheme,

                        focusedPinTheme:
                            defaultPinTheme
                                .copyDecorationWith(
                          border: Border.all(
                            color:
                                const Color(0xff173A63),
                            width: 1.5,
                          ),
                        ),

                        keyboardType:
                            TextInputType.number,

                        textInputAction:
                            TextInputAction.done,

                        autofocus: false,

                        onChanged: (value) {
                          if (otpError != null) {
                            setState(() {
                              otpError = null;
                            });
                          }
                        },

                        onCompleted: (_) {
                          // Keep keyboard open so user can still
                          // review/edit OTP if needed.
                        },
                      ),

                      // =====================================================
                      // OTP ERROR
                      // =====================================================

                      if (otpError != null) ...[
                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.center,

                          child: Padding(
                            padding:
                                const EdgeInsets.only(
                              left: 6,
                            ),

                            child: Text(
                              otpError!,

                              textAlign:
                                  TextAlign.center,

                              style:
                                  GoogleFonts.manrope(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // =====================================================
                      // RESEND OTP
                      // =====================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

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
                              color:
                                  Colors.grey[700],
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

                      const SizedBox(height: 50),

                      // =====================================================
                      // VERIFY BUTTON
                      // =====================================================

                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton(
                          onPressed: _verifyOtp,

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                ChopdiColors.navy,

                            elevation: 0,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                            ),
                          ),

                          child: Text(
                            "Verify OTP",

                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =====================================================
                      // CHANGE MOBILE NUMBER
                      // =====================================================

                      TextButton(
                        onPressed: () {
                          FocusScope.of(context)
                              .unfocus();

                          Navigator.pop(context);
                        },

                        child: Text(
                          "Change Mobile Number",

                          style: GoogleFonts.inter(
                            color:
                                const Color(0xff173A63),
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===============================================================
  // VERIFY OTP
  // ===============================================================

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();

    // ---------------------------------------------------------------
    // EMPTY OTP
    // ---------------------------------------------------------------

    if (otp.isEmpty) {
      setState(() {
        otpError = "Please enter OTP";
      });

      _scrollToOtp();

      return;
    }

    // ---------------------------------------------------------------
    // INVALID OTP LENGTH
    // ---------------------------------------------------------------

    if (otp.length != 6) {
      setState(() {
        otpError =
            "Please enter a valid 6-digit OTP";
      });

      _scrollToOtp();

      return;
    }

    // ---------------------------------------------------------------
    // HARD-CODED OTP
    // ---------------------------------------------------------------

    if (otp != "123456") {
      setState(() {
        otpError = "Invalid OTP";
      });

      _scrollToOtp();

      return;
    }

    // ---------------------------------------------------------------
    // VALID OTP
    // ---------------------------------------------------------------

    setState(() {
      otpError = null;
    });

    // Hide keyboard before navigation.
    FocusScope.of(context).unfocus();

    // Small delay allows keyboard to start closing
    // before navigating.
    await Future.delayed(
      const Duration(milliseconds: 100),
    );

    // ---------------------------------------------------------------
    // SAVE LOGIN SESSION
    // ---------------------------------------------------------------

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.userSessions.put(
        UserSession()
          ..phoneNumber = widget.phoneNumber
          ..isLoggedIn = true
          ..loginTime = DateTime.now(),
      );
    });

    // ---------------------------------------------------------------
    // NAVIGATE TO MAIN SCREEN
    // ---------------------------------------------------------------

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ),

      (route) => false,
    );
  }

  // ===============================================================
  // SCROLL OTP INTO VIEW
  // ===============================================================

  void _scrollToOtp() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final context = otpFocusNode.context;

      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration:
              const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.35,
        );
      }
    });
  }
}