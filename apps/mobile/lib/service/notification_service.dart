import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/notification.dart';

class NotificationService {
  final Isar isar;

  NotificationService(this.isar);

  // ============================================================
  // APP UPDATE NOTIFICATION
  // ============================================================

  Future<int> createAppUpdateNotification({
    required int chopdiId,
    required String version,
    String? message,
  }) async {
    final notification = NotificationModel()
      ..title = "App Update"
      ..subtitle = message ??
          "A new version of Chopdi ($version) is available."
      ..type = "app_update"
      ..createdAt = DateTime.now()
      ..isRead = false
      ..chopdiId = chopdiId;

    return await isar.writeTxn(() async {
      return await isar.notificationModels.put(notification);
    });
  }

  // ============================================================
  // INTEREST CALCULATED NOTIFICATION
  // ============================================================

  Future<int> createInterestNotification({
    required int chopdiId,
    required String customerName,
    required double interestAmount,
    int? customerId,
  }) async {
    final notification = NotificationModel()
      ..title = "Interest Calculated"
      ..subtitle =
          "₹${interestAmount.toStringAsFixed(2)} interest calculated for $customerName."
      ..type = "interest_calculated"
      ..createdAt = DateTime.now()
      ..isRead = false
      ..customerId = customerId
      ..customerName = customerName
      ..amount = interestAmount
      ..chopdiId = chopdiId;

    return await isar.writeTxn(() async {
      return await isar.notificationModels.put(notification);
    });
  }

  // ============================================================
  // INTEREST UPDATED
  // ============================================================

  Future<int> createInterestUpdatedNotification({
    required int chopdiId,
    required String customerName,
    required double interestAmount,
    required String interestPeriod,
    int? customerId,
  }) async {
    final notification = NotificationModel()
      ..title = "Interest Updated"
      ..subtitle =
          "Interest for $interestPeriod for $customerName has been updated to ₹${interestAmount.toStringAsFixed(2)}."
      ..type = "interest_updated"
      ..createdAt = DateTime.now()
      ..isRead = false
      ..customerId = customerId
      ..customerName = customerName
      ..amount = interestAmount
      ..chopdiId = chopdiId;

    return await isar.writeTxn(() async {
      return await isar.notificationModels.put(
        notification,
      );
    });
  }

  Future<int> createPaymentReminderNotification({
    required int chopdiId,
    required String customerName,
    required DateTime dueDate,
    required String reminderType,
    int? customerId,
    double? amount,
  }) async {
    String reminderText;

    switch (reminderType) {
      case 'oneDayBefore':
        reminderText = 'Payment is due tomorrow';
        break;

      case 'threeDaysBefore':
        reminderText = 'Payment is due in 3 days';
        break;

      case 'dueDate':
      default:
        reminderText = 'Payment is due today';
        break;
    }

    final amountText = amount == null
        ? ''
        : ' Amount: ₹${amount.toStringAsFixed(2)}.';

    final notification = NotificationModel()
      ..title = 'Payment Reminder'
      ..subtitle =
          '$reminderText for $customerName.$amountText'
      ..type = 'payment_reminder'
      ..createdAt = DateTime.now()
      ..isRead = false
      ..customerId = customerId
      ..customerName = customerName
      ..amount = amount
      ..chopdiId = chopdiId;

    return await isar.writeTxn(() async {
      return await isar.notificationModels.put(
        notification,
      );
    });
  }

  // ============================================================
  // WATCH ALL NOTIFICATIONS
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
  // MARK ONE AS READ
  // ============================================================

  Future<void> markAsRead(
    int notificationId,
  ) async {
    final notification =
        await isar.notificationModels.get(notificationId);

    if (notification == null) {
      return;
    }

    notification.isRead = true;

    await isar.writeTxn(() async {
      await isar.notificationModels.put(
        notification,
      );
    });
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> markAllAsRead(
    int chopdiId,
  ) async {
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
      await isar.notificationModels.putAll(
        notifications,
      );
    });
  }

  // ============================================================
  // DELETE ONE
  // ============================================================

  Future<void> deleteNotification(
    int notificationId,
  ) async {
    await isar.writeTxn(() async {
      await isar.notificationModels.delete(
        notificationId,
      );
    });
  }

  // ============================================================
  // DELETE ALL
  // ============================================================

  Future<void> clearAll(
    int chopdiId,
  ) async {
    await isar.writeTxn(() async {
      await isar.notificationModels
          .filter()
          .chopdiIdEqualTo(chopdiId)
          .deleteAll();
    });
  }
}