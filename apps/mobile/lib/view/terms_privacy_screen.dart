import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({
    super.key,
    this.onContactSupport,
  });

  final VoidCallback? onContactSupport;

  static const Color backgroundColor = Color(0xFFFDEDD9);
  static const Color darkBlue = Color(0xFF223A5E);
  static const Color textColor = Color(0xFF223A5E);
  static const Color secondaryText =
  Color.fromRGBO(34, 58, 94, 0.62);
  static const Color borderColor = Color(0xFFAAB9CF);

  static const Color iconCircleColor = Color(0xFFFFDCC7);
  static const Color orange = Color(0xFFC74C4C);

  static const Color infoBackground = Color(0xFFFEE0C9);
  static const Color infoBorder =
  Color.fromRGBO(177, 95, 39, 0.23);

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
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    bottom: keyboardVisible ? 30 : 14,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),

                      const SizedBox(height: 18),

                      _buildDocumentIllustration(),

                      const SizedBox(height: 18),

                      _buildTrustText(context),

                      const SizedBox(height: 18),

                      _buildDivider(),

                      _buildTermsSection(context),

                      const SizedBox(height: 8),

                      _buildDivider(),

                      _buildPrivacySection(context),

                      const SizedBox(height: 11),

                      _buildDivider(),

                      const SizedBox(height: 38),
                    ],
                  ),
                ),
              ),

              _buildContactBox(context),

              _buildLastUpdated(context),

              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
              Icons.arrow_back_ios_new,
              size: 19,
              color: darkBlue,
            ),
          ),
        ),
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              l10n.termsPrivacy,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.readOurPolicies,
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

  Widget _buildDocumentIllustration() {
    return SizedBox(
      width: double.infinity,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 107.43,
            height: 107.43,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(34, 58, 94, 0.62),
              shape: BoxShape.circle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              height: 64,
              width: 90,
              child: Image.asset(
                'assets/terms_and_privacy.png',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustText(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(
            l10n.yourTrustIsImportant,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.pleaseReadTermsAndPrivacy,
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

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1.0,
      color: borderColor,
    );
  }

  Widget _buildTermsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                  l10n.loginTermsOfService,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.termsAgreementIntro,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                _buildBullet(
                  l10n.termsBulletLedger,
                ),
                _buildBullet(
                  l10n.termsBulletAccuracy,
                ),
                _buildBullet(
                  l10n.termsBulletAsIs,
                ),
                _buildBullet(
                  l10n.termsBulletLiability,
                ),
                _buildBullet(
                  l10n.termsBulletUpdates,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                  l10n.loginPrivacyPolicy,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.privacyIntro,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                _buildBullet(
                  l10n.privacyBulletDataCollection,
                ),
                _buildBullet(
                  l10n.privacyBulletSecureData,
                ),
                _buildBullet(
                  l10n.privacyBulletNoSelling,
                ),
                _buildBullet(
                  l10n.privacyBulletDataControl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
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

  Widget _buildContactBox(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        onContactSupport?.call();
      },
      child: Container(
        width: double.infinity,
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
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.questionsContactUs,
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
                  const SizedBox(height: 2),
                  const Text(
                    'chopdi@geloratech.com',
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: orange,
                      fontWeight: FontWeight.w700,
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

  Widget _buildLastUpdated(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final locale =
    Localizations.localeOf(context).toLanguageTag();

    final formattedDate = DateFormat(
      'dd MMMM yyyy',
      locale,
    ).format(DateTime.now());

    return SizedBox(
      width: double.infinity,
      child: Text(
        '${l10n.lastUpdatedOn} $formattedDate',
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