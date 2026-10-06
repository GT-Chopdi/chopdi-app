import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/notification.dart';
import 'package:mychopdi/service/local_notification_service.dart';

class NotificationService {
  final Isar isar;

  NotificationService(this.isar);

  // ============================================================
  // APP UPDATE
  // ============================================================

  Future<int> createAppUpdateNotification({
    required int chopdiId,
    required String version,
    String? message,
  }) async {
    final enabled =
    await LocalNotificationService.instance.areNotificationsEnabled();

    if (!enabled) {
      return -1;
    }

    final notification = NotificationModel()
      ..title = 'App Update'
      ..subtitle =
          message ?? 'A new version of Chopdi ($version) is available.'
      ..type = 'app_update'
      ..createdAt = DateTime.now()
      ..isRead = false
      ..chopdiId = chopdiId;

    final id = await isar.writeTxn(() async {
      return isar.notificationModels.put(notification);
    });

    await LocalNotificationService.instance.showAppEventNotification(
      id: id,
      title: notification.title,
      body: notification.subtitle,
      payload: 'app_update',
    );

    return id;
  }

  // ============================================================
  // INTEREST CALCULATED - CUSTOMER
  // ============================================================

  Future<int> createCustomerInterestNotification({
    required int chopdiId,
    required String customerName,
    required double interestAmount,
    required int customerId,
  }) async {
    final enabled =
    await LocalNotificationService.instance.areNotificationsEnabled();

    if (!enabled) {
      return -1;
    }

    final notification = NotificationModel()
      ..title = 'Interest Calculated'
      ..subtitle =
          '₹${interestAmount.toStringAsFixed(2)} '
          'interest calculated for Customer $customerName.'
      ..type = 'interest_calculated'
      ..createdAt = DateTime.now()
      ..isRead = false
      ..customerId = customerId
      ..customerName = customerName
      ..amount = interestAmount
      ..chopdiId = chopdiId;

    final id = await isar.writeTxn(() async {
      return isar.notificationModels.put(notification);
    });

    await LocalNotificationService.instance.showAppEventNotification(
      id: id,
      title: notification.title,
      body: notification.subtitle,
      payload: 'interest_calculated:customer:$customerId',
    );

    return id;
  }

  // ============================================================
  // INTEREST CALCULATED - LENDER
  // ============================================================

  Future<int> createLenderInterestNotification({
    required int chopdiId,
    required String lenderName,
    required double interestAmount,
    required int lenderId,
  }) async {
    final enabled =
    await LocalNotificationService.instance.areNotificationsEnabled();

    if (!enabled) {
      return -1;
    }

    final notification = NotificationModel()
      ..title = 'Interest Calculated'
      ..subtitle =
          '₹${interestAmount.toStringAsFixed(2)} '
          'interest calculated for Lender $lenderName.'
      ..type = 'lender_interest_calculated'
      ..createdAt = DateTime.now()
      ..isRead = false
      ..customerName = lenderName
      ..amount = interestAmount
      ..chopdiId = chopdiId;

    final id = await isar.writeTxn(() async {
      return isar.notificationModels.put(notification);
    });

    await LocalNotificationService.instance.showAppEventNotification(
      id: id,
      title: notification.title,
      body: notification.subtitle,
      payload: 'interest_calculated:lender:$lenderId',
    );

    return id;
  }

  // ============================================================
  // INTEREST UPDATED - CUSTOMER
  // ============================================================

  Future<int> createCustomerInterestUpdatedNotification({
    required int chopdiId,
    required String customerName,
    required double interestAmount,
    required String interestPeriod,
    required int customerId,
  }) async {
    final enabled =
    await LocalNotificationService.instance.areNotificationsEnabled();

    if (!enabled) {
      return -1;
    }

    final notification = NotificationModel()
      ..title = 'Interest Updated'
      ..subtitle =
          'Interest for $interestPeriod for Customer $customerName '
          'has been updated to '
          '₹${interestAmount.toStringAsFixed(2)}.'
      ..type = 'interest_updated'
      ..createdAt = DateTime.now()
      ..isRead = false
      ..customerId = customerId
      ..customerName = customerName
      ..amount = interestAmount
      ..chopdiId = chopdiId;

    final id = await isar.writeTxn(() async {
      return isar.notificationModels.put(notification);
    });

    await LocalNotificationService.instance.showAppEventNotification(
      id: id,
      title: notification.title,
      body: notification.subtitle,
      payload: 'interest_updated:customer:$customerId',
    );

    return id;
  }

