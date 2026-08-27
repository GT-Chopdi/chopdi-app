/// A one-way notification that local data changed.
///
/// The repositories are the only write path, so they are the only place that
/// can announce a change without something being forgotten — which has already
/// happened twice in this codebase when a responsibility lived at the call
/// sites instead. But a repository must not depend on the network stack: it has
/// to work in tests, and before sign-in, with no client wired up at all.
///
/// This is the seam. [SyncService] registers a listener at startup; if nothing
/// registers, [notify] does nothing at all.
class SyncTrigger {
  const SyncTrigger._();

  static void Function()? _listener;

  static void register(void Function() listener) => _listener = listener;

  static void clear() => _listener = null;

  /// Announces that something was written. Never throws and never blocks: a
  /// failure to *schedule* a sync must not fail the write that caused it, since
  /// the write is already durable and the outbox will be drained regardless.
  static void notify() {
    final listener = _listener;
    if (listener == null) return;

    try {
      listener();
    } catch (_) {
      // Deliberately swallowed. The periodic and connectivity triggers still
      // cover this change; losing the immediate attempt costs latency, not data.
    }
  }
}
