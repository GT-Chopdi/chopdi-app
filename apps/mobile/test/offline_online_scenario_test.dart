@Tags(['isar'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/data/repository/customer_repository.dart';
import 'package:mychopdi/data/repository/ledger_repository.dart';
import 'package:mychopdi/data/repository/sync_queue.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/sync_meta.dart';
import 'package:mychopdi/model/sync_op.dart';
import 'package:mychopdi/model/sync_status.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/model/user_session.dart';
import 'package:mychopdi/utils/money.dart';

/// Walks the real user journey: record entries with a connection, lose it,
/// keep recording, close the app, reopen it.
///
/// No network is configured anywhere in this file, which is the point — the
/// save path must not care. If any of these needed connectivity, the test could
/// not pass at all.
void main() {
  late Directory dir;
  late Isar isar;
  late String name;
  late CustomerRepository customers;
  late LedgerRepository ledger;
  const queue = SyncQueue();

  setUpAll(() async => Isar.initializeIsarCore(download: true));

  Future<void> openDb() async {
    isar = await Isar.open(
      [
        CustomerSchema,
        TransactionSchema,
        UserSessionSchema,
        SyncOpSchema,
        SyncMetaSchema,
      ],
      directory: dir.path,
      name: name,
    );
    customers = CustomerRepository(isar);
    ledger = LedgerRepository(isar);
  }

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('chopdi_scenario');
    name = 'sc${DateTime.now().microsecondsSinceEpoch}';
    await openDb();
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('entries survive going offline, coming back, and an app restart',
      () async {
    // ---- connection available -------------------------------------------
    final ramesh = await customers.create(name: 'Ramesh', phone: '+919876500001', chopdiId: 1, loanType: 'gave');
    await ledger.create(
      customer: ramesh,
      amountPaise: Money.toPaise(5000),
      type: TransactionType.gave,
      date: DateTime(2026, 3, 1),
    );

    expect(await queue.pendingCount(isar), 2,
        reason: 'customer + entry are queued the moment they are saved');

    // ---- connection lost -------------------------------------------------
    // Nothing changes. The save path never opened a socket in the first place,
    // so there is no state to switch.
    final suresh = await customers.create(name: 'Suresh', phone: '+919876500002', chopdiId: 1, loanType: 'gave');
    await ledger.create(
      customer: suresh,
      amountPaise: Money.toPaise(1200.75),
      type: TransactionType.gave,
      date: DateTime(2026, 3, 2),
    );
    await ledger.create(
      customer: ramesh,
      amountPaise: Money.toPaise(2000),
      type: TransactionType.received,
      date: DateTime(2026, 3, 3),
    );

    expect(await isar.transactions.count(), 3);
    expect(await queue.pendingCount(isar), 5);

    // The user's balances are correct while offline — they are derived from
    // local rows, never fetched.
    expect(await ledger.balancePaise(ramesh), 500000 - 200000);
    expect(await ledger.balancePaise(suresh), 120075);

    // ---- the app is killed and reopened ----------------------------------
    final queuedBefore =
        (await queue.pending(isar)).map((o) => o.opId).toList();
    await isar.close();
    await openDb();

    final queuedAfter = (await queue.pending(isar)).map((o) => o.opId).toList();

    expect(queuedAfter, queuedBefore,
        reason: 'the outbox is on disk, not in memory — a crash or a swipe-away '
            'must not lose the intent to sync');
    expect(await isar.transactions.count(), 3);

    // Order is preserved, which matters: a customer must reach the server
    // before the entry that references it.
    final ops = await queue.pending(isar);
    expect(ops.first.entity, 'customer');
    final ids = ops.map((o) => o.id).toList();
    expect(ids, orderedEquals(List<int>.from(ids)..sort()));

    // Every queued operation is already a complete, valid request body.
    for (final op in ops.where((o) => o.entity == 'ledger_entry')) {
      final payload = jsonDecode(op.payload) as Map<String, dynamic>;
      expect(payload['customerId'], isNotEmpty);
      expect(payload['amountPaise'], greaterThan(0));
      expect(payload['direction'], anyOf('gave', 'received'));
      expect(payload['entryDate'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    }

    // Everything is still marked unsent — nothing drains the queue yet.
    final rows = await isar.transactions.where().findAll();
    expect(rows.every((t) => t.syncStatus == SyncStatus.pending), isTrue);
  });

  test('editing and deleting while offline queues follow-up operations',
      () async {
    final c = await customers.create(name: 'Ramesh', phone: '+919876500003', chopdiId: 1, loanType: 'gave');
    final tx = await ledger.create(
      customer: c,
      amountPaise: Money.toPaise(5000),
      type: TransactionType.gave,
      date: DateTime(2026, 3, 1),
    );

    await ledger.update(tx, amountPaise: Money.toPaise(5500));
    await ledger.voidEntry(tx, reason: 'entered twice');

    final ops = await queue.pending(isar);
    expect(ops.map((o) => o.opType).toList(), ['create', 'create', 'update', 'void']);

    // The create still carries its original amount. Re-serialising at send time
    // would put different bytes under the same idempotency key, which the
    // server rejects permanently.
    final entryCreate =
        ops.firstWhere((o) => o.entity == 'ledger_entry' && o.opType == 'create');
    expect(jsonDecode(entryCreate.payload)['amountPaise'], 500000);

    final update = ops.firstWhere((o) => o.opType == 'update');
    expect(jsonDecode(update.payload)['amountPaise'], 550000);
  });

  test('a long offline stretch just accumulates work', () async {
    final c = await customers.create(name: 'Ramesh', phone: '+919876500004', chopdiId: 1, loanType: 'gave');

    for (var day = 1; day <= 40; day++) {
      await ledger.create(
        customer: c,
        amountPaise: Money.toPaise(100.0 + day),
        type: TransactionType.gave,
        date: DateTime(2026, 1, 1).add(Duration(days: day)),
      );
    }

    expect(await queue.pendingCount(isar), 41);
    expect(await isar.transactions.count(), 40);

    // 200 is the server's batch cap, so this drains in one request when a
    // connection returns.
    expect((await queue.pending(isar, limit: 200)).length, 41);
  });
}
