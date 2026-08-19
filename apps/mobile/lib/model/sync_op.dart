import 'package:isar_community/isar.dart';

part 'sync_op.g.dart';

/// One pending change, waiting to reach the server.
///
/// This is the outbox. Every domain write appends one of these **inside the
/// same `isar.writeTxn` as the row itself** — if the two were separate
/// transactions, a crash between them would either lose the intent to sync (the
/// user sees their entry, the server never does) or leave an operation for a
/// row that does not exist.
@collection
class SyncOp {
  /// Doubles as the local sequence number.
  ///
  /// Isar's autoincrement id is monotonic and device-local, which is exactly
  /// what ordering the outbox needs: a create must reach the server before the
  /// update that follows it. The same property that makes autoincrement wrong
  /// for domain rows — it collides across devices — is harmless here, because
  /// the outbox never leaves this phone.
  Id id = Isar.autoIncrement;

  /// Idempotency key: a client-generated UUIDv7, created with the row and
  /// **never regenerated on retry**.
  ///
  /// This is what makes a lost response survivable. When the server commits and
  /// the reply vanishes into a tunnel, the client cannot tell that apart from
  /// "it never arrived" — retrying duplicates a loan, not retrying loses one.
  /// Retrying with the same key lets the server recognise the operation and
  /// answer without writing again. Regenerating it is the single mistake that
  /// reintroduces duplicates.
  @Index(unique: true, replace: true)
  late String opId;

  /// `customer` | `ledger_entry`
  late String entity;

  /// The target row's `uuid`.
  @Index()
  late String entityId;

  /// `create` | `update` | `void`
  late String opType;

  /// The payload, frozen as JSON at enqueue time.
  ///
  /// Frozen, not re-serialised at send time, and that distinction matters: if
  /// the user edits a row before it syncs, re-serialising would send different
  /// bytes under the same [opId]. The server hashes the payload and rejects a
  /// known key carrying different content — a *permanent* rejection, so the
  /// entry would dead-letter instead of syncing. Freezing means an edit simply
  /// produces a second operation.
  late String payload;

  /// Guards an update against a concurrent change. Null for creates.
  int? expectedVersion;

  late DateTime createdAt;

  /// Attempts against a *reachable* server.
  ///
  /// Network failures deliberately do not count. A multi-day outage would
  /// otherwise exhaust the cap and dead-letter perfectly good entries, telling
  /// the user their data is broken when the server is simply down.
  int attempts = 0;

  DateTime? nextAttemptAt;

  String? lastErrorCode;
  String? lastError;

  /// Permanently rejected, or out of attempts. Kept, surfaced, never discarded.
  @Index()
  bool deadLettered = false;
}
