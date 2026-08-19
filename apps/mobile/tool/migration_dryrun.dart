// Dry-runs the one-time migration against a copy of a real device database and
// reports what it would do — without touching the original.
//
// The automated tests use realistic shapes, but real ledgers always contain
// something nobody predicted: an entry whose customer was deleted two releases
// ago, an amount typed as 1e9, a date from 1970. This is how you find those
// before they reach every user at once.
//
//   dart run tool/migration_dryrun.dart <path-to-copy-of.isar>
//
// Pull one off an Android device (debuggable builds only):
//   adb exec-out run-as com.example.mychopdi cat app_flutter/default.isar > real.isar

import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mychopdi/data/migration/local_migration.dart';
import 'package:mychopdi/data/repository/sync_queue.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/sync_meta.dart';
import 'package:mychopdi/model/sync_op.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/model/user_session.dart';
import 'package:mychopdi/utils/money.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run tool/migration_dryrun.dart <file.isar>');
    exit(64);
  }

  final source = File(args.first);
  if (!source.existsSync()) {
    stderr.writeln('No such file: ${source.path}');
    exit(66);
  }

  await Isar.initializeIsarCore(download: true);

  // Work on a throwaway copy. The point of a dry run is that the input survives
  // it, however badly the migration behaves.
  final work = await Directory.systemTemp.createTemp('chopdi_dryrun');
  const name = 'dryrun';
  source.copySync('${work.path}/$name.isar');

  final isar = await Isar.open(
    [
      CustomerSchema,
      TransactionSchema,
      UserSessionSchema,
      SyncOpSchema,
      SyncMetaSchema,
    ],
    directory: work.path,
    name: name,
  );

  int money(int paise) => paise;

  print('=' * 62);
  print('  BEFORE');
  print('=' * 62);

  final customersBefore = await isar.customers.where().findAll();
  final entriesBefore = await isar.transactions.where().findAll();

  print('  customers            : ${customersBefore.length}');
  print('  entries              : ${entriesBefore.length}');
  print('  already have a uuid  : '
      '${customersBefore.where((c) => c.uuid.isNotEmpty).length}');
  print('  schema version       : '
      '${(await isar.syncMetas.get(0))?.schemaVersion ?? 0}');

  // The sum the user currently sees, computed the old way.
  final legacyTotal = entriesBefore.fold<double>(
    0,
    (sum, t) => t.type == TransactionType.gave
        ? sum + t.legacyAmount
        : sum - t.legacyAmount,
  );
  print('  net balance (legacy) : ₹${legacyTotal.toStringAsFixed(2)}');

  final knownCustomerIds = customersBefore.map((c) => c.id).toSet();
  final orphans =
      entriesBefore.where((t) => !knownCustomerIds.contains(t.customerId));
  final nonPositive = entriesBefore.where((t) => t.legacyAmount <= 0);

  if (orphans.isNotEmpty) {
    print('  ⚠ orphaned entries    : ${orphans.length} '
        '(customer no longer exists — kept, never synced)');
  }
  if (nonPositive.isNotEmpty) {
    print('  ⚠ non-positive amounts: ${nonPositive.length} '
        '(server would reject — kept, never synced)');
  }

  final result = await const LocalMigration()
      .run(isar, directory: work.path, instanceName: name);

  print('');
  print('=' * 62);
  print('  RESULT');
  print('=' * 62);
  print('  $result');

  final customersAfter = await isar.customers.where().findAll();
  final entriesAfter = await isar.transactions.where().findAll();
  const queue = SyncQueue();

  print('');
  print('=' * 62);
  print('  AFTER — these must all hold');
  print('=' * 62);

  var failures = 0;
  void check(String label, bool ok, [String detail = '']) {
    if (!ok) failures++;
    print('  ${ok ? 'OK  ' : 'FAIL'}  $label${detail.isEmpty ? '' : ' — $detail'}');
  }

  check('no customers lost', customersAfter.length == customersBefore.length,
      '${customersBefore.length} → ${customersAfter.length}');
  check('no entries lost', entriesAfter.length == entriesBefore.length,
      '${entriesBefore.length} → ${entriesAfter.length}');
  check('every customer has an identity',
      customersAfter.every((c) => c.uuid.isNotEmpty));
  check('every entry has an identity',
      entriesAfter.every((t) => t.uuid.isNotEmpty));
  check('identities are unique',
      entriesAfter.map((t) => t.uuid).toSet().length == entriesAfter.length);

  // The number the user sees must not move. This is the check that matters
  // most: a balance that shifts on upgrade destroys trust in the ledger even
  // when no data was actually lost.
  final migratedTotal = entriesAfter.fold<int>(
    0,
    (sum, t) => t.type == TransactionType.gave
        ? sum + money(t.amountPaise)
        : sum - money(t.amountPaise),
  );
  final expectedPaise = Money.toPaise(legacyTotal);
  check(
    'net balance unchanged',
    (migratedTotal - expectedPaise).abs() <= entriesAfter.length,
    '₹${legacyTotal.toStringAsFixed(2)} → ₹${Money.toRupees(migratedTotal).toStringAsFixed(2)}',
  );

  final queued = await queue.pendingCount(isar);
  final syncable = entriesAfter
          .where((t) =>
              t.customerUuid.isNotEmpty && t.amountPaise > 0 && t.voidedAt == null)
          .length +
      customersAfter.where((c) => c.deletedAt == null).length;
  check('everything syncable is queued', queued == syncable,
      '$queued queued, $syncable expected');

  // Per-entry conversion, so a single bad row is visible rather than averaged
  // away by the total.
  final mismatches = <String>[];
  for (final t in entriesAfter) {
    if (t.legacyAmount == 0) continue;
    final expected = Money.toPaise(t.legacyAmount);
    if (t.amountPaise != expected) {
      mismatches.add('  entry ${t.id}: ₹${t.legacyAmount} → '
          '${t.amountPaise} paise (expected $expected)');
    }
  }
  check('every amount converted exactly', mismatches.isEmpty,
      '${mismatches.length} mismatched');
  for (final m in mismatches.take(10)) {
    print(m);
  }

  print('');
  print(failures == 0
      ? '  ✅ Safe to ship against this database.'
      : '  ❌ $failures check(s) failed — do NOT ship. Original file untouched.');

  await isar.close();
  work.deleteSync(recursive: true);
  exit(failures == 0 ? 0 : 1);
}
