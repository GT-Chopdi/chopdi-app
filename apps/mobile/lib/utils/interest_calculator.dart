// import 'dart:math';

// class InterestCalculator {
//   static double calculate({
//     required double principal,
//     required double rate,
//     required DateTime startDate,
//     required String interestType,
//     required String frequency,
//   }) {
//     final days = DateTime.now().difference(startDate).inDays;

//     double time;

//     if (frequency == "Monthly") {
//       time = days / 30;
//     } else {
//       time = days / 365;
//     }

//     if (interestType == "Simple Interest") {
//       return principal * rate * time / 100;
//     }

//     return principal *
//         (pow(1 + rate / 100, time) - 1);
//   }
// }

// import 'dart:math';

// class InterestCalculator {
//   static double calculate({
//     required double principal,
//     required double rate,
//     required DateTime startDate,
//     required String interestType,
//     required String frequency,
//   }) {
//     final days = DateTime.now().difference(startDate).inDays;

//     if (days <= 0) return 0;

//     final double annualRate = rate / 100;

//     if (interestType == "Simple Interest") {
//       if (frequency == "Monthly") {
//         final months = days / 30;

//         return principal * (rate / 100) * months;
//       } else {
//         final years = days / 365;

//         return principal * (rate / 100) * years;
//       }
//     }

//     // Compound Interest
//     if (frequency == "Monthly") {
//       final years = days / 365;

//       final amount = principal *
//           pow(1 + annualRate / 12, 12 * years);

//       return amount - principal;
//     } else {
//       final years = days / 365;

//       final amount = principal *
//           pow(1 + annualRate, years);

//       return amount - principal;
//     }
//   }
// }

import 'dart:math';


class InterestCalculator {
  static double calculate({
    required double principal,
    required double rate,
    required DateTime startDate,
    required String interestType,
    required String frequency,
    DateTime? endDate,
  }) {
    final end = endDate ?? DateTime.now();

    final days = end.difference(startDate).inDays;

    if (days <= 0) {
      return 0;
    }

    // ============================
    // SIMPLE INTEREST
    // ============================

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

    // ============================
    // COMPOUND INTEREST
    // ============================

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
        (pow(1 + periodicRate, periods) - 1);
  }

  static String formatAmount(double amount) {
    return "₹${amount.toStringAsFixed(2)}";
  }

  static String formatDateRange(
    DateTime startDate, {
    DateTime? endDate,
  }) {
    final end = endDate ?? DateTime.now();

    return "${startDate.day} ${_month(startDate.month)} → "
        "${end.day} ${_month(end.month)}";
  }

  static String _month(int month) {
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