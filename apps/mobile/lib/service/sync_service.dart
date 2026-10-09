import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar_community/isar.dart';

import '../data/remote/sync_api.dart';
import '../data/repository/sync_queue.dart';
import '../data/sync/sync_engine.dart';
import '../data/sync/sync_trigger.dart';

import 'auth_service.dart';
import 'isar_service.dart';

import '../model/customer.dart';
import '../model/lender.dart';
import '../model/transaction.dart';

/// Handles:
/// - Pulling remote changes
/// - Applying remote changes to Isar
/// - Draining local outbox
/// - Connectivity based sync
/// - Periodic sync
class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  static const String _cursorKey = 'sync_cursor_latest';

  static const Duration _debounce =
  Duration(milliseconds: 800);

  static const Duration _interval =
  Duration(seconds: 60);

  SyncEngine? _engine;

  StreamSubscription<List<ConnectivityResult>>?
  _connectivity;

  Timer? _timer;

  Timer? _debounceTimer;

  /// Prevents two complete sync operations from running
  /// at the same time.
  bool _syncRunning = false;

  /// If sync is requested while another sync is running,
  /// run one more sync after the current one finishes.
  bool _resyncQueued = false;

  final ValueNotifier<SyncResult?> lastResult =
  ValueNotifier(null);

  final ValueNotifier<int> pendingCount =
  ValueNotifier(0);

  // ===========================================================================
  // LOGGING
  // ===========================================================================

  void _log(String message) {
    developer.log(
      message,
      name: 'SyncService',
    );
  }

  void _logSeparator() {
    _log('========================================');
  }

  /// Prints JSON request/response data only in debug builds.
  /// Never log access tokens or authorization headers.
  void _logJson(String title, dynamic data) {
    if (!kDebugMode) return;

    try {
      _log('$title\\n${const JsonEncoder.withIndent('  ').convert(data)}');
    } catch (error, stackTrace) {
      developer.log(
        '$title (JSON encoding failed)',
        name: 'SyncService',
        error: error,
        stackTrace: stackTrace,
      );
      _log('$title: $data');
    }
  }

  // ===========================================================================
  // SYNC ENGINE
  // ===========================================================================

  SyncEngine get _sync =>
      _engine ??= SyncEngine(
        isar: IsarService.isar,
        api: SyncApi(AuthService.instance.client),
      );

  // ===========================================================================
  // START
  // ===========================================================================

  Future<void> start() async {
    _logSeparator();
    _log('SYNC SERVICE STARTED');
    _logSeparator();

    SyncTrigger.register(requestSync);

    // -------------------------------------------------------------------------
    // Connectivity listener
    // -------------------------------------------------------------------------

    _connectivity ??=
        Connectivity().onConnectivityChanged.listen(
              (results) {
            final online = results.any(
                  (r) => r != ConnectivityResult.none,
            );

            _log('Connectivity changed');
            _log('Online: $online');

            if (online) {
              _log(
                'Network available -> requesting sync',
              );

              requestSync();
            }
          },
        );

    // -------------------------------------------------------------------------
    // Periodic sync
    // -------------------------------------------------------------------------

    _timer ??= Timer.periodic(
      _interval,
          (_) {
        _log('Periodic sync triggered');
        unawaited(syncNow());
      },
    );

    // -------------------------------------------------------------------------
    // Pending count
    // -------------------------------------------------------------------------

    await refreshPendingCount();

    _log(
      'Initial pending count: ${pendingCount.value}',
    );

    // -------------------------------------------------------------------------
    // Initial sync
    // -------------------------------------------------------------------------

    _log('Starting initial sync');

    unawaited(syncNow());
  }

  // ===========================================================================
  // STOP
  // ===========================================================================

  void stop() {
    _logSeparator();
    _log('SYNC SERVICE STOPPED');
    _logSeparator();

    SyncTrigger.clear();

    _connectivity?.cancel();
    _connectivity = null;

    _timer?.cancel();
    _timer = null;

    _debounceTimer?.cancel();
    _debounceTimer = null;

    _syncRunning = false;
    _resyncQueued = false;
  }

  // ===========================================================================
  // REQUEST SYNC
  // ===========================================================================

  void requestSync() {
    _log('Sync requested');

    _debounceTimer?.cancel();

    _debounceTimer = Timer(
      _debounce,
          () {
        _log('Debounced sync started');

        unawaited(syncNow());
      },
    );
  }

  // ===========================================================================
  // MAIN SYNC
  // ===========================================================================

  Future<SyncResult> syncNow() async {
    _logSeparator();
    _log('SYNC NOW STARTED');
    _logSeparator();

    // -------------------------------------------------------------------------
    // Prevent duplicate complete sync operations.
    // -------------------------------------------------------------------------

    if (_syncRunning) {
      _log('Sync already running');
      _log('Queuing another sync request');

      _resyncQueued = true;

      return const SyncResult(
        stoppedBecause: 'already running',
      );
    }

    _syncRunning = true;

    try {
      // -----------------------------------------------------------------------
      // Authentication
      // -----------------------------------------------------------------------

      final loggedIn =
      await AuthService.instance.isLoggedIn();

      _log(
        'Authentication status: $loggedIn',
      );

      if (!loggedIn) {
        _log('User is NOT logged in');
        _log('Sync stopped');

        final result = SyncResult(
          remaining:
          await const SyncQueue().pendingCount(
            IsarService.isar,
          ),
          stoppedBecause: 'not signed in',
        );

        lastResult.value = result;
        pendingCount.value = result.remaining;

        return result;
      }

      // -----------------------------------------------------------------------
      // PHASE 1 - PULL
      // -----------------------------------------------------------------------

      _logSeparator();
      _log('PHASE 1: PULL REMOTE DATA');
      _logSeparator();

      bool pullSuccessful = false;

      try {
        await pullData();

        pullSuccessful = true;

        _log(
          'Remote pull completed successfully',
        );
      } catch (e, stackTrace) {
        _log('Pull phase FAILED');
        _log('Error: $e');

        developer.log(
          'Pull Error',
          name: 'SyncService',
          error: e,
          stackTrace: stackTrace,
        );
      }

      // -----------------------------------------------------------------------
      // PHASE 2 - PUSH
      // -----------------------------------------------------------------------

      _logSeparator();
      _log('PHASE 2: DRAIN LOCAL OUTBOX');
      _logSeparator();

      final result = await _sync.drain();

      _log('Outbox drain completed');
      _log('Remaining: ${result.remaining}');
      _log('Complete: ${result.isComplete}');
      _log(
        'Stopped because: ${result.stoppedBecause}',
      );

      lastResult.value = result;
      pendingCount.value = result.remaining;

      // -----------------------------------------------------------------------
      // Decide if another sync is required.
      // -----------------------------------------------------------------------

      final moreToSend =
          _resyncQueued ||
              (
                  result.isComplete == false &&
                      result.stoppedBecause == null &&
                      result.remaining > 0
              );

      _log(
        'Pull successful: $pullSuccessful',
      );

      _log(
        'More sync required: $moreToSend',
      );

      _resyncQueued = false;

      if (moreToSend) {
        _log('Scheduling another sync');

        _debounceTimer?.cancel();

        _debounceTimer = Timer(
          _debounce,
              () {
            _log('Retry sync triggered');

            unawaited(syncNow());
          },
        );
      }

      _logSeparator();
      _log('SYNC NOW COMPLETED');
      _logSeparator();

      return result;
    } finally {
      _syncRunning = false;

      // -----------------------------------------------------------------------
      // If a request arrived while the sync was running,
      // schedule another complete sync.
      // -----------------------------------------------------------------------

      if (_resyncQueued) {
        _log(
          'Queued sync request detected after completion',
        );

        _resyncQueued = false;

        _debounceTimer?.cancel();

        _debounceTimer = Timer(
          _debounce,
              () {
            _log('Running queued sync');

            unawaited(syncNow());
          },
        );
      }
    }
  }

  // ===========================================================================
  // PULL SYNC
  // ===========================================================================

  Future<void> pullData() async {
    _logSeparator();
    _log('SYNC PULL STARTED');
    _logSeparator();

    // -------------------------------------------------------------------------
    // Device
    // -------------------------------------------------------------------------

    final deviceId =
    await AuthService.instance.tokens.deviceId;

    _log(
      'Device ID: ${deviceId ?? "NULL"}',
    );

    if (deviceId == null || deviceId.isEmpty) {
      _log('ERROR: No Device ID found');
      _log('Cannot perform pull sync');

      return;
    }

    _log('Device ID available');
    _log('Pull sync authorized for device');

    // -------------------------------------------------------------------------
    // Access token
    // -------------------------------------------------------------------------

    final accessToken =
    await AuthService.instance.tokens.accessToken;

    _log(
      'Access token exists: '
          '${accessToken != null && accessToken.isNotEmpty}',
    );

    bool hasMore = true;

    int page = 0;

    int totalChanges = 0;

    // -------------------------------------------------------------------------
    // Pull pages
    // -------------------------------------------------------------------------

    while (hasMore) {
      page++;

      _logSeparator();
      _log('PULL PAGE $page');
      _logSeparator();

      final currentCursor =
      await _getLocalCursor();

      _log(
        'Current cursor: '
            '${currentCursor ?? "INITIAL"}',
      );

      final endpoint =
      currentCursor != null
          ? '/v1/sync/pull?cursor=$currentCursor'
          : '/v1/sync/pull';

      _log(
        'Pull endpoint: $endpoint',
      );

      // -----------------------------------------------------------------------
      // API CALL
      // -----------------------------------------------------------------------

      _log('Calling sync pull API...');

      final stopwatch = Stopwatch()..start();

      dynamic data;

      try {
        _log('========== CLOUD PULL REQUEST ==========');
        _log('HTTP method: GET');
        _log('Endpoint: $endpoint');
        _log('Cursor sent: ${currentCursor ?? "INITIAL"}');
        _log('Request time UTC: ${DateTime.now().toUtc().toIso8601String()}');

        data = await AuthService.instance.client.get(endpoint);

        stopwatch.stop();

        _log(
          'Sync pull API response received '
              'in ${stopwatch.elapsedMilliseconds} ms',
        );
        _log('========== CLOUD PULL RESPONSE ==========');
        _logJson('FULL DATA RECEIVED FROM CLOUD', data);
      } catch (error, stackTrace) {
        stopwatch.stop();

        developer.log(
          'CLOUD PULL REQUEST FAILED after '
              '${stopwatch.elapsedMilliseconds} ms',
          name: 'SyncService',
          error: error,
          stackTrace: stackTrace,
        );

        rethrow;
      }

      // -----------------------------------------------------------------------
      // RESPONSE
      // -----------------------------------------------------------------------

      final changes =
          data['changes'] as List<dynamic>? ?? [];

      _log('Cloud changes received: ${changes.length}');
      for (var i = 0; i < changes.length; i++) {
        _logJson('CLOUD CHANGE ${i + 1}/${changes.length}', changes[i]);
      }

      final nextCursor =
      data['nextCursor'] as String?;

      hasMore =
          data['hasMore'] as bool? ?? false;

      totalChanges += changes.length;

      _log('Response parsed successfully');

      _log(
        'Changes received: ${changes.length}',
      );

      _log(
        'Next cursor: ${nextCursor ?? "NULL"}',
      );

      _log(
        'Has more: $hasMore',
      );

      _log(
        'Total changes received so far: '
            '$totalChanges',
      );

      // -----------------------------------------------------------------------
      // APPLY CHANGES
      // -----------------------------------------------------------------------

      if (changes.isNotEmpty) {
        _log(
          'Applying ${changes.length} changes to Isar...',
        );

        await _applyChangesToIsar(
          changes,
        );

        _log(
          'Successfully applied '
              '${changes.length} changes',
        );
      } else {
        _log('No changes received');
      }

      // -----------------------------------------------------------------------
      // SAVE CURSOR
      //
      // IMPORTANT:
      // Cursor is saved only after Isar successfully applies
      // all changes.
      // -----------------------------------------------------------------------

      if (nextCursor != null) {
        _log(
          'Saving cursor: $nextCursor',
        );

        await _saveLocalCursor(
          nextCursor,
        );

        _log(
          'Cursor saved successfully',
        );
      } else {
        _log('No next cursor returned');
      }
    }

    _logSeparator();
    _log(
      'SYNC PULL COMPLETED SUCCESSFULLY',
    );
    _log('Pages: $page');
    _log(
      'Total changes applied: $totalChanges',
    );
    _logSeparator();
  }

  // ===========================================================================
  // APPLY CHANGES
  // ===========================================================================

  Future<void> _applyChangesToIsar(
      List<dynamic> changes,
      ) async {
    final isar = IsarService.isar;

    _log('Starting Isar transaction');

    await isar.writeTxn(() async {
      for (
      var i = 0;
      i < changes.length;
      i++
      ) {
        final change = changes[i];

        final String entity =
            change['entity']?.toString() ?? '';

        final String opType =
            change['opType']?.toString() ?? '';

        final String entityId =
            change['entityId']?.toString() ?? '';

        final Map<String, dynamic> data =
        Map<String, dynamic>.from(
          change['data']
          as Map<dynamic, dynamic>? ??
              {},
        );

        _logSeparator();

        _log(
          'CHANGE ${i + 1}/${changes.length}',
        );

        _log('Entity: $entity');
        _log('Operation: $opType');
        _log('Entity ID: $entityId');

        // ---------------------------------------------------------------------
        // TEMPORARY FULL PAYLOAD LOG
        // ---------------------------------------------------------------------

        _log(
          'FULL SYNC DATA: $data',
        );

        // ---------------------------------------------------------------------
        // CUSTOMER
        // ---------------------------------------------------------------------

        if (entity == 'customer') {
          _log(
            'Processing customer',
          );

          await _processCustomerChange(
            isar,
            opType,
            entityId,
            data,
          );
        }

        // ---------------------------------------------------------------------
        // LENDER
        // ---------------------------------------------------------------------

        else if (entity == 'lender') {
          _log(
            'Processing lender',
          );

          await _processLenderChange(
            isar,
            opType,
            entityId,
            data,
          );
        }

        // ---------------------------------------------------------------------
        // LEDGER ENTRY
        // ---------------------------------------------------------------------

        else if (entity == 'ledger_entry') {
          _log(
            'Processing ledger entry',
          );

          await _processLedgerEntryChange(
            isar,
            opType,
            entityId,
            data,
          );
        }

        // ---------------------------------------------------------------------
        // UNKNOWN
        // ---------------------------------------------------------------------

        else {
          _log(
            'WARNING: Unknown entity type: $entity',
          );
        }
      }
    });

    _log(
      'Isar transaction completed',
    );
  }

  // ===========================================================================
  // CUSTOMER
  // ===========================================================================

  Future<void> _processCustomerChange(
      Isar isar,
      String opType,
      String entityId,
      Map<String, dynamic> data,
      ) async {
    final existingCustomer =
    await isar.customers
        .filter()
        .uuidEqualTo(entityId)
        .findFirst();

    final name =
        data['name']?.toString() ?? '';

    final phone =
        data['phone']?.toString() ?? '';

    final notes =
        data['notes']?.toString() ?? '';

    final status =
        data['status']?.toString() ??
            'Pending';

    final loanType =
        data['loanType']?.toString() ??
            'gave';

    final received =
    data['received'] is bool
        ? data['received'] as bool
        : false;

    final version =
        int.tryParse(
          data['version']?.toString() ?? '',
        ) ??
            1;

    final chopdiId =
        int.tryParse(
          data['chopdiId']?.toString() ?? '',
        ) ??
            1;

    final updatedAt =
        _parseDate(
          data['updatedAt'],
        ) ??
            DateTime.now();

    final deletedAt =
    _parseDate(
      data['deletedAt'],
    );

    _log(
      'Customer name: $name',
    );

    _log(
      'Customer phone: $phone',
    );

    _log(
      'Customer status: $status',
    );

    _log(
      'Customer loanType: $loanType',
    );

    _log(
      'Customer received: $received',
    );

    _log(
      'Customer chopdiId: $chopdiId',
    );

    if (opType == 'create' ||
        opType == 'update') {
      final customer =
          existingCustomer ??
              (Customer()
                ..uuid = entityId);

      customer
        ..name = name
        ..phone = phone
        ..notes = notes
        ..status = status
        ..loanType = loanType
        ..received = received
        ..chopdiId = chopdiId
        ..version = version
        ..updatedAt = updatedAt
        ..deletedAt = deletedAt;

      await isar.customers.put(
        customer,
      );

      _log(
        'Customer saved to Isar',
      );

      _log(
        'Local customer ID: ${customer.id}',
      );
    } else if (opType == 'void') {
      if (existingCustomer != null) {
        existingCustomer
          ..deletedAt =
              deletedAt ?? DateTime.now()
          ..updatedAt = updatedAt;

        await isar.customers.put(
          existingCustomer,
        );

        _log(
          'Customer marked as deleted',
        );
      } else {
        _log(
          'Customer to void not found locally',
        );
      }
    }
  }

  // ===========================================================================
  // LENDER
  // ===========================================================================

  Future<void> _processLenderChange(
      Isar isar,
      String opType,
      String entityId,
      Map<String, dynamic> data,
      ) async {
    final existingLender = await isar.lenders
        .filter()
        .uuidEqualTo(entityId)
        .findFirst();

    final name = data['name']?.toString() ?? '';
    final phone = data['phone']?.toString() ?? '';
    final notes = data['notes']?.toString() ?? '';
    final status = data['status']?.toString() ?? 'Pending';

    final received = data['received'] is bool
        ? data['received'] as bool
        : false;

    final version =
        int.tryParse(data['version']?.toString() ?? '') ?? 1;

    // --- ADD THESE TWO LINES ---
    final chopdiId =
        int.tryParse(data['chopdiId']?.toString() ?? '') ?? 1;
    final loanType =
        data['loanType']?.toString() ?? 'took';

    final updatedAt =
        _parseDate(data['updatedAt']) ?? DateTime.now();

    final deletedAt =
    _parseDate(data['deletedAt']);

    _log('Lender name: $name');
    _log('Lender phone: $phone');
    _log('Lender status: $status');
    _log('Lender received: $received');
    _log('Lender chopdiId: $chopdiId'); // Debug log

    if (opType == 'create' || opType == 'update') {
      final lender = existingLender ??
          (Lender()
            ..uuid = entityId);

      lender
        ..name = name
        ..phone = phone
        ..status = status
        ..received = received
        ..notes = notes
        ..chopdiId = chopdiId // <-- Required for the UI to display it
        ..loanType = loanType // <-- Keeps the model accurate
        ..version = version
        ..updatedAt = updatedAt
        ..deletedAt = deletedAt;

      await isar.lenders.put(lender);

      _log('Lender saved to Isar');
      _log('Local lender ID: ${lender.id}');
    } else if (opType == 'void') {
      if (existingLender != null) {
        existingLender
          ..deletedAt = deletedAt ?? DateTime.now()
          ..updatedAt = updatedAt;

        await isar.lenders.put(existingLender);

        _log('Lender marked as deleted');
      } else {
        _log('Lender to void not found locally');
      }
    }
  }

  // ===========================================================================
  // LEDGER ENTRY
  // ===========================================================================

  Future<void> _processLedgerEntryChange(
      Isar isar,
      String opType,
      String entityId,
      Map<String, dynamic> data,
      ) async {
    _log('Ledger entry sync started');
    _log('Operation: $opType');
    _log('UUID: $entityId');

    final existingTx =
    await isar.transactions
        .filter()
        .uuidEqualTo(entityId)
        .findFirst();

    final transaction =
        existingTx ??
            (Transaction()
              ..uuid = entityId);

    _log(
      'Existing transaction: '
          '${existingTx != null}',
    );

    final ledgerSide =
        data['ledgerSide']?.toString() ?? '';

    final direction =
        data['direction']?.toString() ?? '';

    final amountPaise =
        int.tryParse(
          data['amountPaise']
              ?.toString() ??
              '0',
        ) ??
            0;

    _log(
      'Ledger side: $ledgerSide',
    );

    _log(
      'Direction: $direction',
    );

    _log(
      'Amount paise: $amountPaise',
    );

    final TransactionType txType =
    direction == 'gave'
        ? TransactionType.gave
        : TransactionType.took;

    // =========================================================================
    // CREATE / UPDATE
    // =========================================================================

    if (opType == 'create' ||
        opType == 'update') {
      _log(
        existingTx != null
            ? 'Updating transaction'
            : 'Creating transaction',
      );

      transaction
        ..type = txType
        ..amountPaise = amountPaise
        ..date =
            _parseDate(
              data['entryDate'],
            ) ??
                DateTime.now()
        ..description =
            data['description']?.toString() ?? ''
        ..updatedAt =
            _parseDate(
              data['updatedAt'],
            ) ??
                DateTime.now()
        ..voidedAt =
        _parseDate(
          data['voidedAt'],
        )
        ..voidedReason =
        data['voidedReason']?.toString()
        ..version =
            int.tryParse(
              data['version']?.toString() ?? '',
            ) ??
                1;

      // -----------------------------------------------------------------------
      // Backend relation ID
      // -----------------------------------------------------------------------

      final dynamic rawCustomerId =
      data['customerId'];

      final dynamic rawLenderId =
      data['lenderId'];

      final String? backendCustomerId =
      rawCustomerId?.toString().trim().isNotEmpty ==
          true
          ? rawCustomerId.toString()
          : null;

      final String? backendLenderId =
      rawLenderId?.toString().trim().isNotEmpty ==
          true
          ? rawLenderId.toString()
          : null;

      _log(
        'Backend customer ID: '
            '${backendCustomerId ?? "NULL"}',
      );

      _log(
        'Backend lender ID: '
            '${backendLenderId ?? "NULL"}',
      );

      // =========================================================================
      // LENT
      // =========================================================================

      if (ledgerSide == 'lent') {
        _log(
          'Finding related customer',
        );

        if (backendCustomerId == null) {
          _log(
            'WARNING: Lent ledger entry has no customerId',
          );
        } else {
          final relCustomer =
          await isar.customers
              .filter()
              .uuidEqualTo(
            backendCustomerId,
          )
              .findFirst();

          if (relCustomer != null) {
            transaction.customerId =
                relCustomer.id;

            _log(
              'Transaction linked to customer '
                  'local ID: ${relCustomer.id}',
            );
          } else {
            _log(
              'WARNING: Related customer not found: '
                  '$backendCustomerId',
            );
          }
        }
      }

      // =========================================================================
      // BORROWED
      // =========================================================================

      else if (ledgerSide == 'borrowed') {
        _log(
          'Finding related lender',
        );

        final relationId =
            backendLenderId ??
                backendCustomerId;

        if (relationId == null) {
          _log(
            'WARNING: Borrowed ledger entry has '
                'no lenderId/customerId',
          );
        } else {
          final relLender =
          await isar.lenders
              .filter()
              .uuidEqualTo(
            relationId,
          )
              .findFirst();

          if (relLender != null) {
            transaction.customerId =
                relLender.id;

            _log(
              'Transaction linked to lender '
                  'local ID: ${relLender.id}',
            );
          } else {
            _log(
              'WARNING: Related lender not found: '
                  '$relationId',
            );
          }
        }
      }

      // =========================================================================
      // SAVE TRANSACTION
      // =========================================================================

      await isar.transactions.put(
        transaction,
      );

      _log(
        'Transaction saved to Isar',
      );
    }

    // =========================================================================
    // VOID
    // =========================================================================

    else if (opType == 'void') {
      _log(
        'Voiding transaction',
      );

      transaction
        ..voidedAt =
            _parseDate(
              data['voidedAt'],
            ) ??
                DateTime.now()
        ..voidedReason =
            data['voidedReason']?.toString() ??
                'Voided by remote sync'
        ..updatedAt =
            _parseDate(
              data['updatedAt'],
            ) ??
                DateTime.now();

      await isar.transactions.put(
        transaction,
      );

      _log(
        'Transaction marked as voided',
      );
    }
  }

  // ===========================================================================
  // DATE HELPER
  // ===========================================================================

  DateTime? _parseDate(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final stringValue =
    value.toString().trim();

    if (stringValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(
      stringValue,
    );
  }

  // ===========================================================================
  // CURSOR
  // ===========================================================================

  Future<String?> _getLocalCursor() async {
    final prefs =
    await SharedPreferences.getInstance();

    final cursor =
    prefs.getString(
      _cursorKey,
    );

    _log(
      'Local sync cursor: '
          '${cursor ?? "NONE"}',
    );

    return cursor;
  }

  Future<void> _saveLocalCursor(
      String cursor,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      _cursorKey,
      cursor,
    );

    _log(
      'Local sync cursor saved: $cursor',
    );
  }

  Future<void> clearLocalCursor() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      _cursorKey,
    );

    _log(
      'Local sync cursor CLEARED',
    );
  }

  // ===========================================================================
  // OUTBOX
  // ===========================================================================

  Future<int> retryFailed() async {
    _log(
      'Retry failed sync started',
    );

    final revived =
    await const SyncQueue()
        .revive(
      IsarService.isar,
    );

    _log(
      'Revived records: $revived',
    );

    if (revived > 0) {
      await refreshPendingCount();

      _log(
        'Starting sync after retry',
      );

      unawaited(syncNow());
    }

    return revived;
  }

  Future<int> failedCount() async {
    final count =
    await const SyncQueue()
        .deadLetterCount(
      IsarService.isar,
    );

    _log(
      'Failed sync count: $count',
    );

    return count;
  }

  Future<void> refreshPendingCount() async {
    final count =
    await const SyncQueue()
        .pendingCount(
      IsarService.isar,
    );

    pendingCount.value = count;

    _log(
      'Pending sync count: $count',
    );
  }
}