import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mychopdi/data/migration/local_migration.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar_community/isar.dart';
import '../model/sync_meta.dart';
import '../model/sync_op.dart';
import '../model/user_session.dart';

class IsarService {
  static late final Isar isar;

  static Null get instance => null;

  /// Outcome of the one-time data migration, for diagnostics.
  ///
  /// Null until [init] has run.
  static MigrationResult? migrationResult;

  /// Set when the migration failed.
  ///
  /// A failure is survivable rather than fatal, and deliberately so: the
  /// derived money getters fall back to the legacy columns, so the ledger still
  /// renders and nothing is lost. New entries work normally; older ones cannot
  /// be edited or synced until the migration succeeds, and the repository says
  /// exactly that when asked. Refusing to start would turn a recoverable state
  /// into an app that will not open.
  static Object? migrationError;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [
        CustomerSchema,
        TransactionSchema,
        UserSessionSchema,
        SyncOpSchema,
        SyncMetaSchema,
      ],
      directory: dir.path,
    );

    // Runs before any screen reads, so the UI never sees a half-converted
    // ledger. It is a no-op after the first successful run.
    try {
      migrationResult = await const LocalMigration().run(
        isar,
        directory: dir.path,
      );

      if (migrationResult!.ran) {
        debugPrint('[chopdi] $migrationResult');
      }

      // Housekeeping only, and never allowed to break startup.
      //
      // `unawaited` does NOT route errors to the catch below — an async failure
      // in a detached future becomes an unhandled error, which is a crash on
      // some configurations. Deleting old backups is the least important thing
      // this method does; it must never be the reason the app fails to open.
      unawaited(
        LocalMigration.pruneBackups(dir.path).catchError(
          (Object e) => debugPrint('[chopdi] backup pruning skipped: $e'),
        ),
      );
    } catch (error, stack) {
      migrationError = error;
      debugPrint('[chopdi] migration failed: $error\n$stack');
    }
  }

  static Future<List<Customer>> getCustomers() async {
    // Soft-deleted customers stay in the table so the deletion can reach
    // other devices; they must not appear in a customer list.
    return await isar.customers.filter().deletedAtIsNull().findAll();
  }

  static Future<Customer?> getCustomerByPhone(String phone) async {
    return await isar.customers
        .filter()
        .phoneEqualTo(phone)
        .deletedAtIsNull()
        .findFirst();
  }

  static Future<SummaryData> getSummary() async {
    final customers = await getCustomers();

    double totalOutstanding = 0;
    double totalLoanGiven = 0;
    double totalInterestEarned = 0;

    for (final customer in customers) {
      // totalOutstanding += customer.amount;

      // totalLoanGiven += customer.amount;

      // totalInterestEarned += customer.interest; // change according to your model
    }

    return SummaryData(
      outstanding: totalOutstanding,
      loanGiven: totalLoanGiven,
      interest: totalInterestEarned,
    );
  }
}

class SummaryData {
  final double outstanding;
  final double loanGiven;
  final double interest;

  SummaryData({
    required this.outstanding,
    required this.loanGiven,
    required this.interest,
  });
}