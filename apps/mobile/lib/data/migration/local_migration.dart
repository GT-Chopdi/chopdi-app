import 'dart:convert';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../model/customer.dart';
import '../../model/sync_meta.dart';
import '../../model/sync_op.dart';
import '../../model/sync_status.dart';
import '../../model/transaction.dart';
import '../../utils/money.dart';
import '../repository/sync_payload.dart';

/// What a migration run did. Worth logging — this executes once on a real
/// phone, against a real ledger, and cannot be rolled back.
class MigrationResult {
  const MigrationResult({
    required this.ran,
    this.customersMigrated = 0,
    this.entriesMigrated = 0,
    this.operationsSeeded = 0,
    this.orphanedEntries = 0,
    this.unsyncableEntries = 0,
    this.backupPath,
  });

  /// False when the database was already at the current version.
  final bool ran;

  final int customersMigrated;
  final int entriesMigrated;
  final int operationsSeeded;

  /// Entries whose customer no longer exists — kept, never synced.
  final int orphanedEntries;

  /// Entries the server would reject (a non-positive amount) — kept, never sent.
  final int unsyncableEntries;

  final String? backupPath;

  @override
  String toString() => ran
      ? 'Migration: $customersMigrated customers, $entriesMigrated entries, '
          '$operationsSeeded queued, $orphanedEntries orphaned, '
          '$unsyncableEntries unsyncable, backup: $backupPath'
      : 'Migration: already current';
}

class MigrationException implements Exception {
  const MigrationException(this.message);
  final String message;
  @override
  String toString() => 'MigrationException: $message';
}

/// One-time conversion of locally stored data into the sync-ready shape.
///
/// Runs at startup, before any screen reads. It mints a permanent identity for
/// every existing row, converts money from floating-point rupees to integer
/// paise, replaces the local customer foreign key with the one that means
/// something on another device, and — the step that is easy to forget — seeds
/// the outbox so a user's existing ledger actually reaches the server. Without
/// that last part only *new* entries would ever sync, and years of history
/// would sit on the phone looking perfectly healthy.
///
/// The whole conversion is a single transaction. A partial migration is the
/// worst possible outcome: customers with identities and entries without, and
/// nothing on disk saying so.
class LocalMigration {
  const LocalMigration();

  /// Bump when a future release needs another pass.
  static const currentSchemaVersion = 1;

  static const _uuid = Uuid();

