import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mychopdi/utils/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({
    super.key,
    this.onSave,
  });

  final VoidCallback? onSave;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color backgroundColor = Color(0xFFFFEEDB);
  static const Color cardColor = Color(0xFFFFFAF3);

  static const Color darkBlue = Color.fromRGBO(34, 58, 94, 1);
  static const Color textColor = Color.fromRGBO(34, 58, 94, 1);
  static const Color secondaryText = Color(0xFF66758A);
  static const Color borderColor = Color.fromRGBO(170, 185, 207, 1);

  static const Color iconCircleColor = Color(0xFFF8D6D1);
  static const Color redColor = Color(0xFFE35B55);

  static const Color infoColor = Color(0xFFF2D0B2);
  static const Color infoBorder = Color(0xFFE4B58F);

  static const Color helpColor = Color(0xFFFFEEDB);
  static const Color helpBorder = Color(0xFFFFCFA7);

  static const Color securityColor = Color(0xFFD2D5D9);

  // ===========================================================================
  // DEFAULT VALUES
  // ===========================================================================

  static const String defaultReminder = 'dueDate';

  static const bool defaultPaymentReminder = true;
  static const bool defaultDailyReminder = false;

  // ===========================================================================
  // SHARED PREFERENCES KEYS
  // ===========================================================================

  static const String _paymentReminderKey =
      'notification_payment_reminder_enabled';

  static const String _dailyReminderKey =
      'notification_daily_reminder_enabled';

  static const String _selectedReminderKey =
      'notification_selected_reminder';

  // ===========================================================================
  // STATE
  // ===========================================================================

  String _selectedReminder = defaultReminder;

  bool _paymentReminderEnabled = defaultPaymentReminder;
  bool _dailyReminderEnabled = defaultDailyReminder;

  bool _loading = true;
  bool _saving = false;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  // ===========================================================================
  // RESPONSIVE HELPERS
  // ===========================================================================

  double _horizontalPadding(double width) {
    if (width >= 1200) {
      return 32;
    }

    if (width >= 700) {
      return 24;
    }

    if (width >= 400) {
      return 16;
    }

    return 14;
  }

  double _contentMaxWidth(double width) {
    if (width >= 1000) {
      return 720;
    }

    if (width >= 700) {
      return 680;
    }

    return double.infinity;
  }

  double _titleFontSize(double width) {
    if (width < 360) {
      return 18;
    }

    if (width < 600) {
      return 20;
    }

    return 21;
  }

  double _sectionTitleFontSize(double width) {
    if (width < 360) {
      return 15;
    }

    return 16;
  }

  double _descriptionFontSize(double width) {
    if (width < 360) {
      return 12;
    }

    return 14;
  }

  double _optionTitleFontSize(double width) {
    if (width < 360) {
      return 14;
    }

    return 16;
  }

  double _optionSubtitleFontSize(double width) {
    if (width < 360) {
      return 11;
    }

    return 12;
  }

  // ===========================================================================
  // LOAD SETTINGS
  // ===========================================================================

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedReminder = prefs.getString(
        _selectedReminderKey,
      );

      final savedPaymentReminder = prefs.getBool(
        _paymentReminderKey,
      );

      final savedDailyReminder = prefs.getBool(
        _dailyReminderKey,
      );

      if (!mounted) return;

      setState(() {
        _selectedReminder = _isValidReminder(savedReminder)
            ? savedReminder!
            : defaultReminder;

        _paymentReminderEnabled =
            savedPaymentReminder ?? defaultPaymentReminder;

        _dailyReminderEnabled =
            savedDailyReminder ?? defaultDailyReminder;

        _loading = false;
      });
    } catch (e) {
      debugPrint(
        '[NotificationSettings] Failed to load settings: $e',
      );

      if (!mounted) return;

      setState(() {
        _selectedReminder = defaultReminder;
        _paymentReminderEnabled = defaultPaymentReminder;
        _dailyReminderEnabled = defaultDailyReminder;
        _loading = false;
      });
    }
  }

  // ===========================================================================
  // VALIDATE REMINDER
  // ===========================================================================

  bool _isValidReminder(String? value) {
    return value == 'dueDate' ||
        value == 'oneDayBefore' ||
        value == 'threeDaysBefore';
  }

  // ===========================================================================
  // SAVE SETTINGS
  // ===========================================================================

  Future<void> _saveNotificationSettings() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // ============================================================
      // SAVE SETTINGS
      // ============================================================

      await prefs.setBool(
        _paymentReminderKey,
        _paymentReminderEnabled,
      );

      await prefs.setBool(
        _dailyReminderKey,
        _dailyReminderEnabled,
      );

      await prefs.setString(
        _selectedReminderKey,
        _selectedReminder,
      );

      // ============================================================
      // LOCAL NOTIFICATIONS
      // ============================================================

      final localNotificationService =
          LocalNotificationService.instance;

      await localNotificationService.initialize();

      await localNotificationService.requestPermission();

      // ============================================================
      // DAILY REMINDER
      // ============================================================

      if (_dailyReminderEnabled) {
        await localNotificationService.scheduleDailyReminder();
      } else {
        await localNotificationService.cancelDailyReminder();
      }

      // ============================================================
      // PAYMENT REMINDERS
      // ============================================================

      if (_paymentReminderEnabled) {
        await localNotificationService.rescheduleAllPaymentReminders(
          database: IsarService.isar,
        );
      } else {
        await localNotificationService.cancelAllPaymentReminders(
          database: IsarService.isar,
        );
      }

      // ============================================================
      // EXISTING CALLBACK
      // ============================================================

      widget.onSave?.call();

      if (!mounted) return;

      await _showSuccess(
        'Notification settings saved successfully.',
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint(
        '[NotificationSettings] Failed to save settings: $e',
      );

      if (!mounted) return;

      await _showError(
        'Unable to save notification settings.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  Future<void> _showError(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Error',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkBlue,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'OK',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: darkBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // SUCCESS
  // ===========================================================================

  Future<void> _showSuccess(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Success',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkBlue,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'OK',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: darkBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final screenWidth = mediaQuery.size.width;
    final keyboardVisible = mediaQuery.viewInsets.bottom > 0;

    final horizontalPadding = _horizontalPadding(screenWidth);
    final maxWidth = _contentMaxWidth(screenWidth);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        14,
                        horizontalPadding,
                        keyboardVisible ? 30 : 18,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxWidth,
                            minHeight: constraints.maxHeight - 32,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(screenWidth),

                              const SizedBox(height: 12),

                              _buildTopInformation(screenWidth),

                              const SizedBox(height: 12),

                              _buildPaymentReminderCard(
                                screenWidth,
                              ),

                              const SizedBox(height: 12),

                              _buildDailyReminderCard(
                                screenWidth,
                              ),

                              const SizedBox(height: 24),

                              _buildSecurityBox(screenWidth),

                              const SizedBox(height: 20),

                              _buildSaveButton(screenWidth),

                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader(double screenWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const SizedBox(
            width: 32,
            height: 40,
            child: Center(
              child: Icon(
                Icons.arrow_back,
                size: 19,
                color: darkBlue,
              ),
            ),
          ),
        ),

        const SizedBox(width: 4),

        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification Settings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: _titleFontSize(screenWidth),
                  fontWeight: FontWeight.w700,
                  color: darkBlue,
                ),
              ),

              const SizedBox(height: 1),

              Text(
                'Manage app notifications',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TOP INFORMATION
  // ===========================================================================

  Widget _buildTopInformation(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: infoColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: infoBorder.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Image.asset(
              'assets/info-outline.png',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose what you want to be notified about.',
                  softWrap: true,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'You can change these settings anytime.',
                  softWrap: true,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PAYMENT REMINDER CARD
  // ===========================================================================

  Widget _buildPaymentReminderCard(double screenWidth) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 248, 240, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // ===============================================================
          // PAYMENT HEADER
          // ===============================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              14,
              12,
              12,
              12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNotificationIcon(
                  Icons.notifications_none_rounded,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Due Reminders',
                          softWrap: true,
                          style: GoogleFonts.manrope(
                            fontSize:
                                _sectionTitleFontSize(screenWidth),
                            fontWeight: FontWeight.w700,
                            color: darkBlue,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'Get notified when a customer’s payment due date is approaching.',
                          softWrap: true,
                          style: GoogleFonts.manrope(
                            fontSize:
                                _descriptionFontSize(screenWidth),
                            height: 1.2,
                            fontWeight: FontWeight.w400,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                _buildSwitch(
                  value: _paymentReminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      _paymentReminderEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),

          Container(
            height: 0.7,
            color: borderColor,
          ),

          // ===============================================================
          // REMIND ME
          // ===============================================================

          const Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              10,
              12,
              5,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Remind Me',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: secondaryText,
                ),
              ),
            ),
          ),

          // ===============================================================
          // OPTIONS
          // ===============================================================

          _buildReminderOption(
            value: 'dueDate',
            title: 'On the due date',
            subtitle:
                'Notify me on the same day the payment is due.',
            screenWidth: screenWidth,
          ),

          _buildReminderOption(
            value: 'oneDayBefore',
            title: '1 day before',
            subtitle:
                'Notify me 1 day before the due date.',
            screenWidth: screenWidth,
          ),

          _buildReminderOption(
            value: 'threeDaysBefore',
            title: '3 days before',
            subtitle:
                'Notify me 3 days before the due date.',
            screenWidth: screenWidth,
          ),

          const SizedBox(height: 10),

          _buildHowItWorks(screenWidth),

          const SizedBox(height: 9),
        ],
      ),
    );
  }

  // ===========================================================================
  // NOTIFICATION ICON
  // ===========================================================================

  Widget _buildNotificationIcon(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: iconCircleColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 19,
        color: redColor,
      ),
    );
  }

  // ===========================================================================
  // SWITCH
  // ===========================================================================

  Widget _buildSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      width: 38,
      height: 22,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize:
              MaterialTapTargetSize.shrinkWrap,
          activeThumbColor: Colors.white,
          activeTrackColor: darkBlue,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor:
              const Color(0xFFAABBD1),
          trackOutlineColor:
              WidgetStateProperty.all(
            Colors.transparent,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // REMINDER OPTION
  // ===========================================================================

  Widget _buildReminderOption({
    required String value,
    required String title,
    required String subtitle,
    required double screenWidth,
  }) {
    final bool selected = _selectedReminder == value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 3,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedReminder = value;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 248, 240, 1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // =============================================================
              // RADIO
              // =============================================================

              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? darkBlue
                        : borderColor,
                    width: 0.9,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration:
                              const BoxDecoration(
                            color: darkBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 8),

              // =============================================================
              // TEXT
              // =============================================================

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      softWrap: true,
                      style: GoogleFonts.manrope(
                        fontSize:
                            _optionTitleFontSize(
                          screenWidth,
                        ),
                        fontWeight: FontWeight.w700,
                        color: darkBlue,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize:
                            _optionSubtitleFontSize(
                          screenWidth,
                        ),
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HOW IT WORKS
  // ===========================================================================

  Widget _buildHowItWorks(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(253, 237, 217, 1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: helpBorder,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Image.asset(
                'assets/bulb.png',
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works?',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color:
                          const Color.fromRGBO(
                        199,
                        76,
                        76,
                        1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'You will receive a notification once a day for all upcoming due payments.',
                    softWrap: true,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: darkBlue,
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
  // DAILY REMINDER
  // ===========================================================================

  Widget _buildDailyReminderCard(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 248, 240, 1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNotificationIcon(
            Icons.calendar_month_outlined,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Reminder',
                    softWrap: true,
                    style: GoogleFonts.manrope(
                      fontSize:
                          _sectionTitleFontSize(
                        screenWidth,
                      ),
                      fontWeight: FontWeight.w700,
                      color: darkBlue,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Get a daily reminder to review today’s pending collections.',
                    softWrap: true,
                    style: GoogleFonts.manrope(
                      fontSize:
                          _descriptionFontSize(
                        screenWidth,
                      ),
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 4),

          _buildSwitch(
            value: _dailyReminderEnabled,
            onChanged: (value) {
              setState(() {
                _dailyReminderEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECURITY BOX
  // ===========================================================================

  Widget _buildSecurityBox(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(
          170,
          185,
          207,
          0.6,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: SizedBox(
              height: 24,
              width: 24,
              child: Image.asset(
                'assets/shield-lock-outline.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Your data is safe with us.',
                  softWrap: true,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: darkBlue,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  'We never share your information with anyone.',
                  softWrap: true,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SAVE BUTTON
  // ===========================================================================

  Widget _buildSaveButton(double screenWidth) {
    final double buttonHeight = screenWidth < 360 ? 52 : 56;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed:
            _saving ? null : _saveNotificationSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlue,
          disabledBackgroundColor:
              darkBlue.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _saving
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ChopdiColors.cream,
                ),
              )
            : Text(
                'Save Changes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: screenWidth < 360 ? 18 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}