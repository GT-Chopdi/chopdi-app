import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({
    super.key,
    this.onContactSupport,
  });

  final VoidCallback? onContactSupport;

  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color backgroundColor = Color(0xFFFDEDD9);
  static const Color darkBlue = Color(0xFF223A5E);
  static const Color textColor = Color(0xFF223A5E);
  static const Color secondaryText = Color.fromRGBO(34, 58, 94, 0.62);
  static const Color borderColor = Color(0xFFAAB9CF);

  static const Color iconCircleColor = Color(0xFFFFDCC7);
  static const Color orange = Color(0xFFC74C4C);

  static const Color infoBackground = Color(0xFFFEE0C9);
  static const Color infoBorder = Color.fromRGBO(177, 95, 39, 0.23);

  @override
  Widget build(BuildContext context) {
    final keyboardVisible =
        MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: backgroundColor,

      resizeToAvoidBottomInset: true,

      body: SafeArea(
        bottom: false,

        child: Padding(
          // ===============================================================
          // SAME OUTER PADDING AS MY CHOPDI / HELP / NOTIFICATION SETTINGS
          // ===============================================================

          padding: const EdgeInsets.all(14),

          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior
                          .onDrag,

                  // No additional horizontal padding.
                  padding: EdgeInsets.only(
                    bottom:
                        keyboardVisible ? 30 : 14,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // =====================================================
                      // HEADER
                      // =====================================================

                      _buildHeader(context),

                      const SizedBox(
                        height: 18,
                      ),

                      // =====================================================
                      // DOCUMENT ILLUSTRATION
                      // =====================================================

                      _buildDocumentIllustration(),

                      const SizedBox(
                        height: 18,
                      ),

                      // =====================================================
                      // TRUST TEXT
                      // =====================================================

                      _buildTrustText(),

                      const SizedBox(
                        height: 18,
                      ),

                      // =====================================================
                      // DIVIDER
                      // =====================================================

                      _buildDivider(),

                      // =====================================================
                      // TERMS
                      // =====================================================

                      _buildTermsSection(),

                      const SizedBox(
                        height: 8,
                      ),

                      _buildDivider(),

                      // =====================================================
                      // PRIVACY
                      // =====================================================

                      _buildPrivacySection(),

                      const SizedBox(
                        height: 11,
                      ),

                      _buildDivider(),

                      const SizedBox(
                        height: 18,
                      ),

                      // =====================================================
                      // CONTACT
                      // =====================================================

                      _buildContactBox(),

                      const SizedBox(
                        height: 18,
                      ),

                      // =====================================================
                      // LAST UPDATED
                      // =====================================================

                      _buildLastUpdated(),

                      const SizedBox(
                        height: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },

          child: const Padding(
            padding: EdgeInsets.only(
              top: 1,
              right: 8,
            ),

            child: Icon(
              Icons.arrow_back,
              size: 19,
              color: darkBlue,
            ),
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Privacy',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: darkBlue,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Read our policies',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: secondaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // DOCUMENT ILLUSTRATION
  // ===========================================================================

  Widget _buildDocumentIllustration() {
    return SizedBox(
      width: double.infinity,
      height: 88,

      child: Stack(
        alignment: Alignment.center,
        children: [
          // ---------------------------------------------------------------
          // CIRCLE
          // ---------------------------------------------------------------

          Container(
            width: 107.43,
            height: 107.43,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(34, 58, 94, 0.62),
              shape: BoxShape.circle,
            ),
          ),

          // ---------------------------------------------------------------
          // DOCUMENT
          // ---------------------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              height: 64,
              width: 90,
              child: Image.asset('assets/terms_and_privacy.png')
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentLine({double? width}) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Container(
        width: width ?? 25,
        height: 2,

        decoration: BoxDecoration(
          color: const Color(0xFFD6C9B9),
          borderRadius:
              BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ===========================================================================
  // TRUST TEXT
  // ===========================================================================

  Widget _buildTrustText() {
    return SizedBox(
      width: double.infinity,

      child: Column(
        children: [
          Text(
            'Your trust is important to us.',
            textAlign: TextAlign.center,

            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: darkBlue,
            ),
          ),

          SizedBox(height: 2),

          Text(
            'Please read our Terms & Conditions and Privacy Policy.',
            textAlign: TextAlign.center,

            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DIVIDER
  // ===========================================================================

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1.0,
      color: borderColor,
    );
  }

  // ===========================================================================
  // TERMS SECTION
  // ===========================================================================

  Widget _buildTermsSection() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 5,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _buildSectionIcon(
            Icons.description_outlined,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Terms & Conditions',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkBlue,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'By using Chopdi, you agree to the following terms:',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 3),

                _buildBullet(
                  'Chopdi is a digital ledger app to help you record and '
                  'manage loans, payments, interest and related notes.',
                ),

                _buildBullet(
                  'You are responsible for the accuracy of the information '
                  'you enter.',
                ),

                _buildBullet(
                  'Chopdi is provided “as is” without any warranties.',
                ),

                _buildBullet(
                  'We are not liable for any loss or damage.',
                ),

                _buildBullet(
                  'We may update these terms from time to time. '
                  'Continued use means you accept the updated terms.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PRIVACY SECTION
  // ===========================================================================

  Widget _buildPrivacySection() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 5,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _buildSectionIcon(
            Icons.privacy_tip_outlined,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Privacy Policy',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkBlue,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'We are committed to protecting your privacy:',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 3),

                _buildBullet(
                  'We collect only the data needed to provide and improve '
                  'our services.',
                ),

                _buildBullet(
                  'Your data is securely stored and encrypted.',
                ),

                _buildBullet(
                  'We never sell or share your personal information with '
                  'third parties.',
                ),

                _buildBullet(
                  'You are in control of your data and can export or delete '
                  'it anytime.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION ICON
  // ===========================================================================

  Widget _buildSectionIcon(IconData icon) {
    return Container(
      width: 29,
      height: 29,

      decoration: const BoxDecoration(
        color: iconCircleColor,
        shape: BoxShape.circle,
      ),

      child: Icon(
        icon,
        size: 15,
        color: orange,
      ),
    );
  }

  // ===========================================================================
  // BULLET
  // ===========================================================================

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 1,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 2,
              right: 4,
            ),

            child: Text(
              '•',
              style: GoogleFonts.manrope(
                fontSize: 7,
                color: darkBlue,
              ),
            ),
          ),

          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.12,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CONTACT BOX
  // ===========================================================================

  Widget _buildContactBox() {
    return GestureDetector(
      onTap: () {
        onContactSupport?.call();
      },

      child: Container(
        width: double.infinity,

        // Do not force a small height.
        // Let the content determine the height.
        constraints: const BoxConstraints(
          minHeight: 39,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 7,
        ),

        decoration: BoxDecoration(
          color: infoBackground,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: infoBorder,
            width: 0.8,
          ),
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [
            const Icon(
              Icons.info_outline,
              size: 14,
              color: orange,
            ),

            const SizedBox(
              width: 7,
            ),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                mainAxisAlignment:
                    MainAxisAlignment.center,

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'If you have any questions, feel free to contact us at',

                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.15,
                    ),
                  ),

                  SizedBox(
                    height: 2,
                  ),

                  Text(
                    'support@chopdi.app',

                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: orange,
                      fontWeight:
                          FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // LAST UPDATED
  // ===========================================================================

  Widget _buildLastUpdated() {
    return SizedBox(
      width: double.infinity,

      child: Text(
        'Last Updated on 30 July 2026',
        textAlign: TextAlign.center,

        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: secondaryText,
        ),
      ),
    );
  }
}