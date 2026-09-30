// See customer_repository.dart for why this lint is disabled.
// ignore_for_file: prefer_initializing_formals

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../model/customer.dart';
import '../../model/lender.dart'; // <-- Imported Lender model
import '../../model/sync_status.dart';
import '../../model/transaction.dart';
import 'lender_repo.dart';
import 'repository_exception.dart';
import 'customer_repository.dart';
// import 'lender_repository.dart'; // <-- Imported Lender repository
import 'sync_payload.dart';
import 'sync_queue.dart';

/// The only write path for ledger entries.
///
/// Entries are facts, not state: two devices recording entries offline produce
/// a union rather than a conflict, and balances are derived by folding them.
/// That is why no balance is stored anywhere — there is no shared number for
/// two devices to disagree about.
class LedgerRepository {
  LedgerRepository(
      this._isar, {
        SyncQueue queue = const SyncQueue(),
        CustomerRepository? customers,
        LenderRepository? lenders,
      }) : _queue = queue,
        _customers = customers ?? CustomerRepository(_isar, queue: queue),
        _lenders = lenders ?? LenderRepository(_isar, queue: queue);

  final Isar _isar;
  final SyncQueue _queue;
  final CustomerRepository _customers;
  final LenderRepository _lenders; // <-- Added Lender Repo
  static const _uuid = Uuid();

  /// ₹100 crore, matching `ledger_entry_amount_sane` on the server.
  static const maxAmountPaise = 10000000000000;

  /// 0%–10000% in basis points, matching `ledger_entry_rate_sane`.
  static const maxRateBp = 1000000;

  static const maxDescriptionLength = 500;

