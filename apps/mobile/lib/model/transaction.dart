import 'package:isar_community/isar.dart';

import 'sync_status.dart';

part 'transaction.g.dart';

enum TransactionType {
  gave,
  received,
  took,
  paid,
}

@collection
class Transaction {
  /// Local row id only. See the note on [Customer.id].
  Id id = Isar.autoIncrement;

  /// The synced identity. Empty until the migration mints one — see
  /// [Customer.uuid] for why this is not `late`.
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

  /// Legacy local foreign key. Kept so the one-time migration can map it to
  /// [customerUuid]; nothing new should read it.
  late int customerId;

  /// The synced foreign key: the owning customer's [Customer.uuid].
  @Index()
  String customerUuid = '';

  /// The pre-paise value, still stored under its original column name.
  ///
  /// `@Name('amount')` is load-bearing: the generator keys properties by
  /// `isarName`, so the stored column and its property id are unchanged and
  /// existing rows map straight through. Renaming without it would read as
  /// "drop `amount`, add `legacyAmount`" and silently zero every ledger on
  /// upgrade.
  ///
  /// Migration input only. Nothing else should read it — use [amount].
  @Name('amount')
  double legacyAmount = 0;

  /// Amount as an exact integer count of paise. **The authoritative value.**
  ///
  /// Always positive; [type] carries the direction, which makes a negative
  /// amount unrepresentable rather than merely rejected.
  int amountPaise = 0;

  /// Rupee view of [amountPaise], for display and the existing UI.
  ///
  /// A derived getter rather than a second stored column, so there is exactly
  /// one number of record and the two cannot drift — a ledger that shows the
  /// user one figure while syncing another is the worst failure this app has.
  ///
  /// The fallback covers rows the migration has not reached yet: amounts are
  /// always positive, so a zero [amountPaise] means "not migrated", not "no
  /// money". Without it, a migration that failed would render every balance as
  /// ₹0 even though the data was intact.
  @ignore
  double get amount => amountPaise != 0 ? amountPaise / 100.0 : legacyAmount;

  /// Calculated interest in ₹.
  ///
  /// Display only, and deliberately never synced: interest is a function of
  /// time, so this is correct at the instant it was computed and stale the next
  /// morning. The server recomputes it on read and is authoritative.
  double interest = 0;

  /// The pre-basis-point rate, stored under its original column name.
  /// Migration input only — see [legacyAmount] for why `@Name` matters.
  @Name('interestRate')
  double legacyInterestRate = 0;

  /// Interest rate in basis points — 12.5% is 1250. **Authoritative.**
  int interestRateBp = 0;

  /// Percentage view of [interestRateBp], for display and the existing UI.
  @ignore
  double get interestRate =>
      interestRateBp != 0 ? interestRateBp / 100.0 : legacyInterestRate;

  late DateTime date;
  /// Defaulted, not `late`.
  ///
  /// Isar adds a new column to existing rows with no value, and a `late`
  /// non-nullable field throws `LateInitializationError` the moment such a row
  /// is read — which is every row already on a user's device. The app could not
  /// load a single existing entry. A default is readable; code that
  /// needs the real value sets it explicitly.
  int chopdiId = 0;

  @enumerated
  late TransactionType type;

  String description = "";
  String paymentMode = "";
  String interestType = "";
  String interestFrequency = "";

  int version = 0;

  DateTime updatedAt = DateTime.utc(1970);

  /// Soft delete for a financial record. The row is never removed, so the
  /// history survives and a later `create` carrying this uuid collides instead
  /// of silently resurrecting it.
  DateTime? voidedAt;
  String? voidedReason;

  @enumerated
  SyncStatus syncStatus = SyncStatus.pending;
}