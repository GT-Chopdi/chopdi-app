// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class LocalNotificationService {
//   LocalNotificationService._();

//   static final LocalNotificationService instance =
//       LocalNotificationService._();

//   final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   bool _initialized = false;

//   // ============================================================
//   // CHANNELS
//   // ============================================================

//   static const String paymentChannelId =
//       'payment_reminders';

//   static const String dailyChannelId =
//       'daily_reminders';

//   // Keep daily notification ID separate.
//   static const int dailyReminderId = 900000;

//   // Test notification ID.
//   static const int testNotificationId = 999999;

//   // ============================================================
//   // INITIALIZE
//   // ============================================================

//   Future<void> initialize() async {
//     if (_initialized) {
//       return;
//     }

//     // Initialize timezone database.
//     tz.initializeTimeZones();

//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );

//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings(
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//     );

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _plugin.initialize(
//       settings: initializationSettings,
//       onDidReceiveNotificationResponse:
//           _onNotificationResponse,
//     );

//     await _createAndroidChannels();

//     _initialized = true;

//     debugPrint(
//       '[LocalNotification] Initialized successfully',
//     );
//   }

//   // ============================================================
//   // ANDROID CHANNELS
//   // ============================================================

//   Future<void> _createAndroidChannels() async {
//     final AndroidFlutterLocalNotificationsPlugin?
//         androidPlugin =
//         _plugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     if (androidPlugin == null) {
//       return;
//     }

//     const AndroidNotificationChannel paymentChannel =
//         AndroidNotificationChannel(
//       paymentChannelId,
//       'Payment Reminders',
//       description:
//           'Notifications for upcoming customer payment due dates.',
//       importance: Importance.high,
//     );

//     const AndroidNotificationChannel dailyChannel =
//         AndroidNotificationChannel(
//       dailyChannelId,
//       'Daily Reminders',
//       description:
//           'Daily reminders to review pending collections.',
//       importance: Importance.defaultImportance,
//     );

//     await androidPlugin.createNotificationChannel(
//       paymentChannel,
//     );

//     await androidPlugin.createNotificationChannel(
//       dailyChannel,
//     );
//   }

//   // ============================================================
//   // REQUEST PERMISSION
//   // ============================================================

//   Future<void> requestPermission() async {
//     await initialize();

//     // -------------------------------
//     // Android
//     // -------------------------------

//     final AndroidFlutterLocalNotificationsPlugin?
//         androidPlugin =
//         _plugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     if (androidPlugin != null) {
//       await androidPlugin.requestNotificationsPermission();
//     }

//     // -------------------------------
//     // iOS
//     // -------------------------------

//     final IOSFlutterLocalNotificationsPlugin?
//         iosPlugin =
//         _plugin.resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin>();

//     if (iosPlugin != null) {
//       await iosPlugin.requestPermissions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//     }
//   }

//   // ============================================================
//   // TEST NOTIFICATION
//   // ============================================================

//   Future<void> showTestNotification() async {
//     await initialize();
//     await requestPermission();

//     const NotificationDetails details =
//         NotificationDetails(
//       android: AndroidNotificationDetails(
//         paymentChannelId,
//         'Payment Reminders',
//         channelDescription:
//             'Notifications for upcoming customer payment due dates.',
//         importance: Importance.high,
//         priority: Priority.high,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );

//     await _plugin.show(
//       id: testNotificationId,
//       title: 'Notifications Enabled',
//       body: 'Your notification settings are now active.',
//       notificationDetails: details,
//       payload: 'test_notification',
//     );
//   }

//   // ============================================================
//   // PAYMENT REMINDER
//   // ============================================================

//   Future<void> schedulePaymentReminder({
//     required int notificationId,
//     required String customerName,
//     required DateTime dueDate,
//     required String reminderType,
//     double? amount,
//   }) async {
//     await initialize();

//     DateTime scheduledDate;

//     // ============================================================
//     // CALCULATE REMINDER DATE
//     // ============================================================

//     switch (reminderType) {
//       case 'oneDayBefore':
//         scheduledDate = DateTime(
//           dueDate.year,
//           dueDate.month,
//           dueDate.day,
//           9,
//           0,
//         ).subtract(
//           const Duration(days: 1),
//         );
//         break;

//       case 'threeDaysBefore':
//         scheduledDate = DateTime(
//           dueDate.year,
//           dueDate.month,
//           dueDate.day,
//           9,
//           0,
//         ).subtract(
//           const Duration(days: 3),
//         );
//         break;

//       case 'dueDate':
//       default:
//         scheduledDate = DateTime(
//           dueDate.year,
//           dueDate.month,
//           dueDate.day,
//           9,
//           0,
//         );
//         break;
//     }

//     // ============================================================
//     // DON'T SCHEDULE PAST NOTIFICATIONS
//     // ============================================================

//     if (scheduledDate.isBefore(DateTime.now())) {
//       debugPrint(
//         '[LocalNotification] '
//         'Skipping past payment reminder: '
//         '$scheduledDate',
//       );

//       return;
//     }

//     // ============================================================
//     // MESSAGE
//     // ============================================================

//     final String amountText = amount == null
//         ? ''
//         : ' Amount due: ₹${amount.toStringAsFixed(2)}.';

//     final String title = 'Payment Reminder';

//     final String body;

//     switch (reminderType) {
//       case 'oneDayBefore':
//         body =
//             '$customerName has a payment due tomorrow.'
//             '$amountText';
//         break;

//       case 'threeDaysBefore':
//         body =
//             '$customerName has a payment due in 3 days.'
//             '$amountText';
//         break;

//       case 'dueDate':
//       default:
//         body =
//             '$customerName has a payment due today.'
//             '$amountText';
//         break;
//     }

//     // ============================================================
//     // DETAILS
//     // ============================================================

//     const NotificationDetails details =
//         NotificationDetails(
//       android: AndroidNotificationDetails(
//         paymentChannelId,
//         'Payment Reminders',
//         channelDescription:
//             'Notifications for upcoming customer payment due dates.',
//         importance: Importance.high,
//         priority: Priority.high,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );

//     // ============================================================
//     // SCHEDULE
//     // ============================================================

//     final tz.TZDateTime notificationDate =
//         tz.TZDateTime.from(
//       scheduledDate,
//       tz.local,
//     );

//     await _plugin.zonedSchedule(
//       id: notificationId,
//       title: title,
//       body: body,
//       scheduledDate: notificationDate,
//       notificationDetails: details,
//       androidScheduleMode:
//           AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: 'payment:$notificationId',
//     );

//     debugPrint(
//       '[LocalNotification] Payment reminder scheduled: '
//       '$notificationDate',
//     );
//   }

//   // ============================================================
//   // DAILY REMINDER
//   // ============================================================

//   Future<void> scheduleDailyReminder({
//     int hour = 9,
//     int minute = 0,
//   }) async {
//     await initialize();

//     // Remove existing daily reminder first.
//     await cancelDailyReminder();

//     final tz.TZDateTime now =
//         tz.TZDateTime.now(tz.local);

//     tz.TZDateTime scheduled =
//         tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       hour,
//       minute,
//     );

//     // If today's time already passed,
//     // schedule from tomorrow.
//     if (!scheduled.isAfter(now)) {
//       scheduled = scheduled.add(
//         const Duration(days: 1),
//       );
//     }

//     const NotificationDetails details =
//         NotificationDetails(
//       android: AndroidNotificationDetails(
//         dailyChannelId,
//         'Daily Reminders',
//         channelDescription:
//             'Daily reminders to review pending collections.',
//         importance: Importance.defaultImportance,
//         priority: Priority.defaultPriority,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );

//     await _plugin.zonedSchedule(
//       id: dailyReminderId,
//       title: 'Daily Reminder',
//       body:
//           'Review today\'s pending collections.',
//       scheduledDate: scheduled,
//       notificationDetails: details,
//       androidScheduleMode:
//           AndroidScheduleMode.inexactAllowWhileIdle,
//       matchDateTimeComponents:
//           DateTimeComponents.time,
//       payload: 'daily_reminder',
//     );

//     debugPrint(
//       '[LocalNotification] Daily reminder scheduled '
//       'at $hour:$minute',
//     );
//   }

//   // ============================================================
//   // CANCEL DAILY REMINDER
//   // ============================================================

//   Future<void> cancelDailyReminder() async {
//     await initialize();

//     await _plugin.cancel(
//       id: dailyReminderId,
//     );

//     debugPrint(
//       '[LocalNotification] Daily reminder cancelled',
//     );
//   }

//   // ============================================================
//   // CANCEL ONE PAYMENT REMINDER
//   // ============================================================

//   Future<void> cancelPaymentReminder(
//     int notificationId,
//   ) async {
//     await initialize();

//     await _plugin.cancel(
//       id: notificationId,
//     );

//     debugPrint(
//       '[LocalNotification] Payment reminder cancelled: '
//       '$notificationId',
//     );
//   }

//   // ============================================================
//   // CANCEL ALL
//   // ============================================================

//   Future<void> cancelAllPaymentReminders() async {
//     await initialize();

//     /*
//      * Do NOT loop through 1 -> 900000.
//      *
//      * The previous implementation did that, which is inefficient
//      * and unnecessary.
//      *
//      * cancelAll() removes all scheduled/presented notifications.
//      *
//      * We then reschedule the notifications that should remain.
//      */

//     await _plugin.cancelAll();

//     debugPrint(
//       '[LocalNotification] All local notifications cancelled',
//     );
//   }

//   // ============================================================
//   // CANCEL ALL NOTIFICATIONS
//   // ============================================================

//   Future<void> cancelAllNotifications() async {
//     await initialize();

//     await _plugin.cancelAll();

//     debugPrint(
//       '[LocalNotification] All notifications cancelled',
//     );
//   }

//   // ============================================================
//   // CLICK HANDLER
//   // ============================================================

//   void _onNotificationResponse(
//     NotificationResponse response,
//   ) {
//     debugPrint(
//       '[LocalNotification] Notification clicked',
//     );

//     debugPrint(
//       '[LocalNotification] Payload: '
//       '${response.payload}',
//     );

//     // Later we can use the payload to navigate:
//     //
//     // payment:123
//     //      ↓
//     // Customer details
//     //
//     // daily_reminder
//     //      ↓
//     // Pending collections
//   }
// }

// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:isar_community/isar.dart';
// import 'package:mychopdi/model/customer.dart';
// import 'package:mychopdi/model/transaction.dart';
// import 'package:mychopdi/service/isar_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class LocalNotificationService {
//   LocalNotificationService._();

//   static final LocalNotificationService instance =
//       LocalNotificationService._();

//   final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   bool _initialized = false;

//   // ============================================================
//   // CHANNELS
//   // ============================================================

//   static const String paymentChannelId =
//       'payment_reminders';

//   static const String dailyChannelId =
//       'daily_reminders';

//   // Keep daily notification ID separate.
//   static const int dailyReminderId = 900000;

//   // Test notification ID.
//   static const int testNotificationId = 999999;

//   // Base ID for payment reminders.
//   //
//   // We use one deterministic ID per customer so that an old
//   // reminder can be cancelled before a new one is scheduled.
//   static const int paymentReminderIdBase = 100000;

//   // ============================================================
//   // SHARED PREFERENCES KEYS
//   // ============================================================

//   static const String paymentReminderKey =
//       'notification_payment_reminder_enabled';

//   static const String selectedReminderKey =
//       'notification_selected_reminder';

//   // ============================================================
//   // INITIALIZE
//   // ============================================================

//   Future<void> initialize() async {
//     if (_initialized) {
//       return;
//     }

//     // Initialize timezone database.
//     tz.initializeTimeZones();

//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );

//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings(
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//     );

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _plugin.initialize(
//       settings: initializationSettings,
//       onDidReceiveNotificationResponse:
//           _onNotificationResponse,
//     );

//     await _createAndroidChannels();

//     _initialized = true;

//     debugPrint(
//       '[LocalNotification] Initialized successfully',
//     );
//   }

//   // ============================================================
//   // ANDROID CHANNELS
//   // ============================================================

//   Future<void> _createAndroidChannels() async {
//     final AndroidFlutterLocalNotificationsPlugin?
//         androidPlugin =
//         _plugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     if (androidPlugin == null) {
//       return;
//     }

//     const AndroidNotificationChannel paymentChannel =
//         AndroidNotificationChannel(
//       paymentChannelId,
//       'Payment Reminders',
//       description:
//           'Notifications for upcoming customer payment due dates.',
//       importance: Importance.high,
//     );

//     const AndroidNotificationChannel dailyChannel =
//         AndroidNotificationChannel(
//       dailyChannelId,
//       'Daily Reminders',
//       description:
//           'Daily reminders to review pending collections.',
//       importance: Importance.defaultImportance,
//     );

//     await androidPlugin.createNotificationChannel(
//       paymentChannel,
//     );

//     await androidPlugin.createNotificationChannel(
//       dailyChannel,
//     );
//   }

//   // ============================================================
//   // REQUEST PERMISSION
//   // ============================================================

//   Future<void> requestPermission() async {
//     await initialize();

//     // -------------------------------
//     // Android
//     // -------------------------------

//     final AndroidFlutterLocalNotificationsPlugin?
//         androidPlugin =
//         _plugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     if (androidPlugin != null) {
//       await androidPlugin.requestNotificationsPermission();
//     }

//     // -------------------------------
//     // iOS
//     // -------------------------------

//     final IOSFlutterLocalNotificationsPlugin?
//         iosPlugin =
//         _plugin.resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin>();

//     if (iosPlugin != null) {
//       await iosPlugin.requestPermissions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//     }
//   }

//   // ============================================================
//   // TEST NOTIFICATION
//   // ============================================================

//   Future<void> showTestNotification() async {
//     await initialize();
//     await requestPermission();

//     const NotificationDetails details =
//         NotificationDetails(
//       android: AndroidNotificationDetails(
//         paymentChannelId,
//         'Payment Reminders',
//         channelDescription:
//             'Notifications for upcoming customer payment due dates.',
//         importance: Importance.high,
//         priority: Priority.high,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );

//     await _plugin.show(
//       id: testNotificationId,
//       title: 'Notifications Enabled',
//       body: 'Your notification settings are now active.',
//       notificationDetails: details,
//       payload: 'test_notification',
//     );
//   }

//   // ============================================================
//   // CALCULATE NEXT DUE DATE
//   // ============================================================

//   DateTime calculateNextDueDate({
//     required DateTime startDate,
//     required String frequency,
//   }) {
//     final today = DateTime.now();

//     DateTime dueDate = DateTime(
//       startDate.year,
//       startDate.month,
//       startDate.day,
//     );

//     while (!dueDate.isAfter(
//       DateTime(
//         today.year,
//         today.month,
//         today.day,
//       ),
//     )) {
//       dueDate = _addFrequency(
//         dueDate,
//         frequency,
//       );
//     }

//     return dueDate;
//   }

//   // ============================================================
//   // ADD FREQUENCY
//   // ============================================================

//   DateTime _addFrequency(
//     DateTime date,
//     String frequency,
//   ) {
//     switch (frequency) {
//       case 'Daily':
//         return date.add(
//           const Duration(days: 1),
//         );

//       case 'Weekly':
//         return date.add(
//           const Duration(days: 7),
//         );

//       case 'Monthly':
//         return _addMonth(date);

//       case 'Yearly':
//         return _addYear(date);

//       default:
//         // Keep existing app behavior safe.
//         return _addMonth(date);
//     }
//   }

//   // ============================================================
//   // ADD MONTH
//   // ============================================================

//   DateTime _addMonth(DateTime date) {
//     final int nextMonth =
//         date.month == 12 ? 1 : date.month + 1;

//     final int nextYear =
//         date.month == 12
//             ? date.year + 1
//             : date.year;

//     // Last day of next month.
//     final int lastDay =
//         DateTime(
//           nextYear,
//           nextMonth + 1,
//           0,
//         ).day;

//     final int day =
//         date.day > lastDay
//             ? lastDay
//             : date.day;

//     return DateTime(
//       nextYear,
//       nextMonth,
//       day,
//     );
//   }

//   // ============================================================
//   // ADD YEAR
//   // ============================================================

//   DateTime _addYear(DateTime date) {
//     final int nextYear =
//         date.year + 1;

//     // Handle Feb 29 in non-leap years.
//     if (date.month == 2 &&
//         date.day == 29) {
//       return DateTime(
//         nextYear,
//         2,
//         28,
//       );
//     }

//     return DateTime(
//       nextYear,
//       date.month,
//       date.day,
//     );
//   }

//   // ============================================================
//   // PAYMENT REMINDER ID
//   // ============================================================

//   int paymentReminderNotificationId(
//     int customerId,
//   ) {
//     return paymentReminderIdBase +
//         customerId;
//   }

//   // ============================================================
//   // SCHEDULE PAYMENT REMINDER
//   // ============================================================

//   Future<void> schedulePaymentReminder({
//     required int notificationId,
//     required String customerName,
//     required DateTime dueDate,
//     required String reminderType,
//     double? amount,
//   }) async {
//     await initialize();

//     DateTime scheduledDate;

//     // ============================================================
//     // CALCULATE REMINDER DATE
//     // ============================================================

//     switch (reminderType) {
//       case 'oneDayBefore':
//         scheduledDate = DateTime(
//           dueDate.year,
//           dueDate.month,
//           dueDate.day,
//           9,
//           0,
//         ).subtract(
//           const Duration(days: 1),
//         );
//         break;

//       case 'threeDaysBefore':
//         scheduledDate = DateTime(
//           dueDate.year,
//           dueDate.month,
//           dueDate.day,
//           9,
//           0,
//         ).subtract(
//           const Duration(days: 3),
//         );
//         break;

//       case 'dueDate':
//       default:
//         scheduledDate = DateTime(
//           dueDate.year,
//           dueDate.month,
//           dueDate.day,
//           9,
//           0,
//         );
//         break;
//     }

//     // ============================================================
//     // DON'T SCHEDULE PAST NOTIFICATIONS
//     // ============================================================

//     if (scheduledDate.isBefore(
//       DateTime.now(),
//     )) {
//       debugPrint(
//         '[LocalNotification] '
//         'Skipping past payment reminder: '
//         '$scheduledDate',
//       );

//       return;
//     }

//     // ============================================================
//     // MESSAGE
//     // ============================================================

//     final String amountText =
//         amount == null
//             ? ''
//             : ' Amount due: ₹${amount.toStringAsFixed(2)}.';

//     final String title =
//         'Payment Reminder';

//     final String body;

//     switch (reminderType) {
//       case 'oneDayBefore':
//         body =
//             '$customerName has a payment due tomorrow.'
//             '$amountText';
//         break;

//       case 'threeDaysBefore':
//         body =
//             '$customerName has a payment due in 3 days.'
//             '$amountText';
//         break;

//       case 'dueDate':
//       default:
//         body =
//             '$customerName has a payment due today.'
//             '$amountText';
//         break;
//     }

//     // ============================================================
//     // DETAILS
//     // ============================================================

//     const NotificationDetails details =
//         NotificationDetails(
//       android: AndroidNotificationDetails(
//         paymentChannelId,
//         'Payment Reminders',
//         channelDescription:
//             'Notifications for upcoming customer payment due dates.',
//         importance: Importance.high,
//         priority: Priority.high,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );

//     // ============================================================
//     // SCHEDULE
//     // ============================================================

//     final tz.TZDateTime notificationDate =
//         tz.TZDateTime.from(
//       scheduledDate,
//       tz.local,
//     );

//     await _plugin.zonedSchedule(
//       id: notificationId,
//       title: title,
//       body: body,
//       scheduledDate: notificationDate,
//       notificationDetails: details,
//       androidScheduleMode:
//           AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: 'payment:$notificationId',
//     );

//     debugPrint(
//       '[LocalNotification] '
//       'Payment reminder scheduled: '
//       '$notificationDate',
//     );
//   }

//   // ============================================================
//   // SCHEDULE PAYMENT REMINDER FOR CUSTOMER
//   // ============================================================

//   Future<void> scheduleCustomerPaymentReminder({
//     required Customer customer,
//     required DateTime loanDate,
//     required String interestFrequency,
//     required String reminderType,
//     double? amount,
//   }) async {
//     final int notificationId =
//         paymentReminderNotificationId(
//       customer.id,
//     );

//     // Always remove the old reminder first.
//     await cancelPaymentReminder(
//       notificationId,
//     );

//     final DateTime dueDate =
//         calculateNextDueDate(
//       startDate: loanDate,
//       frequency: interestFrequency,
//     );

//     await schedulePaymentReminder(
//       notificationId: notificationId,
//       customerName: customer.name,
//       dueDate: dueDate,
//       reminderType: reminderType,
//       amount: amount,
//     );

//     debugPrint(
//       '[LocalNotification] '
//       'Customer: ${customer.name}',
//     );

//     debugPrint(
//       '[LocalNotification] '
//       'Loan date: $loanDate',
//     );

//     debugPrint(
//       '[LocalNotification] '
//       'Frequency: $interestFrequency',
//     );

//     debugPrint(
//       '[LocalNotification] '
//       'Next due date: $dueDate',
//     );
//   }

//   // ============================================================
//   // RESCHEDULE ALL PAYMENT REMINDERS
//   // ============================================================

//   Future<void> rescheduleAllPaymentReminders({
//     Isar? database,
//   }) async {
//     await initialize();

//     final Isar db =
//         database ?? IsarService.isar;

//     final prefs =
//         await SharedPreferences.getInstance();

//     final bool enabled =
//         prefs.getBool(
//               paymentReminderKey,
//             ) ??
//             true;

//     final String reminderType =
//         prefs.getString(
//               selectedReminderKey,
//             ) ??
//             'dueDate';

//     // ------------------------------------------------------------
//     // Get customers
//     // ------------------------------------------------------------

//     final customers =
//         await db.customers
//             .where()
//             .findAll();

//     // ------------------------------------------------------------
//     // Process each customer
//     // ------------------------------------------------------------

//     for (final customer in customers) {
//       final int notificationId =
//           paymentReminderNotificationId(
//         customer.id,
//       );

//       // Always cancel old reminder first.
//       await cancelPaymentReminder(
//         notificationId,
//       );

//       if (!enabled) {
//         continue;
//       }

//       // ----------------------------------------------------------
//       // Get customer's transactions
//       // ----------------------------------------------------------

//       final transactions =
//           await db.transactions
//               .filter()
//               .customerIdEqualTo(
//                 customer.id,
//               )
//               .sortByDate()
//               .findAll();

//       if (transactions.isEmpty) {
//         continue;
//       }

//       // ----------------------------------------------------------
//       // Only customers who have given loans
//       // ----------------------------------------------------------

//       final gaveTransactions =
//           transactions
//               .where(
//                 (transaction) =>
//                     transaction.type ==
//                     TransactionType.gave,
//               )
//               .toList();

//       if (gaveTransactions.isEmpty) {
//         continue;
//       }

//       // ----------------------------------------------------------
//       // Calculate outstanding amount
//       //
//       // Existing customer details logic:
//       //
//       // totalGiven - totalReceived + totalInterest
//       // ----------------------------------------------------------

//       final double totalGiven =
//           gaveTransactions.fold(
//         0.0,
//         (sum, transaction) =>
//             sum + transaction.amount,
//       );

//       final double totalReceived =
//           transactions
//               .where(
//                 (transaction) =>
//                     transaction.type ==
//                     TransactionType.received,
//               )
//               .fold(
//                 0.0,
//                 (sum, transaction) =>
//                     sum + transaction.amount,
//               );

//       final double totalInterest =
//           gaveTransactions.fold(
//         0.0,
//         (sum, transaction) =>
//             sum + transaction.interest,
//       );

//       final double outstanding =
//           (totalGiven -
//                   totalReceived) +
//               totalInterest;

//       // ----------------------------------------------------------
//       // Fully paid -> no reminder
//       // ----------------------------------------------------------

//       if (outstanding <= 0) {
//         debugPrint(
//           '[LocalNotification] '
//           'No reminder for ${customer.name}. '
//           'Outstanding: $outstanding',
//         );

//         continue;
//       }

//       // ----------------------------------------------------------
//       // Use first loan transaction
//       //
//       // This matches the existing CustomerDetailsScreen logic.
//       // ----------------------------------------------------------

//       gaveTransactions.sort(
//         (a, b) =>
//             a.date.compareTo(b.date),
//       );

//       final Transaction loan =
//           gaveTransactions.first;

//       final String frequency =
//           loan.interestFrequency.isNotEmpty
//               ? loan.interestFrequency
//               : 'Monthly';

//       // ----------------------------------------------------------
//       // Schedule
//       // ----------------------------------------------------------

//       await scheduleCustomerPaymentReminder(
//         customer: customer,
//         loanDate: loan.date,
//         interestFrequency: frequency,
//         reminderType: reminderType,
//         amount: outstanding,
//       );
//     }
//   }

//   // ============================================================
//   // DAILY REMINDER
//   // ============================================================

//   Future<void> scheduleDailyReminder({
//     int hour = 9,
//     int minute = 0,
//   }) async {
//     await initialize();

//     // Remove existing daily reminder first.
//     await cancelDailyReminder();

//     final tz.TZDateTime now =
//         tz.TZDateTime.now(
//       tz.local,
//     );

//     tz.TZDateTime scheduled =
//         tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       hour,
//       minute,
//     );

//     // If today's time already passed,
//     // schedule from tomorrow.
//     if (!scheduled.isAfter(now)) {
//       scheduled = scheduled.add(
//         const Duration(days: 1),
//       );
//     }

//     const NotificationDetails details =
//         NotificationDetails(
//       android: AndroidNotificationDetails(
//         dailyChannelId,
//         'Daily Reminders',
//         channelDescription:
//             'Daily reminders to review pending collections.',
//         importance: Importance.defaultImportance,
//         priority: Priority.defaultPriority,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );

//     await _plugin.zonedSchedule(
//       id: dailyReminderId,
//       title: 'Daily Reminder',
//       body:
//           'Review today\'s pending collections.',
//       scheduledDate: scheduled,
//       notificationDetails: details,
//       androidScheduleMode:
//           AndroidScheduleMode.inexactAllowWhileIdle,
//       matchDateTimeComponents:
//           DateTimeComponents.time,
//       payload: 'daily_reminder',
//     );

//     debugPrint(
//       '[LocalNotification] '
//       'Daily reminder scheduled '
//       'at $hour:$minute',
//     );
//   }

//   // ============================================================
//   // CANCEL DAILY REMINDER
//   // ============================================================

//   Future<void> cancelDailyReminder() async {
//     await initialize();

//     await _plugin.cancel(
//       id: dailyReminderId,
//     );

//     debugPrint(
//       '[LocalNotification] '
//       'Daily reminder cancelled',
//     );
//   }

//   // ============================================================
//   // CANCEL ONE PAYMENT REMINDER
//   // ============================================================

//   Future<void> cancelPaymentReminder(
//     int notificationId,
//   ) async {
//     await initialize();

//     await _plugin.cancel(
//       id: notificationId,
//     );

//     debugPrint(
//       '[LocalNotification] '
//       'Payment reminder cancelled: '
//       '$notificationId',
//     );
//   }

//   // ============================================================
//   // CANCEL ALL PAYMENT REMINDERS
//   // ============================================================

//   Future<void> cancelAllPaymentReminders({
//     Isar? database,
//   }) async {
//     await initialize();

//     final Isar db =
//         database ?? IsarService.isar;

//     final customers =
//         await db.customers
//             .where()
//             .findAll();

//     for (final customer in customers) {
//       final int notificationId =
//           paymentReminderNotificationId(
//         customer.id,
//       );

//       await _plugin.cancel(
//         id: notificationId,
//       );
//     }

//     debugPrint(
//       '[LocalNotification] '
//       'All payment reminders cancelled',
//     );
//   }

//   // ============================================================
//   // CANCEL ALL NOTIFICATIONS
//   // ============================================================

//   Future<void> cancelAllNotifications() async {
//     await initialize();

//     await _plugin.cancelAll();

//     debugPrint(
//       '[LocalNotification] '
//       'All notifications cancelled',
//     );
//   }

//   // ============================================================
//   // CLICK HANDLER
//   // ============================================================

//   void _onNotificationResponse(
//     NotificationResponse response,
//   ) {
//     debugPrint(
//       '[LocalNotification] '
//       'Notification clicked',
//     );

//     debugPrint(
//       '[LocalNotification] Payload: '
//       '${response.payload}',
//     );

//     // Later we can use the payload to navigate:
//     //
//     // payment:123
//     //      ↓
//     // Customer details
//     //
//     // daily_reminder
//     //      ↓
//     // Pending collections
//   }

//   Future<void> showRealDeviceTestNotification() async {
//     await initialize();
//     await requestPermission();

//     const NotificationDetails details =
//         NotificationDetails(
//       android: AndroidNotificationDetails(
//         paymentChannelId,
//         'Payment Reminders',
//         channelDescription:
//             'Notifications for upcoming customer payment due dates.',
//         importance: Importance.max,
//         priority: Priority.high,
//         playSound: true,
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );

//     await _plugin.show(
//       id: 888888,
//       title: 'MyChopdi Test Notification',
//       body: 'Notifications are working correctly on this device.',
//       notificationDetails: details,
//       payload: 'device_test',
//     );

//     debugPrint(
//       '[LocalNotification] REAL DEVICE TEST SENT',
//     );
//   }

//   Future<void> scheduleTestNotificationAfterOneMinute() async {
//     await initialize();
//     await requestPermission();

//     final tz.TZDateTime scheduledDate =
//         tz.TZDateTime.now(tz.local).add(
//       const Duration(minutes: 1),
//     );

//     const NotificationDetails details =
//         NotificationDetails(
//       android: AndroidNotificationDetails(
//         paymentChannelId,
//         'Payment Reminders',
//         channelDescription:
//             'Notifications for upcoming customer payment due dates.',
//         importance: Importance.high,
//         priority: Priority.high,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );

//     await _plugin.zonedSchedule(
//       id: 777777,
//       title: 'TEST Payment Reminder',
//       body: 'This is a test notification from MyChopdi.',
//       scheduledDate: scheduledDate,
//       notificationDetails: details,
//       androidScheduleMode:
//           AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: 'test_payment',
//     );

//     debugPrint(
//       '[TEST] Notification scheduled for: $scheduledDate',
//     );
//   }

//   Future<void> scheduleTestDailyReminder() async {
//     await initialize();
//     await requestPermission();

//     final scheduled =
//         tz.TZDateTime.now(tz.local).add(
//       const Duration(minutes: 1),
//     );

//     const NotificationDetails details =
//         NotificationDetails(
//       android: AndroidNotificationDetails(
//         dailyChannelId,
//         'Daily Reminders',
//         channelDescription:
//             'Daily reminders to review pending collections.',
//         importance: Importance.high,
//         priority: Priority.high,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );

//     await _plugin.zonedSchedule(
//       id: dailyReminderId,
//       title: 'Daily Reminder',
//       body: 'Review today\'s pending collections.',
//       scheduledDate: scheduled,
//       notificationDetails: details,
//       androidScheduleMode:
//           AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: 'daily_reminder',
//     );

//     debugPrint(
//       '[LocalNotification] TEST daily reminder scheduled '
//       'for $scheduled',
//     );
//   }
// }


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

  // Keep daily notification ID separate.
  static const int dailyReminderId = 900000;

  // Test notification ID.
  static const int testNotificationId = 999999;

  // Base ID for payment reminders.
  //
  // We use one deterministic ID per customer so that an old
  // reminder can be cancelled before a new one is scheduled.
  static const int paymentReminderIdBase = 100000;

  // ============================================================
  // SHARED PREFERENCES KEYS
  // ============================================================

  static const String paymentReminderKey =
      'notification_payment_reminder_enabled';

  static const String selectedReminderKey =
      'notification_selected_reminder';

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    // Initialize timezone database.
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

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

    // -------------------------------
    // Android
    // -------------------------------

    final AndroidFlutterLocalNotificationsPlugin?
        androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // -------------------------------
    // iOS
    // -------------------------------

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
  // TEST NOTIFICATION
  // ============================================================

  Future<void> showTestNotification() async {
    await initialize();
    await requestPermission();

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
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: testNotificationId,
      title: 'Notifications Enabled',
      body: 'Your notification settings are now active.',
      notificationDetails: details,
      payload: 'test_notification',
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

    while (!dueDate.isAfter(
      DateTime(
        today.year,
        today.month,
        today.day,
      ),
    )) {
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
        // Keep existing app behavior safe.
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

    // Last day of next month.
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

    // Handle Feb 29 in non-leap years.
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

    // ============================================================
    // CALCULATE REMINDER DATE
    // ============================================================

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

    // ============================================================
    // DON'T SCHEDULE PAST NOTIFICATIONS
    // ============================================================

    if (scheduledDate.isBefore(
      DateTime.now(),
    )) {
      debugPrint(
        '[LocalNotification] '
        'Skipping past payment reminder: '
        '$scheduledDate',
      );

      return;
    }

    // ============================================================
    // MESSAGE
    // ============================================================

    final String amountText =
        amount == null
            ? ''
            : ' Amount due: ₹${amount.toStringAsFixed(2)}.';

    final String title =
        'Payment Reminder';

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

    // ============================================================
    // DETAILS
    // ============================================================

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
      iOS: DarwinNotificationDetails(),
    );

    // ============================================================
    // SCHEDULE
    // ============================================================

    final tz.TZDateTime notificationDate =
        tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: notificationDate,
      notificationDetails: details,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'payment:$notificationId',
    );

    debugPrint(
      '[LocalNotification] '
      'Payment reminder scheduled: '
      '$notificationDate',
    );
  }

  // ============================================================
  // SCHEDULE PAYMENT REMINDER FOR CUSTOMER
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

    // Always remove the old reminder first.
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

    final prefs =
        await SharedPreferences.getInstance();

    final bool enabled =
        prefs.getBool(
              paymentReminderKey,
            ) ??
            true;

    final String reminderType =
        prefs.getString(
              selectedReminderKey,
            ) ??
            'dueDate';

    // ------------------------------------------------------------
    // Get customers
    // ------------------------------------------------------------

    final customers =
        await db.customers
            .where()
            .findAll();

    // ------------------------------------------------------------
    // Process each customer
    // ------------------------------------------------------------

    for (final customer in customers) {
      final int notificationId =
          paymentReminderNotificationId(
        customer.id,
      );

      // Always cancel the customer's old reminder first.
      // This prevents an old reminder from remaining after
      // a payment has been added or the balance has changed.
      await cancelPaymentReminder(
        notificationId,
      );

      if (!enabled) {
        continue;
      }

      // ----------------------------------------------------------
      // Get customer's transactions
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

      // ==========================================================
      // CUSTOMER OWES YOU
      //
      // gave     = money you gave to customer
      // received = money customer returned to you
      //
      // Outstanding:
      //     totalGiven - totalReceived + totalInterest
      // ==========================================================

      final gaveTransactions =
          transactions
              .where(
                (transaction) =>
                    transaction.type ==
                    TransactionType.gave,
              )
              .toList();

      // ==========================================================
      // YOU OWE CUSTOMER
      //
      // took = money customer gave to you
      // paid = money you returned to customer
      //
      // Outstanding:
      //     totalTook - totalPaid + totalInterest
      // ==========================================================

      final tookTransactions =
          transactions
              .where(
                (transaction) =>
                    transaction.type ==
                    TransactionType.took,
              )
              .toList();

      // ----------------------------------------------------------
      // No loan/debt transaction means no payment reminder.
      // ----------------------------------------------------------

      if (gaveTransactions.isEmpty &&
          tookTransactions.isEmpty) {
        continue;
      }

      // ----------------------------------------------------------
      // Calculate customer -> you balance.
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
      // Calculate you -> customer balance.
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
      // Select the active side.
      //
      // A customer normally belongs to one side:
      //   gave/received OR took/paid.
      //
      // If both sides exist, keep the side that currently has
      // an outstanding balance. This avoids scheduling a reminder
      // for a fully settled side.
      // ----------------------------------------------------------

      final bool hasCustomerOwesYouBalance =
          customerOwesYou > 0;

      final bool hasYouOweCustomerBalance =
          youOweCustomer > 0;

      if (!hasCustomerOwesYouBalance &&
          !hasYouOweCustomerBalance) {
        debugPrint(
          '[LocalNotification] '
          'No reminder for ${customer.name}. '
          'Both balances are settled.',
        );
        continue;
      }

      final bool useCustomerOwesYou =
          hasCustomerOwesYouBalance;

      final List<Transaction> activeLoans =
          useCustomerOwesYou
              ? gaveTransactions
              : tookTransactions;

      final double outstanding =
          useCustomerOwesYou
              ? customerOwesYou
              : youOweCustomer;

      // ----------------------------------------------------------
      // Use the first loan/took transaction.
      //
      // This preserves the existing behaviour of using the
      // original transaction's interest frequency.
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
      // Schedule the reminder.
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

    // Remove existing daily reminder first.
    await cancelDailyReminder();

    final tz.TZDateTime now =
        tz.TZDateTime.now(
      tz.local,
    );

    tz.TZDateTime scheduled =
        tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If today's time already passed,
    // schedule from tomorrow.
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
      iOS: DarwinNotificationDetails(),
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
      'Daily reminder scheduled '
      'at $hour:$minute',
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
      'Payment reminder cancelled: '
      '$notificationId',
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
  // CLICK HANDLER
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

    // Later we can use the payload to navigate:
    //
    // payment:123
    //      ↓
    // Customer details
    //
    // daily_reminder
    //      ↓
    // Pending collections
  }

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
      id: 888888,
      title: 'MyChopdi Test Notification',
      body: 'Notifications are working correctly on this device.',
      notificationDetails: details,
      payload: 'device_test',
    );

    debugPrint(
      '[LocalNotification] REAL DEVICE TEST SENT',
    );
  }

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
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: 777777,
      title: 'TEST Payment Reminder',
      body: 'This is a test notification from MyChopdi.',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'test_payment',
    );

    debugPrint(
      '[TEST] Notification scheduled for: $scheduledDate',
    );
  }

  Future<void> scheduleTestDailyReminder() async {
    await initialize();
    await requestPermission();

    final scheduled =
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
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: dailyReminderId,
      title: 'Daily Reminder',
      body: 'Review today\'s pending collections.',
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'daily_reminder',
    );

    debugPrint(
      '[LocalNotification] TEST daily reminder scheduled '
      'for $scheduled',
    );
  }
}