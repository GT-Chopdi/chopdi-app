// ignore_for_file: prefer_initializing_formals

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../model/lender.dart';
import '../../model/sync_status.dart';
import 'repository_exception.dart';
import 'sync_queue.dart';

class LenderRepository {
  LenderRepository(this._isar, {SyncQueue queue = const SyncQueue()})
      : _queue = queue;

  final Isar _isar;
  final SyncQueue _queue;

  static const _uuid = Uuid();
  static const maxNameLength = 120;

  // ============================================================
  // CREATE
  // ============================================================

  Future<Lender> create({
    required String name,
    required String phone,
    required int chopdiId,
    required String loanType, // Usually "took"
    String notes = '',
    String status = 'active',
    bool received = false,
  }) async {
    final cleanName = _validateName(name);
    final cleanPhone = phone.trim();
    final now = DateTime.now().toUtc();

    final lender = Lender()
      ..uuid = _uuid.v7()
      ..name = cleanName
      ..phone = cleanPhone
      ..notes = notes.trim()
      ..status = status
      ..received = received
      ..chopdiId = chopdiId
      ..loanType = loanType
      ..version = 0
      ..updatedAt = now
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.lenders.put(lender);

      // Tell the sync engine this is a 'lender'
      await _queue.enqueueCreate(
        _isar,
        entity: 'lender',
        entityId: lender.uuid,
        payload: {
          'name': lender.name,
          'phone': lender.phone.isEmpty ? null : lender.phone,
          'notes': lender.notes,
        },
      );
    });

    return lender;
  }

  // ============================================================
  // FIND BY UUID / PHONE
  // ============================================================

  Future<Lender?> findByUuid(String uuid) {
    return _isar.lenders.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<Lender?> findActiveByPhoneAndChopdi(
      String phone,
      int chopdiId,
      ) {
    final cleanPhone = phone.trim();

    if (cleanPhone.isEmpty) {
      return Future.value(null);
    }

    return _isar.lenders
        .filter()
        .phoneEqualTo(cleanPhone)
        .and()
        .chopdiIdEqualTo(chopdiId)
        .and()
        .deletedAtIsNull()
        .findFirst();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<Lender> update(
      Lender lender, {
        String? name,
        String? phone,
        String? notes,
      }) async {
    if (lender.uuid.isEmpty) {
      throw const RepositoryException('Not migrated yet.', field: 'uuid');
    }
    if (lender.deletedAt != null) {
      throw const RepositoryException('This lender has been deleted.');
    }

    if (name != null) lender.name = _validateName(name);
    if (phone != null) lender.phone = phone.trim();
    if (notes != null) lender.notes = notes.trim();

    lender
      ..updatedAt = DateTime.now().toUtc()
      ..syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.lenders.put(lender);

      await _queue.enqueueUpdate(
        _isar,
        entity: 'lender',
        entityId: lender.uuid,
        expectedVersion: lender.version,
        payload: {
          'name': lender.name,
          'phone': lender.phone.isEmpty ? null : lender.phone,
          'notes': lender.notes,
        },
      );
    });

    return lender;
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const RepositoryException('Name is required.', field: 'name');
    }
    if (trimmed.length > maxNameLength) {
      throw const RepositoryException('Name is too long.', field: 'name');
    }
    return trimmed;
  }
}