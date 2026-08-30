import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../model/customer.dart';
import '../model/sync_status.dart';
import 'isar_service.dart';

class CustomerMigrationService {
  static const Uuid _uuid = Uuid();

  static Future<void> migrateCustomers() async {
    final isar = IsarService.isar;

    final customers = await isar.customers
        .filter()
        .uuidEqualTo('')
        .findAll();

    if (customers.isEmpty) {
      return;
    }

    await isar.writeTxn(() async {
      for (final customer in customers) {
        customer
          ..uuid = _uuid.v7()
          ..updatedAt = DateTime.now().toUtc()
          ..syncStatus = SyncStatus.pending;

        await isar.customers.put(customer);
      }
    });

    print(
      '[CustomerMigration] Migrated ${customers.length} customers',
    );
  }
}