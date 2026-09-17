import 'dart:math';


class InterestCalculator {
  /// ============================================================
  /// WHOLE CALENDAR DAYS
  /// ============================================================

  static int daysBetween(
    DateTime from,
    DateTime to,
  ) {
    final start = DateTime.utc(
      from.year,
      from.month,
      from.day,
    );

    final end = DateTime.utc(
      to.year,
      to.month,
      to.day,
    );

    return end.difference(start).inDays;
  }

  /// ============================================================
  /// CALCULATE INTEREST
  /// ============================================================

  static double calculate({
    required double principal,
    required double rate,
    required DateTime startDate,
    required String interestType,
    required String frequency,
    DateTime? endDate,
  }) {
    final end = endDate ?? DateTime.now();

    final days = daysBetween(
      startDate,
      end,
    );

    if (days <= 0 ||
        principal <= 0 ||
        rate <= 0) {
      return 0;
    }

    // Normalize values so old data such as
    // "monthly" or "Monthly" also works.
    final normalizedFrequency =
        frequency.trim().toLowerCase();

    final normalizedInterestType =
        interestType.trim().toLowerCase();

    // ============================================================
    // SIMPLE INTEREST
    // ============================================================

    if (normalizedInterestType ==
        "simple interest") {
      double periods;

      switch (normalizedFrequency) {
        case "daily":
          periods = days.toDouble();
          break;

        case "weekly":
          periods = days / 7.0;
          break;

        case "monthly":
          periods = days / 30.0;
          break;

        case "yearly":
          periods = days / 365.0;
          break;

        default:
          periods = days / 30.0;
      }

      return principal *
          rate *
          periods /
          100.0;
    }

    // ============================================================
    // COMPOUND INTEREST
    // ============================================================

    double periods;

    switch (normalizedFrequency) {
      case "daily":
        periods = days.toDouble();
        break;

      case "weekly":
        periods = days / 7.0;
        break;

      case "monthly":
        periods = days / 30.0;
        break;

      case "yearly":
        periods = days / 365.0;
        break;

      default:
        periods = days / 30.0;
    }

    final periodicRate =
        rate / 100.0;

    return principal *
        (pow(
              1 + periodicRate,
              periods,
            ) -
            1);
  }

  // ============================================================
  // DAILY INTEREST
  // ============================================================

  /// Calculates the interest accumulated from startDate
  /// to endDate using the selected frequency.
  ///
  /// This is intentionally NOT a separate formula.
  /// It simply calls [calculate], so the entire app uses
  /// exactly the same interest calculation.
  static double calculateDailyAccruedInterest({
    required double principal,
    required double rate,
    required DateTime startDate,
    required String interestType,
    required String frequency,
    DateTime? endDate,
  }) {
    return calculate(
      principal: principal,
      rate: rate,
      startDate: startDate,
      interestType: interestType,
      frequency: frequency,
      endDate: endDate,
    );
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

    final days = daysBetween(
      startDate,
      end,
    );

    if (days <= 0) {
      return "0 days";
    }

    switch (frequency.trim().toLowerCase()) {
      case "daily":
        if (days == 1) {
          return "1 day";
        }

        return "$days days";

      case "weekly":
        final weeks = days ~/ 7;

        if (weeks <= 0) {
          return "$days days";
        }

        if (weeks == 1) {
          return "1 week";
        }

        return "$weeks weeks";

      case "monthly":
        final months = days ~/ 30;

        if (months <= 0) {
          return "$days days";
        }

        if (months == 1) {
          return "1 month";
        }

        return "$months months";

      case "yearly":
        final years = days ~/ 365;

        if (years <= 0) {
          return "$days days";
        }

        if (years == 1) {
          return "1 year";
        }

        return "$years years";

      default:
        final months = days ~/ 30;

        if (months <= 0) {
          return "$days days";
        }

        if (months == 1) {
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

