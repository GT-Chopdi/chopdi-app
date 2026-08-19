import 'package:mychopdi/data/repository/repositories.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';

/// Thin façade kept for the screens that already call it.
///
/// Every method now delegates to [Repositories.ledger], so writes land in the
/// outbox in the same transaction as the row. Previously this wrote to Isar
/// directly, which meant an entry saved here was never queued for sync — it
/// simply lived on the device, with no error and no pending indicator.
class TransactionService {
  const TransactionService();

  /// Persists a draft entry and queues it for sync.
  static Future<Transaction> addTransaction(Transaction tx) =>
      Repositories.ledger.adoptDraft(tx);

  /// Marks an entry deleted.
  ///
  /// A soft delete, not a removal. A hard delete cannot be communicated to
  /// another device — the row just stops appearing there, indistinguishable
  /// from one never seen — and it destroys the audit history the server keeps
  /// for a financial record. Every read path filters `voidedAt`, so the entry
  /// disappears from the UI exactly as before.
  Future<void> deleteTransaction({
    required int transactionId,
    required int customerId,
    String reason = 'Deleted by user',
  }) async {
    final tx = await IsarService.isar.transactions.get(transactionId);
    if (tx == null) return;

    await Repositories.ledger.voidEntry(tx, reason: reason);
  }
}
