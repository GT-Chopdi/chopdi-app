import 'package:isar_community/isar.dart';

part 'user_session.g.dart';

@collection
class UserSession {
  Id id = Isar.autoIncrement;

  late String phoneNumber;

  late bool isLoggedIn;

  late DateTime loginTime;
}