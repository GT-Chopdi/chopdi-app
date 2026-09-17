import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_colors.dart';

class PhoneCallService {
  PhoneCallService._();

  /// Opens the phone dialer after checking phone permission.
  ///
  /// Permission is requested only when it is actually needed.
  /// Once the user allows it, Android remembers the permission
  /// for the entire app, so it will work from Gave, Took Loan,
  /// and other screens without showing the permission again.
  static Future<void> makePhoneCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    final trimmedNumber = phoneNumber.trim();

    // ------------------------------------------------------------
    // PHONE NUMBER CHECK
    // ------------------------------------------------------------

    if (trimmedNumber.isEmpty) {
      if (!context.mounted) return;

      await _showPhoneUnavailableDialog(context);
      return;
    }

    // ------------------------------------------------------------
    // CHECK CURRENT PERMISSION
    // ------------------------------------------------------------

    PermissionStatus status = await Permission.phone.status;

    // ------------------------------------------------------------
    // ALREADY GRANTED
    // ------------------------------------------------------------

    if (status.isGranted) {
      await _openDialer(context, trimmedNumber);
      return;
    }

    // ------------------------------------------------------------
    // REQUEST PERMISSION
    // ------------------------------------------------------------

    if (status.isDenied) {
      status = await Permission.phone.request();

      // User allowed permission
      if (status.isGranted) {
        await _openDialer(context, trimmedNumber);
        return;
      }

      // User denied permission
      if (status.isDenied) {
        if (!context.mounted) return;

        await _showPermissionDeniedDialog(context);
        return;
      }
    }

    // ------------------------------------------------------------
    // PERMANENTLY DENIED
    // ------------------------------------------------------------

    if (status.isPermanentlyDenied ||
        status.isRestricted ||
        status.isLimited) {
      if (!context.mounted) return;

      final openSettings = await _showPermanentlyDeniedDialog(context);

      if (openSettings == true) {
        await openAppSettings();
      }

      return;
    }
  }

  // ============================================================
  // OPEN DIALER
  // ============================================================

  static Future<void> _openDialer(
    BuildContext context,
    String phoneNumber,
  ) async {
    final cleanedNumber = phoneNumber.replaceAll(
      RegExp(r'[\s\-()]'),
      '',
    );

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: cleanedNumber,
    );

    try {
      // Don't use canLaunchUrl() here.
      // It can return false on some Android devices even when
      // the dialer is actually available.
      final launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (!context.mounted) return;

        await _showUnableToOpenDialerDialog(context);
      }
    } catch (e) {
      debugPrint('Unable to open phone dialer: $e');

      if (!context.mounted) return;

      await _showUnableToOpenDialerDialog(context);
    }
  }

  // ============================================================
  // PHONE NUMBER NOT AVAILABLE
  // ============================================================

  static Future<void> _showPhoneUnavailableDialog(
    BuildContext context,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffFFF8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Phone Number Not Available',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ChopdiColors.navy,
            ),
          ),
          content: Text(
            'Phone number is not available for this customer.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'OK',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: ChopdiColors.navy,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PERMISSION DENIED
  // ============================================================

  static Future<void> _showPermissionDeniedDialog(
    BuildContext context,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffFFF8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Phone Permission Required',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ChopdiColors.navy,
            ),
          ),
          content: Text(
            'Phone permission is required to make a call.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'OK',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: ChopdiColors.navy,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PERMISSION PERMANENTLY DENIED
  // ============================================================

  static Future<bool?> _showPermanentlyDeniedDialog(
    BuildContext context,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffFFF8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Phone Permission Required',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ChopdiColors.navy,
            ),
          ),
          content: Text(
            'Phone permission has been denied. '
            'Please enable it from app settings to make a call.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                'Open Settings',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: ChopdiColors.navy,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // UNABLE TO OPEN DIALER
  // ============================================================

  static Future<void> _showUnableToOpenDialerDialog(
    BuildContext context,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffFFF8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Unable to Open Dialer',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ChopdiColors.navy,
            ),
          ),
          content: Text(
            'Unable to open the phone dialer on this device.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'OK',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: ChopdiColors.navy,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}