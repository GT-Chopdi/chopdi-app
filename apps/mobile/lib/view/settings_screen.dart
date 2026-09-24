import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import 'notifications_setting_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color backgroundColor = Color(0xFFFFEEDB);
  static const Color darkBlue = Color(0xFF223A5E);
  static const Color lightBlue = Color(0xFFDCE6F2);

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: backgroundColor,

      // -----------------------------------------------------------------------
      // APP BAR
      // -----------------------------------------------------------------------
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          // 'Settings',
          // Later you can replace with:
          l10n.settings,

          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkBlue,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // BODY
      // -----------------------------------------------------------------------
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===============================================================
              // SETTINGS OPTIONS
              // ===============================================================

              _buildMenuCard(
                icon: Icons.notifications_none_rounded,
                title: l10n.notificationsSettings,
                subtitle: l10n.manageAppNotifications,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildMenuCard(
                icon: Icons.language_rounded,
                title: l10n.language,
                subtitle: _getCurrentLanguageName(),
                onTap: _showLanguageSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // MENU CARD
  // ===========================================================================

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,
        height: 64,

        decoration: BoxDecoration(
          color: const Color(0xFFFDEDD9),
          borderRadius: BorderRadius.circular(10),

          border: Border.all(color: const Color(0xFFAAC0D8), width: 0.9),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 10),

            // ---------------------------------------------------------------
            // ICON
            // ---------------------------------------------------------------
            Container(
              width: 34,
              height: 34,

              decoration: const BoxDecoration(
                color: Color(0x99AAB9CF),
                shape: BoxShape.circle,
              ),

              child: Icon(icon, size: 19, color: const Color(0xFF3D5F8B)),
            ),

            const SizedBox(width: 11),

            // ---------------------------------------------------------------
            // TITLE + SUBTITLE
            // ---------------------------------------------------------------
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: darkBlue,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: GoogleFonts.manrope(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF58687A),
                    ),
                  ),
                ],
              ),
            ),

            // ---------------------------------------------------------------
            // ARROW
            // ---------------------------------------------------------------
            const Icon(Icons.chevron_right_rounded, size: 22, color: darkBlue),

            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // CURRENT LANGUAGE
  // ===========================================================================

  String _getCurrentLanguageName() {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'hi':
        return 'हिन्दी';

      case 'en':
      default:
        return 'English';
    }
  }

  // ===========================================================================
  // LANGUAGE SHEET
  // ===========================================================================

  Future<void> _showLanguageSheet() async {
    final currentLocale = Localizations.localeOf(context);

    // Capture app state before async gap.
    final appState = ChopdiApp.of(context);

    final selectedLocale = await showModalBottomSheet<Locale>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,

      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),

          decoration: const BoxDecoration(
            color: Color(0xFFFFF8F0),

            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =============================================================
              // SHEET HEADER
              // =============================================================

              Row(
                children: [
                  const Icon(Icons.language_rounded, color: darkBlue, size: 25),

                  const SizedBox(width: 10),

                  Text(
                    AppLocalizations.of(sheetContext).language,

                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: darkBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =============================================================
              // ENGLISH
              // =============================================================
              _buildLanguageOption(
                context: sheetContext,
                locale: const Locale('en'),
                title: 'English',
                subtitle: 'English',
                currentLocale: currentLocale,
              ),

              const SizedBox(height: 10),

              // =============================================================
              // HINDI
              // =============================================================
              _buildLanguageOption(
                context: sheetContext,
                locale: const Locale('hi'),
                title: 'हिन्दी',
                subtitle: 'Hindi',
                currentLocale: currentLocale,
              ),
            ],
          ),
        );
      },
    );

    // -----------------------------------------------------------------------
    // APPLY LANGUAGE
    // -----------------------------------------------------------------------

    if (!mounted || selectedLocale == null) {
      return;
    }

    await appState?.changeLanguage(selectedLocale);
  }

  // ===========================================================================
  // LANGUAGE OPTION
  // ===========================================================================

  Widget _buildLanguageOption({
    required BuildContext context,
    required Locale locale,
    required String title,
    required String subtitle,
    required Locale currentLocale,
  }) {
    final isSelected = currentLocale.languageCode == locale.languageCode;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context, locale);
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

        decoration: BoxDecoration(
          color: isSelected ? lightBlue : backgroundColor,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: isSelected ? darkBlue : const Color(0xFFAAC0D8),

            width: isSelected ? 1.2 : 1,
          ),
        ),

        child: Row(
          children: [
            // ---------------------------------------------------------------
            // RADIO
            // ---------------------------------------------------------------

            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,

              color: darkBlue,
            ),

            const SizedBox(width: 12),

            // ---------------------------------------------------------------
            // LANGUAGE NAME
            // ---------------------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,

                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: darkBlue,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,

                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF58687A),
                    ),
                  ),
                ],
              ),
            ),

            // ---------------------------------------------------------------
            // CHECK
            // ---------------------------------------------------------------
            if (isSelected)
              const Icon(Icons.check_rounded, color: darkBlue, size: 20),
          ],
        ),
      ),
    );
  }
}
