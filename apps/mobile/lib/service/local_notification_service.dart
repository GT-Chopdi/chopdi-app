import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance =
      LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ============================================================
  // CHANNELS
  // ============================================================

  static const String paymentChannelId =
      'payment_reminders';

  static const String dailyChannelId =
      'daily_reminders';

  // ============================================================
  // NOTIFICATION IDS
  // ============================================================

  static const int dailyReminderId = 900000;

  static const int testNotificationId = 999999;

  static const int paymentReminderIdBase = 100000;

  // ============================================================
  // SHARED PREFERENCES KEYS
  // ============================================================

  static const String paymentReminderKey =
      'notification_payment_reminder_enabled';

  static const String dailyReminderKey =
      'notification_daily_reminder_enabled';

  static const String selectedReminderKey =
      'notification_selected_reminder';

  // ============================================================
  // DEFAULT SETTINGS
  // ============================================================

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
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
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
    );

    await _createAndroidChannels();

    _initialized = true;

    debugPrint(
      '[LocalNotification] Initialized successfully',
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

    await androidPlugin.createNotificationChannel(
      paymentChannel,
    );

    await androidPlugin.createNotificationChannel(
      dailyChannel,
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

    final IOSFlutterLocalNotificationsPlugin?
        iosPlugin =
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
  // GET SETTINGS
  // ============================================================

  Future<bool> isPaymentReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(paymentReminderKey) ??
        defaultPaymentReminder;
  }

  Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(dailyReminderKey) ??
        defaultDailyReminder;
  }

  Future<String> getSelectedReminderType() async {
    final prefs = await SharedPreferences.getInstance();

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

    debugPrint(
      '[LocalNotification] '
      'Payment: $paymentReminderEnabled',
    );

    debugPrint(
      '[LocalNotification] '
      'Daily: $dailyReminderEnabled',
    );

    debugPrint(
      '[LocalNotification] '
      'Reminder type: $selectedReminder',
    );
  }

  // ============================================================
  // CENTRAL SYNC
  //
  // THIS IS THE MAIN METHOD.
  //
  // Call this:
  // - App startup
  // - After transaction added
  // - After transaction edited
  // - After transaction deleted
  // - After interest updated
  // - After notification settings saved
  // ============================================================

  Future<void> syncNotifications({
    Isar? database,
    bool requestPermissionIfNeeded = false,
  }) async {
    await initialize();

    if (requestPermissionIfNeeded) {
      await requestPermission();
    }

    final Isar db =
        database ?? IsarService.isar;

    final bool paymentEnabled =
        await isPaymentReminderEnabled();

    final bool dailyEnabled =
        await isDailyReminderEnabled();

    debugPrint(
      '[LocalNotification] Starting notification sync',
    );

    debugPrint(
      '[LocalNotification] '
      'Payment enabled: $paymentEnabled',
    );

    debugPrint(
      '[LocalNotification] '
      'Daily enabled: $dailyEnabled',
    );

    // ------------------------------------------------------------
    // DAILY REMINDER
    // ------------------------------------------------------------

    if (dailyEnabled) {
      await scheduleDailyReminder();
    } else {
      await cancelDailyReminder();
    }

    // ------------------------------------------------------------
    // PAYMENT REMINDERS
    // ------------------------------------------------------------

    if (paymentEnabled) {
      await rescheduleAllPaymentReminders(
        database: db,
      );
    } else {
      await cancelAllPaymentReminders(
        database: db,
      );
    }

    debugPrint(
      '[LocalNotification] Notification sync completed',
    );
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
        date.month == 12
            ? 1
            : date.month + 1;

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
    double? amount,
  }) async {
    await initialize();

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

    // ------------------------------------------------------------
    // DON'T SCHEDULE PAST NOTIFICATIONS
    // ------------------------------------------------------------

    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint(
        '[LocalNotification] '
        'Skipping past reminder: $scheduledDate',
      );

      return;
    }

    // ------------------------------------------------------------
    // MESSAGE
    // ------------------------------------------------------------

    final String amountText =
        amount == null
            ? ''
            : ' Amount due: ₹${amount.toStringAsFixed(2)}.';

    final String body;

    switch (reminderType) {
      case 'oneDayBefore':
        body =
            '$customerName has a payment due tomorrow.'
            '$amountText';
        break;

      case 'threeDaysBefore':
        body =
            '$customerName has a payment due in 3 days.'
            '$amountText';
        break;

      case 'dueDate':
      default:
        body =
            '$customerName has a payment due today.'
            '$amountText';
        break;
    }

    const NotificationDetails details =
        NotificationDetails(
      android: AndroidNotificationDetails(
        paymentChannelId,
        'Payment Reminders',
        channelDescription:
            'Notifications for upcoming customer payment due dates.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final tz.TZDateTime notificationDate =
        tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await _plugin.zonedSchedule(
      id: notificationId,
      title: 'Payment Reminder',
      body: body,
      scheduledDate: notificationDate,
      notificationDetails: details,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'payment:$notificationId',
    );

    debugPrint(
      '[LocalNotification] '
      'Payment reminder scheduled: $notificationDate',
    );
  }

  // ============================================================
  // SCHEDULE CUSTOMER PAYMENT REMINDER
  // ============================================================

  Future<void> scheduleCustomerPaymentReminder({
    required Customer customer,
    required DateTime loanDate,
    required String interestFrequency,
    required String reminderType,
    double? amount,
  }) async {
    final int notificationId =
        paymentReminderNotificationId(
      customer.id,
    );

    // Remove previous reminder first.
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
      amount: amount,
    );

    debugPrint(
      '[LocalNotification] '
      'Customer: ${customer.name}',
    );

    debugPrint(
      '[LocalNotification] '
      'Loan date: $loanDate',
    );

    debugPrint(
      '[LocalNotification] '
      'Frequency: $interestFrequency',
    );

    debugPrint(
      '[LocalNotification] '
      'Next due date: $dueDate',
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

    final bool enabled =
        await isPaymentReminderEnabled();

    final String reminderType =
        await getSelectedReminderType();

    final customers =
        await db.customers
            .where()
            .findAll();

    debugPrint(
      '[LocalNotification] '
      'Customers found: ${customers.length}',
    );

    for (final customer in customers) {
      final int notificationId =
          paymentReminderNotificationId(
        customer.id,
      );

      // Always cancel old reminder.
      await cancelPaymentReminder(
        notificationId,
      );

      if (!enabled) {
        continue;
      }

      // ----------------------------------------------------------
      // CUSTOMER TRANSACTIONS
      // ----------------------------------------------------------

      final transactions =
          await db.transactions
              .filter()
              .customerIdEqualTo(
                customer.id,
              )
              .sortByDate()
              .findAll();

      if (transactions.isEmpty) {
        continue;
      }

      // ----------------------------------------------------------
      // GAVE
      // ----------------------------------------------------------

      final gaveTransactions =
          transactions
              .where(
                (transaction) =>
                    transaction.type ==
                    TransactionType.gave,
              )
              .toList();

      // ----------------------------------------------------------
      // TOOK
      // ----------------------------------------------------------

      final tookTransactions =
          transactions
              .where(
                (transaction) =>
                    transaction.type ==
                    TransactionType.took,
              )
              .toList();

      if (gaveTransactions.isEmpty &&
          tookTransactions.isEmpty) {
        continue;
      }

      // ----------------------------------------------------------
      // CUSTOMER OWES YOU
      //
      // GIVEN - RECEIVED + INTEREST
      // ----------------------------------------------------------

      final double totalGiven =
          gaveTransactions.fold(
        0.0,
        (sum, transaction) =>
            sum + transaction.amount,
      );

      final double totalReceived =
          transactions
              .where(
                (transaction) =>
                    transaction.type ==
                    TransactionType.received,
              )
              .fold(
                0.0,
                (sum, transaction) =>
                    sum + transaction.amount,
              );

      final double totalGivenInterest =
          gaveTransactions.fold(
        0.0,
        (sum, transaction) =>
            sum + transaction.interest,
      );

      final double customerOwesYou =
          (totalGiven -
                  totalReceived) +
              totalGivenInterest;

      // ----------------------------------------------------------
      // YOU OWE CUSTOMER
      //
      // TOOK - PAID + INTEREST
      // ----------------------------------------------------------

      final double totalTook =
          tookTransactions.fold(
        0.0,
        (sum, transaction) =>
            sum + transaction.amount,
      );

      final double totalPaid =
          transactions
              .where(
                (transaction) =>
                    transaction.type ==
                    TransactionType.paid,
              )
              .fold(
                0.0,
                (sum, transaction) =>
                    sum + transaction.amount,
              );

      final double totalTookInterest =
          tookTransactions.fold(
        0.0,
        (sum, transaction) =>
            sum + transaction.interest,
      );

      final double youOweCustomer =
          (totalTook -
                  totalPaid) +
              totalTookInterest;

      // ----------------------------------------------------------
      // SELECT ACTIVE SIDE
      // ----------------------------------------------------------

      final bool hasCustomerOwesYouBalance =
          customerOwesYou > 0;

      final bool hasYouOweCustomerBalance =
          youOweCustomer > 0;

      // Fully settled.
      if (!hasCustomerOwesYouBalance &&
          !hasYouOweCustomerBalance) {
        debugPrint(
          '[LocalNotification] '
          'No reminder for ${customer.name}. '
          'Both balances are settled.',
        );

        continue;
      }

      // If both sides somehow exist, prefer
      // the customer-owes-you side.
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

      // ----------------------------------------------------------
      // ORIGINAL LOAN TRANSACTION
      // ----------------------------------------------------------

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

      debugPrint(
        '[LocalNotification] '
        '${customer.name}: '
        '${useCustomerOwesYou ? 'customer owes you' : 'you owe customer'} '
        'Outstanding: $outstanding',
      );

      // ----------------------------------------------------------
      // SCHEDULE
      // ----------------------------------------------------------

      await scheduleCustomerPaymentReminder(
        customer: customer,
        loanDate: loan.date,
        interestFrequency: frequency,
        reminderType: reminderType,
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
      scheduled = scheduled.add(
        const Duration(days: 1),
      );
    }

    const NotificationDetails details =
        NotificationDetails(
      android: AndroidNotificationDetails(
        dailyChannelId,
        'Daily Reminders',
        channelDescription:
            'Daily reminders to review pending collections.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(
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

    debugPrint(
      '[LocalNotification] '
      'Daily reminder scheduled at '
      '$hour:$minute',
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

    debugPrint(
      '[LocalNotification] '
      'Daily reminder cancelled',
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

    debugPrint(
      '[LocalNotification] '
      'Payment reminder cancelled: $notificationId',
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
        await db.customers
            .where()
            .findAll();

    for (final customer in customers) {
      final int notificationId =
          paymentReminderNotificationId(
        customer.id,
      );

      await _plugin.cancel(
        id: notificationId,
      );
    }

    debugPrint(
      '[LocalNotification] '
      'All payment reminders cancelled',
    );
  }

  // ============================================================
  // CANCEL ALL NOTIFICATIONS
  // ============================================================

  Future<void> cancelAllNotifications() async {
    await initialize();

    await _plugin.cancelAll();

    debugPrint(
      '[LocalNotification] '
      'All notifications cancelled',
    );
  }

  // ============================================================
  // TEST NOTIFICATION
  // ============================================================

  Future<void> showRealDeviceTestNotification() async {
    await initialize();

    await requestPermission();

    const NotificationDetails details =
        NotificationDetails(
      android: AndroidNotificationDetails(
        paymentChannelId,
        'Payment Reminders',
        channelDescription:
            'Notifications for upcoming customer payment due dates.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
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

    debugPrint(
      '[LocalNotification] '
      'REAL DEVICE TEST SENT',
    );
  }

  // ============================================================
  // TEST PAYMENT REMINDER - 1 MINUTE
  // ============================================================

  Future<void> scheduleTestNotificationAfterOneMinute() async {
    await initialize();

    await requestPermission();

    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.now(tz.local).add(
      const Duration(minutes: 1),
    );

    const NotificationDetails details =
        NotificationDetails(
      android: AndroidNotificationDetails(
        paymentChannelId,
        'Payment Reminders',
        channelDescription:
            'Notifications for upcoming customer payment due dates.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
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

    debugPrint(
      '[TEST] Notification scheduled for: '
      '$scheduledDate',
    );
  }

  // ============================================================
  // TEST DAILY REMINDER - 1 MINUTE
  // ============================================================

  Future<void> scheduleTestDailyReminder() async {
    await initialize();

    await requestPermission();

    final tz.TZDateTime scheduled =
        tz.TZDateTime.now(tz.local).add(
      const Duration(minutes: 1),
    );

    const NotificationDetails details =
        NotificationDetails(
      android: AndroidNotificationDetails(
        dailyChannelId,
        'Daily Reminders',
        channelDescription:
            'Daily reminders to review pending collections.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
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

    debugPrint(
      '[TEST] Daily reminder scheduled for: '
      '$scheduled',
    );
  }

  // ============================================================
  // NOTIFICATION CLICK
  // ============================================================

  void _onNotificationResponse(
    NotificationResponse response,
  ) {
    debugPrint(
      '[LocalNotification] '
      'Notification clicked',
    );

    debugPrint(
      '[LocalNotification] Payload: '
      '${response.payload}',
    );

    if (response.payload == null) {
      return;
    }

    final payload = response.payload!;

    if (payload.startsWith('payment:')) {
      final String id =
          payload.replaceFirst(
        'payment:',
        '',
      );

      debugPrint(
        '[LocalNotification] '
        'Payment notification clicked: $id',
      );

      // Navigation can be added here later.
    }

    if (payload == 'daily_reminder') {
      debugPrint(
        '[LocalNotification] '
        'Daily reminder clicked',
      );

      // Navigate to pending collections later.
    }
  }
}