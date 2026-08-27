import 'package:flutter/material.dart';
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
  static const Color darkBlue = Color(0xFF213F69);
  static const Color textColor = Color(0xFF263D5B);
  static const Color secondaryText = Color(0xFF66758A);
  static const Color borderColor = Color(0xFFB7C7DA);

  static const Color iconCircleColor = Color(0xFFF8D6D1);
  static const Color redColor = Color(0xFFE35B55);

  static const Color infoColor = Color(0xFFF2D0B2);
  static const Color infoBorder = Color(0xFFE4B58F);

  static const Color helpColor = Color(0xFFFFEEDB);
  static const Color helpBorder = Color(0xFFFFCFA7);

  static const Color securityColor = Color(0xFFD2D5D9);

  // ===========================================================================
  // STATE
  // ===========================================================================

  String _selectedReminder = 'dueDate';

  bool _paymentReminderEnabled = true;
  bool _dailyReminderEnabled = false;

  bool _saving = false;

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              27,
              39,
              27,
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =============================================================
                // HEADER
                // =============================================================

                _buildHeader(),

                const SizedBox(height: 14),

                // =============================================================
                // INFORMATION BOX
                // =============================================================

                _buildTopInformation(),

                const SizedBox(height: 15),

                // =============================================================
                // PAYMENT DUE REMINDER CARD
                // =============================================================

                _buildPaymentReminderCard(),

                const SizedBox(height: 11),

                // =============================================================
                // DAILY REMINDER
                // =============================================================

                _buildDailyReminderCard(),

                const SizedBox(height: 23),

                // =============================================================
                // SECURITY INFORMATION
                // =============================================================

                _buildSecurityBox(),

                const SizedBox(height: 14),

                // =============================================================
                // SAVE BUTTON
                // =============================================================

                _buildSaveButton(),
              ],
            ),
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
              'Notification Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkBlue,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Manage app notifications',
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
  // TOP INFORMATION
  // ===========================================================================

  Widget _buildTopInformation() {
    return Container(
      width: double.infinity,
      height: 37,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: infoColor,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: infoBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline,
              size: 14,
              color: redColor,
            ),
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose what you want to be notified about.',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'You can change these settings anytime.',
                  style: TextStyle(
                    fontSize: 7,
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
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 0.9,
        ),
      ),
      child: Column(
        children: [
          // -------------------------------------------------------------------
          // PAYMENT HEADER
          // -------------------------------------------------------------------

          SizedBox(
            height: 55,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                8,
                9,
                6,
              ),
              child: Row(
                children: [
                  _buildNotificationIcon(
                    Icons.notifications_none_rounded,
                  ),

                  const SizedBox(width: 9),

                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Due Reminders',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: darkBlue,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          'Get notified when a customer’s\n'
                          'payment due date is approaching.',
                          style: TextStyle(
                            fontSize: 7.8,
                            height: 1.15,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

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
          ),

          // -------------------------------------------------------------------
          // DIVIDER
          // -------------------------------------------------------------------

          Container(
            height: 0.7,
            color: borderColor,
          ),

          // -------------------------------------------------------------------
          // REMIND ME LABEL
          // -------------------------------------------------------------------

          const Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              9,
              12,
              5,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Remind Me',
                style: TextStyle(
                  fontSize: 8.5,
                  color: secondaryText,
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // RADIO OPTIONS
          // -------------------------------------------------------------------

          _buildReminderOption(
            value: 'dueDate',
            title: 'On the due date',
            subtitle: 'Notify me on the same day the payment is due.',
          ),

          _buildReminderOption(
            value: 'oneDayBefore',
            title: '1 day before',
            subtitle: 'Notify me 1 day before the due date.',
          ),

          _buildReminderOption(
            value: 'threeDaysBefore',
            title: '3 days before',
            subtitle: 'Notify me 3 days before the due date.',
          ),

          const SizedBox(height: 10),

          // -------------------------------------------------------------------
          // HOW IT WORKS
          // -------------------------------------------------------------------

          _buildHowItWorks(),

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
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeThumbColor: Colors.white,
          activeTrackColor: darkBlue,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFAABBD1),
          trackOutlineColor:
              WidgetStateProperty.all(Colors.transparent),
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
    final bool selected = _selectedReminder == value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 3,
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedReminder = value;
          });
        },
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: ChopdiColors.cream,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: borderColor,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              // ---------------------------------------------------------------
              // RADIO
              // ---------------------------------------------------------------

              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? darkBlue
                        : const Color(0xFFB7C5D5),
                    width: 0.9,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: darkBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 8),

              // ---------------------------------------------------------------
              // TEXT
              // ---------------------------------------------------------------

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 9.8,
                        fontWeight: FontWeight.w600,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 7,
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

  Widget _buildHowItWorks() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: helpColor,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: helpBorder,
            width: 0.8,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 1,
              ),
              child: Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: redColor,
              ),
            ),

            const SizedBox(width: 8),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works?',
                    style: TextStyle(
                      fontSize: 7.8,
                      fontWeight: FontWeight.w500,
                      color: redColor,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'You will receive a notification once a day for all upcoming due '
                    'payments.',
                    style: TextStyle(
                      fontSize: 6.6,
                      height: 1.15,
                      color: textColor,
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
  // DAILY REMINDER CARD
  // ===========================================================================

  Widget _buildDailyReminderCard() {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          _buildNotificationIcon(
            Icons.calendar_month_outlined,
          ),

          const SizedBox(width: 9),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Reminder',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'Get a daily reminder to review today’s\n'
                  'pending collections.',
                  style: TextStyle(
                    fontSize: 7.8,
                    height: 1.15,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),

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

  Widget _buildSecurityBox() {
    return Container(
      width: double.infinity,
      height: 37,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: securityColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              top: 1,
            ),
            child: Icon(
              Icons.verified_user_outlined,
              size: 13,
              color: darkBlue,
            ),
          ),

          const SizedBox(width: 7),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your data is safe with us.',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                  ),
                ),

                SizedBox(height: 1),

                Text(
                  'We never share your information with anyone.',
                  style: TextStyle(
                    fontSize: 6.5,
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
      height: 41,
      child: ElevatedButton(
        onPressed: _saving
            ? null
            : () async {
                setState(() {
                  _saving = true;
                });

                try {
                  widget.onSave?.call();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Notification settings saved',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _saving = false;
                    });
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlue,
          disabledBackgroundColor:
              darkBlue.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: _saving
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}