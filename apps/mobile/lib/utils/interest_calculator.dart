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

    if (principal <= 0 || rate <= 0) {
      return 0;
    }

    final normalizedFrequency = frequency.trim().toLowerCase();

    // ============================================================
    // MONTHLY INTEREST
    // ============================================================
    //
    // IMPORTANT:
    // Use the same calendar-month calculation as
    // calculateMonthlyBreakdown().
    //
    // This keeps SummaryCard, CustomerCard,
    // CustomerDetailsScreen and TransactionTable consistent.
    //
    if (normalizedFrequency == "monthly") {
      final monthlyEntries = calculateMonthlyBreakdown(
        principal: principal,
        rate: rate,
        startDate: startDate,
        interestType: interestType,
        frequency: frequency,
        endDate: end,
        activeLoanCount: 1,
      );

      return monthlyEntries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.interest,
      );
    }

    // ============================================================
    // OTHER FREQUENCIES
    // ============================================================

    final days = daysBetween(startDate, end);

    if (days <= 0) {
      return 0;
    }

    final normalizedInterestType =
        interestType.trim().toLowerCase();

    double periods;

    switch (normalizedFrequency) {
      case "daily":
        periods = days.toDouble();
        break;

      case "weekly":
        periods = days / 7.0;
        break;

      case "yearly":
        periods = days / 365.0;
        break;

      default:
        periods = days / 365.0;
    }

    // ============================================================
    // SIMPLE INTEREST
    // ============================================================

    if (normalizedInterestType == "simple interest" ||
        normalizedInterestType == "simple") {
      return principal * rate * periods / 100.0;
    }

    // ============================================================
    // COMPOUND INTEREST
    // ============================================================

    final periodicRate = rate / 100.0;

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
  /// This uses [calculate] so the rest of the app keeps
  /// the same interest calculation behavior.
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

  // ============================================================
  // MONTHLY INTEREST BREAKDOWN
  // ============================================================

  /// Returns one interest entry for every calendar month
  /// from the loan start month through [endDate].
  ///
  /// Rules for Issue #111:
  ///
  /// 1. Past month:
  ///    Full calendar month.
  ///
  ///    Example:
  ///    01 Sep -> 30 Sep
  ///
  /// 2. Current month:
  ///    1st -> today.
  ///
  ///    Example:
  ///    01 Oct -> 05 Oct
  ///
  /// 3. First month of a mid-month loan:
  ///    Interest starts from the loan start day.
  ///
  ///    Example:
  ///    Loan starts 15 Sep:
  ///    15 / 30 of monthly interest.
  ///
  /// 4. Date displayed for every monthly entry is the
  ///    calendar month range. The interest calculation
  ///    itself respects the actual loan start date.
  ///
  /// 5. No future month is generated.
  static List<MonthlyInterestEntry> calculateMonthlyBreakdown({
    required double principal,
    required double rate,
    required DateTime startDate,
    required String interestType,
    required String frequency,
    DateTime? endDate,
    int activeLoanCount = 1,
  }) {
    final end = endDate ?? DateTime.now();

    final today = DateTime(
      end.year,
      end.month,
      end.day,
    );

    final loanStartDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    // Future loan.
    if (loanStartDate.isAfter(today)) {
      return [];
    }

    final List<MonthlyInterestEntry> entries = [];

    DateTime currentMonthStart = DateTime(
      loanStartDate.year,
      loanStartDate.month,
      1,
    );

    bool isFirstMonth = true;

    while (
    currentMonthStart.isBefore(today) ||
        (currentMonthStart.year == today.year &&
            currentMonthStart.month == today.month)) {
      // ==========================================================
      // MONTH BOUNDARIES
      // ==========================================================

      final nextMonthStart = DateTime(
        currentMonthStart.year,
        currentMonthStart.month + 1,
        1,
      );

      final lastDayOfMonth = DateTime(
        currentMonthStart.year,
        currentMonthStart.month + 1,
        0,
      );

      final daysInMonth =
          lastDayOfMonth.day;

      final isCurrentMonth =
          currentMonthStart.year == today.year &&
              currentMonthStart.month == today.month;

      // ==========================================================
      // DISPLAY RANGE
      // ==========================================================

      final displayStart = currentMonthStart;

      final displayEnd = isCurrentMonth
          ? today
          : lastDayOfMonth;

      // ==========================================================
      // CALCULATION DAYS
      // ==========================================================
      //
      // Issue #111 examples:
      //
      // 01 Aug -> 31 Aug
      // = 31 days
      //
      // 01 Oct -> 05 Oct
      // = 5 days
      //
      // 15 Sep -> 30 Sep
      // = 15 days
      //
      // Therefore:
      //
      // - full past month = number of days in month
      // - current month = today's day
      // - mid-month first month = daysInMonth - startDay
      //

      int calculationDays;

      if (isCurrentMonth && isFirstMonth) {

        calculationDays = today.day - loanStartDate.day;
      } else if (isCurrentMonth) {

        calculationDays = today.day - 1;
      } else if (isFirstMonth && loanStartDate.day > 1) {

        calculationDays = daysInMonth - loanStartDate.day;
      } else {

        calculationDays = daysInMonth;
      }

      // Never allow invalid/negative days.
      if (calculationDays < 0) {
        calculationDays = 0;
      }

      if (calculationDays > 0 &&
          principal > 0 &&
          rate > 0) {
        final normalizedFrequency =
        frequency.trim().toLowerCase();

        final normalizedInterestType =
        interestType.trim().toLowerCase();

        double interest;

        // ========================================================
        // SIMPLE INTEREST
        // ========================================================

        if (normalizedInterestType == "simple interest" ||
            normalizedInterestType == "simple") {
          double periods;

          switch (normalizedFrequency) {
            case "daily":
              periods =
                  calculationDays.toDouble();
              break;

            case "weekly":
              periods =
                  calculationDays / 7.0;
              break;

            case "monthly":
            // IMPORTANT:
            // Use the actual number of days in this
            // calendar month.
            //
            // Oct:
            // 5 / 31
            //
            // Sep mid-month:
            // 15 / 30
              periods =
                  calculationDays / daysInMonth;
              break;

            case "yearly":
              periods =
                  calculationDays / 365.0;
              break;

            default:
              periods =
                  calculationDays / daysInMonth;
          }

          interest =
              principal *
                  rate *
                  periods /
                  100.0;
        } else {
          // ======================================================
          // COMPOUND INTEREST
          // ======================================================

          double periods;

          switch (normalizedFrequency) {
            case "daily":
              periods =
                  calculationDays.toDouble();
              break;

            case "weekly":
              periods =
                  calculationDays / 7.0;
              break;

            case "monthly":
              periods =
                  calculationDays / daysInMonth;
              break;

            case "yearly":
              periods =
                  calculationDays / 365.0;
              break;

            default:
              periods =
                  calculationDays / daysInMonth;
          }

          final periodicRate =
              rate / 100.0;

          interest = principal *
              (pow(
                1 + periodicRate,
                periods,
              ) -
                  1);
        }

        // ========================================================
        // DESCRIPTION
        // ========================================================

        final monthName =
        _month(currentMonthStart.month);

        final yearShort =
        currentMonthStart.year
            .toString()
            .substring(2);

        final loanText =
        activeLoanCount == 1
            ? "loan"
            : "loans";

        final String description;

        if (isCurrentMonth) {
          description =
          "Interest for $monthName "
              "$yearShort up to "
              "${today.day} $monthName "
              "($activeLoanCount $loanText)";
        } else {
          description =
          "Interest for $monthName "
              "$yearShort "
              "($activeLoanCount $loanText)";
        }

        // ========================================================
        // ADD MONTHLY ENTRY
        // ========================================================

        entries.add(
          MonthlyInterestEntry(
            // Always show calendar month start
            // in the UI.
            startDate: displayStart,

            // Past month = month end.
            // Current month = today.
            endDate: displayEnd,

            interest: interest,

            description: description,

            loanCount: activeLoanCount,
          ),
        );
      }

      // ==========================================================
      // NEXT MONTH
      // ==========================================================

      currentMonthStart =
          nextMonthStart;

      isFirstMonth = false;
    }

    return entries;
  }
}

// ================================================================
// MONTHLY INTEREST ENTRY
// ================================================================

class MonthlyInterestEntry {
  final DateTime startDate;
  final DateTime endDate;
  final double interest;
  final String description;
  final int loanCount;

  MonthlyInterestEntry({
    required this.startDate,
    required this.endDate,
    required this.interest,
    required this.description,
    required this.loanCount,
  });
}