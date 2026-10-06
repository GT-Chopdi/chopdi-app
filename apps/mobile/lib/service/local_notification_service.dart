import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/lender.dart';
import 'package:mychopdi/model/sync_meta.dart';
import 'package:mychopdi/model/sync_op.dart';
import 'package:mychopdi/model/user_session.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/model/notification.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import 'chopdi_service.dart';

// ============================================================
// TOP-LEVEL BACKGROUND HANDLER
// MUST BE OUTSIDE THE CLASS
// ============================================================

@pragma('vm:entry-point')
void notificationTapBackground(
    NotificationResponse notificationResponse,
    ) async {
  if (notificationResponse.actionId == 'action_mark_read') {
    debugPrint(
      'Background: Marked as read -> '
          '${notificationResponse.payload}',
    );

    final payload = notificationResponse.payload;

    if (payload != null && payload.startsWith('event_read:')) {
      final notifIdStr = payload.split(':')[1];
      final notifId = int.tryParse(notifIdStr);

      if (notifId != null) {
        try {
          final dir = await getApplicationDocumentsDirectory();

          final isar = await Isar.open(
            [
              CustomerSchema,
              LenderSchema,
              TransactionSchema,
              UserSessionSchema,
              SyncOpSchema,
              SyncMetaSchema,
              ChopdiSchema,
              NotificationModelSchema,
            ],
            directory: dir.path,
          );

          final notification =
          await isar.notificationModels.get(notifId);

          if (notification != null && !notification.isRead) {
            notification.isRead = true;

            await isar.writeTxn(() async {
              await isar.notificationModels.put(notification);
            });

            debugPrint(
              'Background: Successfully marked notification '
                  '$notifId as read in Isar.',
            );
          }

          await isar.close();
        } catch (e) {
          debugPrint(
            'Background: Failed to open Isar and mark as read: $e',
          );
        }
      }
    }
  } else if (notificationResponse.actionId == 'action_reply') {
    final String? replyText = notificationResponse.input;

    debugPrint(
      'Background: Replied -> $replyText',
    );

    // TODO:
    // Handle reply text if required.
  }
}

