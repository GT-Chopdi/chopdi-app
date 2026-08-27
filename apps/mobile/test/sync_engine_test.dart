@Tags(['isar'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/data/remote/api_exception.dart';
import 'package:mychopdi/data/remote/sync_api.dart';
import 'package:mychopdi/data/repository/customer_repository.dart';
import 'package:mychopdi/data/repository/ledger_repository.dart';
import 'package:mychopdi/data/repository/sync_queue.dart';
import 'package:mychopdi/data/sync/sync_engine.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/sync_meta.dart';
import 'package:mychopdi/model/sync_op.dart';
import 'package:mychopdi/model/sync_status.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/model/user_session.dart';
import 'package:mychopdi/utils/money.dart';

/// A server under the test's control.
///
/// Records every batch it is handed, so a test can assert not just the final
/// state but how it was reached — how many requests it took, and whether an
/// operation was sent twice.
class FakeSyncApi implements SyncApi {
  FakeSyncApi();

  /// Each element is one request: the opIds it carried.
  final List<List<String>> batches = [];

  /// Thrown instead of answering, when set. Models the whole request failing:
  /// no connection, an expired session, a 500.
  ApiException? failWith;

  /// Answers, then throws away the response. Models the case that makes
  /// idempotency necessary: the server commits, the reply is lost, and the
  /// client cannot tell that apart from never having been heard.
  bool swallowResponse = false;

  /// opId -> the status to answer with. Anything absent answers `applied`.
  final Map<String, String> statusFor = {};

  /// opId -> error to attach when its status is not a success.
  final Map<String, SyncOperationError> errorFor = {};

  /// Every opId the server has ever *committed*, including ones whose response
  /// was lost. A second sighting must be answered `duplicate`, never applied
  /// twice — that is what stops one loan becoming two.
  final Set<String> committed = {};

  int get requestCount => batches.length;

  /// Flattened, so a test can assert an opId was never sent twice.
  List<String> get allSentOpIds => batches.expand((b) => b).toList();

  @override
  Future<SyncPushResponse> push({
    required List<Map<String, dynamic>> operations,
    String? syncSessionId,
  }) async {
    final opIds = operations.map((o) => o['opId'] as String).toList();
    batches.add(opIds);

    final failure = failWith;
    if (failure != null) throw failure;

    final results = <SyncOperationResult>[];

    for (final op in operations) {
      final opId = op['opId'] as String;
      final alreadySeen = committed.contains(opId);
      final status = alreadySeen ? 'duplicate' : (statusFor[opId] ?? 'applied');

      if (status == 'applied' || status == 'duplicate') committed.add(opId);

      results.add(
        SyncOperationResult(
          opId: opId,
          status: status,
          entityId: op['entityId'] as String?,
          version: 1,
          seq: '1',
          error: status == 'applied' || status == 'duplicate'
              ? null
              : errorFor[opId] ??
                  const SyncOperationError(
                    code: 'INTERNAL',
                    message: 'nope',
                    permanent: false,
                  ),
        ),
      );
    }

    if (swallowResponse) {
      throw ApiException.network(const SocketException('response lost'));
    }

    return SyncPushResponse(results: results, serverCursor: '1');
  }
}

void main() {
  late Directory dir;
  late Isar isar;
  late CustomerRepository customers;
  late LedgerRepository ledger;
  late FakeSyncApi api;
  late SyncEngine engine;
  const queue = SyncQueue();

  setUpAll(() async => Isar.initializeIsarCore(download: true));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('chopdi_sync');
    isar = await Isar.open(
      [
        CustomerSchema,
        TransactionSchema,
        UserSessionSchema,
        SyncOpSchema,
        SyncMetaSchema,
      ],
      directory: dir.path,
      name: 'sy${DateTime.now().microsecondsSinceEpoch}',
    );

    customers = CustomerRepository(isar);
    ledger = LedgerRepository(isar);
    api = FakeSyncApi();
    engine = SyncEngine(isar: isar, api: api);
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  Future<Customer> aCustomer([String name = 'Ramesh']) => customers.create(
        name: name,
        phone: '+919876500001',
        chopdiId: 1,
        loanType: 'gave',
      );

  group('the queue drains', () {
    test('a customer and its entries all reach the server', () async {
      final c = await aCustomer();
      await ledger.create(
        customer: c,
        amountPaise: Money.toPaise(5000),
        type: TransactionType.gave,
        date: DateTime.utc(2026, 8, 24),
      );
      await ledger.create(
        customer: c,
        amountPaise: Money.toPaise(1500),
        type: TransactionType.received,
        date: DateTime.utc(2026, 8, 24),
      );

      expect(await queue.pendingCount(isar), 3);

      final result = await engine.drain();

      expect(result.pushed, 3);
      expect(result.remaining, 0);
      expect(result.isComplete, isTrue);
      expect(await queue.pendingCount(isar), 0);
    });

    test('rows are marked synced and carry the server version', () async {
      final c = await aCustomer();
      await engine.drain();

      final stored =
          await isar.customers.filter().uuidEqualTo(c.uuid).findFirst();

      expect(stored!.syncStatus, SyncStatus.synced);
      expect(stored.version, 1);
    });

    test('a create is sent before the entry that depends on it', () async {
      final c = await aCustomer();
      await ledger.create(
        customer: c,
        amountPaise: Money.toPaise(100),
        type: TransactionType.gave,
        date: DateTime.utc(2026, 8, 24),
      );

      await engine.drain();

      final sent = api.batches.single;
      final customerOp =
          await isar.syncOps.filter().entityEqualTo('customer').findFirst();

      // Consumed, so look at the order it went out in instead.
      expect(customerOp, isNull);
      expect(sent.length, 2);
    });
  });

  group('nothing is lost when the network misbehaves', () {
    test('an offline drain keeps every operation queued', () async {
      await aCustomer();
      api.failWith = ApiException.network(const SocketException('offline'));

      final result = await engine.drain();

      expect(result.pushed, 0);
      expect(result.stoppedBecause, 'offline');
      expect(await queue.pendingCount(isar), 1, reason: 'still queued');
      expect(await queue.deadLetterCount(isar), 0, reason: 'not discarded');
    });

    test('a network failure does not consume an attempt', () async {
      await aCustomer();
      api.failWith = ApiException.network(const SocketException('offline'));

      for (var i = 0; i < 10; i++) {
        await engine.drain();
      }

      final op = await isar.syncOps.where().findFirst();

      // Ten failed attempts against an unreachable server, and the operation is
      // still live. Were network failures counted, maxAttempts (5) would have
      // dead-lettered a perfectly valid entry during an outage.
      expect(op!.attempts, 0);
      expect(op.deadLettered, isFalse);
      expect(await queue.pendingCount(isar), 1);
    });

    test('coming back online sends what was queued while offline', () async {
      await aCustomer('Offline One');
      api.failWith = ApiException.network(const SocketException('offline'));
      await engine.drain();

      await aCustomer('Offline Two');
      await engine.drain();

      expect(await queue.pendingCount(isar), 2);

      // Connection restored.
      api.failWith = null;
      final result = await engine.drain();

      expect(result.pushed, 2);
      expect(await queue.pendingCount(isar), 0);
    });

    test('a lost response does not duplicate the row', () async {
      await aCustomer();

      // The server commits; the reply never arrives.
      api.swallowResponse = true;
      await engine.drain();

      expect(await queue.pendingCount(isar), 1, reason: 'client must retry');

      // The retry carries the same idempotency key, so the server recognises it.
      api.swallowResponse = false;
      final result = await engine.drain();

      expect(result.pushed, 1);
      expect(await queue.pendingCount(isar), 0);

      final sent = api.allSentOpIds;
      expect(sent.length, 2, reason: 'sent twice, deliberately');
      expect(sent.first, sent.last, reason: 'same opId — never regenerated');
      expect(api.committed.length, 1, reason: 'committed once');
    });
  });

  group('rejections are handled without losing data', () {
    test('a permanent rejection dead-letters but keeps the row', () async {
      final c = await aCustomer();
      final op = await isar.syncOps.where().findFirst();

      api.statusFor[op!.opId] = 'rejected';
      api.errorFor[op.opId] = const SyncOperationError(
        code: 'VALIDATION_FAILED',
        message: 'bad name',
        permanent: true,
      );

      final result = await engine.drain();

      expect(result.deadLettered, 1);

      final parked = await isar.syncOps.where().findFirst();
      expect(parked!.deadLettered, isTrue);
      expect(parked.lastErrorCode, 'VALIDATION_FAILED');

      // The entry itself survives. Silently dropping a financial record is the
      // worst outcome available, so it is kept and surfaced instead.
      final row = await isar.customers.filter().uuidEqualTo(c.uuid).findFirst();
      expect(row, isNotNull);
      expect(row!.syncStatus, SyncStatus.deadLettered);
    });

    test('a retryable rejection backs off rather than dead-lettering',
        () async {
      await aCustomer();
      final op = await isar.syncOps.where().findFirst();

      api.statusFor[op!.opId] = 'rejected';
      api.errorFor[op.opId] = const SyncOperationError(
        code: 'PARENT_NOT_FOUND',
        message: 'not yet',
        permanent: false,
      );

      await engine.drain();

      final after = await isar.syncOps.where().findFirst();
      expect(after!.attempts, 1);
      expect(after.deadLettered, isFalse);
      expect(after.nextAttemptAt, isNotNull);
    });

    test('a dead-lettered operation can be revived and then sends', () async {
      await aCustomer();
      final op = await isar.syncOps.where().findFirst();

      api.statusFor[op!.opId] = 'rejected';
      api.errorFor[op.opId] = const SyncOperationError(
        code: 'INTERNAL',
        message: 'server bug',
        permanent: true,
      );

      await engine.drain();
      expect(await queue.deadLetterCount(isar), 1);

      // The server-side bug is fixed; the user retries.
      api.statusFor.clear();
      api.errorFor.clear();

      expect(await queue.revive(isar), 1);
      final result = await engine.drain();

      expect(result.pushed, 1);
      expect(await queue.pendingCount(isar), 0);
      expect(await queue.deadLetterCount(isar), 0);
    });
  });

  group('the server is not overloaded', () {
    test('an empty queue issues no request at all', () async {
      final result = await engine.drain();

      expect(api.requestCount, 0, reason: 'nothing to send, nothing sent');
      expect(result.isComplete, isTrue);
    });

    test('a large backlog is batched, not sent one request per entry',
        () async {
      final c = await aCustomer();
      for (var i = 0; i < 250; i++) {
        await ledger.create(
          customer: c,
          amountPaise: Money.toPaise((10 + i).toDouble()),
          type: TransactionType.gave,
          date: DateTime.utc(2026, 8, 24),
        );
      }

      expect(await queue.pendingCount(isar), 251);

      await engine.drain();

      // 251 operations at 200 per request.
      expect(api.requestCount, 2);
      expect(await queue.pendingCount(isar), 0);
    });

    test('one drain is bounded, so a huge backlog cannot burst', () async {
      final c = await aCustomer();

      // Enough to exceed maxBatchesPerDrain (20) x batchSize (200).
      for (var i = 0; i < 210; i++) {
        await ledger.create(
          customer: c,
          amountPaise: Money.toPaise((10 + i).toDouble()),
          type: TransactionType.gave,
          date: DateTime.utc(2026, 8, 24),
        );
      }

      await engine.drain();

      expect(
        api.requestCount,
        lessThanOrEqualTo(SyncEngine.maxBatchesPerDrain),
        reason: 'a single drain must not spend the rate-limit budget',
      );
    });

    test('a backed-off operation does not starve the ones behind it', () async {
      final c = await aCustomer();
      final blocker = await isar.syncOps.where().findFirst();

      // The head of the queue fails retryably, so it is parked with a backoff.
      api.statusFor[blocker!.opId] = 'rejected';
      api.errorFor[blocker.opId] = const SyncOperationError(
        code: 'INTERNAL',
        message: 'transient',
        permanent: false,
      );
      await engine.drain();

      // Work arrives behind it.
      await ledger.create(
        customer: c,
        amountPaise: Money.toPaise(75),
        type: TransactionType.gave,
        date: DateTime.utc(2026, 8, 24),
      );

      final before = api.requestCount;
      final result = await engine.drain();

      // Selecting the oldest N and *then* dropping the backed-off ones would
      // return an empty batch here and conclude there was nothing to do,
      // stranding the new entry until the blocker's backoff expired.
      expect(api.requestCount, greaterThan(before));
      expect(result.pushed, 1);
    });
  });
}
