// import 'package:isar_community/isar.dart';
// import 'package:mychopdi/model/notification.dart';

// class NotificationService {
//   final Isar isar;

//   NotificationService(this.isar);

//   /// Add a new notification.
//   Future<int> addNotification({
//     required String title,
//     required String subtitle,
//     required String type,
//     required int chopdiId,
//     int? customerId,
//     String? customerName,
//     double? amount,
//   }) async {
//     final notification = NotificationModel()
//       ..title = title
//       ..subtitle = subtitle
//       ..type = type
//       ..createdAt = DateTime.now()
//       ..customerId = customerId
//       ..customerName = customerName
//       ..amount = amount
//       ..chopdiId = chopdiId;

//     return await isar.writeTxn(() async {
//       return await isar.notificationModels.put(notification);
//     });
//   }

//   /// Watch notifications for one Chopdi.
//   Stream<List<NotificationModel>> watchNotifications(
//     int chopdiId,
//   ) {
//     return isar.notificationModels
//         .filter()
//         .chopdiIdEqualTo(chopdiId)
//         .sortByCreatedAtDesc()
//         .watch(
//           fireImmediately: true,
//         );
//   }

//   /// Number of unread notifications.
//   Stream<int> watchUnreadCount(int chopdiId) {
//     return isar.notificationModels
//         .filter()
//         .chopdiIdEqualTo(chopdiId)
//         .isReadEqualTo(false)
//         .watch(
//           fireImmediately: true,
//         )
//         .map((notifications) => notifications.length);
//   }

//   /// Mark one notification as read.
//   Future<void> markAsRead(int notificationId) async {
//     final notification =
//         await isar.notificationModels.get(notificationId);

//     if (notification == null) return;

//     notification.isRead = true;

//     await isar.writeTxn(() async {
//       await isar.notificationModels.put(notification);
//     });
//   }

//   /// Mark all notifications of one Chopdi as read.
//   Future<void> markAllAsRead(int chopdiId) async {
//     final notifications = await isar.notificationModels
//         .filter()
//         .chopdiIdEqualTo(chopdiId)
//         .isReadEqualTo(false)
//         .findAll();

//     if (notifications.isEmpty) return;

//     for (final notification in notifications) {
//       notification.isRead = true;
//     }

//     await isar.writeTxn(() async {
//       await isar.notificationModels.putAll(notifications);
//     });
//   }

//   /// Delete one notification.
//   Future<void> deleteNotification(int id) async {
//     await isar.writeTxn(() async {
//       await isar.notificationModels.delete(id);
//     });
//   }

//   /// Delete all notifications for a Chopdi.
//   Future<void> clearAll(int chopdiId) async {
//     await isar.writeTxn(() async {
//       await isar.notificationModels
//           .filter()
//           .chopdiIdEqualTo(chopdiId)
//           .deleteAll();
//     });
//   }
// }

import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/notification.dart';

class NotificationService {
  final Isar isar;

  NotificationService(this.isar);

  // Future<void> createLoanNotification({
  //   required int chopdiId,
  //   required String loanType,
  //   required String customerName,
  //   required double amount,
  //   int? customerId,
  // }) async {
  //   final bool isGaveLoan = loanType == "gave";

  //   final notification = NotificationModel()
  //     ..title = isGaveLoan
  //         ? "Loan Given"
  //         : "Loan Taken"
  //     ..subtitle = isGaveLoan
  //         ? "You gave ₹${amount.toStringAsFixed(0)} to $customerName."
  //         : "You took ₹${amount.toStringAsFixed(0)} from $customerName."
  //     ..type = isGaveLoan
  //         ? "loan_given"
  //         : "loan_taken"
  //     ..createdAt = DateTime.now()
  //     ..isRead = false
  //     ..customerId = customerId
  //     ..customerName = customerName
  //     ..amount = amount
  //     ..chopdiId = chopdiId;

  //   await isar.writeTxn(() async {
  //     await isar.notificationModels.put(notification);
  //   });
  // }

  Future<int> createLoanNotification({
    required int chopdiId,
    required String loanType,
    required String customerName,
    required double amount,
    int? customerId,
  }) async {
    final bool isGaveLoan = loanType == "gave";

    final notification = NotificationModel()
      ..title = isGaveLoan
          ? "Loan Given"
          : "Loan Taken"
      ..subtitle = isGaveLoan
          ? "You gave ₹${amount.toStringAsFixed(0)} to $customerName."
          : "You took ₹${amount.toStringAsFixed(0)} from $customerName."
      ..type = isGaveLoan
          ? "loan_given"
          : "loan_taken"
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

  Stream<List<NotificationModel>> watchUnreadNotifications(
    int chopdiId,
  ) {
    return isar.notificationModels
        .filter()
        .chopdiIdEqualTo(chopdiId)
        .isReadEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(
          fireImmediately: true,
        );
  }

  Future<void> markAsRead(int id) async {
    final notification =
        await isar.notificationModels.get(id);

    if (notification == null) return;

    notification.isRead = true;

    await isar.writeTxn(() async {
      await isar.notificationModels.put(notification);
    });
  }

  Future<void> markAllAsRead(int chopdiId) async {
    final notifications = await isar.notificationModels
        .filter()
        .chopdiIdEqualTo(chopdiId)
        .isReadEqualTo(false)
        .findAll();

    if (notifications.isEmpty) return;

    for (final notification in notifications) {
      notification.isRead = true;
    }

    await isar.writeTxn(() async {
      await isar.notificationModels.putAll(
        notifications,
      );
    });
  }

  Future<void> deleteNotification(int id) async {
    await isar.writeTxn(() async {
      await isar.notificationModels.delete(id);
    });
  }

  Future<void> clearAll(int chopdiId) async {
    await isar.writeTxn(() async {
      await isar.notificationModels
          .filter()
          .chopdiIdEqualTo(chopdiId)
          .deleteAll();
    });
  }
}