import 'package:isar_community/isar.dart';

part 'chopdi.g.dart';

@collection
class Chopdi {
  Id id = Isar.autoIncrement;

  late String name;

  String description =
      'My personal lending ledger\n'
      'to track loans and interest.';

  late DateTime createdAt;

  // Stores which Chopdi is currently active.
  bool isActive = false;
}