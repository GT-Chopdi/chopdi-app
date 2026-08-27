@Tags(['isar'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/data/repository/customer_repository.dart';
import 'package:mychopdi/data/repository/ledger_repository.dart';
import 'package:mychopdi/data/repository/repository_exception.dart';
import 'package:mychopdi/data/repository/sync_queue.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/sync_meta.dart';
import 'package:mychopdi/model/sync_op.dart';
import 'package:mychopdi/model/sync_status.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/model/user_session.dart';
import 'package:mychopdi/utils/money.dart';

void main() {
  late Directory dir;
  late Isar isar;
  late CustomerRepository customers;
  late LedgerRepository ledger;
  const queue = SyncQueue();

  setUpAll(() async => Isar.initializeIsarCore(download: true));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('chopdi_repo');
    isar = await Isar.open(
      [
        CustomerSchema,
        TransactionSchema,
        UserSessionSchema,
        SyncOpSchema,
        SyncMetaSchema,
      ],
      directory: dir.path,
      name: 'repo_${DateTime.now().microsecondsSinceEpoch}',
    );
    customers = CustomerRepository(isar);
    ledger = LedgerRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  Future<Customer> aCustomer() =>
      customers.create(name: 'Ramesh', phone: '+919876543210', chopdiId: 1, loanType: 'gave');

  group('every write reaches the outbox', () {
    test('creating a customer enqueues exactly one create', () async {
      final c = await aCustomer();

      final ops = await queue.pending(isar);
      expect(ops, hasLength(1));
      expect(ops.first.entity, 'customer');
      expect(ops.first.entityId, c.uuid);
      expect(ops.first.opType, 'create');
      expect(ops.first.opId, isNotEmpty);
      expect(c.syncStatus, SyncStatus.pending);
    });

    test('creating an entry enqueues one create carrying the server contract',
        () async {
      final c = await aCustomer();
      final tx = await ledger.create(
        customer: c,
        amountPaise: Money.toPaise(5000),
        type: TransactionType.gave,
        date: DateTime(2026, 3, 3),
        interestRateBp: Money.rateToBasisPoints(2),
        interestType: 'Simple Interest',
        interestFrequency: 'Monthly',
      );

      final ops = await queue.pending(isar);
      expect(ops, hasLength(2));

      final entryOp = ops.last;
      final payload = jsonDecode(entryOp.payload) as Map<String, dynamic>;

      // These names and values are the wire contract. A mismatch here is a
      // permanent server rejection, which dead-letters a valid entry.
      expect(payload['customerId'], c.uuid);
      expect(payload['amountPaise'], 500000);
      expect(payload['direction'], 'gave');
      expect(payload['interestRateBp'], 200);
      expect(payload['interestType'], 'simple');
      expect(payload['interestFrequency'], 'monthly');
      expect(payload['entryDate'], '2026-03-03');
      expect(tx.uuid, isNotEmpty);
    });

    test('updates and voids enqueue with the expected version', () async {
      final c = await aCustomer();
      await customers.update(c, name: 'Ramesh Patel');
      await customers.softDelete(c, reason: 'left town');

      final ops = await queue.pending(isar);
      expect(ops.map((o) => o.opType), ['create', 'update', 'void']);
      expect(ops[1].expectedVersion, 0);
      expect(jsonDecode(ops[2].payload)['reason'], 'left town');
    });

    test('operations keep creation order', () async {
      // An update overtaking its create is a rejected operation, not a slow one.
      final c = await aCustomer();
      for (var i = 0; i < 5; i++) {
        await customers.update(c, name: 'Name $i');
      }

      final ops = await queue.pending(isar);
      final ids = ops.map((o) => o.id).toList();
      expect(ids, orderedEquals(List<int>.from(ids)..sort()));
      expect(ops.first.opType, 'create');
    });

    test('the payload is frozen at enqueue time', () async {
      // Re-serialising at send time would put different bytes under the same
      // opId, which the server rejects permanently as key reuse.
      final c = await aCustomer();
      final before = jsonDecode((await queue.pending(isar)).first.payload);

      await customers.update(c, name: 'Changed Later');

      final createOp = (await queue.pending(isar)).first;
      expect(jsonDecode(createOp.payload), before);
      expect(jsonDecode(createOp.payload)['name'], 'Ramesh');
    });
  });

  group('validation rejects what the server would refuse', () {
    test('a blank name', () async {
      await expectLater(
        customers.create(name: '   ', phone: '1', chopdiId: 1, loanType: 'gave'),
        throwsA(isA<RepositoryException>()),
      );
    });

    test('a zero or negative amount', () async {
      final c = await aCustomer();
      for (final bad in [0, -1, -500000]) {
        await expectLater(
          ledger.create(
            customer: c,
            amountPaise: bad,
            type: TransactionType.gave,
            date: DateTime(2026, 3, 3),
          ),
          throwsA(isA<RepositoryException>()),
          reason: '$bad paise must be refused',
        );
      }
    });

    test('an absurd amount', () async {
      final c = await aCustomer();
      await expectLater(
        ledger.create(
          customer: c,
          amountPaise: LedgerRepository.maxAmountPaise + 1,
          type: TransactionType.gave,
          date: DateTime(2026, 3, 3),
        ),
        throwsA(isA<RepositoryException>()),
      );
    });

    test('a future-dated entry', () async {
      final c = await aCustomer();
      await expectLater(
        ledger.create(
          customer: c,
          amountPaise: 100,
          type: TransactionType.gave,
          date: DateTime.now().add(const Duration(days: 30)),
        ),
        throwsA(isA<RepositoryException>()),
      );
    });

    test('an entry against a deleted customer', () async {
      final c = await aCustomer();
      await customers.softDelete(c);

      await expectLater(
        ledger.create(
          customer: c,
          amountPaise: 100,
          type: TransactionType.gave,
          date: DateTime(2026, 3, 3),
        ),
        throwsA(isA<RepositoryException>()),
      );
    });

    test('voiding without a reason', () async {
      final c = await aCustomer();
      final tx = await ledger.create(
        customer: c,
        amountPaise: 100,
        type: TransactionType.gave,
        date: DateTime(2026, 3, 3),
      );

      await expectLater(
        ledger.voidEntry(tx, reason: '  '),
        throwsA(isA<RepositoryException>()),
      );
    });

    test('a rejected write leaves neither a row nor an operation', () async {
      // Validation must run before the transaction opens. A half-write that
      // enqueued an operation for a row that was never stored would be sent to
      // the server and fail there instead.
      final c = await aCustomer();
      final opsBefore = (await queue.pending(isar)).length;

      try {
        await ledger.create(
          customer: c,
          amountPaise: -1,
          type: TransactionType.gave,
          date: DateTime(2026, 3, 3),
        );
      } catch (_) {}

      expect(await isar.transactions.count(), 0);
      expect((await queue.pending(isar)).length, opsBefore);
    });
  });

  group('balances are derived from entries', () {
    test('gave adds, received subtracts', () async {
      final c = await aCustomer();
      await ledger.create(
        customer: c,
        amountPaise: Money.toPaise(5000),
        type: TransactionType.gave,
        date: DateTime(2026, 3, 1),
      );
      await ledger.create(
        customer: c,
        amountPaise: Money.toPaise(1500.50),
        type: TransactionType.received,
        date: DateTime(2026, 3, 2),
      );

      expect(await ledger.balancePaise(c), 500000 - 150050);
    });

    test('voided entries drop out of the balance', () async {
      final c = await aCustomer();
      final tx = await ledger.create(
        customer: c,
        amountPaise: Money.toPaise(5000),
        type: TransactionType.gave,
        date: DateTime(2026, 3, 1),
      );

      expect(await ledger.balancePaise(c), 500000);
      await ledger.voidEntry(tx, reason: 'duplicate');
      expect(await ledger.balancePaise(c), 0);
    });

    test('integer maths avoids the drift a double would accumulate', () async {
      // 0.1 + 0.2 != 0.3 in binary floating point. Three ₹0.10 entries must
      // total exactly ₹0.30, not 0.30000000000000004.
      final c = await aCustomer();
      for (var i = 0; i < 3; i++) {
        await ledger.create(
          customer: c,
          amountPaise: Money.toPaise(0.10),
          type: TransactionType.gave,
          date: DateTime(2026, 3, 1),
        );
      }

      expect(await ledger.balancePaise(c), 30);
      expect(Money.toRupees(await ledger.balancePaise(c)), 0.30);
    });
  });

  group('deleting a customer takes their entries with it', () {
    test('customer and entries are voided together and all queued', () async {
      final c = await aCustomer();
      for (var i = 0; i < 3; i++) {
        await ledger.create(
          customer: c,
          amountPaise: 1000,
          type: TransactionType.gave,
          date: DateTime(2026, 3, 1),
        );
      }

      await customers.softDeleteWithEntries(c);

      expect(c.deletedAt, isNotNull);
      expect(await ledger.forCustomer(c), isEmpty,
          reason: 'voided entries must drop out of every read');
      expect(await ledger.balancePaise(c), 0);

      final ops = await queue.pending(isar);
      final voids = ops.where((o) => o.opType == 'void').toList();
      expect(voids, hasLength(4),
          reason: 'three entries plus the customer, each its own operation — '
              'the server has no cascade on the wire');
    });

    test('entries survive as rows so the deletion can reach other devices',
        () async {
      final c = await aCustomer();
      await ledger.create(
        customer: c,
        amountPaise: 1000,
        type: TransactionType.gave,
        date: DateTime(2026, 3, 1),
      );

      await customers.softDeleteWithEntries(c);

      // A hard delete would be invisible to another device: the row simply
      // stops appearing, indistinguishable from one never seen.
      expect(await isar.transactions.count(), 1);
      expect(await isar.customers.count(), 1);
    });

    test('unmigrated entries are voided locally without an operation',
        () async {
      // Rows predating the migration have no uuid, so the server has never
      // heard of them. Enqueuing a void for one would be permanently rejected.
      final c = await aCustomer();
      await isar.writeTxn(() async {
        await isar.transactions.put(Transaction()
          ..customerId = c.id
          ..legacyAmount = 500
          ..date = DateTime(2026, 3, 1)
          ..type = TransactionType.gave);
      });

      await customers.softDeleteWithEntries(c);

      final ops = await queue.pending(isar);
      expect(ops.where((o) => o.entity == 'ledger_entry'), isEmpty);
      final legacy = await isar.transactions.where().findFirst();
      expect(legacy!.voidedAt, isNotNull, reason: 'still voided locally');
    });
  });

  group('applying rows from the server', () {
    test('re-pulling the same row does not duplicate it', () async {
      // The uuid index is not unique, so a blind put would insert a second row
      // every time a page was re-fetched.
      for (var i = 0; i < 3; i++) {
        await customers.applyFromServer(
          uuid: 'server-uuid-1',
          name: 'From Server $i',
          phone: '+911111111111',
          notes: '',
          version: i + 1,
          updatedAt: DateTime.utc(2026, 3, 3),
          deletedAt: null,
        );
      }

      final rows =
          await isar.customers.filter().uuidEqualTo('server-uuid-1').findAll();
      expect(rows, hasLength(1));
      expect(rows.first.name, 'From Server 2');
      expect(rows.first.version, 3);
    });

    test('a pull never enqueues an operation', () async {
      // Echoing an incoming row back as a push would loop forever.
      await customers.applyFromServer(
        uuid: 'server-uuid-2',
        name: 'Server Row',
        phone: null,
        notes: '',
        version: 1,
        updatedAt: DateTime.utc(2026, 3, 3),
        deletedAt: null,
      );

      expect(await queue.pendingCount(isar), 0);
    });

    test('a pending local edit is flagged, not overwritten', () async {
      final c = await aCustomer();
      await customers.update(c, name: 'My Local Edit');

      await customers.applyFromServer(
        uuid: c.uuid,
        name: 'Server Version',
        phone: '+910000000000',
        notes: '',
        version: 5,
        updatedAt: DateTime.utc(2026, 3, 4),
        deletedAt: null,
      );

      final row = await customers.findByUuid(c.uuid);
      expect(row!.name, 'My Local Edit',
          reason: 'an unsent local change must not be silently discarded');
      expect(row.syncStatus, SyncStatus.conflicted);
      expect(row.version, 5, reason: 'the server version is still recorded');
    });
  });
}
