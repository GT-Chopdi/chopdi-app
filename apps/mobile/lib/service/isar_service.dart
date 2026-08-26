// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:mychopdi/data/migration/local_migration.dart';
// import 'package:mychopdi/model/chopdi.dart';
// import 'package:mychopdi/model/customer.dart';
// import 'package:mychopdi/model/notification.dart';
// import 'package:mychopdi/model/transaction.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:isar_community/isar.dart';
// import '../model/sync_meta.dart';
// import '../model/sync_op.dart';
// import '../model/user_session.dart';

// class IsarService {
//   static late final Isar isar;

//   static Null get instance => null;

//   /// Outcome of the one-time data migration, for diagnostics.
//   ///
//   /// Null until [init] has run.
//   static MigrationResult? migrationResult;

//   /// Set when the migration failed.
//   ///
//   /// A failure is survivable rather than fatal, and deliberately so: the
//   /// derived money getters fall back to the legacy columns, so the ledger still
//   /// renders and nothing is lost. New entries work normally; older ones cannot
//   /// be edited or synced until the migration succeeds, and the repository says
//   /// exactly that when asked. Refusing to start would turn a recoverable state
//   /// into an app that will not open.
//   static Object? migrationError;

//   static Future<void> init() async {
//     final dir =
//         await getApplicationDocumentsDirectory();

//     isar = await Isar.open(
//       [
//         CustomerSchema,
//         TransactionSchema,
//         UserSessionSchema,
//         SyncOpSchema,
//         SyncMetaSchema,
//         ChopdiSchema,
//         NotificationModelSchema,
//       ],
//       directory: dir.path,
//     );

//     // Runs before any screen reads, so the UI never sees a half-converted
//     // ledger. It is a no-op after the first successful run.
//     try {
//       migrationResult = await const LocalMigration().run(
//         isar,
//         directory: dir.path,
//       );

//       if (migrationResult!.ran) {
//         debugPrint('[chopdi] $migrationResult');
//       }

//       // Housekeeping only, and never allowed to break startup.
//       //
//       // `unawaited` does NOT route errors to the catch below — an async failure
//       // in a detached future becomes an unhandled error, which is a crash on
//       // some configurations. Deleting old backups is the least important thing
//       // this method does; it must never be the reason the app fails to open.
//       unawaited(
//         LocalMigration.pruneBackups(dir.path).catchError(
//           (Object e) => debugPrint('[chopdi] backup pruning skipped: $e'),
//         ),
//       );
//     } catch (error, stack) {
//       migrationError = error;
//       debugPrint('[chopdi] migration failed: $error\n$stack');
//     }
//   }
  

//   static Future<List<Customer>> getCustomers() async {
//     // Soft-deleted customers stay in the table so the deletion can reach
//     // other devices; they must not appear in a customer list.
//     return await isar.customers.filter().deletedAtIsNull().findAll();
//   }

//   static Future<Customer?> getCustomerByPhone(
//     String phone,
//   ) async {
//     return await isar.customers
//         .filter()
//         .phoneEqualTo(phone)
//         .deletedAtIsNull()
//         .findFirst();
//   }

//   static Future<Customer?> getCustomerByPhoneAndChopdi(
//     String phone,
//     int chopdiId,
//   ) async {
//     return await isar.customers
//         .filter()
//         .phoneEqualTo(phone)
//         .and()
//         .chopdiIdEqualTo(chopdiId)
//         .findFirst();
//   }

//   static Future<SummaryData> getSummary() async {
//     final customers =
//         await getCustomers();

//     double totalOutstanding = 0;
//     double totalLoanGiven = 0;
//     double totalInterestEarned = 0;

//     for (final customer in customers) {
//       // Add your summary calculations here.
//     }

//     return SummaryData(
//       outstanding: totalOutstanding,
//       loanGiven: totalLoanGiven,
//       interest: totalInterestEarned,
//     );
//   }
// }

// class SummaryData {
//   final double outstanding;
//   final double loanGiven;
//   final double interest;

//   SummaryData({
//     required this.outstanding,
//     required this.loanGiven,
//     required this.interest,
//   });
// }

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/data/migration/local_migration.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/notification.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../model/sync_meta.dart';
import '../model/sync_op.dart';
import '../model/user_session.dart';

class IsarService {
  static late final Isar isar;

  static Null get instance => null;

  static MigrationResult? migrationResult;

  static Object? migrationError;

