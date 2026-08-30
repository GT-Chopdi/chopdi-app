import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({
    super.key,
    this.onContactSupport,
  });

  final VoidCallback? onContactSupport;

  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color backgroundColor = Color(0xFFFFEEDB);
  static const Color darkBlue = Color(0xFF203E68);
  static const Color textColor = Color(0xFF263D5B);
  static const Color secondaryText = Color(0xFF66758A);
  static const Color borderColor = Color(0xFFB9C8D9);

  static const Color iconCircleColor = Color(0xFFFFDCC7);
  static const Color orange = Color(0xFFE56B48);

  static const Color infoBackground = Color(0xFFFFDFC9);
  static const Color infoBorder = Color(0xFFFFC49D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
            30,
            38,
            15,
            28,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================================
              // HEADER
              // =================================================================

              _buildHeader(context),

              const SizedBox(height: 14),

              // =================================================================
              // DOCUMENT ILLUSTRATION
              // =================================================================

              _buildDocumentIllustration(),

              const SizedBox(height: 9),

              // =================================================================
              // TRUST TEXT
              // =================================================================

              _buildTrustText(),

              const SizedBox(height: 10),

              // =================================================================
              // DIVIDER
              // =================================================================

              _buildDivider(),

              // =================================================================
              // TERMS & CONDITIONS
              // =================================================================

              _buildTermsSection(),

              const SizedBox(height: 8),

              _buildDivider(),

              // =================================================================
              // PRIVACY POLICY
              // =================================================================

              _buildPrivacySection(),

              const SizedBox(height: 11),

              _buildDivider(),

              const SizedBox(height: 19),

              // =================================================================
              // CONTACT BOX
              // =================================================================

              _buildContactBox(),

              const SizedBox(height: 28),

              // =================================================================
              // LAST UPDATED
              // =================================================================

              _buildLastUpdated(),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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

        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Privacy',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkBlue,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Read our policies',
              style: TextStyle(
                fontSize: 8.5,
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
            width: 66,
            height: 66,

            decoration: const BoxDecoration(
              color: Color(0xFF718096),
              shape: BoxShape.circle,
            ),
          ),

          // ---------------------------------------------------------------
          // DOCUMENT
          // ---------------------------------------------------------------

          Container(
            width: 40,
            height: 46,

            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EE),
              borderRadius:
                  BorderRadius.circular(3),

              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 2,
                  offset: Offset(1, 2),
                ),
              ],
            ),

            child: Stack(
              children: [
                // Top fold
                Positioned(
                  right: 0,
                  top: 0,

                  child: Container(
                    width: 10,
                    height: 10,

                    decoration:
                        const BoxDecoration(
                      color: Color(0xFFE8D9C6),

                      borderRadius:
                          BorderRadius.only(
                        topRight:
                            Radius.circular(3),
                        bottomLeft:
                            Radius.circular(3),
                      ),
                    ),
                  ),
                ),

                // Lines
                Positioned(
                  left: 7,
                  right: 7,
                  top: 16,

                  child: Column(
                    children: [
                      _documentLine(),
                      const SizedBox(height: 4),
                      _documentLine(),
                      const SizedBox(height: 4),
                      _documentLine(width: 18),
                    ],
                  ),
                ),

                // Small document icon
                const Positioned(
                  left: 7,
                  top: 6,
                  child: Icon(
                    Icons.description_outlined,
                    size: 12,
                    color: Color(0xFF8793A1),
                  ),
                ),
              ],
            ),
          ),

          // ---------------------------------------------------------------
          // LOCK CIRCLE
          // ---------------------------------------------------------------

          Positioned(
            right: 112,
            bottom: 10,

            child: Container(
              width: 24,
              height: 24,

              decoration: const BoxDecoration(
                color: Color(0xFFFFD2B7),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.lock_outline,
                size: 14,
                color: orange,
              ),
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
    return const SizedBox(
      width: double.infinity,

      child: Column(
        children: [
          Text(
            'Your trust is important to us.',
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 7.7,
              fontWeight: FontWeight.w600,
              color: darkBlue,
            ),
          ),

          SizedBox(height: 2),

          Text(
            'Please read our Terms & Conditions and Privacy Policy.',
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 6.5,
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
      height: 0.8,
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
                const Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'By using Chopdi, you agree to the following terms:',
                  style: TextStyle(
                    fontSize: 7.2,
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
                const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'We are committed to protecting your privacy:',
                  style: TextStyle(
                    fontSize: 7.2,
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
          const Padding(
            padding: EdgeInsets.only(
              top: 2,
              right: 4,
            ),

            child: Text(
              '•',
              style: TextStyle(
                fontSize: 7,
                color: darkBlue,
              ),
            ),
          ),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 7,
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
        height: 39,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          color: infoBackground,

          borderRadius:
              BorderRadius.circular(7),

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

            const SizedBox(width: 7),

            const Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'If you have any questions, feel free to contact us at',
                    style: TextStyle(
                      fontSize: 7.2,
                      color: textColor,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'support@chopdi.app',
                    style: TextStyle(
                      fontSize: 7.2,
                      color: orange,
                      fontWeight:
                          FontWeight.w500,
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
    return const SizedBox(
      width: double.infinity,

      child: Text(
        'Last Updated on 30 July 2026',
        textAlign: TextAlign.center,

        style: TextStyle(
          fontSize: 6.5,
          color: secondaryText,
        ),
      ),
    );
  }
}