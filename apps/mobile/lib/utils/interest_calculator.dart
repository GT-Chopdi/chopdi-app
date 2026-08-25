import 'dart:math';

class InterestCalculator {
  /// Whole calendar days between two dates.
  ///
  /// Deliberately not `end.difference(start).inDays`, which measures elapsed
  /// time and truncates. Entry dates carry a time and the end date defaults to
  /// `DateTime.now()`, so elapsed-time counting made a loan recorded at 6pm
  /// show zero interest the next morning — then jump as soon as it synced,
  /// because the server counts calendar days. A ledger amount that changes on
  /// its own is worse than one that is slightly wrong.
  ///
  /// Mirrors `InterestService.daysBetween` on the server. Both must agree; the
  /// shared fixture in docs/rnd/interest-vectors.json is what keeps them
  /// agreeing.
  static int daysBetween(DateTime from, DateTime to) {
    // Compare calendar dates in each value's own zone: a business date is the
    // user's day, not a UTC instant.
    final start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(to.year, to.month, to.day);

    return end.difference(start).inDays;
  }

  static double calculate({
    required double principal,
    required double rate,
    required DateTime startDate,
    required String interestType,
    required String frequency,
    DateTime? endDate,
  }) {
    final end = endDate ?? DateTime.now();

    final days = daysBetween(startDate, end);

    if (days <= 0) {
      return 0;
    }

    // ============================================================
    // SIMPLE INTEREST
    // ============================================================

    if (interestType == "Simple Interest") {
      double periods;

      switch (frequency) {
        case "Daily":
          periods = days.toDouble();
          break;

        case "Weekly":
          periods = days / 7;
          break;

        case "Monthly":
          periods = days / 30;
          break;

        case "Yearly":
          periods = days / 365;
          break;

        default:
          periods = days / 30;
      }

      return principal * rate * periods / 100;
    }

    // ============================================================
    // COMPOUND INTEREST
    // ============================================================

    double periods;
    double periodicRate;

    switch (frequency) {
      case "Daily":
        periods = days.toDouble();
        periodicRate = rate / 100;
        break;

      case "Weekly":
        periods = days / 7;
        periodicRate = rate / 100;
        break;

      case "Monthly":
        periods = days / 30;
        periodicRate = rate / 100;
        break;

      case "Yearly":
        periods = days / 365;
        periodicRate = rate / 100;
        break;

      default:
        periods = days / 30;
        periodicRate = rate / 100;
    }

    return principal *
        (pow(
          1 + periodicRate,
          periods,
        ) -
            1);
  }

  // ============================================================
  // GET INTEREST PERIOD
  // ============================================================

  static String getInterestPeriod({
    required DateTime startDate,
    DateTime? endDate,
    required String frequency,
  }) {
    final end = endDate ?? DateTime.now();

    final days = end.difference(startDate).inDays;

    if (days <= 0) {
      return "0 days";
    }

    switch (frequency) {
      case "Daily":
        if (days == 1) {
          return "1 day";
        }

        return "$days days";

      case "Weekly":
        final weeks = (days / 7).round();

        if (weeks <= 1) {
          return "1 week";
        }

        return "$weeks weeks";

      case "Monthly":
        final months = (days / 30).round();

        if (months <= 1) {
          return "1 month";
        }

        return "$months months";

      case "Yearly":
        final years = (days / 365).round();

        if (years <= 1) {
          return "1 year";
        }

        return "$years years";

      default:
        final months = (days / 30).round();

        if (months <= 1) {
          return "1 month";
        }

        return "$months months";
    }
  }

  // ============================================================
  // FORMAT AMOUNT
  // ============================================================

  static String formatAmount(
    double amount,
  ) {
    return "₹${amount.toStringAsFixed(2)}";
  }

  // ============================================================
  // FORMAT DATE RANGE
  // ============================================================

  static String formatDateRange(
    DateTime startDate, {
    DateTime? endDate,
  }) {
    final end =
        endDate ?? DateTime.now();

    return "${startDate.day} ${_month(startDate.month)} → "
        "${end.day} ${_month(end.month)}";
  }

  static String _month(
    int month,
  ) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return months[month - 1];
  }
}