  static const Uuid _uuid = Uuid();

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [
        CustomerSchema,
        TransactionSchema,
        UserSessionSchema,
        SyncOpSchema,
        SyncMetaSchema,
        ChopdiSchema,
        NotificationModelSchema,
      ],
      directory: dir.path,
    );

    try {
      migrationResult = await const LocalMigration().run(
        isar,
        directory: dir.path,
      );

      if (migrationResult!.ran) {
        debugPrint('[chopdi] $migrationResult');
      }

      // ---------------------------------------------------------------
      // Repair old rows which existed before UUID/chopdi migration.
      // ---------------------------------------------------------------
      //
      // This is intentionally idempotent:
      // - Existing UUIDs are never replaced.
      // - Existing chopdiId values are never replaced.
      // - Existing customerUuid values are never replaced.
      // - Existing transaction UUIDs are never replaced.
      //
      // This fixes old local data which otherwise causes:
      //
      // RepositoryException:
      // This customer has not been migrated yet.
      //
      await _repairLegacyIdentities();

      // Housekeeping only.
      unawaited(
        LocalMigration.pruneBackups(dir.path).catchError(
          (Object e) => debugPrint(
            '[chopdi] backup pruning skipped: $e',
          ),
        ),
      );
    } catch (error, stack) {
      migrationError = error;

      debugPrint(
        '[chopdi] migration failed: $error\n$stack',
      );
    }
  }

  /// Repairs old Customer and Transaction rows that were created before
  /// UUID-based synchronization was introduced.
  ///
  /// This does NOT replace existing identities.
  static Future<void> _repairLegacyIdentities() async {
    try {
      await isar.writeTxn(() async {
        final customers = await isar.customers.where().findAll();

        // ---------------------------------------------------------------
        // 1. Customers
        // ---------------------------------------------------------------
        //
        // Old customers can have:
        //
        // uuid = ''
        //
        // The repository refuses to create transactions for such customers
        // because a transaction now references customerUuid.
        //
        // Give those old rows a permanent local UUID.
        for (final customer in customers) {
          if (customer.uuid.isEmpty) {
            customer.uuid = _uuid.v7();

            await isar.customers.put(customer);

            debugPrint(
              '[chopdi] repaired customer '
              'id=${customer.id} '
              'name=${customer.name} '
              'uuid=${customer.uuid} '
              'chopdiId=${customer.chopdiId}',
            );
          }
        }

        // ---------------------------------------------------------------
        // 2. Transactions
        // ---------------------------------------------------------------
        //
        // Old transactions can have:
        //
        // uuid = ''
        // customerUuid = ''
        //
        // Resolve their customer using the legacy local customerId.
        final transactions =
            await isar.transactions.where().findAll();

        for (final transaction in transactions) {
          bool changed = false;

          // Give old transactions their permanent UUID.
          if (transaction.uuid.isEmpty) {
            transaction.uuid = _uuid.v7();
            changed = true;
          }

          // Resolve the owning customer.
          Customer? customer;

          if (transaction.customerUuid.isNotEmpty) {
            customer = await isar.customers
                .filter()
                .uuidEqualTo(transaction.customerUuid)
                .findFirst();
          }

          // If customerUuid was missing, use the legacy local customerId.
          customer ??= await isar.customers.get(
              transaction.customerId,
            );

          if (customer != null) {
            // Only fill customerUuid when it is missing.
            if (transaction.customerUuid.isEmpty) {
              transaction.customerUuid = customer.uuid;
              changed = true;
            }

            // Old transactions also need the same Chopdi as their customer.
            //
            // Do NOT overwrite a non-zero existing chopdiId.
            if (transaction.chopdiId == 0 &&
                customer.chopdiId != 0) {
              transaction.chopdiId = customer.chopdiId;
              changed = true;
            }
          }

          if (changed) {
            await isar.transactions.put(transaction);

            debugPrint(
              '[chopdi] repaired transaction '
              'id=${transaction.id} '
              'uuid=${transaction.uuid} '
              'customerId=${transaction.customerId} '
              'customerUuid=${transaction.customerUuid} '
              'chopdiId=${transaction.chopdiId}',
            );
          }
        }
      });

      debugPrint('[chopdi] legacy identity repair completed');
    } catch (error, stack) {
      debugPrint(
        '[chopdi] legacy identity repair failed: '
        '$error\n$stack',
      );

      // Do not crash application startup because of repair.
    }
  }

  static Future<List<Customer>> getCustomers() async {
    return await isar.customers
        .filter()
        .deletedAtIsNull()
        .findAll();
  }

  static Future<Customer?> getCustomerByPhone(
    String phone,
  ) async {
    return await isar.customers
        .filter()
        .phoneEqualTo(phone)
        .deletedAtIsNull()
        .findFirst();
  }

  static Future<Customer?> getCustomerByPhoneAndChopdi(
    String phone,
    int chopdiId,
  ) async {
    return await isar.customers
        .filter()
        .phoneEqualTo(phone)
        .and()
        .chopdiIdEqualTo(chopdiId)
        .findFirst();
  }

  static Future<SummaryData> getSummary() async {
    final customers = await getCustomers();

    double totalOutstanding = 0;
    double totalLoanGiven = 0;
    double totalInterestEarned = 0;

    for (final customer in customers) {
      // Add your summary calculations here.
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