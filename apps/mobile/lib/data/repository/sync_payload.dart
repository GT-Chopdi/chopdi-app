import '../../model/transaction.dart';

/// Translates client vocabulary into the wire contract the API expects.
///
/// The two sides genuinely differ: the UI stores `"Simple Interest"` and
/// `"Monthly"` because that is what it renders, while the server stores
/// `'simple'` and `'monthly'` because those are CHECK-constrained enums. A
/// mismatch here is a *permanent* server rejection, so the entry dead-letters
/// and the user is told their data failed — which is why the mapping lives in
/// one place with tests rather than being inlined at each call site.
class SyncPayload {
  const SyncPayload._();

  /// `gave` | `received`
  static String direction(TransactionType type) =>
      type == TransactionType.gave ? 'gave' : 'received';

  static TransactionType directionToType(String direction) =>
      direction == 'gave' ? TransactionType.gave : TransactionType.received;

  /// `none` | `simple` | `compound`
  ///
  /// Anything unrecognised maps to `none` rather than guessing. Guessing
  /// `simple` would silently start charging interest the user never agreed to.
  static String interestType(String clientValue, {required int rateBp}) {
    if (rateBp == 0) return 'none';

    final v = clientValue.trim().toLowerCase();
    if (v.startsWith('simple')) return 'simple';
    if (v.startsWith('compound')) return 'compound';
    return 'none';
  }

  /// `daily` | `weekly` | `monthly` | `yearly`
  ///
  /// Defaults to monthly, matching the client calculator's own fallback — the
  /// two must agree or the same loan accrues differently on each side.
  static String interestFrequency(String clientValue) {
    switch (clientValue.trim().toLowerCase()) {
      case 'daily':
        return 'daily';
      case 'weekly':
        return 'weekly';
      case 'yearly':
        return 'yearly';
      case 'monthly':
        return 'monthly';
      default:
        return 'monthly';
    }
  }

  /// A business date as `YYYY-MM-DD`.
  ///
  /// Date only, in the user's own calendar. Sending an instant would let a
  /// late-evening entry in IST arrive dated the previous day once rendered in
  /// UTC, and interest day-counts run on calendar days regardless.
  static String entryDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