  Future<Transaction> create({
    required Customer customer,
    required int amountPaise,
    required TransactionType type,
    required DateTime date,
    int interestRateBp = 0,
    String interestType = '',
    String interestFrequency = 'Monthly',
    String description = '',
    String paymentMode = '',
    int chopdiId = 0,
    String loanType = 'gave'
  }) async {
    _validateCustomer(customer);
    _validateAmount(amountPaise);
    _validateRate(interestRateBp);
    _validateDate(date);
    final cleanDescription = _validateDescription(description);

    final now = DateTime.now().toUtc();

    final tx = Transaction()
      ..uuid = _uuid.v7()
      ..customerId = customer.id
      ..customerUuid = customer.uuid
      ..chopdiId = customer.chopdiId
      ..amountPaise = amountPaise
      ..interestRateBp = interestRateBp
      ..date = date
      ..type = type
      ..interestType = interestType
      ..interestFrequency = interestFrequency
      ..description = cleanDescription
      ..paymentMode = paymentMode.trim()
      ..version = 0
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.transactions.put(tx);
      await _touchCustomerInTxn(customer.id, now);
      await _queue.enqueueCreate(
        _isar,
        entity: 'ledger_entry',
        entityId: tx.uuid,
        payload: _payloadFor(tx),
      );
    });

    return tx;
  }

  /// Adopts a draft row built by a caller, validating and enqueuing it.
  Future<Transaction> adoptDraft(Transaction draft) async {
    final bool isTookLoan = draft.type == TransactionType.took ||
        draft.type == TransactionType.paid;

    // ============================================================
    // ROUTE TO LENDERS TABLE ("I Took Loan")
    // ============================================================
    if (isTookLoan) {
      Lender? lender = await _isar.lenders.get(draft.customerId);

      if (lender == null) {
        throw const RepositoryException(
          'That lender no longer exists.',
          field: 'lender',
        );
      }

      if (lender.deletedAt != null) {
        throw const RepositoryException(
          'Cannot add an entry to a deleted lender.',
          field: 'lender',
        );
      }

      _validateAmount(draft.amountPaise);
      _validateRate(draft.interestRateBp);
      _validateDate(draft.date);
      draft.description = _validateDescription(draft.description);

      final now = DateTime.now().toUtc();

      draft
        ..uuid = _uuid.v7()
        ..customerId = lender.id
        ..customerUuid = lender.uuid
        ..chopdiId = lender.chopdiId
        ..paymentMode = draft.paymentMode.trim()
        ..version = 0
        ..updatedAt = now
        ..voidedAt = null
        ..voidedReason = null
        ..syncStatus = SyncStatus.pending;

      await _isar.writeTxn(() async {
        await _isar.transactions.put(draft);
        await _touchLenderInTxn(lender.id, now); // Touch Lender

        await _queue.enqueueCreate(
          _isar,
          entity: 'ledger_entry',
          entityId: draft.uuid,
          payload: _payloadFor(draft),
        );
      });

      return draft;
    }
    // ============================================================
    // ROUTE TO CUSTOMERS TABLE ("I Gave Loan")
    // ============================================================
    else {
      Customer? customer = await _isar.customers.get(draft.customerId);

      if (customer == null) {
        throw const RepositoryException(
          'That customer no longer exists.',
          field: 'customer',
        );
      }

      customer = await _customers.ensureMigrated(customer);

      if (customer.deletedAt != null) {
        throw const RepositoryException(
          'Cannot add an entry to a deleted customer.',
          field: 'customer',
        );
      }

      _validateAmount(draft.amountPaise);
      _validateRate(draft.interestRateBp);
      _validateDate(draft.date);
      draft.description = _validateDescription(draft.description);

      final now = DateTime.now().toUtc();

      draft
        ..uuid = _uuid.v7()
        ..customerId = customer.id
        ..customerUuid = customer.uuid
        ..chopdiId = customer.chopdiId
        ..paymentMode = draft.paymentMode.trim()
        ..version = 0
        ..updatedAt = now
        ..voidedAt = null
        ..voidedReason = null
        ..syncStatus = SyncStatus.pending;

      await _isar.writeTxn(() async {
        await _isar.transactions.put(draft);
        await _touchCustomerInTxn(customer!.id, now); // Touch Customer

        await _queue.enqueueCreate(
          _isar,
          entity: 'ledger_entry',
          entityId: draft.uuid,
          payload: _payloadFor(draft),
        );
      });

      return draft;
    }
  }

  Future<Transaction> update(
      Transaction tx, {
        int? amountPaise,
        int? interestRateBp,
        DateTime? date,
        String? description,
        String? paymentMode,
      }) async {
    if (tx.uuid.isEmpty) {
      throw const RepositoryException(
        'This entry has not been migrated yet and cannot be edited.',
        field: 'uuid',
      );
    }
    if (tx.voidedAt != null) {
      throw const RepositoryException('This entry has been deleted.');
    }

    if (amountPaise != null) {
      _validateAmount(amountPaise);
      tx.amountPaise = amountPaise;
    }
    if (interestRateBp != null) {
      _validateRate(interestRateBp);
      tx.interestRateBp = interestRateBp;
    }
    if (date != null) {
      _validateDate(date);
      tx.date = date;
    }
    if (description != null) tx.description = _validateDescription(description);
    if (paymentMode != null) tx.paymentMode = paymentMode.trim();

    final now = DateTime.now().toUtc();

    tx
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.transactions.put(tx);

      // Route the timestamp update to the correct parent table
      final bool isTookLoan = tx.type == TransactionType.took ||
          tx.type == TransactionType.paid;
      if (isTookLoan) {
        await _touchLenderInTxn(tx.customerId, now);
      } else {
        await _touchCustomerInTxn(tx.customerId, now);
      }

      await _queue.enqueueUpdate(
        _isar,
        entity: 'ledger_entry',
        entityId: tx.uuid,
        expectedVersion: tx.version,
        payload: _payloadFor(tx),
      );
    });

    return tx;
  }

  /// Voids an entry. Never deletes it.
  Future<void> voidEntry(Transaction tx, {required String reason}) async {
    if (tx.uuid.isEmpty) {
      throw const RepositoryException(
        'This entry has not been migrated yet and cannot be deleted.',
        field: 'uuid',
      );
    }
    if (reason.trim().isEmpty) {
      throw const RepositoryException(
        'A reason is required to delete an entry.',
        field: 'reason',
      );
    }
    if (tx.voidedAt != null) return;

    final now = DateTime.now().toUtc();

    tx
      ..voidedAt = now
      ..voidedReason = reason.trim()
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.transactions.put(tx);

      // Route the timestamp update to the correct parent table
      final bool isTookLoan = tx.type == TransactionType.took ||
          tx.type == TransactionType.paid;
      if (isTookLoan) {
        await _touchLenderInTxn(tx.customerId, now);
      } else {
        await _touchCustomerInTxn(tx.customerId, now);
      }

      await _queue.enqueueVoid(
        _isar,
        entity: 'ledger_entry',
        entityId: tx.uuid,
        reason: reason.trim(),
        expectedVersion: tx.version,
      );
    });
  }

  /// Live entries for a customer, newest first.
  Future<List<Transaction>> forCustomer(Customer customer) => _isar.transactions
      .filter()
      .customerIdEqualTo(customer.id)
      .voidedAtIsNull()
      .sortByDateDesc()
      .findAll();

  /// Balance in paise: what was given, less what came back.
  Future<int> balancePaise(Customer customer) async {
    final entries = await forCustomer(customer);
    return entries.fold<int>(
      0,
          (sum, tx) => sum + SyncPayload.signedPaise(tx.type, tx.amountPaise),
    );
  }

  /// Updates the customer's activity timestamp.
  Future<void> _touchCustomerInTxn(
      int customerId,
      DateTime now,
      ) async {
    final customer = await _isar.customers.get(customerId);

    if (customer == null || customer.deletedAt != null) {
      return;
    }

    customer.updatedAt = now;
    await _isar.customers.put(customer);
  }

  /// Updates the lender's activity timestamp.
  Future<void> _touchLenderInTxn(
      int lenderId,
      DateTime now,
      ) async {
    final lender = await _isar.lenders.get(lenderId);

    if (lender == null || lender.deletedAt != null) {
      return;
    }

    lender.updatedAt = now;
    await _isar.lenders.put(lender);
  }

  Map<String, dynamic> _payloadFor(Transaction tx) => {
    'customerId': tx.customerUuid,
    'amountPaise': tx.amountPaise,
    'direction': SyncPayload.direction(tx.type),
    'ledgerSide': SyncPayload.ledgerSide(tx.type),
    'interestRateBp': tx.interestRateBp,
    'interestType':
    SyncPayload.interestType(tx.interestType, rateBp: tx.interestRateBp),
    'interestFrequency': SyncPayload.interestFrequency(tx.interestFrequency),
    'entryDate': SyncPayload.entryDate(tx.date),
    'description': tx.description,
    'paymentMode': tx.paymentMode,
  };

  void _validateCustomer(Customer customer) {
    if (customer.uuid.isEmpty) {
      throw const RepositoryException(
        'This customer has not been migrated yet.',
        field: 'customer',
      );
    }
    if (customer.deletedAt != null) {
      throw const RepositoryException(
        'Cannot add an entry to a deleted customer.',
        field: 'customer',
      );
    }
  }

  void _validateAmount(int amountPaise) {
    if (amountPaise <= 0) {
      throw const RepositoryException(
        'Amount must be greater than zero.',
        field: 'amount',
      );
    }
    if (amountPaise > maxAmountPaise) {
      throw const RepositoryException(
        'That amount is too large.',
        field: 'amount',
      );
    }
  }

  void _validateRate(int rateBp) {
    if (rateBp < 0 || rateBp > maxRateBp) {
      throw const RepositoryException(
        'Interest rate is out of range.',
        field: 'interestRate',
      );
    }
  }

  void _validateDate(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now.add(const Duration(days: 1)))) {
      throw const RepositoryException(
        'Entry date cannot be in the future.',
        field: 'date',
      );
    }
    if (date.isBefore(DateTime(now.year - 50))) {
      throw const RepositoryException(
        'Entry date is too far in the past.',
        field: 'date',
      );
    }
  }

  String _validateDescription(String description) {
    final trimmed = description.trim();
    if (trimmed.length > maxDescriptionLength) {
      throw const RepositoryException(
        'Description is too long.',
        field: 'description',
      );
    }
    return trimmed;
  }
}