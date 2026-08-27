// See api_client.dart: `required this._isar` would create a *private* named
// parameter, which is unusable from any other file because privacy in Dart is
// library-scoped.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../model/customer.dart';
import '../../model/sync_meta.dart';
import '../../model/sync_op.dart';
import '../../model/sync_status.dart';
import '../../model/transaction.dart';
import '../remote/api_exception.dart';
import '../remote/sync_api.dart';
import '../repository/sync_queue.dart';

/// What one drain attempt did. Worth surfacing: "saved" and "safe" are
/// different states, and the user is entitled to know which one they are in.
class SyncResult {
  const SyncResult({
    this.pushed = 0,
    this.conflicted = 0,
    this.deadLettered = 0,
    this.remaining = 0,
    this.stoppedBecause,
  });

  final int pushed;
  final int conflicted;
  final int deadLettered;
  final int remaining;

  /// Null when the queue drained cleanly.
  final String? stoppedBecause;

  bool get isComplete => stoppedBecause == null && remaining == 0;

  @override
  String toString() => stoppedBecause == null
      ? 'Sync: $pushed pushed, $conflicted conflicted, '
          '$deadLettered dead-lettered, $remaining remaining'
      : 'Sync stopped ($stoppedBecause): $pushed pushed, $remaining remaining';
}

/// Drains the outbox to the server.
///
/// The outbox and its idempotency keys already existed; this is the half that
/// sends them. Everything here is built around one asymmetry: **losing a
/// ledger entry is far worse than sending one twice.** The server deduplicates
/// on `opId`, so when the two options are "retry and risk a duplicate the
/// server will collapse" and "give up and risk losing a financial record", this
/// always retries.
class SyncEngine {
  SyncEngine({
    required Isar isar,
    required SyncApi api,
    SyncQueue queue = const SyncQueue(),
  })  : _isar = isar,
        _api = api,
        _queue = queue;

  final Isar _isar;
  final SyncApi _api;
  final SyncQueue _queue;

  static const _uuid = Uuid();

  /// Matches `ArrayMaxSize(200)` on the server's `PushBatchDto`. A larger batch
  /// is rejected outright, so this is a contract value, not a tuning knob.
  static const int batchSize = 200;

  /// Attempts against a *reachable* server before an operation is parked.
  ///
  /// Network failures deliberately do not count toward this — see
  /// [SyncOp.attempts]. A week-long outage must not dead-letter valid entries.
  static const int maxAttempts = 5;

  /// Requests one drain may issue before yielding.
  ///
  /// The server allows 300 requests per minute per IP, shared with auth. A
  /// device returning from a long offline stretch could otherwise push tens of
  /// thousands of operations in an unbroken burst and spend that budget for
  /// everyone behind the same NAT — an office, or a carrier gateway. At 200
  /// operations per request this still moves 4,000 per drain, and the next
  /// drain follows a second later, so a real backlog clears in seconds while
  /// the request rate stays bounded.
  static const int maxBatchesPerDrain = 20;

  /// Breathing room between batches, so a backlog arrives as a stream rather
  /// than a spike.
  static const Duration _betweenBatches = Duration(milliseconds: 250);

  /// Guards against two drains running at once.
  ///
  /// Two concurrent drains would send the same operations twice. The server's
  /// idempotency makes that survivable rather than corrupting, but it doubles
  /// traffic and interleaves result handling, so a single-flight latch is
  /// cheaper than reasoning about the race.
  bool _running = false;

  bool get isRunning => _running;