  // ============================================================
  // INTEREST UPDATED - LENDER
  // ============================================================

  Future<int> createLenderInterestUpdatedNotification({
    required int chopdiId,
    required String lenderName,
    required double interestAmount,
    required String interestPeriod,
    required int lenderId,
  }) async {
    final enabled =
    await LocalNotificationService.instance.areNotificationsEnabled();

    if (!enabled) {
      return -1;
    }

    final notification = NotificationModel()
      ..title = 'Interest Updated'
      ..subtitle =
          'Interest for $interestPeriod for Lender $lenderName '
          'has been updated to '
          '₹${interestAmount.toStringAsFixed(2)}.'
      ..type = 'lender_interest_updated'
      ..createdAt = DateTime.now()
      ..isRead = false
      ..customerName = lenderName
      ..amount = interestAmount
      ..chopdiId = chopdiId;

    final id = await isar.writeTxn(() async {
      return isar.notificationModels.put(notification);
    });

    await LocalNotificationService.instance.showAppEventNotification(
      id: id,
      title: notification.title,
      body: notification.subtitle,
      payload: 'interest_updated:lender:$lenderId',
    );

    return id;
  }

  // ============================================================
  // WATCH NOTIFICATIONS
  // ============================================================

  Stream<List<NotificationModel>> watchNotifications(
      int chopdiId,
      ) {
    return isar.notificationModels
        .filter()
        .chopdiIdEqualTo(chopdiId)
        .sortByCreatedAtDesc()
        .watch(
      fireImmediately: true,
    );
  }

  // ============================================================
  // WATCH UNREAD COUNT
  // ============================================================

  Stream<int> watchUnreadCount(
      int chopdiId,
      ) {
    return isar.notificationModels
        .filter()
        .chopdiIdEqualTo(chopdiId)
        .isReadEqualTo(false)
        .watch(
      fireImmediately: true,
    )
        .map(
          (notifications) => notifications.length,
    );
  }

  // ============================================================
  // MARK AS READ
  // ============================================================

  Future<void> markAsRead(int notificationId) async {
    final notification =
    await isar.notificationModels.get(notificationId);

    if (notification == null) {
      return;
    }

    if (notification.isRead) {
      return;
    }

    notification.isRead = true;

    await isar.writeTxn(() async {
      await isar.notificationModels.put(notification);
    });
  }

  // ============================================================
  // MARK AS UNREAD
  // ============================================================

  Future<void> markAsUnread(int notificationId) async {
    final notification =
    await isar.notificationModels.get(notificationId);

    if (notification == null) {
      return;
    }

    if (!notification.isRead) {
      return;
    }

    notification.isRead = false;

    await isar.writeTxn(() async {
      await isar.notificationModels.put(notification);
    });
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> markAllAsRead(int chopdiId) async {
    final notifications = await isar.notificationModels
        .filter()
        .chopdiIdEqualTo(chopdiId)
        .isReadEqualTo(false)
        .findAll();

    if (notifications.isEmpty) {
      return;
    }

    for (final notification in notifications) {
      notification.isRead = true;
    }

    await isar.writeTxn(() async {
      await isar.notificationModels.putAll(notifications);
    });
  }

  // ============================================================
  // DELETE ONE
  // ============================================================

  Future<void> deleteNotification(int notificationId) async {
    await isar.writeTxn(() async {
      await isar.notificationModels.delete(notificationId);
    });
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  Future<void> clearAll(int chopdiId) async {
    await isar.writeTxn(() async {
      await isar.notificationModels
          .filter()
          .chopdiIdEqualTo(chopdiId)
          .deleteAll();
    });
  }
}