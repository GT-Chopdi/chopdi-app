import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../model/sync_op.dart';

/// Appends operations to the outbox.
///
/// Every method here **must** be called from inside an open `writeTxn` that
/// also writes the domain row. That is not a style preference: if the row and
/// its operation could commit separately, a crash between them would either
/// strand the entry on the device with nothing to sync it, or leave an
/// operation pointing at a row that does not exist. Isar has no nested
/// transactions, so the only way to guarantee it is for the caller to own the
/// transaction — hence these take an [Isar] and never open one.
class SyncQueue {
  const SyncQueue();

  static const _uuid = Uuid();

  /// Records a newly created row.
  Future<void> enqueueCreate(
    Isar isar, {
    required String entity,
    required String entityId,
    required Map<String, dynamic> payload,
  }) =>
      _append(isar, entity: entity, entityId: entityId, opType: 'create', payload: payload);

  /// Records a change, guarded by the version the client last saw.
  ///
  /// [expectedVersion] is what makes a conflict detectable: if the server has
  /// moved on, it rejects rather than overwriting, and the user is asked
  /// instead of silently losing an edit.
  Future<void> enqueueUpdate(
    Isar isar, {
    required String entity,
    required String entityId,
    required Map<String, dynamic> payload,
    required int expectedVersion,
  }) =>
      _append(
        isar,
        entity: entity,
        entityId: entityId,
        opType: 'update',
        payload: payload,
        expectedVersion: expectedVersion,
      );

  /// Records a soft delete.
  Future<void> enqueueVoid(
    Isar isar, {
    required String entity,
    required String entityId,
    required String reason,
    required int expectedVersion,
  }) =>
      _append(
        isar,
        entity: entity,
        entityId: entityId,
        opType: 'void',
        payload: {'reason': reason},
        expectedVersion: expectedVersion,
      );

  Future<void> _append(
    Isar isar, {
    required String entity,
    required String entityId,
    required String opType,
    required Map<String, dynamic> payload,
    int? expectedVersion,
  }) async {
    await isar.syncOps.put(
      SyncOp()
        // Minted once, here, and never regenerated. This is the idempotency
        // key: when the server commits and the response is lost, retrying with
        // the same key is what stops one loan becoming two.
        ..opId = _uuid.v7()
        ..entity = entity
        ..entityId = entityId
        ..opType = opType
        // Serialised now, not at send time. If the user edits the row before it
        // syncs, re-serialising would put different bytes under the same opId —
        // which the server rejects permanently as key reuse, dead-lettering an
        // entry that was perfectly valid. Freezing means an edit simply becomes
        // a second operation.
        ..payload = jsonEncode(payload)
        ..expectedVersion = expectedVersion
        ..createdAt = DateTime.now().toUtc(),
    );
  }

  /// Operations waiting to be sent, oldest first.
  ///
  /// Ordered by the autoincrement id, which is the local sequence: a create
  /// must reach the server before the update that follows it.
  Future<List<SyncOp>> pending(Isar isar, {int limit = 200}) => isar.syncOps
      // `where().anyId()` walks the primary-key index in order; a `filter()`
      // alone would return rows in unspecified order, and an update overtaking
      // the create it depends on is a rejected operation, not a slow one.
      .where()
      .anyId()
      .filter()
      .deadLetteredEqualTo(false)
      .limit(limit)
      .findAll();

  Future<int> pendingCount(Isar isar) =>
      isar.syncOps.filter().deadLetteredEqualTo(false).count();

  Future<int> deadLetterCount(Isar isar) =>
      isar.syncOps.filter().deadLetteredEqualTo(true).count();
}
