// See customer_repository.dart for why this lint is disabled.
// ignore_for_file: prefer_initializing_formals

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../model/customer.dart';
import '../../model/sync_status.dart';
import '../../model/transaction.dart';
import 'repository_exception.dart';
import 'customer_repository.dart';
import 'sync_payload.dart';
import 'sync_queue.dart';

/// The only write path for ledger entries.
///
/// Entries are facts, not state: two devices recording entries offline produce
/// a union rather than a conflict, and balances are derived by folding them.
/// That is why no balance is stored anywhere — there is no shared number for
/// two devices to disagree about.
class LedgerRepository {
  // LedgerRepository(this._isar, {SyncQueue queue = const SyncQueue()})
  //     : _queue = queue;
  LedgerRepository(
    this._isar, {
    SyncQueue queue = const SyncQueue(),
    CustomerRepository? customers,
  }) : _queue = queue,
       _customers = customers ?? CustomerRepository(_isar, queue: queue);

  final Isar _isar;
  final SyncQueue _queue;
  final CustomerRepository _customers;
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
      // Both keys are kept and neither is redundant: `customerId` is the local
      // foreign key that Isar queries use, `customerUuid` is the one that means
      // anything on another device.
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
  ///
  /// The existing screens construct a [Transaction] and hand it over, so this
  /// takes the finished object rather than a parameter list — which keeps those
  /// call sites unchanged while still forcing every write through validation
  /// and the outbox. The owning customer is resolved from [Transaction.customerId]
  /// so callers do not have to thread it through.
  ///
  /// Any sync metadata already on the draft is overwritten: identity and
  /// versioning are the repository's to assign, never a caller's.
  // Future<Transaction> adoptDraft(Transaction draft) async {
  //   final customer = await _isar.customers.get(draft.customerId);

  //   if (customer == null) {
  //     throw const RepositoryException(
  //       'That customer no longer exists.',
  //       field: 'customer',
  //     );
  //   }

  //   _validateCustomer(customer);
  //   _validateAmount(draft.amountPaise);
  //   _validateRate(draft.interestRateBp);
  //   _validateDate(draft.date);
  //   draft.description = _validateDescription(draft.description);

  //   final now = DateTime.now().toUtc();

  //   draft
  //     ..uuid = _uuid.v7()
  //     ..customerUuid = customer.uuid
  //     ..chopdiId = customer.chopdiId
  //     ..paymentMode = draft.paymentMode.trim()
  //     ..version = 0
  //     ..updatedAt = now
  //     ..voidedAt = null
  //     ..voidedReason = null
  //     ..syncStatus = SyncStatus.pending;

  //   await _isar.writeTxn(() async {
  //     await _isar.transactions.put(draft);
  //     await _queue.enqueueCreate(
  //       _isar,
  //       entity: 'ledger_entry',
  //       entityId: draft.uuid,
  //       payload: _payloadFor(draft),
  //     );
  //   });

  //   return draft;
  // }

  Future<Transaction> adoptDraft(Transaction draft) async {
    // Resolve the customer using the local Isar ID.
    Customer? customer = await _isar.customers.get(draft.customerId);

    if (customer == null) {
      throw const RepositoryException(
        'That customer no longer exists.',
        field: 'customer',
      );
    }

    // ------------------------------------------------------------
    // IMPORTANT FIX
    // ------------------------------------------------------------
    //
    // Old customers created before UUID migration can have:
    //
    //     customer.uuid == ''
    //
    // Make sure the customer receives a permanent UUID before creating
    // the ledger entry.
    //
    // This is what fixes:
    //
    // RepositoryException [customer]:
    // This customer has not been migrated yet.
    //
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

    draft.description =
        _validateDescription(draft.description);

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

      await _queue.enqueueCreate(
        _isar,
        entity: 'ledger_entry',
        entityId: draft.uuid,
        payload: _payloadFor(draft),
      );
    });

    return draft;
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

    tx
      ..updatedAt = DateTime.now().toUtc()
      ..syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.transactions.put(tx);
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
  ///
  /// A reason is required because the server requires one — an audit trail that
  /// records a deletion without saying why explains nothing.
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
  ///
  /// Derived, never stored. A stored balance is a number two devices can
  /// disagree about, and reconciling two disagreeing balances is impossible
  /// without re-deriving it from the entries anyway.
  Future<int> balancePaise(Customer customer) async {
    final entries = await forCustomer(customer);

    // Uses the shared direction rule rather than `type == gave`. That shortcut
    // was correct while only two types existed, but silently mis-signed `paid`
    // once borrowing was added: repaying a debt reduces what you owe, so it
    // must add to the net position, not subtract.
    return entries.fold<int>(
      0,
      (sum, tx) => sum + SyncPayload.signedPaise(tx.type, tx.amountPaise),
    );
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

  /// Mirrors `ledger_entry_amount_positive` and `_amount_sane`.
  ///
  /// Strictly positive: direction carries the sign, so a negative amount is not
  /// a rejected value but an unrepresentable one. Without this, a phantom
  /// credit would sync, be refused permanently, and dead-letter.
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

  /// Bounds the business date.
  ///
  /// Tomorrow is allowed to absorb timezone skew; beyond that a future-dated
  /// entry is a typo. The lower bound stops a mis-keyed year creating a loan
  /// that appears to have been accruing interest for decades.
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
