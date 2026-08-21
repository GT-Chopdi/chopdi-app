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

  /// Which way the money moved: `gave` (out) | `received` (in).
  ///
  /// The app has four transaction types but they describe two independent
  /// things — the direction of the cash, and whose ledger it belongs to. Those
  /// are split rather than collapsed, because a single four-valued column would
  /// force every reader to know that `took` happens to mean money coming in.
  ///
  ///   gave     I lent money out          → gave     / lent
  ///   received they repaid me            → received / lent
  ///   took     I borrowed money          → received / borrowed
  ///   paid     I repaid what I borrowed  → gave     / borrowed
  ///
  /// Read that table carefully: `took` is money *arriving*, so its direction is
  /// `received`, and `paid` is money *leaving*, so its direction is `gave`. The
  /// obvious-looking mapping is backwards for both.
  static String direction(TransactionType type) => switch (type) {
        TransactionType.gave => 'gave',
        TransactionType.paid => 'gave',
        TransactionType.received => 'received',
        TransactionType.took => 'received',
      };

  /// Whose ledger this belongs to: `lent` | `borrowed`.
  static String ledgerSide(TransactionType type) => switch (type) {
        TransactionType.gave || TransactionType.received => 'lent',
        TransactionType.took || TransactionType.paid => 'borrowed',
      };

  /// Rebuilds the client type from the two server fields.
  static TransactionType toType(String direction, String ledgerSide) {
    final borrowed = ledgerSide == 'borrowed';

    if (direction == 'gave') {
      return borrowed ? TransactionType.paid : TransactionType.gave;
    }
    return borrowed ? TransactionType.took : TransactionType.received;
  }

  /// Signed contribution to the net position with a customer, in paise.
  ///
  /// Money out is positive (they owe me more), money in is negative. Because
  /// direction already encodes that, one rule covers all four types — which is
  /// the payoff for splitting them: no reader needs a special case for
  /// borrowing.
  static int signedPaise(TransactionType type, int amountPaise) =>
      direction(type) == 'gave' ? amountPaise : -amountPaise;

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
