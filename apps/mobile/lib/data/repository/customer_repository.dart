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

/// The only write path for customers.
///
/// Nothing outside this class may call `isar.customers.put`. That rule is what
/// makes offline sync trustworthy: a write that bypasses the repository never
/// reaches the outbox, so it lives on the device and silently never syncs — no
/// error, no indicator, just a row the server has never heard of.
class CustomerRepository {
  CustomerRepository(this._isar, {SyncQueue queue = const SyncQueue()})
      : _queue = queue;

  final Isar _isar;
  final SyncQueue _queue;

  static const _uuid = Uuid();

  /// Longest name the server accepts.
  static const maxNameLength = 120;

  Future<Customer> create({
    required String name,
    required String phone,
    String notes = '',
    String status = 'active',
    bool received = false, 
  }) async {
    final cleanName = _validateName(name);
    final now = DateTime.now().toUtc();

    final customer = Customer()
      // A permanent identity from birth, minted offline. The row may be
      // referenced by a ledger entry long before either reaches the server.
      ..uuid = _uuid.v7()
      ..name = cleanName
      ..phone = phone.trim()
      ..notes = notes.trim()
      ..status = status
      ..received = received
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
      throw const RepositoryException('This customer has been deleted.');
    }

    if (name != null) customer.name = _validateName(name);
    if (phone != null) customer.phone = phone.trim();
    if (notes != null) customer.notes = notes.trim();

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

  /// Soft delete.
  ///
  /// The row stays. A hard delete cannot be communicated to another device —
  /// it simply stops appearing there, indistinguishable from a row that was
  /// never seen — and it would destroy the history the server audits.
  Future<void> softDelete(Customer customer, {String reason = 'deleted'}) async {
    if (customer.uuid.isEmpty) {
      throw const RepositoryException(
        'This customer has not been migrated yet and cannot be deleted.',
        field: 'uuid',
      );
    }
    if (customer.deletedAt != null) return;

    customer
      ..deletedAt = DateTime.now().toUtc()
      ..updatedAt = DateTime.now().toUtc()
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

  /// Deletes a customer together with their ledger entries.
  ///
  /// One transaction, deliberately. Deleting the customer and voiding their
  /// entries separately would leave a window where a crash orphans entries
  /// against a deleted customer — rows the UI no longer shows but that still
  /// sync, and which the server rejects because their parent is gone.
  ///
  /// This reaches into transactions, which is otherwise [LedgerRepository]'s
  /// territory. Atomicity wins: Isar has no nested transactions, so the only
  /// way to make this one unit is to write it in one place.
  ///
  /// Every entry gets its own operation because the server applies them
  /// individually — there is no cascade on the wire.
  Future<void> softDeleteWithEntries(
    Customer customer, {
    String reason = 'Customer deleted',
  }) async {
    if (customer.uuid.isEmpty) {
      throw const RepositoryException(
        'This customer has not been migrated yet and cannot be deleted.',
        field: 'uuid',
      );
    }

    final entries = await _isar.transactions
        .filter()
        .customerIdEqualTo(customer.id)
        .voidedAtIsNull()
        .findAll();

    final now = DateTime.now().toUtc();

    await _isar.writeTxn(() async {
      for (final tx in entries) {
        // Entries created before the migration have no uuid, so the server has
        // never seen them and there is nothing to enqueue. Void locally and
        // move on rather than failing the whole delete.
        tx
          ..voidedAt = now
          ..voidedReason = reason
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending;

        await _isar.transactions.put(tx);

        if (tx.uuid.isNotEmpty) {
          await _queue.enqueueVoid(
            _isar,
            entity: 'ledger_entry',
            entityId: tx.uuid,
            reason: reason,
            expectedVersion: tx.version,
          );
        }
      }

      customer
        ..deletedAt = now
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending;

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

  Future<Customer?> findByUuid(String uuid) =>
      _isar.customers.filter().uuidEqualTo(uuid).findFirst();

  /// Live customers, excluding soft-deleted rows.
  Future<List<Customer>> active() =>
      _isar.customers.filter().deletedAtIsNull().findAll();

  /// Applies a row received from the server. Does **not** enqueue anything —
  /// echoing a pull straight back as a push would loop forever.
  ///
  /// Resolves the local id by uuid first. The uuid index is deliberately not
  /// unique (a unique index on a defaulted column collapses unmigrated rows),
  /// so a blind `put` would insert a duplicate every time a page was re-pulled.
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

      // A local edit that has not yet been pushed must not be silently
      // overwritten by an incoming row. Losing a user's unsent change is
      // indistinguishable, from their side, from the app discarding their work.
      // Flag it instead and let the sync engine or the user decide.
      final hadPendingLocalEdit =
          existing != null && existing.syncStatus == SyncStatus.pending;

      row = existing ?? Customer()
        ..uuid = uuid
        ..version = version
        ..updatedAt = updatedAt
        ..deletedAt = deletedAt;

      if (!hadPendingLocalEdit) {
        row
          ..name = name
          ..phone = phone ?? ''
          ..notes = notes
          ..syncStatus = SyncStatus.synced;
      } else {
        row.syncStatus = SyncStatus.conflicted;
      }

      // Fields the server does not own keep whatever the client had.
      if (existing == null) {
        row
          ..status = 'active'
          ..received = false;
      }

      await _isar.customers.put(row);
    });

    return row;
  }

  String _validateName(String name) {
    final trimmed = name.trim();

    // Mirrors `customer_name_not_blank` on the server.
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
