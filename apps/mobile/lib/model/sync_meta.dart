import 'package:isar_community/isar.dart';

part 'sync_meta.g.dart';

/// Singleton row holding sync bookkeeping.
@collection
class SyncMeta {
  /// Fixed id: there is only ever one of these.
  Id id = 0;

  /// Local schema version, advanced by the one-time data migration.
  ///
  /// Checked at startup so the migration runs exactly once. Without it a
  /// re-run would mint fresh UUIDs for rows that already have them, orphaning
  /// every outbox entry that referenced the old ones.
  int schemaVersion = 0;

  /// How far this device has pulled. Advanced only *after* a page has been
  /// committed — advancing first loses that page permanently.
  int cursor = 0;

  DateTime? lastPulledAt;
  DateTime? lastPushedAt;

  /// True when local data was wiped but credentials survived — a reinstall or
  /// a corrupted database.
  ///
  /// In this state the device must pull only and never push: the outbox is gone
  /// along with its idempotency keys, so re-sending whatever rows remain would
  /// duplicate server-side rows whose keys no longer exist locally.
  bool recoveryMode = false;
}
