@Tags(['isar'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/sync_op.dart';
import 'package:mychopdi/model/sync_status.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/model/user_session.dart';

/// Safety checks for the schema change that ships to existing devices.
///
/// This migration runs once, on real phones, against real ledgers, and cannot
/// be rolled back. Everything here is a way it could silently lose data.
void main() {
  late Directory dir;
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('chopdi_test');
    isar = await Isar.open(
      [CustomerSchema, TransactionSchema, UserSessionSchema, SyncOpSchema],
      directory: dir.path,
      name: 'test_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  group('the unique uuid index vs. unmigrated rows', () {
    test('rows sharing the default empty uuid must all survive', () async {
      // THE critical case. Every row written by the previous build has
      // uuid == '' . If the unique index treats those as duplicates, a
      // `replace` policy would collapse an entire customer list into one row
      // the first time the app opens after an update.
      await isar.writeTxn(() async {
        for (var i = 1; i <= 5; i++) {
          await isar.customers.put(
            Customer()
              ..name = 'Customer $i'
              ..phone = '+91900000000$i'
              ..status = 'active'
              ..received = false,
          );
        }
      });

      final all = await isar.customers.where().findAll();

      expect(all.length, 5,
          reason: 'Rows with the default empty uuid collapsed — this would '
              'destroy every unmigrated customer on upgrade.');
      expect(all.map((c) => c.name).toSet(), hasLength(5));
    });

    test('the index alone does NOT dedupe — the repository must', () async {
      // Documents the consequence of dropping `unique`. Blindly putting a row
      // that arrived twice from a pull would duplicate it, so the repository is
      // obliged to look up by uuid and reuse the local id. This test exists so
      // that obligation is visible rather than folklore.
      await isar.writeTxn(() async {
        await isar.customers.put(Customer()
          ..uuid = 'aaaa'
          ..name = 'First'
          ..phone = '1'
          ..status = 'a'
          ..received = false);
        await isar.customers.put(Customer()
          ..uuid = 'aaaa'
          ..name = 'Second'
          ..phone = '1'
          ..status = 'a'
          ..received = false);
      });

      expect(await isar.customers.filter().uuidEqualTo('aaaa').count(), 2,
          reason: 'Without a unique index Isar happily stores both — which is '
              'why upserts must resolve the local id first.');
    });

    test('upserting by uuid the way the repository will is idempotent',
        () async {
      Future<void> upsert(String uuid, String name) async {
        await isar.writeTxn(() async {
          final existing =
              await isar.customers.filter().uuidEqualTo(uuid).findFirst();

          final row = existing ?? Customer()
            ..uuid = uuid
            ..name = name
            ..phone = '1'
            ..status = 'a'
            ..received = false;

          await isar.customers.put(row);
        });
      }

      await upsert('bbbb', 'First');
      await upsert('bbbb', 'Updated');
      await upsert('bbbb', 'Updated again');

      final rows = await isar.customers.filter().uuidEqualTo('bbbb').findAll();
      expect(rows.length, 1);
      expect(rows.first.name, 'Updated again');
    });
  });

  group('defaults are readable on rows that predate them', () {
    test('a row written without the new fields reads back with defaults',
        () async {
      await isar.writeTxn(() async {
        await isar.customers.put(Customer()
          ..name = 'Legacy'
          ..phone = '+919000000000'
          ..status = 'active'
          ..received = true);
      });

      final row = await isar.customers.where().findFirst();

      // If any of these were `late`, reading here would throw — on a real
      // device, at launch, before the migration could run.
      expect(row!.uuid, '');
      expect(row.version, 0);
      expect(row.deletedAt, isNull);
      expect(row.syncStatus, SyncStatus.pending);
      expect(row.received, isTrue, reason: 'existing fields must be untouched');
    });

    test('transactions keep their legacy values alongside the new ones',
        () async {
      await isar.writeTxn(() async {
        await isar.transactions.put(Transaction()
          ..customerId = 7
          ..legacyAmount = 5000.50
          ..legacyInterestRate = 2.0
          ..date = DateTime.utc(2026, 3, 3)
          ..type = TransactionType.gave);
      });

      final tx = await isar.transactions.where().findFirst();

      // The migration needs these as its input; losing them loses the ledger.
      expect(tx!.legacyAmount, 5000.50);
      expect(tx.customerId, 7);
      expect(tx.amountPaise, 0);
      expect(tx.customerUuid, '');
      expect(tx.voidedAt, isNull);
    });
  });

  group('the outbox orders correctly', () {
    test('autoincrement ids give a monotonic local sequence', () async {
      await isar.writeTxn(() async {
        for (var i = 0; i < 10; i++) {
          await isar.syncOps.put(SyncOp()
            ..opId = 'op-$i'
            ..entity = 'customer'
            ..entityId = 'e-$i'
            ..opType = 'create'
            ..payload = '{}'
            ..createdAt = DateTime.utc(2026, 1, 1));
        }
      });

      final ops = await isar.syncOps.where().anyId().findAll();
      final ids = ops.map((o) => o.id).toList();

      expect(ids, orderedEquals(List<int>.from(ids)..sort()));
      expect(ids.toSet(), hasLength(10));
    });

    test('the same opId cannot be enqueued twice', () async {
      // Re-enqueueing a key already in flight would let one operation reach the
      // server as two.
      await isar.writeTxn(() async {
        await isar.syncOps.put(SyncOp()
          ..opId = 'dup'
          ..entity = 'customer'
          ..entityId = 'x'
          ..opType = 'create'
          ..payload = '{}'
          ..createdAt = DateTime.utc(2026, 1, 1));
      });
      await isar.writeTxn(() async {
        await isar.syncOps.put(SyncOp()
          ..opId = 'dup'
          ..entity = 'customer'
          ..entityId = 'x'
          ..opType = 'create'
          ..payload = '{"changed":true}'
          ..createdAt = DateTime.utc(2026, 1, 1));
      });

      final ops = await isar.syncOps.filter().opIdEqualTo('dup').findAll();
      expect(ops.length, 1);
    });
  });

  group('the derived rupee view', () {
    test('reflects stored paise exactly', () async {
      await isar.writeTxn(() async {
        await isar.transactions.put(Transaction()
          ..customerId = 1
          ..amountPaise = 500050
          ..interestRateBp = 250
          ..date = DateTime.utc(2026, 3, 3)
          ..type = TransactionType.gave);
      });

      final tx = await isar.transactions.where().findFirst();
      expect(tx!.amount, 5000.50);
      expect(tx.interestRate, 2.5);
    });

    test('falls back to the legacy value for unmigrated rows', () async {
      // The safety net: if the migration has not run, or failed, balances must
      // still render from the old column rather than showing every entry as ₹0.
      await isar.writeTxn(() async {
        await isar.transactions.put(Transaction()
          ..customerId = 1
          ..legacyAmount = 1234.56
          ..legacyInterestRate = 3.0
          ..date = DateTime.utc(2026, 3, 3)
          ..type = TransactionType.gave);
      });

      final tx = await isar.transactions.where().findFirst();
      expect(tx!.amountPaise, 0);
      expect(tx.amount, 1234.56, reason: 'unmigrated rows must still display');
      expect(tx.interestRate, 3.0);
    });

    test('paise wins once migrated', () async {
      await isar.writeTxn(() async {
        await isar.transactions.put(Transaction()
          ..customerId = 1
          ..legacyAmount = 999.99
          ..amountPaise = 123456
          ..date = DateTime.utc(2026, 3, 3)
          ..type = TransactionType.gave);
      });

      final tx = await isar.transactions.where().findFirst();
      expect(tx!.amount, 1234.56,
          reason: 'the authoritative value is paise, not the legacy column');
    });
  });

  group('atomicity of row + outbox', () {
    test('a failed transaction leaves neither the row nor the op', () async {
      // The rule the whole design rests on: if these could commit separately, a
      // crash between them would either lose the sync intent (data stranded on
      // the device) or orphan an operation.
      try {
        await isar.writeTxn(() async {
          await isar.customers.put(Customer()
            ..uuid = 'atomic'
            ..name = 'Half written'
            ..phone = '1'
            ..status = 'a'
            ..received = false);
          await isar.syncOps.put(SyncOp()
            ..opId = 'atomic-op'
            ..entity = 'customer'
            ..entityId = 'atomic'
            ..opType = 'create'
            ..payload = '{}'
            ..createdAt = DateTime.utc(2026, 1, 1));
          throw Exception('simulated crash');
        });
      } catch (_) {
        // expected
      }

      expect(await isar.customers.filter().uuidEqualTo('atomic').count(), 0);
      expect(await isar.syncOps.filter().opIdEqualTo('atomic-op').count(), 0);
    });
  });
}
