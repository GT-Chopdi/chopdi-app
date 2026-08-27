import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../data/remote/sync_api.dart';
import '../data/repository/sync_queue.dart';
import '../data/sync/sync_engine.dart';
import '../data/sync/sync_trigger.dart';
import 'auth_service.dart';
import 'isar_service.dart';

/// Decides *when* the outbox drains. [SyncEngine] decides what happens when it
/// does.
///
/// Four triggers, because each covers a case the others miss:
///
///  - **a local write** — the entry should reach the server now, not on the
///    next tick, whenever there is a connection to carry it;
///  - **regained connectivity** — the defining case for an offline-first app;
///  - **app start** — a previous session may have left the queue full;
///  - **a slow timer** — a backed-off operation coming due is the one event
///    nothing else announces.
class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  /// Coalesces a burst of writes into one drain.
  ///
  /// Saving five entries in quick succession should cost one request, not five.
  /// Short enough that a single save still feels immediate.
  static const Duration _debounce = Duration(milliseconds: 800);

  /// Backstop only. The write, connectivity, and startup triggers cover every
  /// case except a backed-off operation falling due, so this can be unhurried —
  /// a tight poll on a phone spends battery to discover an empty queue.
  static const Duration _interval = Duration(seconds: 60);

  SyncEngine? _engine;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  Timer? _timer;
  Timer? _debounceTimer;

  /// Set when a change arrives mid-drain.
  ///
  /// Without it, an entry saved while a drain is in flight is simply missed:
  /// its `requestSync` finds the latch held and returns, and the drain that is
  /// already running selected its batch before the entry existed. It would then
  /// wait for the 60-second timer despite the app being online — which is
  /// exactly the "created directly" case failing.
  bool _resyncQueued = false;

  /// The most recent outcome, for a UI that wants to show sync state.
  final ValueNotifier<SyncResult?> lastResult = ValueNotifier(null);

  /// How many writes are still only on this device.
  final ValueNotifier<int> pendingCount = ValueNotifier(0);

  SyncEngine get _sync => _engine ??= SyncEngine(
        isar: IsarService.isar,
        api: SyncApi(AuthService.instance.client),
      );

  /// Begins watching for opportunities to sync. Safe to call more than once.
  Future<void> start() async {
    SyncTrigger.register(requestSync);

    _connectivity ??= Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) requestSync();
    });

    _timer ??= Timer.periodic(_interval, (_) => unawaited(syncNow()));

    await refreshPendingCount();
    unawaited(syncNow());
  }

  void stop() {
    SyncTrigger.clear();
    _connectivity?.cancel();
    _connectivity = null;
    _timer?.cancel();
    _timer = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Asks for a sync soon. Cheap, non-blocking, safe to call on every write.
  void requestSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () => unawaited(syncNow()));
  }

  /// Drains the outbox once.
  ///
  /// Never throws: callers fire this and forget, and an unhandled rejection in
  /// a detached future is a crash on some configurations.
  Future<SyncResult> syncNow() async {
    // A drain is already in flight. Remember that something wants another one,
    // rather than dropping the request — see [_resyncQueued].
    if (_sync.isRunning) {
      _resyncQueued = true;
      return const SyncResult(stoppedBecause: 'already running');
    }

    if (!await AuthService.instance.isLoggedIn()) {
      final result = SyncResult(
        remaining: await const SyncQueue().pendingCount(IsarService.isar),
        stoppedBecause: 'not signed in',
      );
      lastResult.value = result;
      pendingCount.value = result.remaining;
      return result;
    }

    final result = await _sync.drain();

    lastResult.value = result;
    pendingCount.value = result.remaining;

    // Something was written while that drain was running, or the batch cap cut
    // it short with work still due. Either way there is more to send and no
    // external event is coming to say so.
    final moreToSend = _resyncQueued || (result.isComplete == false &&
        result.stoppedBecause == null &&
        result.remaining > 0);

    _resyncQueued = false;

    if (moreToSend) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounce, () => unawaited(syncNow()));
    }

    return result;
  }

  /// Puts dead-lettered operations back in the queue.
  ///
  /// The engine parks an operation after repeated rejection rather than
  /// discarding it, but parked is still unsent. This is the way back — for a
  /// "retry failed entries" action, or after a server-side fix.
  Future<int> retryFailed() async {
    final revived = await const SyncQueue().revive(IsarService.isar);

    if (revived > 0) {
      await refreshPendingCount();
      unawaited(syncNow());
    }

    return revived;
  }

  Future<int> failedCount() =>
      const SyncQueue().deadLetterCount(IsarService.isar);

  Future<void> refreshPendingCount() async {
    pendingCount.value = await const SyncQueue().pendingCount(IsarService.isar);
  }
}
