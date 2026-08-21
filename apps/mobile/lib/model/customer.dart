// import 'package:isar_community/isar.dart';
// part 'customer.g.dart';
// @collection
// class Customer {

//   Id id = Isar.autoIncrement;

//   late String name;
//   late String phone;
//   late double amount;
//   late double interest;
//   late String status;
//   late bool received;
//   late String loan;

// }

import 'package:isar_community/isar.dart';

import 'sync_status.dart';

part 'customer.g.dart';

@collection
class Customer {
  /// Local row id. Isar's `Id` is an `int` alias — a String primary key is not
  /// possible — so this stays autoincrement and is **never sent anywhere**.
  /// It collides across devices by design; only [uuid] crosses the wire.
  Id id = Isar.autoIncrement;

  /// The synced identity: a client-generated UUIDv7, minted when the row is
  /// created even while offline.
  ///
  /// Defaults to empty rather than being `late` on purpose. Rows written by an
  /// earlier build have no value for this column, and a `late` non-nullable
  /// field throws the moment such a row is read — before the migration that
  /// would have filled it ever gets a chance to run. An empty string is
  /// readable, and the migration replaces it.
  /// Indexed for lookup, but deliberately **not** unique.
  ///
  /// A unique index here is a data-loss bug, not a safeguard. Every row written
  /// by the previous build carries the empty default, so a unique index sees
  /// them all as the same key: with `replace` it collapses an entire customer
  /// list into one row, and without it the first write after upgrade throws.
  /// Verified in test/isar_migration_safety_test.dart — five rows became one.
  ///
  /// Uniqueness is guaranteed where it can be: ids are UUIDv7, minted once, and
  /// the repository is the only write path, so upserts look the row up by uuid
  /// before writing. A database constraint that destroys data to enforce an
  /// invariant the application already holds is a bad trade.
  @Index()
  String uuid = '';

  late String name;

  late String phone;

  late String status;

  late bool received;

  String notes = '';

  /// Server-assigned optimistic-concurrency version. 0 means "never synced".
  int version = 0;

  /// Last local modification, used as the tiebreak for non-financial fields.
  DateTime updatedAt = DateTime.utc(1970);

  /// Soft delete. Hard deletes cannot be communicated to another device — the
  /// row simply stops appearing, indistinguishable from one never seen.
  DateTime? deletedAt;

  @enumerated
  SyncStatus syncStatus = SyncStatus.pending;
  /// Defaulted, not `late`.
  ///
  /// Isar adds a new column to existing rows with no value, and a `late`
  /// non-nullable field throws `LateInitializationError` the moment such a row
  /// is read — which is every row already on a user's device. The app could not
  /// load a single existing customer. A default is readable; code that
  /// needs the real value sets it explicitly.
  int chopdiId = 0;

  /// See [chopdiId] for why this is not `late`.
  String loanType = '';
}