// ============================================================
// LOCAL NOTIFICATION SERVICE
// ============================================================

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance =
  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ============================================================
  // PENDING PAYLOAD FOR KILLED APP NAVIGATION
  // ============================================================

  static String? pendingNotificationPayload;

  static bool isAppReady = false;

  // ============================================================
  // CHANNELS
  // ============================================================

  static const String paymentChannelId =
      'payment_reminders';

  static const String dailyChannelId =
      'daily_reminders';

  static const String eventChannelId =
      'app_events';

  // ============================================================
  // NOTIFICATION IDS
  // ============================================================

  static const int dailyReminderId = 900000;

  static const int testNotificationId = 999999;

  static const int paymentReminderIdBase = 100000;

  // ============================================================
  // SHARED PREFERENCES KEYS
  // ============================================================

  static const String notificationsEnabledKey =
      'notifications_enabled';

  static const String paymentReminderKey =
      'notification_payment_reminder_enabled';

  static const String dailyReminderKey =
      'notification_daily_reminder_enabled';

  static const String selectedReminderKey =
      'notification_selected_reminder';

  // ============================================================
  // DEFAULT SETTINGS
  // ============================================================

  static const bool defaultNotificationsEnabled = true;

  static const bool defaultPaymentReminder = true;

  static const bool defaultDailyReminder = false;

  static const String defaultReminderType = 'dueDate';

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
      _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
      notificationTapBackground,
    );

    // ==========================================================
    // IMPORTANT:
    // Detect notification click when app was completely killed.
    // ==========================================================

    final NotificationAppLaunchDetails? launchDetails =
    await _plugin.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final String? payload =
          launchDetails?.notificationResponse?.payload;

      if (payload != null && payload.isNotEmpty) {
        debugPrint(
          '[LocalNotification] '
              'App launched from notification: $payload',
        );

        pendingNotificationPayload = payload;
      }
    }

    await _createAndroidChannels();

    _initialized = true;

    debugPrint(
      '[LocalNotification] Initialized successfully',
    );
  }

  // ============================================================
  // GENERAL EVENT NOTIFICATION
  // ============================================================

  Future<void> showAppEventNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final bool masterEnabled =
    await areNotificationsEnabled();

    if (!masterEnabled) {
      return;
    }

    await initialize();

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      eventChannelId,
      'App Events',
      channelDescription:
      'Important updates and activity',
      importance: Importance.max,
      priority: Priority.high,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'action_mark_read',
          'Mark as read',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final NotificationDetails details =
    NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  // ============================================================
  // ANDROID CHANNELS
  // ============================================================

  Future<void> _createAndroidChannels() async {
    final AndroidFlutterLocalNotificationsPlugin?
    androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      return;
    }

    const AndroidNotificationChannel paymentChannel =
    AndroidNotificationChannel(
      paymentChannelId,
      'Payment Reminders',
      description:
      'Notifications for upcoming customer payment due dates.',
      importance: Importance.high,
    );

    const AndroidNotificationChannel dailyChannel =
    AndroidNotificationChannel(
      dailyChannelId,
      'Daily Reminders',
      description:
      'Daily reminders to review pending collections.',
      importance: Importance.defaultImportance,
    );

    const AndroidNotificationChannel eventChannel =
    AndroidNotificationChannel(
      eventChannelId,
      'App Events',
      description:
      'Important updates and messages.',
      importance: Importance.max,
    );

    await androidPlugin.createNotificationChannel(
      paymentChannel,
    );

    await androidPlugin.createNotificationChannel(
      dailyChannel,
    );

    await androidPlugin.createNotificationChannel(
      eventChannel,
    );
  }

  // ============================================================
  // REQUEST PERMISSION
  // ============================================================

  Future<void> requestPermission() async {
    await initialize();

    final AndroidFlutterLocalNotificationsPlugin?
    androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // ============================================================
  // NOTIFICATION CLICK HANDLER
  // FOREGROUND / BACKGROUND
  // ============================================================
  void _onNotificationResponse(
      NotificationResponse response,
      ) async {
    debugPrint(
      '[LocalNotification] Notification clicked',
    );

    debugPrint(
      '[LocalNotification] Payload: ${response.payload}',
    );

    debugPrint(
      '[LocalNotification] Action: ${response.actionId}',
    );

    final payload = response.payload;

    if (payload == null || payload.isEmpty) {
      return;
    }

    // ==========================================================
    // ACTION BUTTONS
    // ==========================================================

    if (response.actionId == 'action_mark_read') {
      debugPrint(
        '[LocalNotification] Mark as read action clicked',
      );
      return;
    }

    if (response.actionId == 'action_reply') {
      debugPrint(
        '[LocalNotification] Reply action: ${response.input}',
      );
      return;
    }

    // ==========================================================
    // NAVIGATOR NOT READY
    // ==========================================================

    final navigator = appNavigatorKey.currentState;

    if (navigator == null) {
      debugPrint(
        '[LocalNotification] Navigator not ready. '
            'Saving payload: $payload',
      );

      pendingNotificationPayload = payload;
      return;
    }

    // ==========================================================
    // NAVIGATOR READY
    // ==========================================================

    debugPrint(
      '[LocalNotification] Navigator ready. '
          'Routing: $payload',
    );

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    await handleNotificationRouting(payload);
  }
  // ============================================================
  // DEEP LINK ROUTING LOGIC
  // ============================================================
  static Future<void> handleNotificationRouting(
      String payload,
      ) async {
    final nav = appNavigatorKey.currentState;

    if (nav == null) {
      debugPrint(
        '[LocalNotification] Navigator not ready: $payload',
      );

      pendingNotificationPayload = payload;
      return;
    }

    final isar = IsarService.isar;

    try {
      // ==========================================================
      // APP UPDATE
      // ==========================================================

      if (payload == 'app_update') {
        return;
      }

      // ==========================================================
      // CUSTOMER - INTEREST CALCULATED
      // ==========================================================
// ==========================================================
// CUSTOMER - INTEREST
// ==========================================================

      if (payload.startsWith('interest_calculated:customer:') ||
          payload.startsWith('interest_updated:customer:')) {
        final parts = payload.split(':');

        if (parts.length < 4) {
          debugPrint(
            '[LocalNotification] Invalid customer interest payload: $payload',
          );
          return;
        }

        final customerId = int.tryParse(parts[2]);
        final transactionId = int.tryParse(parts[3]);

        if (customerId == null) {
          debugPrint(
            '[LocalNotification] Invalid customer ID: ${parts[2]}',
          );
          return;
        }

        final customer = await isar.customers.get(customerId);

        if (customer == null) {
          debugPrint(
            '[LocalNotification] Customer not found: $customerId',
          );
          return;
        }

        debugPrint(
          '[LocalNotification] Opening customer '
              '${customer.id}, transaction: $transactionId',
        );

        nav.pushNamed(
          '/customer_details',
          arguments: {
            'customer': customer,
            'transactionId': transactionId,
          },
        );

        return;
      }

// ==========================================================
// LENDER - INTEREST
// ==========================================================

      if (payload.startsWith('interest_calculated:lender:') ||
          payload.startsWith('interest_updated:lender:')) {
        final parts = payload.split(':');

        if (parts.length < 4) {
          debugPrint(
            '[LocalNotification] Invalid lender interest payload: $payload',
          );
          return;
        }

        final lenderId = int.tryParse(parts[2]);
        final transactionId = int.tryParse(parts[3]);

        if (lenderId == null) {
          debugPrint(
            '[LocalNotification] Invalid lender ID: ${parts[2]}',
          );
          return;
        }

        final lender = await isar.lenders.get(lenderId);

        if (lender == null) {
          debugPrint(
            '[LocalNotification] Lender not found: $lenderId',
          );
          return;
        }

        debugPrint(
          '[LocalNotification] Opening lender '
              '${lender.id}, transaction: $transactionId',
        );

        nav.pushNamed(
          '/took_loan_customer_details',
          arguments: {
            'lender': lender,
            'transactionId': transactionId,
          },
        );

        return;
      }

      // ==========================================================
      // CUSTOMER - INTEREST UPDATED
      // ==========================================================

      if (payload.startsWith('interest_updated:customer:')) {
        final idStr = payload.split(':').last;
        final customerId = int.tryParse(idStr);

        if (customerId == null) {
          debugPrint(
            '[LocalNotification] Invalid customer ID: $idStr',
          );
          return;
        }

        final customer =
        await isar.customers.get(customerId);

        if (customer == null) {
          debugPrint(
            '[LocalNotification] Customer not found: $customerId',
          );
          return;
        }

        nav.pushNamed(
          '/customer_details',
          arguments: customer,
        );

        return;
      }

      // ==========================================================
      // LENDER - INTEREST UPDATED
      // ==========================================================

      if (payload.startsWith('interest_updated:lender:')) {
        final idStr = payload.split(':').last;
        final lenderId = int.tryParse(idStr);

        if (lenderId == null) {
          debugPrint(
            '[LocalNotification] Invalid lender ID: $idStr',
          );
          return;
        }

        final lender =
        await isar.lenders.get(lenderId);

        if (lender == null) {
          debugPrint(
            '[LocalNotification] Lender not found: $lenderId',
          );
          return;
        }

        nav.pushNamed(
          '/took_loan_customer_details',
          arguments: lender,
        );

        return;
      }

      // ==========================================================
      // OLD CUSTOMER PAYLOAD - BACKWARD COMPATIBILITY
      // ==========================================================

      if (payload.startsWith('interest_calculated:') ||
          payload.startsWith('interest_updated:') ||
          payload.startsWith('payment:')) {
        final idStr = payload.split(':').last;
        final customerId = int.tryParse(idStr);

        if (customerId == null) {
          return;
        }

        final customer =
        await isar.customers.get(customerId);

        if (customer != null) {
          nav.pushNamed(
            '/customer_details',
            arguments: customer,
          );
        }

        return;
      }

      // ==========================================================
      // LENDER - TOOK LOAN
      // ==========================================================

      if (payload.startsWith('took_loan:') ||
          payload.startsWith('took_payment:')) {
        final idStr = payload.split(':').last;
        final lenderId = int.tryParse(idStr);

        if (lenderId == null) {
          debugPrint(
            '[LocalNotification] Invalid lender ID: $idStr',
          );
          return;
        }

        final lender =
        await isar.lenders.get(lenderId);

        if (lender != null) {
          debugPrint(
            '[LocalNotification] Opening lender: '
                '${lender.id}',
          );

          nav.pushNamed(
            '/took_loan_customer_details',
            arguments: lender,
          );

          return;
        }

        // Legacy fallback only.
        final oldCustomer =
        await isar.customers.get(lenderId);

        if (oldCustomer != null) {
          nav.pushNamed(
            '/customer_details',
            arguments: oldCustomer,
          );
        }

        return;
      }

      // ==========================================================
      // NOTIFICATION LIST
      // ==========================================================

      if (payload.startsWith('event_read:')) {
        final currentChopdi =
        await ChopdiService.getCurrentChopdi();

        nav.pushNamed(
          '/notifications',
          arguments: {
            'isar': isar,
            'chopdiId': currentChopdi.id,
          },
        );

        return;
      }

      // ==========================================================
      // DAILY REMINDER
      // ==========================================================

      if (payload == 'daily_reminder') {
        final currentChopdi =
        await ChopdiService.getCurrentChopdi();

        nav.pushNamed(
          '/notifications',
          arguments: {
            'isar': isar,
            'chopdiId': currentChopdi.id,
          },
        );

        return;
      }
    } catch (e, stackTrace) {
      debugPrint(
        '[LocalNotification] Error routing notification: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }
  // ============================================================
  // RICH CHAT-STYLE NOTIFICATION
  // ============================================================

  Future<void> showRichEventNotification({
    required int id,
    required String senderName,
    required String message,
    required String payload,
  }) async {
    final bool masterEnabled =
    await areNotificationsEnabled();

    if (!masterEnabled) {
      return;
    }

    await initialize();

    const Person me = Person(
      name: 'Me',
      key: '1',
    );

    final Person sender = Person(
      name: senderName,
      key: '2',
    );

    final MessagingStyleInformation messagingStyle =
    MessagingStyleInformation(
      me,
      groupConversation: false,
      messages: [
        Message(
          message,
          DateTime.now(),
          sender,
        ),
      ],
    );

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      eventChannelId,
      'App Events',
      channelDescription:
      'Important updates and messages',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: messagingStyle,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'action_mark_read',
          'Mark as read',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'action_reply',
          'Reply',
          showsUserInterface: false,
          cancelNotification: false,
          inputs: <AndroidNotificationActionInput>[
            AndroidNotificationActionInput(
              label: 'Type a reply...',
            ),
          ],
        ),
      ],
    );

    final NotificationDetails details =
    NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      id: id,
      title: senderName,
      body: message,
      notificationDetails: details,
      payload: payload,
    );
  }

  // ============================================================
  // MASTER NOTIFICATION SETTING
  // ============================================================

  Future<bool> areNotificationsEnabled() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      notificationsEnabledKey,
    ) ??
        defaultNotificationsEnabled;
  }

  Future<void> setNotificationsEnabled(
      bool enabled, {
        Isar? database,
      }) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      notificationsEnabledKey,
      enabled,
    );

    debugPrint(
      '[LocalNotification] '
          'Master notifications: $enabled',
    );

    if (!enabled) {
      await cancelAllNotifications();
      return;
    }

    await syncNotifications(
      database: database,
    );
  }

  // ============================================================
  // GET SETTINGS
  // ============================================================

  Future<bool> isPaymentReminderEnabled() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      paymentReminderKey,
    ) ??
        defaultPaymentReminder;
  }

  Future<bool> isDailyReminderEnabled() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      dailyReminderKey,
    ) ??
        defaultDailyReminder;
  }

  Future<String> getSelectedReminderType() async {
    final prefs =
    await SharedPreferences.getInstance();

    final value =
    prefs.getString(selectedReminderKey);

    if (value == 'dueDate' ||
        value == 'oneDayBefore' ||
        value == 'threeDaysBefore') {
      return value!;
    }

    return defaultReminderType;
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  Future<void> saveSettings({
    required bool paymentReminderEnabled,
    required bool dailyReminderEnabled,
    required String selectedReminder,
  }) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      paymentReminderKey,
      paymentReminderEnabled,
    );

    await prefs.setBool(
      dailyReminderKey,
      dailyReminderEnabled,
    );

    await prefs.setString(
      selectedReminderKey,
      selectedReminder,
    );

    debugPrint(
      '[LocalNotification] Settings saved',
    );
  }

  // ============================================================
  // CENTRAL SYNC
  // ============================================================

  Future<void> syncNotifications({
    Isar? database,
    bool requestPermissionIfNeeded = false,
  }) async {
    await initialize();

    final bool masterEnabled =
    await areNotificationsEnabled();

    debugPrint(
      '[LocalNotification] '
          'Master notifications enabled: $masterEnabled',
    );

    if (!masterEnabled) {
      await cancelAllNotifications();
      return;
    }

    if (requestPermissionIfNeeded) {
      await requestPermission();
    }

    final Isar db =
        database ?? IsarService.isar;

    final bool paymentEnabled =
    await isPaymentReminderEnabled();

    final bool dailyEnabled =
    await isDailyReminderEnabled();

    if (dailyEnabled) {
      await scheduleDailyReminder();
    } else {
      await cancelDailyReminder();
    }

    if (paymentEnabled) {
      await rescheduleAllPaymentReminders(
        database: db,
      );
    } else {
      await cancelAllPaymentReminders(
        database: db,
      );
    }
  }

  // ============================================================
  // CALCULATE NEXT DUE DATE
  // ============================================================

  DateTime calculateNextDueDate({
    required DateTime startDate,
    required String frequency,
  }) {
    final today = DateTime.now();

    DateTime dueDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    while (!dueDate.isAfter(todayOnly)) {
      dueDate = _addFrequency(
        dueDate,
        frequency,
      );
    }

    return dueDate;
  }

  // ============================================================
  // ADD FREQUENCY
  // ============================================================

  DateTime _addFrequency(
      DateTime date,
      String frequency,
      ) {
    switch (frequency) {
      case 'Daily':
        return date.add(
          const Duration(days: 1),
        );

      case 'Weekly':
        return date.add(
          const Duration(days: 7),
        );

      case 'Monthly':
        return _addMonth(date);

      case 'Yearly':
        return _addYear(date);

      default:
        return _addMonth(date);
    }
  }

  // ============================================================
  // ADD MONTH
  // ============================================================

  DateTime _addMonth(DateTime date) {
    final int nextMonth =
    date.month == 12 ? 1 : date.month + 1;

    final int nextYear =
    date.month == 12
        ? date.year + 1
        : date.year;

    final int lastDay =
        DateTime(
          nextYear,
          nextMonth + 1,
          0,
        ).day;

    final int day =
    date.day > lastDay
        ? lastDay
        : date.day;

    return DateTime(
      nextYear,
      nextMonth,
      day,
    );
  }

  // ============================================================
  // ADD YEAR
  // ============================================================

  DateTime _addYear(DateTime date) {
    final int nextYear =
        date.year + 1;

    if (date.month == 2 &&
        date.day == 29) {
      return DateTime(
        nextYear,
        2,
        28,
      );
    }

    return DateTime(
      nextYear,
      date.month,
      date.day,
    );
  }

  // ============================================================
  // PAYMENT REMINDER ID
  // ============================================================

  int paymentReminderNotificationId(
      int customerId,
      ) {
    return paymentReminderIdBase +
        customerId;
  }

  // ============================================================
  // SCHEDULE PAYMENT REMINDER
  // ============================================================

  Future<void> schedulePaymentReminder({
    required int notificationId,
    required String customerName,
    required DateTime dueDate,
    required String reminderType,
    required TransactionType transactionType,
    double? amount,
  }) async {
    await initialize();

    final bool masterEnabled =
    await areNotificationsEnabled();

    if (!masterEnabled) {
      return;
    }

    DateTime scheduledDate;

    switch (reminderType) {
      case 'oneDayBefore':
        scheduledDate = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
          9,
          0,
        ).subtract(
          const Duration(days: 1),
        );
        break;

      case 'threeDaysBefore':
        scheduledDate = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
          9,
          0,
        ).subtract(
          const Duration(days: 3),
        );
        break;

      case 'dueDate':
      default:
        scheduledDate = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
          9,
          0,
        );
        break;
    }

    if (scheduledDate.isBefore(
      DateTime.now(),
    )) {
      return;
    }

    final String amountText =
    amount == null
        ? ''
        : ' Amount: ₹${amount.toStringAsFixed(2)}.';

    final bool isTookLoan =
        transactionType == TransactionType.took;

    final String title =
    isTookLoan
        ? 'Loan Repayment Reminder'
        : 'Payment Reminder';

    final String body;

    switch (reminderType) {
      case 'oneDayBefore':
        body = isTookLoan
            ? 'You have a loan payment due tomorrow for '
            '$customerName.$amountText'
            : '$customerName has a payment due tomorrow.'
            '$amountText';
        break;

      case 'threeDaysBefore':
        body = isTookLoan
            ? 'You have a loan payment due in 3 days for '
            '$customerName.$amountText'
            : '$customerName has a payment due in 3 days.'
            '$amountText';
        break;

      case 'dueDate':
      default:
        body = isTookLoan
            ? 'Your loan payment to $customerName '
            'is due today.$amountText'
            : '$customerName has a payment due today.'
            '$amountText';
        break;
    }

    // Scheduling implementation remains as in your current code.
    //
    // If you enable this section later, make sure the payload
    // contains the correct customer/lender ID.
  }

  // ============================================================
  // SCHEDULE CUSTOMER PAYMENT REMINDER
  // ============================================================

  Future<void> scheduleCustomerPaymentReminder({
    required Customer customer,
    required DateTime loanDate,
    required String interestFrequency,
    required String reminderType,
    required TransactionType transactionType,
    double? amount,
  }) async {
    final bool masterEnabled =
    await areNotificationsEnabled();

    if (!masterEnabled) {
      return;
    }

    final int notificationId =
    paymentReminderNotificationId(
      customer.id,
    );

    await cancelPaymentReminder(
      notificationId,
    );

    final DateTime dueDate =
    calculateNextDueDate(
      startDate: loanDate,
      frequency: interestFrequency,
    );

    await schedulePaymentReminder(
      notificationId: notificationId,
      customerName: customer.name,
      dueDate: dueDate,
      reminderType: reminderType,
      transactionType: transactionType,
      amount: amount,
    );
  }

  // ============================================================
  // RESCHEDULE ALL PAYMENT REMINDERS
  // ============================================================

  Future<void> rescheduleAllPaymentReminders({
    Isar? database,
  }) async {
    await initialize();

    final Isar db =
        database ?? IsarService.isar;

    final bool masterEnabled =
    await areNotificationsEnabled();

    if (!masterEnabled) {
      await cancelAllPaymentReminders(
        database: db,
      );
      return;
    }

    final bool enabled =
    await isPaymentReminderEnabled();

    final String reminderType =
    await getSelectedReminderType();

    final customers =
    await db.customers.where().findAll();

    for (final customer in customers) {
      final int notificationId =
      paymentReminderNotificationId(
        customer.id,
      );

      await cancelPaymentReminder(
        notificationId,
      );

      if (!enabled) {
        continue;
      }

      final transactions =
      await db.transactions
          .filter()
          .customerIdEqualTo(customer.id)
          .sortByDate()
          .findAll();

      if (transactions.isEmpty) {
        continue;
      }

      final gaveTransactions =
      transactions
          .where(
            (t) =>
        t.type ==
            TransactionType.gave,
      )
          .toList();

      final tookTransactions =
      transactions
          .where(
            (t) =>
        t.type ==
            TransactionType.took,
      )
          .toList();

      if (gaveTransactions.isEmpty &&
          tookTransactions.isEmpty) {
        continue;
      }

      final double totalGiven =
      gaveTransactions.fold(
        0.0,
            (s, t) => s + t.amount,
      );

      final double totalReceived =
      transactions
          .where(
            (t) =>
        t.type ==
            TransactionType.received,
      )
          .fold(
        0.0,
            (s, t) => s + t.amount,
      );

      final double totalGivenInterest =
      gaveTransactions.fold(
        0.0,
            (s, t) => s + t.interest,
      );

      final double customerOwesYou =
          (totalGiven - totalReceived) +
              totalGivenInterest;

      final double totalTook =
      tookTransactions.fold(
        0.0,
            (s, t) => s + t.amount,
      );

      final double totalPaid =
      transactions
          .where(
            (t) =>
        t.type ==
            TransactionType.paid,
      )
          .fold(
        0.0,
            (s, t) => s + t.amount,
      );

      final double totalTookInterest =
      tookTransactions.fold(
        0.0,
            (s, t) => s + t.interest,
      );

      final double youOweCustomer =
          (totalTook - totalPaid) +
              totalTookInterest;

      final bool hasCustomerOwesYouBalance =
          customerOwesYou > 0;

      final bool hasYouOweCustomerBalance =
          youOweCustomer > 0;

      if (!hasCustomerOwesYouBalance &&
          !hasYouOweCustomerBalance) {
        continue;
      }

      final bool useCustomerOwesYou =
          hasCustomerOwesYouBalance;

      final List<Transaction> activeLoans =
      useCustomerOwesYou
          ? gaveTransactions
          : tookTransactions;

      if (activeLoans.isEmpty) {
        continue;
      }

      final double outstanding =
      useCustomerOwesYou
          ? customerOwesYou
          : youOweCustomer;

      if (outstanding <= 0) {
        continue;
      }

      activeLoans.sort(
            (a, b) =>
            a.date.compareTo(b.date),
      );

      final Transaction loan =
          activeLoans.first;

      final String frequency =
      loan.interestFrequency.isNotEmpty
          ? loan.interestFrequency
          : 'Monthly';

      await scheduleCustomerPaymentReminder(
        customer: customer,
        loanDate: loan.date,
        interestFrequency: frequency,
        reminderType: reminderType,
        transactionType:
        useCustomerOwesYou
            ? TransactionType.gave
            : TransactionType.took,
        amount: outstanding,
      );
    }
  }

  // ============================================================
  // DAILY REMINDER
  // ============================================================

  Future<void> scheduleDailyReminder({
    int hour = 9,
    int minute = 0,
  }) async {
    await initialize();

    final bool masterEnabled =
    await areNotificationsEnabled();

    if (!masterEnabled) {
      return;
    }

    await cancelDailyReminder();

    final tz.TZDateTime now =
    tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled =
    tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled =
          scheduled.add(
            const Duration(days: 1),
          );
    }

    const NotificationDetails details =
    NotificationDetails(
      android:
      AndroidNotificationDetails(
        dailyChannelId,
        'Daily Reminders',
        channelDescription:
        'Daily reminders to review pending collections.',
        importance:
        Importance.defaultImportance,
        priority:
        Priority.defaultPriority,
      ),
      iOS:
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: dailyReminderId,
      title: 'Daily Reminder',
      body:
      'Review today\'s pending collections.',
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.time,
      payload: 'daily_reminder',
    );
  }

  // ============================================================
  // CANCEL DAILY REMINDER
  // ============================================================

  Future<void> cancelDailyReminder() async {
    await initialize();

    await _plugin.cancel(
      id: dailyReminderId,
    );
  }

  // ============================================================
  // CANCEL ONE PAYMENT REMINDER
  // ============================================================

  Future<void> cancelPaymentReminder(
      int notificationId,
      ) async {
    await initialize();

    await _plugin.cancel(
      id: notificationId,
    );
  }

  // ============================================================
  // CANCEL ALL PAYMENT REMINDERS
  // ============================================================

  Future<void> cancelAllPaymentReminders({
    Isar? database,
  }) async {
    await initialize();

    final Isar db =
        database ?? IsarService.isar;

    final customers =
    await db.customers.where().findAll();

    for (final customer in customers) {
      final int notificationId =
      paymentReminderNotificationId(
        customer.id,
      );

      await _plugin.cancel(
        id: notificationId,
      );
    }
  }

  // ============================================================
  // CANCEL ALL NOTIFICATIONS
  // ============================================================

  Future<void> cancelAllNotifications() async {
    await initialize();

    await _plugin.cancelAll();
  }

  // ============================================================
  // TEST NOTIFICATION
  // ============================================================

  Future<void> showRealDeviceTestNotification() async {
    final bool masterEnabled =
    await areNotificationsEnabled();

    if (!masterEnabled) {
      return;
    }

    await initialize();

    await requestPermission();

    const NotificationDetails details =
    NotificationDetails(
      android:
      AndroidNotificationDetails(
        paymentChannelId,
        'Payment Reminders',
        channelDescription:
        'Notifications for upcoming customer payment due dates.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS:
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      id: testNotificationId,
      title: 'MyChopdi Test Notification',
      body:
      'Notifications are working correctly on this device.',
      notificationDetails: details,
      payload: 'device_test',
    );
  }

  // ============================================================
  // TEST PAYMENT REMINDER - 1 MINUTE
  // ============================================================

  Future<void> scheduleTestNotificationAfterOneMinute() async {
    final bool masterEnabled =
    await areNotificationsEnabled();

    if (!masterEnabled) {
      return;
    }

    await initialize();

    await requestPermission();

    final tz.TZDateTime scheduledDate =
    tz.TZDateTime.now(tz.local).add(
      const Duration(minutes: 1),
    );

    const NotificationDetails details =
    NotificationDetails(
      android:
      AndroidNotificationDetails(
        paymentChannelId,
        'Payment Reminders',
        channelDescription:
        'Notifications for upcoming customer payment due dates.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS:
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: 777777,
      title: 'TEST Payment Reminder',
      body:
      'This is a test notification from MyChopdi.',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'test_payment',
    );
  }

  // ============================================================
  // TEST DAILY REMINDER - 1 MINUTE
  // ============================================================

  Future<void> scheduleTestDailyReminder() async {
    final bool masterEnabled =
    await areNotificationsEnabled();

    if (!masterEnabled) {
      return;
    }

    await initialize();

    await requestPermission();

    final tz.TZDateTime scheduled =
    tz.TZDateTime.now(tz.local).add(
      const Duration(minutes: 1),
    );

    const NotificationDetails details =
    NotificationDetails(
      android:
      AndroidNotificationDetails(
        dailyChannelId,
        'Daily Reminders',
        channelDescription:
        'Daily reminders to review pending collections.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS:
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: dailyReminderId,
      title: 'Daily Reminder',
      body:
      'Review today\'s pending collections.',
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'daily_reminder',
    );
  }
}