  /// Sends everything waiting, in batches, until the queue is empty.
  ///
  /// Never throws. A sync failure is not something a caller can meaningfully
  /// handle — the data is safe locally either way — so failure is reported in
  /// the returned [SyncResult] rather than as an exception that some call site
  /// will inevitably forget to catch.
  Future<SyncResult> drain() async {
    if (_running) {
      return const SyncResult(stoppedBecause: 'already running');
    }

    _running = true;

    var pushed = 0;
    var conflicted = 0;
    var deadLettered = 0;

    try {
      final meta = await _meta();

      // A reinstall leaves credentials in secure storage while the database —
      // and every idempotency key in it — is gone. Re-sending rows whose keys
      // no longer exist would duplicate them server-side, so this device may
      // only pull until it is reconciled.
      if (meta.recoveryMode) {
        return SyncResult(
          remaining: await _queue.pendingCount(_isar),
          stoppedBecause: 'recovery mode',
        );
      }

      final sessionId = _uuid.v7();

      for (var round = 0; round < maxBatchesPerDrain; round++) {
        final batch = await _sendable();
        if (batch.isEmpty) break;

        // Not before the first request — an app-start drain of a handful of
        // entries should not pay a quarter second for nothing.
        if (round > 0) await Future<void>.delayed(_betweenBatches);

        final SyncPushResponse response;

        try {
          response = await _api.push(
            operations: batch.map(_toWire).toList(),
            syncSessionId: sessionId,
          );
        } on ApiException catch (error) {
          // The whole request failed, so no operation has an outcome. Nothing
          // is dead-lettered here: a batch-level failure says nothing about
          // whether any individual entry is valid.
          await _recordBatchFailure(batch, error);

          return SyncResult(
            pushed: pushed,
            conflicted: conflicted,
            deadLettered: deadLettered,
            remaining: await _queue.pendingCount(_isar),
            stoppedBecause: error.requiresReauth
                ? 'sign-in required'
                : error.code == 'NETWORK_UNAVAILABLE'
                    ? 'offline'
                    : error.message,
          );
        }

        final counts = await _applyResults(batch, response);

        pushed += counts.pushed;
        conflicted += counts.conflicted;
        deadLettered += counts.deadLettered;

        await _markPushed();

        // Every operation in the batch failed *and* none was retryable-with-
        // progress. Without this the loop would re-select the same rows and
        // spin. A backoff was already stamped on them, so the next drain picks
        // them up when it is due.
        if (counts.settled == 0) break;
      }

      return SyncResult(
        pushed: pushed,
        conflicted: conflicted,
        deadLettered: deadLettered,
        remaining: await _queue.pendingCount(_isar),
      );
    } catch (error) {
      // Belt and braces: a drain must never take the app down.
      return SyncResult(
        pushed: pushed,
        conflicted: conflicted,
        deadLettered: deadLettered,
        remaining: await _queue.pendingCount(_isar),
        stoppedBecause: error.toString(),
      );
    } finally {
      _running = false;
    }
  }

  // ---------------------------------------------------------------- internals

  /// Pending operations whose backoff has elapsed, oldest first.
  Future<List<SyncOp>> _sendable() => _queue.sendable(
        _isar,
        now: DateTime.now().toUtc(),
        limit: batchSize,
      );

  Map<String, dynamic> _toWire(SyncOp op) => {
        'opId': op.opId,
        'entity': op.entity,
        'entityId': op.entityId,
        'opType': op.opType,
        // Sent as frozen at enqueue time. Re-serialising here would put
        // different bytes under an opId the server has already hashed, which it
        // rejects permanently as key reuse.
        'payload': jsonDecode(op.payload),
        if (op.expectedVersion != null) 'expectedVersion': op.expectedVersion,
      };

  Future<_Counts> _applyResults(
    List<SyncOp> batch,
    SyncPushResponse response,
  ) async {
    final byOpId = {for (final op in batch) op.opId: op};
    final counts = _Counts();

    await _isar.writeTxn(() async {
      for (final result in response.results) {
        final op = byOpId.remove(result.opId);
        if (op == null) continue;

        if (result.isSuccess) {
          await _markRowSynced(op, result.version);
          await _isar.syncOps.delete(op.id);
          counts.pushed++;
          counts.settled++;
          continue;
        }

        if (result.isConflict) {
          // Financial fields are never merged automatically. The row is parked
          // as conflicted for the user to resolve; resolving needs the pull
          // half, which does not exist yet, so this is where it stops today.
          await _markRowStatus(op, SyncStatus.conflicted);
          op
            ..deadLettered = true
            ..lastErrorCode = 'CONFLICT'
            ..lastError = result.error?.message ?? 'Changed on another device.';
          await _isar.syncOps.put(op);
          counts.conflicted++;
          counts.settled++;
          continue;
        }

        final error = result.error;
        final outOfAttempts = op.attempts + 1 >= maxAttempts;

        if ((error?.permanent ?? false) || outOfAttempts) {
          await _markRowStatus(op, SyncStatus.deadLettered);
          op
            ..attempts = op.attempts + 1
            ..deadLettered = true
            ..lastErrorCode = error?.code
            ..lastError = error?.message ?? 'Rejected by the server.';
          await _isar.syncOps.put(op);
          counts.deadLettered++;
          counts.settled++;
          continue;
        }

        // Retryable: the server was reachable and said no for a reason that
        // may not hold next time (a parent row that had not arrived yet, a
        // transient database error). Counts as an attempt, backs off.
        op
          ..attempts = op.attempts + 1
          ..nextAttemptAt = _backoffFrom(op.attempts + 1)
          ..lastErrorCode = error?.code
          ..lastError = error?.message;
        await _isar.syncOps.put(op);
      }

      // Operations the server did not mention at all. Not an error and not a
      // success — simply unknown, so they stay queued for the next drain.
      for (final orphan in byOpId.values) {
        orphan
          ..nextAttemptAt = _backoffFrom(orphan.attempts + 1)
          ..lastErrorCode = 'NO_RESULT'
          ..lastError = 'Server returned no result for this operation.';
        await _isar.syncOps.put(orphan);
      }
    });

    return counts;
  }

