import 'package:isar_community/isar.dart';

part 'notification.g.dart';

@collection
class NotificationModel {
  Id id = Isar.autoIncrement;

  late String title;
  late String subtitle;
  late String type;
  late DateTime createdAt;

  bool isRead = false;

  int? customerId;
  String? customerName;
  double? amount;
  int? chopdiId;
}