  Future<MigrationResult> run(
    Isar isar, {
    required String directory,
    String instanceName = Isar.defaultName,
  }) async {
    final meta = await isar.syncMetas.get(0) ?? SyncMeta();

    if (meta.schemaVersion >= currentSchemaVersion) {
      return const MigrationResult(ran: false);
    }

    final customers = await isar.customers.where().findAll();
    final entries = await isar.transactions.where().findAll();

    // Nothing to convert. Still record the version so the check is cheap next
    // launch, and skip the backup — there is nothing to lose.
    if (customers.isEmpty && entries.isEmpty) {
      await isar.writeTxn(() async {
        await isar.syncMetas.put(meta..schemaVersion = currentSchemaVersion);
      });
      return const MigrationResult(ran: true);
    }

    final backupPath = await _backup(isar, directory, instanceName);

    final customerCountBefore = customers.length;
    final entryCountBefore = entries.length;

    var operationsSeeded = 0;
    var orphaned = 0;
    var unsyncable = 0;
    final now = DateTime.now().toUtc();

    await isar.writeTxn(() async {
      // Customers first: entries need their uuids to reference.
      final uuidByLocalId = <int, String>{};

      for (final c in customers) {
        if (c.uuid.isEmpty) c.uuid = _uuid.v7();
        uuidByLocalId[c.id] = c.uuid;

        c
          ..updatedAt = c.updatedAt.millisecondsSinceEpoch == 0 ? now : c.updatedAt
          ..version = 0
          ..syncStatus = SyncStatus.pending;

        await isar.customers.put(c);

        // Soft-deleted rows are not re-created on the server.
        if (c.deletedAt == null) {
          await _enqueue(isar, entity: 'customer', entityId: c.uuid, payload: {
            'name': c.name,
            'phone': c.phone.isEmpty ? null : c.phone,
            'notes': c.notes,
          });
          operationsSeeded++;
        }
      }

      for (final tx in entries) {
        if (tx.uuid.isEmpty) tx.uuid = _uuid.v7();

        // Convert money exactly once, using the same rule as every live write.
        if (tx.amountPaise == 0 && tx.legacyAmount != 0) {
          tx.amountPaise = Money.toPaise(tx.legacyAmount);
        }
        if (tx.interestRateBp == 0 && tx.legacyInterestRate != 0) {
          tx.interestRateBp = Money.rateToBasisPoints(tx.legacyInterestRate);
        }

        final customerUuid = uuidByLocalId[tx.customerId];
        if (customerUuid != null) tx.customerUuid = customerUuid;

        tx
          ..updatedAt =
              tx.updatedAt.millisecondsSinceEpoch == 0 ? now : tx.updatedAt
          ..version = 0
          ..syncStatus = SyncStatus.pending;

        await isar.transactions.put(tx);

        // An entry whose customer was hard-deleted by an older build. It is
        // already invisible in the app, since every query goes through a
        // customer. Keep the row — deleting a financial record during an
        // upgrade is not something to do quietly — but it can never sync,
        // because the server would reject an entry with no parent.
        if (customerUuid == null) {
          orphaned++;
          continue;
        }

        // The server enforces `amount_paise > 0`. Queuing one of these would
        // guarantee a permanent rejection and a dead-letter the user cannot act
        // on, so it stays local and is counted instead.
        if (tx.amountPaise <= 0) {
          unsyncable++;
          continue;
        }

        if (tx.voidedAt != null) continue;

        await _enqueue(isar, entity: 'ledger_entry', entityId: tx.uuid, payload: {
          'customerId': tx.customerUuid,
          'amountPaise': tx.amountPaise,
          'direction': SyncPayload.direction(tx.type),
          'interestRateBp': tx.interestRateBp,
          'interestType': SyncPayload.interestType(tx.interestType,
              rateBp: tx.interestRateBp),
          'interestFrequency': SyncPayload.interestFrequency(tx.interestFrequency),
          'entryDate': SyncPayload.entryDate(tx.date),
          'description': tx.description,
          'paymentMode': tx.paymentMode,
        });
        operationsSeeded++;
      }

      await isar.syncMetas.put(meta..schemaVersion = currentSchemaVersion);
    });

    // Nothing above deletes, so a changed count means the transaction did
    // something unintended. Failing loudly beats shipping a quiet loss.
    final customersAfter = await isar.customers.count();
    final entriesAfter = await isar.transactions.count();

    if (customersAfter != customerCountBefore || entriesAfter != entryCountBefore) {
      throw MigrationException(
        'Row count changed during migration '
        '(customers $customerCountBefore→$customersAfter, '
        'entries $entryCountBefore→$entriesAfter). '
        'Restore from $backupPath.',
      );
    }

    return MigrationResult(
      ran: true,
      customersMigrated: customerCountBefore,
      entriesMigrated: entryCountBefore,
      operationsSeeded: operationsSeeded,
      orphanedEntries: orphaned,
      unsyncableEntries: unsyncable,
      backupPath: backupPath,
    );
  }

  Future<void> _enqueue(
    Isar isar, {
    required String entity,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    await isar.syncOps.put(
      SyncOp()
        ..opId = _uuid.v7()
        ..entity = entity
        ..entityId = entityId
        ..opType = 'create'
        ..payload = jsonEncode(payload)
        ..createdAt = DateTime.now().toUtc(),
    );
  }

  /// Snapshots the database before touching it.
  ///
  /// `copyToFile` takes a consistent snapshot rather than copying a file that
  /// may be mid-write. This is the only way back if the conversion is wrong,
  /// and it is cheap next to the cost of being wrong.
  Future<String> _backup(Isar isar, String directory, String name) async {
    final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    final path = '$directory/$name.pre-migration-$stamp.isar';

    try {
      await isar.copyToFile(path);
      return path;
    } catch (e) {
      throw MigrationException(
        'Could not back up the database before migrating ($e). '
        'Refusing to continue — an unrecoverable conversion is worse than a '
        'delayed one.',
      );
    }
  }

  /// Removes snapshots older than [keepDays], leaving the most recent.
  static Future<void> pruneBackups(
    String directory, {
    int keepDays = 30,
  }) async {
    final dir = Directory(directory);
    if (!dir.existsSync()) return;

    final List<File> backups;
    try {
      backups = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('.pre-migration-'))
          .toList()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    } catch (_) {
      // An unreadable directory is not worth failing over — the caller is
      // deleting old files, not doing anything the app depends on.
      return;
    }

    final cutoff = DateTime.now().subtract(Duration(days: keepDays));

    // Always keep the newest, however old — it is the only route back.
    for (final file in backups.skip(1)) {
      if (file.statSync().modified.isBefore(cutoff)) {
        try {
          file.deleteSync();
        } catch (_) {
          // A backup we cannot delete is harmless; failing startup is not.
        }
      }
    }
  }
}
