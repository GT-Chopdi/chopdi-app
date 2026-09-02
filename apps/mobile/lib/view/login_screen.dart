import 'package:flutter/material.dart';
import 'package:mychopdi/core/config/api_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/data/remote/api_exception.dart';
import 'package:mychopdi/data/remote/error_code.dart';
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
  // Controller for phone number
  final TextEditingController _phoneController = TextEditingController();
  String? errorText;
  bool _requesting = false;
  // Stores the latest OTP challenge so we can reuse it
  // if the user comes back from the OTP screen and
  // presses Continue without changing the number.
  String? _lastChallengeId;
  String? _lastChallengePhone;

  // Focus node for phone field
  final FocusNode _phoneFocusNode = FocusNode();

  /// Asks the server to send a verification code, then moves to the OTP screen
  /// carrying the challenge it issued.
  ///
  /// The code itself never reaches this app — only an identifier for the
  /// attempt. That is what makes the OTP meaningful: a modified build cannot
  /// learn or bypass it.
  // Future<void> _requestOtp() async {
  //   final phone = _phoneController.text.trim();

  //   if (phone.isEmpty) {
  //     setState(() => errorText = "Please enter your mobile number");
  //     return;
  //   }

  //   if (phone.length < 10) {
  //     setState(
  //       () => errorText = "Please enter a valid 10-digit mobile number",
  //     );
  //     return;
  //   }

  //   setState(() {
  //     errorText = null;
  //     _requesting = true;
  //   });

  //   try {
  //     final challenge = await AuthService.instance.requestOtp(phone);

  //     if (!mounted) return;

  //     setState(() => _requesting = false);

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => OTPScreen(
  //           phoneNumber: phone,
  //           challengeId: challenge.challengeId,
  //         ),
  //       ),
  //     );
  //   } on ApiException catch (error) {
  //     if (!mounted) return;

  //     setState(() {
  //       _requesting = false;

  //       errorText = switch (error.code) {
  //         ApiErrorCode.rateLimited =>
  //           "A code was already sent. Please wait a moment.",

  //         'NETWORK_UNAVAILABLE' =>
  //           "Can't reach the server. Check your connection.",

  //         ApiErrorCode.devKeyRequired when ApiConfig.devKey.isEmpty =>
  //           "This build has no DEV_KEY compiled in.\n\n"
  //               "Paste AUTH_DEV_KEY into env/staging.env, then rebuild with\n"
  //               "--dart-define-from-file=env/staging.env",

  //         ApiErrorCode.devKeyRequired =>
  //           "The DEV_KEY in this build was rejected. Check it matches "
  //               "AUTH_DEV_KEY on the server.",

  //         _ => error.message,
  //       };
  //     });
  //   } on ApiConfigException catch (error) {
  //     // A build-time mistake, not a runtime failure. Saying "try again" here
  //     // sends someone retyping their number against a build that can never
  //     // work, so the real reason is shown instead.
  //     if (!mounted) return;

  //     setState(() {
  //       _requesting = false;
  //       errorText = error.message;
  //     });
  //   } catch (error, stack) {
  //     // Anything else is genuinely unexpected. The user gets a plain message,
  //     // but the real error goes to the log — without it, every distinct
  //     // failure looks identical in a bug report.
  //     debugPrint('[chopdi] OTP request failed: $error\n$stack');

  //     if (!mounted) return;

  //     setState(() {
  //       _requesting = false;
  //       errorText = "Something went wrong. Please try again.";
  //     });
  //   }
  // }

  Future<void> _requestOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        errorText = "Please enter your mobile number";
      });
      return;
    }

    if (phone.length < 10) {
      setState(() {
        errorText = "Please enter a valid 10-digit mobile number";
      });
      return;
    }

    // ================================================================
    // REUSE EXISTING OTP CHALLENGE
    // ================================================================
    //
    // If the user came back from the OTP screen using
    // "Change Mobile Number" but did not actually change
    // the number, don't request another OTP.
    //
    // Instead, open the existing OTP screen using the same
    // challengeId.
    // ================================================================

    if (_lastChallengeId != null &&
        _lastChallengePhone == phone) {
      FocusScope.of(context).unfocus();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPScreen(
            phoneNumber: phone,
            challengeId: _lastChallengeId!,
          ),
        ),
      );

      return;
    }

    setState(() {
      errorText = null;
      _requesting = true;
    });

    try {
      final challenge = await AuthService.instance.requestOtp(phone);

      if (!mounted) return;

      // ================================================================
      // SAVE THE CHALLENGE
      // ================================================================

      _lastChallengeId = challenge.challengeId;
      _lastChallengePhone = phone;

      setState(() {
        _requesting = false;
      });

      FocusScope.of(context).unfocus();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPScreen(
            phoneNumber: phone,
            challengeId: challenge.challengeId,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _requesting = false;

        errorText = switch (error.code) {
          ApiErrorCode.rateLimited =>
            "A code was already sent. Please wait a moment.",

          'NETWORK_UNAVAILABLE' =>
            "Can't reach the server. Check your connection.",

          ApiErrorCode.devKeyRequired
              when ApiConfig.devKey.isEmpty =>
            "This build has no DEV_KEY compiled in.\n\n"
                "Paste AUTH_DEV_KEY into env/staging.env, then rebuild with\n"
                "--dart-define-from-file=env/staging.env",

          ApiErrorCode.devKeyRequired =>
            "The DEV_KEY in this build was rejected. Check it matches "
                "AUTH_DEV_KEY on the server.",

          _ => error.message,
        };
      });
    } on ApiConfigException catch (error) {
      if (!mounted) return;

      setState(() {
        _requesting = false;
        errorText = error.message;
      });
    } catch (error, stack) {
      debugPrint(
        '[chopdi] OTP request failed: $error\n$stack',
      );

      if (!mounted) return;

      setState(() {
        _requesting = false;
        errorText = "Something went wrong. Please try again.";
      });
    }
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

    // ================================================================
    // KEYBOARD / PHONE FIELD SCROLL FIX
    // ================================================================
    //
    // When the phone field receives focus, wait for the keyboard to
    // finish opening and then scroll the field into the visible area.
    //
    _phoneFocusNode.addListener(() {
      if (_phoneFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;

          final fieldContext = _phoneFocusNode.context;

          if (fieldContext != null) {
            Scrollable.ensureVisible(
              fieldContext,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignment: 0.25,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChopdiColors.navy,

      // IMPORTANT:
      // Allows Scaffold to resize when keyboard opens.
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            // Responsive values
            final horizontalPadding = width < 360
                ? 12.0
                : width < 600
                    ? 16.0
                    : 24.0;

            final chopdiFontSize = width < 360
                ? 30.0
                : width < 600
                    ? 34.0
                    : 36.0;

            final headingFontSize = width < 360
                ? 23.0
                : width < 600
                    ? 26.0
                    : 28.0;

            final subtitleFontSize = width < 360 ? 14.0 : 16.0;

            final bookWidth = width < 360
                ? 125.0
                : width < 600
                    ? 155.0
                    : 180.0;

            final topSpacing = height < 650
                ? 4.0
                : height < 750
                    ? 8.0
                    : 12.0;

            final headerBottomSpacing = height < 650
                ? 18.0
                : height < 750
                    ? 28.0
                    : 40.0;

            // ============================================================
            // KEYBOARD FIX
            // ============================================================
            //
            // Removed the ConstrainedBox with minHeight.
            //
            // The SingleChildScrollView must be allowed to become smaller
            // when the keyboard opens so it can actually scroll the content.
            //
            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    SizedBox(height: topSpacing),

                    // =====================================================
                    // HEADER SECTION
                    // =====================================================

                    Padding(
                      padding: EdgeInsets.only(
                        left: width < 360 ? 12 : 24,
                        right: width < 360 ? 12 : 24,
                        top: 10,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // -------------------------------------------------
                            // BOOK IMAGE
                            // -------------------------------------------------

                            Positioned(
                              top: -18,
                              right: width < 360 ? -18 : -35,
                              child: Image.asset(
                                'assets/book.png',
                                width: bookWidth,
                                fit: BoxFit.contain,
                              ),
                            ),

                            // -------------------------------------------------
                            // LOGO + HEADING + SUBTITLE
                            // -------------------------------------------------

                            Padding(
                              padding: EdgeInsets.only(
                                right: width < 360 ? 80 : 100,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Logo
                                  const _ChopdiLogo(),

                                  // Chopdi text
                                  Text(
                                    'Chopdi',
                                    style: GoogleFonts.manrope(
                                      color: ChopdiColors.cream,
                                      fontSize: chopdiFontSize,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  SizedBox(
                                    height: height < 650 ? 28 : 40,
                                  ),

                                  // Main heading
                                  RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.manrope(
                                        fontSize: headingFontSize,
                                        height: 1.25,
                                        fontWeight: FontWeight.w700,
                                        color: ChopdiColors.cream,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Your lending records,\n',
                                        ),
                                        TextSpan(
                                          text: 'digitally organized.',
                                          style: GoogleFonts.manrope(
                                            color: const Color(0xFF83A2CE),
                                            fontSize: headingFontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Subtitle
                                  Text(
                                    'Track loans, interest and payments\n'
                                    'with clarity and confidence.',
                                    style: GoogleFonts.manrope(
                                      fontSize: subtitleFontSize,
                                      height: 1.35,
                                      fontWeight: FontWeight.w400,
                                      color: ChopdiColors.cream,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: headerBottomSpacing),

                    // =====================================================
                    // MAIN WHITE CARD
                    // =====================================================

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // =================================================
                          // FORM SECTION
                          // =================================================

                          Container(
                            width: double.infinity,
                            color: const Color(0xFFF4F4F4),
                            padding: EdgeInsets.fromLTRB(
                              width < 360 ? 16 : 20,
                              width < 360 ? 18 : 22,
                              width < 360 ? 16 : 20,
                              18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // -----------------------------------------
                                // STARTED ROW
                                // -----------------------------------------

                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Mobile icon
                                    Container(
                                      width: width < 360 ? 50 : 56,
                                      height: width < 360 ? 50 : 56,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFAAB9CF),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Image.asset(
                                        'assets/mobile.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),

                                    SizedBox(
                                      width: width < 360 ? 10 : 14,
                                    ),

                                    // Text
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Let's get started",
                                            style: GoogleFonts.manrope(
                                              fontSize:
                                                  width < 360 ? 16 : 18,
                                              fontWeight: FontWeight.w600,
                                              color: ChopdiColors.navy,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Enter your mobile number to\n"
                                            "continue to Chopdi",
                                            style: GoogleFonts.manrope(
                                              fontSize:
                                                  width < 360 ? 13 : 14,
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

                                // -----------------------------------------
                                // PHONE INPUT
                                // -----------------------------------------

                                _PhoneInputField(
                                  controller: _phoneController,
                                  errorText: errorText,
                                  focusNode: _phoneFocusNode,
                                ),

                                const SizedBox(height: 22),

                                // -----------------------------------------
                                // CONTINUE BUTTON
                                // -----------------------------------------

                                _ContinueButton(
                                  onPressed: _requestOtp,
                                  loading: _requesting,
                                ),

                                const SizedBox(height: 24),

                                // -----------------------------------------
                                // SECURITY MESSAGE
                                // -----------------------------------------

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFAAB9CF),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: Image.asset(
                                        'assets/secured_logo.png',
                                        height: 20,
                                        width: 20,
                                        fit: BoxFit.contain,
                                      ),
                                    ),

                                    const SizedBox(width: 5),

                                    Flexible(
                                      child: Text(
                                        "Your data is secure with us",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.manrope(
                                          color: ChopdiColors.navy
                                              .withValues(alpha: .7),
                                          fontSize:
                                              width < 360 ? 12 : 13,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // =================================================
                          // TERMS SECTION
                          // =================================================

                          Container(
                            width: double.infinity,
                            color: const Color(0xFFB7C6E0),
                            padding: EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: width < 360 ? 12 : 20,
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoogleFonts.manrope(
                                  fontSize: width < 360 ? 10 : 12,
                                  color: const Color(0xFF33496F),
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        "By continuing, you agree to our\n",
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w400,
                                      fontSize: width < 360 ? 10 : 12,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Terms of Service",
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w600,
                                      fontSize: width < 360 ? 10 : 12,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: " and ",
                                  ),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w600,
                                      fontSize: width < 360 ? 10 : 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =====================================================================
// CHOPDI LOGO
// =====================================================================

class _ChopdiLogo extends StatelessWidget {
  const _ChopdiLogo();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final logoWidth = width < 360
        ? 52.0
        : width < 600
            ? 60.0
            : 66.0;

    final logoHeight = logoWidth * 1.25;

    return Image.asset(
      'assets/applogo.png',
      width: logoWidth,
      height: logoHeight,
      fit: BoxFit.contain,
    );
  }
}

// =====================================================================
// PHONE INPUT FIELD
// =====================================================================

class _PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final FocusNode focusNode;

  const _PhoneInputField({
    required this.controller,
    required this.focusNode,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final countryCodePadding = width < 360 ? 10.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
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
              // ============================================================
              // COUNTRY CODE
              // ============================================================

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: countryCodePadding,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+91',
                      style: GoogleFonts.manrope(
                        fontSize: width < 360 ? 14 : 15,
                        fontWeight: FontWeight.w600,
                        color: ChopdiColors.navy,
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Icon(
                    //   Icons.keyboard_arrow_down,
                    //   size: 18,
                    //   color: ChopdiColors.navy.withValues(alpha: .7),
                    // ),
                  ],
                ),
              ),

              // ============================================================
              // DIVIDER
              // ============================================================

              Container(
                width: 1,
                height: 28,
                color: ChopdiColors.navy.withValues(alpha: .15),
              ),

              // ============================================================
              // PHONE NUMBER
              // ============================================================

              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofocus: false,
                  style: GoogleFonts.manrope(
                    fontSize: width < 360 ? 14 : 15,
                    color: ChopdiColors.navy,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '98765 23564',
                    hintStyle: GoogleFonts.manrope(
                      color: Colors.grey,
                      fontSize: width < 360 ? 14 : 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ================================================================
        // ERROR MESSAGE
        // ================================================================

        if (errorText != null) ...[
          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText!,
              style: GoogleFonts.manrope(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// =====================================================================
// CONTINUE BUTTON
// =====================================================================

class _ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;

  /// Disables the button and shows a spinner while the code is being sent.
  /// Requesting an OTP is a network round trip, and without this the user can
  /// tap repeatedly — each tap another SMS, and the later ones rejected by the
  /// server's resend cooldown anyway.
  final bool loading;

  const _ContinueButton({
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final buttonHeight = width < 360 ? 46.0 : 48.0;

    final fontSize = width < 360 ? 18.0 : 20.0;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ChopdiColors.navy,
          disabledBackgroundColor:
              ChopdiColors.navy.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }
}