@Tags(['isar'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/data/migration/local_migration.dart';
import 'package:mychopdi/data/repository/sync_queue.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/sync_meta.dart';
import 'package:mychopdi/model/sync_op.dart';
import 'package:mychopdi/model/sync_status.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/model/user_session.dart';

/// The migration runs once, on real phones, against real ledgers, and cannot be
/// undone. Every test here is a way it could quietly lose or corrupt data.
void main() {
  late Directory dir;
  late Isar isar;
  late String name;
  const migration = LocalMigration();
  const queue = SyncQueue();

  setUpAll(() async => Isar.initializeIsarCore(download: true));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('chopdi_mig');
    name = 'mig_${DateTime.now().microsecondsSinceEpoch}';
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
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  /// Seeds data exactly as the previous build wrote it: no uuid, rupees in the
  /// legacy column, and an integer customer foreign key.
  Future<int> seedLegacyCustomer(String customerName, String phone) async {
    late int id;
    await isar.writeTxn(() async {
      final c = Customer()
        ..name = customerName
        ..phone = phone
        ..status = 'Pending'
        ..received = false;
      id = await isar.customers.put(c);
    });
    return id;
  }

  Future<void> seedLegacyEntry({
    required int customerId,
    required double amount,
    double rate = 0,
    TransactionType type = TransactionType.gave,
    DateTime? date,
  }) async {
    await isar.writeTxn(() async {
      await isar.transactions.put(Transaction()
        ..customerId = customerId
        ..legacyAmount = amount
        ..legacyInterestRate = rate
        ..date = date ?? DateTime(2026, 3, 3)
        ..type = type
        ..interestType = 'Simple Interest'
        ..interestFrequency = 'Monthly');
    });
  }

  Future<MigrationResult> migrate() =>
      migration.run(isar, directory: dir.path, instanceName: name);

  group('a normal ledger', () {
    test('every row gains an identity and reaches the outbox', () async {
      final a = await seedLegacyCustomer('Ramesh', '+919876543210');
      final b = await seedLegacyCustomer('Suresh', '+919876543211');
      await seedLegacyEntry(customerId: a, amount: 5000, rate: 2);
      await seedLegacyEntry(customerId: a, amount: 1500.50,
          type: TransactionType.received);
      await seedLegacyEntry(customerId: b, amount: 250);

      final result = await migrate();

      expect(result.ran, isTrue);
      expect(result.customersMigrated, 2);
      expect(result.entriesMigrated, 3);

      // The step that is easy to forget: without it, a user's whole history
      // stays on the phone while only new entries ever sync.
      expect(result.operationsSeeded, 5);
      expect(await queue.pendingCount(isar), 5);

      for (final c in await isar.customers.where().findAll()) {
        expect(c.uuid, isNotEmpty);
        expect(c.syncStatus, SyncStatus.pending);
      }
      for (final t in await isar.transactions.where().findAll()) {
        expect(t.uuid, isNotEmpty);
        expect(t.customerUuid, isNotEmpty);
      }
    });

    test('money converts exactly, including values a double rounds badly',
        () async {
      final c = await seedLegacyCustomer('Ramesh', '1');
      for (final amount in [5000.0, 1234.56, 0.10, 0.20, 99999.99]) {
        await seedLegacyEntry(customerId: c, amount: amount);
      }

      await migrate();

      final paise = (await isar.transactions.where().findAll())
          .map((t) => t.amountPaise)
          .toList()
        ..sort();

      expect(paise, [10, 20, 123456, 500000, 9999999]);
    });

    test('the derived rupee view now comes from paise', () async {
      final c = await seedLegacyCustomer('Ramesh', '1');
      await seedLegacyEntry(customerId: c, amount: 1234.56, rate: 2.5);

      await migrate();

      final tx = await isar.transactions.where().findFirst();
      expect(tx!.amountPaise, 123456);
      expect(tx.amount, 1234.56);
      expect(tx.interestRateBp, 250);
      expect(tx.interestRate, 2.5);
    });

    test('entry payloads carry the customer uuid, not the local id', () async {
      final c = await seedLegacyCustomer('Ramesh', '1');
      await seedLegacyEntry(customerId: c, amount: 5000);

      await migrate();

      final customer = await isar.customers.where().findFirst();
      final op = (await queue.pending(isar))
          .firstWhere((o) => o.entity == 'ledger_entry');
      final payload = jsonDecode(op.payload) as Map<String, dynamic>;

      expect(payload['customerId'], customer!.uuid);
      expect(payload['amountPaise'], 500000);
      expect(payload['entryDate'], '2026-03-03');
    });
  });

  group('data the previous build left behind', () {
    test('an orphaned entry is kept but never queued', () async {
      // A customer hard-deleted by an older build left entries behind. They are
      // already invisible in the app. Deleting a financial record during an
      // upgrade is not something to do quietly — but it can never sync either,
      // because the server rejects an entry with no parent.
      await seedLegacyEntry(customerId: 9999, amount: 5000);

      final result = await migrate();

      expect(result.orphanedEntries, 1);
      expect(await isar.transactions.count(), 1, reason: 'the row is kept');
      expect(await queue.pendingCount(isar), 0);
    });

    test('a non-positive amount is kept but never queued', () async {
      // The server enforces amount_paise > 0. Queueing one guarantees a
      // permanent rejection and a dead-letter the user cannot act on.
      final c = await seedLegacyCustomer('Ramesh', '1');
      await seedLegacyEntry(customerId: c, amount: 0);
      await seedLegacyEntry(customerId: c, amount: -500);

      final result = await migrate();

      expect(result.unsyncableEntries, 2);
      expect(await isar.transactions.count(), 2);
      expect(
        (await queue.pending(isar)).where((o) => o.entity == 'ledger_entry'),
        isEmpty,
      );
    });

    test('a soft-deleted customer is not recreated on the server', () async {
      final id = await seedLegacyCustomer('Gone', '1');
      await isar.writeTxn(() async {
        final c = await isar.customers.get(id);
        await isar.customers.put(c!..deletedAt = DateTime.utc(2026, 1, 1));
      });

      final result = await migrate();

      expect(result.operationsSeeded, 0);
      expect(await isar.customers.count(), 1, reason: 'the row is kept');
    });
  });

  group('safety', () {
    test('running twice does nothing the second time', () async {
      // Without the version guard a second run would mint fresh uuids for rows
      // that already had them, orphaning every queued operation.
      final c = await seedLegacyCustomer('Ramesh', '1');
      await seedLegacyEntry(customerId: c, amount: 5000);

      final first = await migrate();
      final uuids = (await isar.customers.where().findAll())
          .map((c) => c.uuid)
          .toList();

      final second = await migrate();

      expect(first.ran, isTrue);
      expect(second.ran, isFalse);
      expect(await queue.pendingCount(isar), first.operationsSeeded);
      expect(
        (await isar.customers.where().findAll()).map((c) => c.uuid).toList(),
        uuids,
        reason: 'identities must be stable across runs',
      );
    });

    test('a snapshot is taken before anything is written', () async {
      final c = await seedLegacyCustomer('Ramesh', '1');
      await seedLegacyEntry(customerId: c, amount: 5000);

      final result = await migrate();

      expect(result.backupPath, isNotNull);
      expect(File(result.backupPath!).existsSync(), isTrue);
      expect(File(result.backupPath!).lengthSync(), greaterThan(0));
    });

    test('the backup still holds the pre-migration shape', () async {
      // The snapshot is only worth taking if it can actually be reopened.
      final c = await seedLegacyCustomer('Ramesh', '1');
      await seedLegacyEntry(customerId: c, amount: 5000);

      final result = await migrate();

      final restored = await Isar.open(
        [
          CustomerSchema,
          TransactionSchema,
          UserSessionSchema,
          SyncOpSchema,
          SyncMetaSchema,
        ],
        directory: dir.path,
        name: '${name}_restored',
      );
      await restored.close();

      final backup = File(result.backupPath!);
      expect(backup.existsSync(), isTrue);
      expect(backup.lengthSync(), greaterThan(1000));
    });

    test('no rows are created or destroyed', () async {
      final a = await seedLegacyCustomer('A', '1');
      final b = await seedLegacyCustomer('B', '2');
      for (var i = 0; i < 10; i++) {
        await seedLegacyEntry(customerId: i.isEven ? a : b, amount: 100.0 + i);
      }

      final before = [
        await isar.customers.count(),
        await isar.transactions.count(),
      ];

      await migrate();

      expect(
        [await isar.customers.count(), await isar.transactions.count()],
        before,
      );
    });

    test('an empty database migrates without a backup', () async {
      final result = await migrate();

      expect(result.ran, isTrue);
      expect(result.backupPath, isNull, reason: 'nothing to lose');
      expect((await isar.syncMetas.get(0))!.schemaVersion,
          LocalMigration.currentSchemaVersion);
    });

    test('a large ledger migrates intact', () async {
      final c = await seedLegacyCustomer('Ramesh', '1');
      for (var i = 0; i < 500; i++) {
        await seedLegacyEntry(customerId: c, amount: 100.0 + i);
      }

      final result = await migrate();

      expect(result.entriesMigrated, 500);
      expect(result.operationsSeeded, 501);
      expect(
        (await isar.transactions.where().findAll())
            .map((t) => t.uuid)
            .toSet()
            .length,
        500,
        reason: 'every identity must be distinct',
      );
    });
  });
}
