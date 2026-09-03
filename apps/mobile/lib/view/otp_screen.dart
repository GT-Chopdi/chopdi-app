import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mychopdi/core/config/api_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/data/remote/api_exception.dart';
import 'package:mychopdi/data/remote/error_code.dart';
import 'package:mychopdi/service/auth_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/main_screen.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  /// Identifies the challenge the server issued for this phone number.
  ///
  /// Verification is bound to it, which is why the code cannot be checked on
  /// device: only the server knows what was sent, and only it can decide
  /// whether this attempt is correct, expired, or one attempt too many.
  final String challengeId;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.challengeId,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();

  final FocusNode otpFocusNode = FocusNode();

  String? otpError;
  bool _verifying = false;

  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool get _canResend => _resendSeconds <= 0;

  void _startResendTimer() {
    _resendTimer?.cancel();

    setState(() {
      _resendSeconds = 30;
    });

    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_resendSeconds <= 1) {
          timer.cancel();

          setState(() {
            _resendSeconds = 0;
          });
        } else {
          setState(() {
            _resendSeconds--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _startResendTimer();

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

  // @override
  // void dispose() {
  //   otpController.dispose();
  //   otpFocusNode.dispose();
  //   super.dispose();
  // }
  @override
  void dispose() {
    _resendTimer?.cancel();
    otpController.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }

  // ===============================================================
  // VERIFY OTP
  // ===============================================================

  /// Verifies OTP against the API.
  ///
  /// The code is never compared on device. Attempt limits, expiry, and the
  /// dev-mode fixed code all live server-side, so a modified APK gains nothing.
  Future<void> _verify() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      setState(() {
        otpError = "Please enter OTP";
      });

      _scrollToOtp();
      return;
    }

    if (otp.length != 6) {
      setState(() {
        otpError = "Please enter a valid 6-digit OTP";
      });

      _scrollToOtp();
      return;
    }

    setState(() {
      _verifying = true;
      otpError = null;
    });

    try {
      await AuthService.instance.verifyOtp(
        challengeId: widget.challengeId,
        code: otp,
      );

      if (!mounted) return;

      setState(() {
        _verifying = false;
      });

      // Hide keyboard before navigation.
      FocusScope.of(context).unfocus();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _verifying = false;
        otpError = _messageFor(error);
      });
    } on ApiConfigException catch (error) {
      if (!mounted) return;

      setState(() {
        _verifying = false;
        otpError = error.message;
      });
    } catch (error, stack) {
      debugPrint(
        '[chopdi] OTP verify failed: $error\n$stack',
      );

      if (!mounted) return;

      setState(() {
        _verifying = false;
        otpError = "Something went wrong. Please try again.";
      });
    }
  }

  // ===============================================================
  // API ERROR MESSAGE
  // ===============================================================

  /// Turns a server error code into something a lender can act on.

  String _messageFor(ApiException error) {
    switch (error.code) {
      case ApiErrorCode.invalidCode:
        return "Incorrect OTP. Please try again.";

      case ApiErrorCode.challengeExpired:
        return "This code has expired. Request a new one.";

      case ApiErrorCode.tooManyAttempts:
        return "Too many incorrect attempts. Request a new code.";

      case ApiErrorCode.rateLimited:
        return "Please wait a moment before trying again.";

      case 'NETWORK_UNAVAILABLE':
        return "Can't reach the server. Check your connection.";

      default:
        return error.message;
    }
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.35,
        );
      }
    });
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
                    crossAxisAlignment: CrossAxisAlignment.center,

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

                        child: Image.asset(
                          'assets/lock.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
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

                        defaultPinTheme: defaultPinTheme,

                        focusedPinTheme:
                            defaultPinTheme.copyDecorationWith(
                          border: Border.all(
                            color: const Color(0xff173A63),
                            width: 1.5,
                          ),
                        ),

                        keyboardType: TextInputType.number,

                        textInputAction: TextInputAction.done,

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
                            padding: const EdgeInsets.only(
                              left: 6,
                            ),

                            child: Text(
                              otpError!,

                              textAlign: TextAlign.center,

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

                      // =====================================================
                      // RESEND OTP
                      // =====================================================

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Color(0xff173A63),
                          ),

                          const SizedBox(width: 6),

                          if (_canResend)
                            GestureDetector(
                              onTap: () {
                                _startResendTimer();

                                // TODO:
                                // Call your resend OTP API here.
                              },
                              child: Text(
                                "Resend OTP",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xff173A63),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            Row(
                              children: [
                                Text(
                                  "Resend OTP in ",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  "00:${_resendSeconds.toString().padLeft(2, '0')}",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
                          onPressed: _verifying ? null : _verify,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: ChopdiColors.navy,

                            disabledBackgroundColor:
                                ChopdiColors.navy.withValues(
                              alpha: 0.6,
                            ),

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),

                          child: _verifying
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
                          FocusScope.of(context).unfocus();

                          Navigator.pop(context);
                        },

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
            );
          },
        ),
      ),
    );
  }
}