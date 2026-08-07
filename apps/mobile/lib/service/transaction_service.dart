import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';

class TransactionService {

  static final isar = IsarService.isar;

  static Future<void> addTransaction(Transaction tx) async {

    await isar.writeTxn(() async {
      await isar.transactions.put(tx);
    });

  }


  Future<void> deleteTransaction({
    required int transactionId,
    required int customerId,
  }) async {
    await isar.writeTxn(() async {
      final transaction =
          await isar.transactions.get(transactionId);

      if (transaction == null) return;

      final customer =
          await isar.customers.get(customerId);

      if (customer != null) {
        // customer.amount -= transaction.amount;
        await isar.customers.put(customer);
      }

      await isar.transactions.delete(transactionId);
    });
  }

}