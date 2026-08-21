/// Conversions between the rupee values the UI works in and the integer paise
/// the ledger stores.
///
/// Centralised so the rounding rule exists in exactly one place. The one-time
/// data migration and every live write must agree to the paise, or a user's
/// balance shifts the day they upgrade — and the same rule has to match the
/// server, which rounds half away from zero.
class Money {
  const Money._();

  /// Rupees to paise, rounded half away from zero.
  ///
  /// The multiply happens in floating point because that is what the UI hands
  /// us, but the result is an exact integer and every later operation — sums,
  /// balances, sync — is integer arithmetic. This is the last point at which a
  /// fraction of a paise can exist.
  static int toPaise(double rupees) => (rupees * 100).round();

  /// Paise to rupees, for display only. Never store or sync the result.
  static double toRupees(int paise) => paise / 100.0;

  /// A percentage to basis points: 12.5% becomes 1250.
  static int rateToBasisPoints(double percent) => (percent * 100).round();

  /// Basis points back to a percentage, for display.
  static double basisPointsToRate(int bp) => bp / 100.0;
}