  /// Marks the domain row acknowledged and stores the version the server
  /// assigned — without it, the next update cannot state what it expected and
  /// every edit would look like a conflict.
  Future<void> _markRowSynced(SyncOp op, int? version) async {
    if (op.entity == 'customer') {
      final row =
          await _isar.customers.filter().uuidEqualTo(op.entityId).findFirst();
      if (row == null) return;

      row.syncStatus = SyncStatus.synced;
      if (version != null) row.version = version;
      await _isar.customers.put(row);
      return;
    }

    final row =
        await _isar.transactions.filter().uuidEqualTo(op.entityId).findFirst();
    if (row == null) return;

    row.syncStatus = SyncStatus.synced;
    if (version != null) row.version = version;
    await _isar.transactions.put(row);
  }

  Future<void> _markRowStatus(SyncOp op, SyncStatus status) async {
    if (op.entity == 'customer') {
      final row =
          await _isar.customers.filter().uuidEqualTo(op.entityId).findFirst();
      if (row == null) return;

      row.syncStatus = status;
      await _isar.customers.put(row);
      return;
    }

    final row =
        await _isar.transactions.filter().uuidEqualTo(op.entityId).findFirst();
    if (row == null) return;

    row.syncStatus = status;
    await _isar.transactions.put(row);
  }

  /// A whole-request failure. Network problems do not consume an attempt.
  Future<void> _recordBatchFailure(
    List<SyncOp> batch,
    ApiException error,
  ) async {
    // Did we actually reach the server? That single question decides both
    // behaviours below, because backoff and the attempt budget exist to protect
    // a server that answered — and neither applies to one we never spoke to.
    final reachedServer = error.isServerRejection;

    // A multi-day outage must not exhaust the attempt budget of valid entries.
    final consumesAttempt = reachedServer && !error.requiresReauth;

    await _isar.writeTxn(() async {
      for (final op in batch) {
        final attempts = consumesAttempt ? op.attempts + 1 : op.attempts;

        op
          ..attempts = attempts
          // No backoff for a network failure. Backing off throttles a server
          // under strain; there is no server in this case, and stamping a delay
          // means the operations queued during an outage are still waiting when
          // connectivity returns — the reconnect drain finds nothing due and
          // the user stays unsynced for no reason. The connectivity trigger and
          // the periodic timer already bound how often this is retried.
          ..nextAttemptAt =
              reachedServer ? _backoffFrom(attempts + 1) : op.nextAttemptAt
          ..lastErrorCode = error.code
          ..lastError = error.message;

        await _isar.syncOps.put(op);
      }
    });
  }

  /// Exponential backoff with jitter, capped.
  ///
  /// Capped because an offline-first app is expected to be offline for long
  /// stretches: an uncapped curve would push the next attempt days out after a
  /// handful of failures, so a user who regains signal would sit unsynced for
  /// no reason.
  ///
  /// Jittered because the failures that matter are correlated ones. When the
  /// API has an outage, every device backs off on the same curve from roughly
  /// the same moment and then retries in lockstep — the recovering server is hit
  /// by the whole fleet at once and knocked over again. Spreading each retry
  /// across its window turns that spike into a ramp.
  DateTime _backoffFrom(int attempt) {
    const base = Duration(seconds: 5);
    const cap = Duration(minutes: 15);

    final scaled = base * (1 << (attempt.clamp(1, 8) - 1));
    final delay = scaled > cap ? cap : scaled;

    // Equal jitter: half the delay is fixed, half is spread. Full jitter — a
    // uniform pick across the whole window — is the textbook choice, but it can
    // schedule a retry milliseconds after a failure, which is precisely the
    // hammering the backoff exists to prevent. Keeping a floor of delay/2
    // preserves the curve and still decorrelates the fleet.
    final half = delay.inMilliseconds ~/ 2;
    final spread =
        half == 0 ? 0 : DateTime.now().microsecondsSinceEpoch % (half + 1);

    return DateTime.now()
        .toUtc()
        .add(Duration(milliseconds: half + spread));
  }

  Future<SyncMeta> _meta() async {
    final existing = await _isar.syncMetas.get(0);
    return existing ?? (SyncMeta()..id = 0);
  }

  /// Records that a batch landed.
  ///
  /// [SyncMeta.cursor] is deliberately **not** advanced here. That field means
  /// "how far this device has *pulled*", and the `serverCursor` a push returns
  /// is the log position after our own writes — adopting it would tell a future
  /// pull it had already seen every change up to that point, silently skipping
  /// everything another device wrote. The two numbers live on the same scale,
  /// which is exactly what makes confusing them easy and costly.
  Future<void> _markPushed() async {
    await _isar.writeTxn(() async {
      final meta = await _isar.syncMetas.get(0) ?? SyncMeta();

      meta
        ..id = 0
        ..lastPushedAt = DateTime.now().toUtc();

      await _isar.syncMetas.put(meta);
    });
  }
}

class _Counts {
  int pushed = 0;
  int conflicted = 0;
  int deadLettered = 0;

  /// Operations that reached a terminal state this round. Zero means the loop
  /// made no progress and must stop rather than re-select the same rows.
  int settled = 0;
}
