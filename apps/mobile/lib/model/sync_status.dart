/// Where a local row stands relative to the server.
///
/// Stored on every syncable row so the UI can show what is still only on this
/// device — the difference between "saved" and "safe" is the whole reason an
/// offline-first app needs a pending indicator.
enum SyncStatus {
  /// Written locally, not yet acknowledged by the server. The row exists in
  /// exactly one place: this phone.
  pending,

  /// The server has it. Safe against losing the device.
  synced,

  /// The server rejected an update because someone else changed the row first.
  /// Both versions are kept and the user chooses — financial fields are never
  /// merged automatically.
  conflicted,

  /// Permanently rejected. Kept locally and surfaced to the user rather than
  /// discarded, because silently dropping a ledger entry is the worst outcome
  /// available.
  deadLettered,
}
