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

  static const Color backgroundColor =
      Color(0xFFFFEEDB);

  static const Color cardColor =
      Color(0xFFFFFAF3);

  static Color darkBlue =
      Color.fromRGBO(34, 58, 94, 1);

  static Color textColor =
      Color.fromRGBO(34, 58, 94, 1);

  static const Color secondaryText =
      Color(0xFF66758A);

  static Color borderColor =
      Color.fromRGBO(170, 185, 207, 1);

  static const Color iconCircleColor =
      Color(0xFFF8D6D1);

  static const Color redColor =
      Color(0xFFE35B55);

  static const Color infoColor =
      Color(0xFFF2D0B2);

  static const Color infoBorder =
      Color(0xFFE4B58F);

  static const Color helpColor =
      Color(0xFFFFEEDB);

  static const Color helpBorder =
      Color(0xFFFFCFA7);

  static const Color securityColor =
      Color(0xFFD2D5D9);

  // ===========================================================================
  // DEFAULT VALUES
  // ===========================================================================

  static const String defaultReminder =
      'dueDate';

  static const bool defaultPaymentReminder =
      true;

  static const bool defaultDailyReminder =
      false;

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

  String _selectedReminder =
      defaultReminder;

  bool _paymentReminderEnabled =
      defaultPaymentReminder;

  bool _dailyReminderEnabled =
      defaultDailyReminder;

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
  // LOAD SETTINGS
  // ===========================================================================

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final savedReminder =
          prefs.getString(
        _selectedReminderKey,
      );

      final savedPaymentReminder =
          prefs.getBool(
        _paymentReminderKey,
      );

      final savedDailyReminder =
          prefs.getBool(
        _dailyReminderKey,
      );

      if (!mounted) return;

      setState(() {
        _selectedReminder =
            _isValidReminder(
          savedReminder,
        )
                ? savedReminder!
                : defaultReminder;

        _paymentReminderEnabled =
            savedPaymentReminder ??
                defaultPaymentReminder;

        _dailyReminderEnabled =
            savedDailyReminder ??
                defaultDailyReminder;

        _loading = false;
      });
    } catch (e) {
      debugPrint(
        '[NotificationSettings] '
        'Failed to load settings: $e',
      );

      if (!mounted) return;

      setState(() {
        _selectedReminder =
            defaultReminder;

        _paymentReminderEnabled =
            defaultPaymentReminder;

        _dailyReminderEnabled =
            defaultDailyReminder;

        _loading = false;
      });
    }
  }

  // ===========================================================================
  // VALIDATE REMINDER
  // ===========================================================================

  bool _isValidReminder(
    String? value,
  ) {
    return value == 'dueDate' ||
        value == 'oneDayBefore' ||
        value == 'threeDaysBefore';
  }

  // ===========================================================================
  // SAVE SETTINGS
  // ===========================================================================

  // Future<void> _saveNotificationSettings() async {
  //   if (_saving) return;

  //   setState(() {
  //     _saving = true;
  //   });

  //   try {
  //     final prefs =
  //         await SharedPreferences.getInstance();

  //     await prefs.setBool(
  //       _paymentReminderKey,
  //       _paymentReminderEnabled,
  //     );

  //     await prefs.setBool(
  //       _dailyReminderKey,
  //       _dailyReminderEnabled,
  //     );

  //     await prefs.setString(
  //       _selectedReminderKey,
  //       _selectedReminder,
  //     );

  //     final localNotificationService = LocalNotificationService.instance;
  //     await localNotificationService.initialize();

  //     await localNotificationService.requestPermission();

  //     if (_dailyReminderEnabled) {
  //       await localNotificationService.scheduleDailyReminder();
  //     } else {
  //       await localNotificationService.cancelDailyReminder();
  //     }

  //     if (_paymentReminderEnabled) {
  //       // Payment schedules should be created here
  //       // using your actual customer/payment data.
  //     } else {
  //       await localNotificationService
  //           .cancelAllPaymentReminders();
  //     }

  //     // Keep your existing callback functionality.
  //     widget.onSave?.call();

  //     if (!mounted) return;

  //     await _showSuccess(
  //       'Notification settings saved successfully.',
  //     );

  //     if (!mounted) return;

  //     Navigator.of(context).pop(true);
  //   } catch (e) {
  //     debugPrint(
  //       '[NotificationSettings] '
  //       'Failed to save settings: $e',
  //     );

  //     if (!mounted) return;

  //     _showError(
  //       'Unable to save notification settings.',
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _saving = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _saveNotificationSettings() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      final prefs =
          await SharedPreferences.getInstance();

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
        await localNotificationService
            .scheduleDailyReminder();
      } else {
        await localNotificationService
            .cancelDailyReminder();
      }

      // ============================================================
      // PAYMENT REMINDERS
      // ============================================================

      if (_paymentReminderEnabled) {
        await localNotificationService
            .rescheduleAllPaymentReminders(
          database: IsarService.isar,
        );
      } else {
        await localNotificationService
            .cancelAllPaymentReminders(
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
        '[NotificationSettings] '
        'Failed to save settings: $e',
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
    final keyboardVisible =
        MediaQuery.of(context)
                .viewInsets
                .bottom >
            0;

    return Scaffold(
      backgroundColor:
          backgroundColor,

      resizeToAvoidBottomInset:
          true,

      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context)
                .unfocus();
          },

          child: _loading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : LayoutBuilder(
                  builder:
                      (
                    context,
                    constraints,
                  ) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior
                              .onDrag,

                      physics:
                          const BouncingScrollPhysics(),

                      // =======================================================
                      // SAME OUTER PADDING AS EDIT CHOPDI
                      // =======================================================

                      padding:
                          EdgeInsets.only(
                        left: 14,
                        right: 14,
                        top: 14,
                        bottom:
                            keyboardVisible
                                ? 30
                                : 14,
                      ),

                      child:
                          ConstrainedBox(
                        constraints:
                            BoxConstraints(
                          minHeight:
                              constraints
                                  .maxHeight -
                              28,
                        ),

                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            // =================================================
                            // HEADER
                            // =================================================

                            _buildHeader(),

                            const SizedBox(
                              height: 12,
                            ),

                            // =================================================
                            // INFORMATION
                            // =================================================

                            _buildTopInformation(),

                            const SizedBox(
                              height: 12,
                            ),

                            // =================================================
                            // PAYMENT REMINDER
                            // =================================================

                            _buildPaymentReminderCard(),

                            const SizedBox(
                              height: 12,
                            ),

                            // =================================================
                            // DAILY REMINDER
                            // =================================================

                            _buildDailyReminderCard(),

                            const SizedBox(
                              height: 24,
                            ),

                            // =================================================
                            // SECURITY
                            // =================================================

                            _buildSecurityBox(),

                            const SizedBox(
                              height: 20,
                            ),

                            // =================================================
                            // SAVE
                            // =================================================

                            _buildSaveButton(),

                            const SizedBox(
                              height: 14,
                            ),
                          ],
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

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,

      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },

          child: SizedBox(
            width: 24,
            height: 32,

            child: Center(
              child: Icon(
                Icons.arrow_back,
                size: 19,
                color: darkBlue,
              ),
            ),
          ),
        ),

        const SizedBox(
          width: 5,
        ),

        Column(
          mainAxisSize:
              MainAxisSize.min,

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              'Notification Settings',

              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: darkBlue,
              ),
            ),

            SizedBox(height: 1),

            Text(
              'Manage app notifications',

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
  // TOP INFORMATION
  // ===========================================================================

  Widget _buildTopInformation() {
    return Container(
      width: double.infinity,
      height: 51,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: infoColor,

        borderRadius:
            BorderRadius.circular(7),

        border: Border.all(
          color: Color.fromRGBO(177, 95, 39, 0.23),
          width: 1,
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [
          Padding(
            padding:
                EdgeInsets.only(top: 1),

            child: Image.asset('assets/info-outline.png'),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Choose what you want to be notified about.',

                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color: textColor,
                  ),
                ),

                SizedBox(height: 1),

                Text(
                  'You can change these settings anytime.',

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

  Widget _buildPaymentReminderCard() {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 248, 240, 1),

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color: Color.fromRGBO(170, 185, 207, 1),
          width: 1.0,
        ),
      ),

      child: Column(
        children: [
          // ===============================================================
          // PAYMENT HEADER
          // ===============================================================

          SizedBox(
            height: 78,

            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                14,
                10,
                14,
                10,
              ),

              child: Row(
                children: [
                  _buildNotificationIcon(
                    Icons.notifications_none_rounded,
                  ),

                  const SizedBox(
                    width: 9,
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Payment Due Reminders',

                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w700,
                            color: darkBlue,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          'Get notified when a customer’s\n'
                          'payment due date is approaching.',

                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            height: 1.15,
                            fontWeight: FontWeight.w400,
                            color:
                                secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildSwitch(
                    value:
                        _paymentReminderEnabled,

                    onChanged: (value) {
                      setState(() {
                        _paymentReminderEnabled =
                            value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          Container(
            height: 0.7,
            color: borderColor,
          ),

          // ===============================================================
          // REMIND ME
          // ===============================================================

          Padding(
            padding:
                EdgeInsets.fromLTRB(
              12,
              9,
              12,
              5,
            ),

            child: Align(
              alignment:
                  Alignment.centerLeft,

              child: Text(
                'Remind Me',

                style: GoogleFonts.manrope(
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
          ),

          _buildReminderOption(
            value: 'oneDayBefore',
            title: '1 day before',
            subtitle:
                'Notify me 1 day before the due date.',
          ),

          _buildReminderOption(
            value: 'threeDaysBefore',
            title: '3 days before',
            subtitle:
                'Notify me 3 days before the due date.',
          ),

          const SizedBox(
            height: 10,
          ),

          _buildHowItWorks(),

          const SizedBox(
            height: 9,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // NOTIFICATION ICON
  // ===========================================================================

  Widget _buildNotificationIcon(
    IconData icon,
  ) {
    return Container(
      width: 34,
      height: 34,

      decoration:
          const BoxDecoration(
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
    required ValueChanged<bool>
        onChanged,
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
              MaterialTapTargetSize
                  .shrinkWrap,

          activeThumbColor:
              Colors.white,

          activeTrackColor:
              darkBlue,

          inactiveThumbColor:
              Colors.white,

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
  }) {
    final bool selected =
        _selectedReminder == value;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 3,
      ),

      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedReminder =
                value;
          });
        },

        child: Container(
          height: 54,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
          ),

          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 248, 240, 1),

            borderRadius:
                BorderRadius.circular(10),

            border: Border.all(
              color: Color.fromRGBO(170, 185, 207, 1),
              width: 1.0,
            ),
          ),

          child: Row(
            children: [
              // =============================================================
              // RADIO
              // =============================================================

              Container(
                width: 26,
                height: 26,

                decoration:
                    BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: selected
                        ? darkBlue
                        : const Color.fromRGBO(170, 185, 207, 1),
                    width: 0.9,
                  ),
                ),

                child: selected
                    ? Center(
                        child:
                            Container(
                          width: 10,
                          height: 10,

                          decoration:
                            BoxDecoration(
                            color:
                                darkBlue,
                            shape:
                                BoxShape
                                    .circle,
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(
                width: 8,
              ),

              // =============================================================
              // TEXT
              // =============================================================

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      title,

                      style:
                        GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                        color: darkBlue,
                      ),
                    ),

                    const SizedBox(
                      height: 1,
                    ),

                    Text(
                      subtitle,

                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,

                      style:
                          GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            secondaryText,
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

  Widget _buildHowItWorks() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),

      child: Container(
        width: double.infinity,
        height: 66,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          color: Color.fromRGBO(253, 237, 217, 1),

          borderRadius:
              BorderRadius.circular(10),

          border: Border.all(
            color: helpBorder,
            width: 1.0,
          ),
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: 1),

              child: Image.asset('assets/bulb.png')
            ),

            const SizedBox(
              width: 8,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'How it works?',

                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                      color: Color.fromRGBO(199, 76, 76, 1),
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'You will receive a notification once a day for all upcoming due payments.',

                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      height: 1.15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(34, 58, 94, 1),
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

  Widget _buildDailyReminderCard() {
    return Container(
      width: double.infinity,
      height: 78,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 248, 240, 1),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Color.fromRGBO(170, 185, 207, 1),
          width: 1.0,
        ),
      ),

      child: Row(
        children: [
          _buildNotificationIcon(
            Icons.calendar_month_outlined,
          ),

          const SizedBox(
            width: 9,
          ),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Daily Reminder',

                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color: darkBlue,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'Get a daily reminder to review today’s\n'
                  'pending collections.',

                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    height: 1.15,
                    fontWeight: FontWeight.w400,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),

          _buildSwitch(
            value:
                _dailyReminderEnabled,

            onChanged: (value) {
              setState(() {
                _dailyReminderEnabled =
                    value;
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

  Widget _buildSecurityBox() {
    return Container(
      width: double.infinity,
      height: 51,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: Color.fromRGBO(170, 185, 207, 0.6),

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: Color.fromRGBO(170, 185, 207, 1),
          width: 1.0,
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Padding(
            padding:
                EdgeInsets.only(top: 1),

            child: SizedBox(
              height: 24,
              width: 24,
              child: Image.asset('assets/shield-lock-outline.png')
            ),
          ),

          const SizedBox(
            width: 7,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Your data is safe with us.',

                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                    color: darkBlue,
                  ),
                ),

                SizedBox(height: 1),

                Text(
                  'We never share your information with anyone.',

                  style: GoogleFonts.manrope(
                    fontSize: 10,
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,

      child: ElevatedButton(
        onPressed:
            _saving
                ? null
                : _saveNotificationSettings,

        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              darkBlue,

          disabledBackgroundColor:
              darkBlue.withValues(
            alpha: 0.6,
          ),

          foregroundColor:
              Colors.white,

          elevation: 0,

          padding: EdgeInsets.zero,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10),
          ),
        ),

        child: _saving
            ? SizedBox(
                width: 17,
                height: 17,

                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ChopdiColors.cream,
                ),
              )
            : Text(
                'Save Changes',

                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
      ),
    );
  }
}