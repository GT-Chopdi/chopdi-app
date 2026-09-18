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
  static Future<void> _repairLegacyIdentities() async {
    try {
      await isar.writeTxn(() async {
        final customers = await isar.customers.where().findAll();

        // ---------------------------------------------------------------
        // 1. Customers
        // ---------------------------------------------------------------
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

      debugPrint(
        '[chopdi] legacy identity repair completed',
      );
    } catch (error, stack) {
      debugPrint(
        '[chopdi] legacy identity repair failed: '
            '$error\n$stack',
      );

      // Do not crash application startup because of repair.
    }
  }

  // -------------------------------------------------------------------
  // GET ALL ACTIVE CUSTOMERS
  // -------------------------------------------------------------------

  static Future<List<Customer>> getCustomers() async {
    return await isar.customers
        .filter()
        .deletedAtIsNull()
        .findAll();
  }

  // -------------------------------------------------------------------
  // GET CUSTOMER BY PHONE
  // -------------------------------------------------------------------
  //
  // Keep this method because other parts of your application may already
  // be using it.
  //
  // NOTE:
  // This method checks phone only.
  // For creating a customer, use getCustomerByNameAndPhone().
  // -------------------------------------------------------------------

  static Future<Customer?> getCustomerByPhone(
      String phone,
      ) async {
    final cleanPhone = phone.trim();

    if (cleanPhone.isEmpty) {
      return null;
    }

    return await isar.customers
        .filter()
        .phoneEqualTo(cleanPhone)
        .deletedAtIsNull()
        .findFirst();
  }

  // -------------------------------------------------------------------
  // GET CUSTOMER BY PHONE + CHOPDI
  // -------------------------------------------------------------------

  static Future<Customer?> getCustomerByPhoneAndChopdi(
      String phone,
      int chopdiId,
      ) async {
    final cleanPhone = phone.trim();

    if (cleanPhone.isEmpty) {
      return null;
    }

    return await isar.customers
        .filter()
        .phoneEqualTo(cleanPhone)
        .and()
        .chopdiIdEqualTo(chopdiId)
        .and()
        .deletedAtIsNull()
        .findFirst();
  }

  // -------------------------------------------------------------------
  // GET CUSTOMER BY NAME + PHONE + CHOPDI
  // -------------------------------------------------------------------
  //
  // This is the duplicate check used when creating a customer.
  //
  // Rules:
  //
  // 1. john + empty
  //    john + empty
  //    => DUPLICATE
  //
  // 2. john + empty
  //    john + 98765
  //    => NEW
  //
  // 3. john + 98765
  //    john + 98765
  //    => DUPLICATE
  //
  // 4. john + 98765
  //    john + 12345
  //    => NEW
  //
  // Different chopdiId values are treated as separate customers.
  // -------------------------------------------------------------------

  static Future<Customer?> getCustomerByNameAndPhone(
      String name,
      String phone,
      int chopdiId,
      ) async {
    final cleanName = name.trim();
    final cleanPhone = phone.trim();

    // Name is required.
    if (cleanName.isEmpty) {
      return null;
    }

    // ---------------------------------------------------------------
    // PHONE IS EMPTY
    // ---------------------------------------------------------------
    //
    // If both names are the same and both phone numbers are empty,
    // it is a duplicate.
    // ---------------------------------------------------------------

    if (cleanPhone.isEmpty) {
      final customers = await isar.customers
          .filter()
          .chopdiIdEqualTo(chopdiId)
          .and()
          .deletedAtIsNull()
          .findAll();

      for (final customer in customers) {
        if (customer.name.trim().toLowerCase() ==
            cleanName.toLowerCase()) {
          if (customer.phone.trim().isEmpty) {
            return customer;
          }
        }
      }

      return null;
    }

    // ---------------------------------------------------------------
    // PHONE EXISTS
    // ---------------------------------------------------------------
    //
    // Match:
    // name + phone + chopdiId
    //
    // Name comparison is case-insensitive.
    // ---------------------------------------------------------------

    final customers = await isar.customers
        .filter()
        .phoneEqualTo(cleanPhone)
        .and()
        .chopdiIdEqualTo(chopdiId)
        .and()
        .deletedAtIsNull()
        .findAll();

    for (final customer in customers) {
      if (customer.name.trim().toLowerCase() ==
          cleanName.toLowerCase()) {
        return customer;
      }
    }

    return null;
  }

  // -------------------------------------------------------------------
  // SUMMARY
  // -------------------------------------------------------------------

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