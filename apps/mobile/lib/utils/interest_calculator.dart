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

import 'dart:math';

class InterestCalculator {
  static double calculate({
    required double principal,
    required double rate,
    required DateTime startDate,
    required String interestType,
    required String frequency,
  }) {
    final days = DateTime.now().difference(startDate).inDays;

    if (days <= 0) return 0;

    final double annualRate = rate / 100;

    if (interestType == "Simple Interest") {
      if (frequency == "Monthly") {
        final months = days / 30;

        return principal * (rate / 100) * months;
      } else {
        final years = days / 365;

        return principal * (rate / 100) * years;
      }
    }

    // Compound Interest
    if (frequency == "Monthly") {
      final years = days / 365;

      final amount = principal *
          pow(1 + annualRate / 12, 12 * years);

      return amount - principal;
    } else {
      final years = days / 365;

      final amount = principal *
          pow(1 + annualRate, years);

      return amount - principal;
    }
  }
}