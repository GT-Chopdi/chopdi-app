// `prefer_initializing_formals` would require `this._queue`, which in Dart
// creates a *private* named parameter — unusable from any other file, since
// privacy is library-scoped. Public names with an initializer list keep the
// constructor callable.
// ignore_for_file: prefer_initializing_formals

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../model/customer.dart';
import '../../model/transaction.dart';
import '../../model/sync_status.dart';
import 'repository_exception.dart';
import 'sync_queue.dart';

class CustomerRepository {
  CustomerRepository(this._isar, {SyncQueue queue = const SyncQueue()})
      : _queue = queue;

  final Isar _isar;
  final SyncQueue _queue;

  static const _uuid = Uuid();

  static const maxNameLength = 120;

  // ============================================================
  // CREATE
  // ============================================================

  /// [chopdiId] and [loanType] are required because every list in the app
  /// filters on them: the home screen shows `chopdiId == active && loanType ==
  /// "gave"`, the took-loan screen the same with `"took"`. A row created without
  /// them saves and syncs correctly and is invisible in the UI — a failure that
  /// looks like the write never happened. Requiring them makes that unbuildable
  /// rather than merely discouraged.
  Future<Customer> create({
    required String name,
    required String phone,
    required int chopdiId,
    required String loanType,
    String notes = '',
    String status = 'active',
    bool received = false,
  }) async {
    final cleanName = _validateName(name);
    final now = DateTime.now().toUtc();

    final customer = Customer()
      ..uuid = _uuid.v7()
      ..name = cleanName
      ..phone = phone.trim()
      ..notes = notes.trim()
      ..status = status
      ..received = received
      ..chopdiId = chopdiId
      ..loanType = loanType
      ..version = 0
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.customers.put(customer);

      await _queue.enqueueCreate(
        _isar,
        entity: 'customer',
        entityId: customer.uuid,
        payload: {
          'name': customer.name,
          'phone': customer.phone.isEmpty ? null : customer.phone,
          'notes': customer.notes,
        },
      );
    });

    return customer;
  }

  // ============================================================
  // MIGRATE OLD CUSTOMERS
  // ============================================================

  /// Migrates customers created before UUID-based sync was introduced.
  ///
  /// Old local customers may have:
  ///
  ///     uuid == ''
  ///
  /// They cannot be used by LedgerRepository because ledger entries need a
  /// permanent customerUuid for synchronization.
  ///
  /// This method only assigns a UUID to customers that do not already have one.
  /// Existing UUIDs are never changed.
  ///
  /// IMPORTANT:
  /// This is intended for legacy/local customers that have not previously
  /// received a server UUID.
  Future<int> migrateLegacyCustomers() async {
    final customers = await _isar.customers.where().findAll();

    final legacyCustomers =
        customers.where((customer) => customer.uuid.trim().isEmpty).toList();

    if (legacyCustomers.isEmpty) {
      return 0;
    }

    var migratedCount = 0;

    await _isar.writeTxn(() async {
      for (final customer in legacyCustomers) {
        final uuid = _uuid.v7();

        customer
          ..uuid = uuid
          ..version = customer.version
          ..updatedAt = DateTime.now().toUtc();

        // We deliberately do NOT enqueue a customer create here.
        //
        // These customers may already be represented by old/local data.
        // The UUID is first needed so newly-created ledger entries can refer
        // to this customer safely.
        //
        // Existing old transactions without UUID remain local legacy rows.
        await _isar.customers.put(customer);

        migratedCount++;
      }
    });

    return migratedCount;
  }

  /// Makes sure one particular customer has a UUID.
  ///
  /// This is used immediately before creating a ledger entry, so even if
  /// startup migration did not run, an old customer can still be used.
  Future<Customer> ensureMigrated(Customer customer) async {
    if (customer.uuid.trim().isNotEmpty) {
      return customer;
    }

    final current = await _isar.customers.get(customer.id);

    if (current == null) {
      throw const RepositoryException(
        'That customer no longer exists.',
        field: 'customer',
      );
    }

    if (current.uuid.trim().isNotEmpty) {
      return current;
    }

    current
      ..uuid = _uuid.v7()
      ..updatedAt = DateTime.now().toUtc();

    await _isar.writeTxn(() async {
      await _isar.customers.put(current);
    });

    return current;
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<Customer> update(
    Customer customer, {
    String? name,
    String? phone,
    String? notes,
  }) async {
    if (customer.uuid.isEmpty) {
      throw const RepositoryException(
        'This customer has not been migrated yet and cannot be edited.',
        field: 'uuid',
      );
    }

    if (customer.deletedAt != null) {
      throw const RepositoryException(
        'This customer has been deleted.',
      );
    }

    if (name != null) {
      customer.name = _validateName(name);
    }

    if (phone != null) {
      customer.phone = phone.trim();
    }

    if (notes != null) {
      customer.notes = notes.trim();
    }

    customer
      ..updatedAt = DateTime.now().toUtc()
      ..syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.customers.put(customer);

      await _queue.enqueueUpdate(
        _isar,
        entity: 'customer',
        entityId: customer.uuid,
        expectedVersion: customer.version,
        payload: {
          'name': customer.name,
          'phone': customer.phone.isEmpty ? null : customer.phone,
          'notes': customer.notes,
        },
      );
    });

    return customer;
  }

  // ============================================================
  // SOFT DELETE
  // ============================================================

  Future<void> softDelete(
    Customer customer, {
    String reason = 'deleted',
  }) async {
    if (customer.uuid.isEmpty) {
      throw const RepositoryException(
        'This customer has not been migrated yet and cannot be deleted.',
        field: 'uuid',
      );
    }

    if (customer.deletedAt != null) {
      return;
    }

    final now = DateTime.now().toUtc();

    customer
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.customers.put(customer);

      await _queue.enqueueVoid(
        _isar,
        entity: 'customer',
        entityId: customer.uuid,
        reason: reason,
        expectedVersion: customer.version,
      );
    });
  }

  // ============================================================
  // DELETE CUSTOMER + TRANSACTIONS
  // ============================================================

  Future<void> softDeleteWithEntries(
    Customer customer, {
    String reason = 'Customer deleted',
  }) async {
    // IMPORTANT:
    // If this is a legacy customer, give it a UUID first.
    final migratedCustomer = await ensureMigrated(customer);

    if (migratedCustomer.deletedAt != null) {
      return;
    }

    final entries = await _isar.transactions
        .filter()
        .customerIdEqualTo(migratedCustomer.id)
        .voidedAtIsNull()
        .findAll();

    final now = DateTime.now().toUtc();

    await _isar.writeTxn(() async {
      for (final tx in entries) {
        tx
          ..voidedAt = now
          ..voidedReason = reason
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending;

        await _isar.transactions.put(tx);

        // Old transactions may not have UUIDs.
        //
        // Such transactions stay local and are voided locally.
        // New/migrated transactions are queued for server sync.
        if (tx.uuid.trim().isNotEmpty) {
          await _queue.enqueueVoid(
            _isar,
            entity: 'ledger_entry',
            entityId: tx.uuid,
            reason: reason,
            expectedVersion: tx.version,
          );
        }
      }

      migratedCustomer
        ..deletedAt = now
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending;

      await _isar.customers.put(migratedCustomer);

      await _queue.enqueueVoid(
        _isar,
        entity: 'customer',
        entityId: migratedCustomer.uuid,
        reason: reason,
        expectedVersion: migratedCustomer.version,
      );
    });
  }

  // ============================================================
  // FIND
  // ============================================================

  Future<Customer?> findByUuid(String uuid) =>
      _isar.customers.filter().uuidEqualTo(uuid).findFirst();

  // ============================================================
  // ACTIVE CUSTOMERS
  // ============================================================

  Future<List<Customer>> active() =>
      _isar.customers.filter().deletedAtIsNull().findAll();

  // ============================================================
  // SERVER PULL
  // ============================================================

  Future<Customer> applyFromServer({
    required String uuid,
    required String name,
    required String? phone,
    required String notes,
    required int version,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) async {
    late Customer row;

    await _isar.writeTxn(() async {
      final existing =
          await _isar.customers.filter().uuidEqualTo(uuid).findFirst();

      final hadPendingLocalEdit =
          existing != null &&
          existing.syncStatus == SyncStatus.pending;

      row = existing ??
          (Customer()
            ..uuid = uuid
            ..version = version
            ..updatedAt = updatedAt
            ..deletedAt = deletedAt);

      if (!hadPendingLocalEdit) {
        row
          ..name = name
          ..phone = phone ?? ''
          ..notes = notes
          ..version = version
          ..updatedAt = updatedAt
          ..deletedAt = deletedAt
          ..syncStatus = SyncStatus.synced;
      } else {
        row.syncStatus = SyncStatus.conflicted;
      }

      if (existing == null) {
        row
          ..status = 'active'
          ..received = false;
      }

      await _isar.customers.put(row);
    });

    return row;
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String _validateName(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      throw const RepositoryException(
        'Customer name is required.',
        field: 'name',
      );
    }

    if (trimmed.length > maxNameLength) {
      throw const RepositoryException(
        'Customer name is too long.',
        field: 'name',
      );
    }

    return trimmed;
  }
}