// import 'package:isar/isar.dart';

// part 'chopdi.g.dart';

// @collection
// class Chopdi {
//   Id id = Isar.autoIncrement;

//   @Index(unique: true)
//   late String uuid;

//   late String name;

//   bool isActive = false;

//   DateTime createdAt = DateTime.now();

//   DateTime updatedAt = DateTime.now();

//   double totalPending = 0;

//   double totalReceived = 0;

//   final customers = IsarLinks<Customer>();
// }

import 'package:isar_community/isar.dart';

part 'chopdi.g.dart';

@collection
class Chopdi {
  Id id = Isar.autoIncrement;

  late String name;

  // String description = '';
   String description =
      'My personal lending ledger\n'
      'to track loans and interest.';

  late DateTime createdAt;
}