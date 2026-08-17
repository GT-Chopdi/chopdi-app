// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mychopdi/model/transaction.dart';
// import 'package:mychopdi/widgets/transaction_details_bottom_sheet.dart';
// import 'package:mychopdi/utils/interest_calculator.dart';

// class TransactionRow extends StatelessWidget {
//   final Transaction transaction;
//   final double balance;
//   final VoidCallback? onChanged;
//   final int customerId;

//   const TransactionRow({
//     super.key,
//     required this.transaction,
//     required this.balance,
//     this.onChanged,
//     required this.customerId,
//   });

//   // String _getTransactionDescription() {
//   //   if (transaction.type == TransactionType.received) {
//   //     return transaction.description.isEmpty
//   //         ? "Payment Received"
//   //         : transaction.description;
//   //   }

//   //   final interest = InterestCalculator.calculate(
//   //     principal: transaction.amount,
//   //     rate: transaction.interestRate,
//   //     startDate: transaction.date,
//   //     interestType: transaction.interestType,
//   //     frequency: transaction.interestFrequency,
//   //   );

//   //   final now = DateTime.now();

//   //   final days = now.difference(transaction.date).inDays;

//   //   final dateRange =
//   //       "${DateFormat("dd MMM").format(transaction.date)}"
//   //       " → "
//   //       "${DateFormat("dd MMM").format(now)}";

//   //   if (days <= 0) {
//   //     return "Loan Given";
//   //   }

//   //   return "Interest ₹${interest.toStringAsFixed(2)}\n"
//   //       "$dateRange\n"
//   //       "${transaction.interestType} • ${transaction.interestFrequency}";
//   // }

//   // String _getTransactionDescription() {
//   //   if (transaction.type == TransactionType.received) {
//   //     return transaction.description.isEmpty
//   //         ? "Payment Received"
//   //         : transaction.description;
//   //   }

//   //   final now = DateTime.now();

//   //   final days = now.difference(transaction.date).inDays;

//   //   if (days <= 0) {
//   //     return transaction.description.isEmpty
//   //         ? "Loan given"
//   //         : transaction.description;
//   //   }

//   //   final interest = InterestCalculator.calculate(
//   //     principal: transaction.amount,
//   //     rate: transaction.interestRate,
//   //     startDate: transaction.date,
//   //     interestType: transaction.interestType,
//   //     frequency: transaction.interestFrequency,
//   //   );

//   //   final startDate =
//   //       DateFormat("dd MMM").format(transaction.date);

//   //   final endDate =
//   //       DateFormat("dd MMM").format(now);

//   //   final interestText =
//   //       "₹${interest.toStringAsFixed(0)}";

//   //   final rateText =
//   //       "${transaction.interestRate.toStringAsFixed(0)}%";

//   //   final typeText =
//   //       transaction.interestType
//   //           .replaceAll(" Interest", "")
//   //           .toLowerCase();

//   //   final frequencyText =
//   //       transaction.interestFrequency.toLowerCase();

//   //   return "$interestText interest from $startDate to "
//   //       "$endDate at $rateText $frequencyText "
//   //       "$typeText interest.";
//   // }

//   String _getTransactionDescription() {
//     if (transaction.type == TransactionType.received) {
//       return transaction.description.isEmpty
//           ? "Payment received."
//           : transaction.description;
//     }

//     final now = DateTime.now();

//     final days = now.difference(transaction.date).inDays;

//     if (days <= 0) {
//       return transaction.description.isEmpty
//           ? "Loan given."
//           : transaction.description;
//     }

//     final interest = InterestCalculator.calculate(
//       principal: transaction.amount,
//       rate: transaction.interestRate,
//       startDate: transaction.date,
//       interestType: transaction.interestType,
//       frequency: transaction.interestFrequency,
//     );

//     final startDate =
//         DateFormat("dd MMM yyyy").format(transaction.date);

//     final endDate =
//         DateFormat("dd MMM yyyy").format(now);

//     final rate =
//         transaction.interestRate.toStringAsFixed(0);

//     final frequency =
//         transaction.interestFrequency.toLowerCase();

//     final interestType =
//         transaction.interestType
//             .replaceAll(" Interest", "")
//             .toLowerCase();

//     return "₹${interest.toStringAsFixed(0)} interest "
//         "from $startDate to $endDate at $rate% "
//         "$frequency $interestType interest.";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // showModalBottomSheet(
//         //   context: context,
//         //   isScrollControlled: true,
//         //   backgroundColor: Colors.transparent,
//         //   builder: (_) {
//         //     return TransactionDetailsScreen(
//         //       transaction: transaction,
//         //     );
//         //   },
//         // );

//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           backgroundColor: Colors.transparent,
//           builder: (_) => TransactionDetailsScreen(
//             transaction: transaction, customerId: customerId,onChanged: onChanged,
//             // onChanged: onChanged, customer: Customer(),
//           ),
//         );
//       },
//       // child: Container(
//       //   margin: const EdgeInsets.only(bottom: 8),
//       //   padding: const EdgeInsets.symmetric(
//       //     horizontal: 8,
//       //     vertical: 10,
//       //   ),
//       //   decoration: BoxDecoration(
//       //     color: const Color(0xFFFFF8F0),
//       //     borderRadius: BorderRadius.circular(10),
//       //     border: Border.all(
//       //       color: const Color(0xFFAAB9CF),
//       //     ),
//       //   ),
//       //   child: Row(
//       //     children: [
//       //       /// Date
//       //       Expanded(
//       //         flex: 3,
//       //         child: Text(
//       //           DateFormat("dd MMM yyyy").format(transaction.date),
//       //           style: const TextStyle(
//       //             fontSize: 12,
//       //             color: Colors.black87,
//       //           ),
//       //         ),
//       //       ),

//       //       /// Given
//       //       Expanded(
//       //         flex: 2,
//       //         child: transaction.type == TransactionType.gave
//       //             ? Column(
//       //                 children: [
//       //                   Text(
//       //                     "₹${transaction.amount.toStringAsFixed(0)}",
//       //                     style: const TextStyle(
//       //                       color: Color(0xFFC74C4C),
//       //                       fontWeight: FontWeight.bold,
//       //                       fontSize: 13,
//       //                     ),
//       //                   ),
//       //                   const SizedBox(height: 2),
//       //                   // Text(
//       //                   //   transaction.description.isEmpty
//       //                   //       ? "Loan Given"
//       //                   //       : transaction.description,
//       //                   //   textAlign: TextAlign.center,
//       //                   //   style: const TextStyle(
//       //                   //     fontSize: 9,
//       //                   //     color: Colors.black,
//       //                   //   ),
//       //                   // ),

//       //                   Text(
//       //                     _getTransactionDescription(),
//       //                     textAlign: TextAlign.center,
//       //                     style: const TextStyle(
//       //                       fontSize: 9,
//       //                       color: Colors.black,
//       //                       height: 1.3,
//       //                     ),
//       //                   ),
//       //                 ],
//       //               )
//       //             : const Center(
//       //                 child: Text("-"),
//       //               ),
//       //       ),

//       //       /// Received
//       //       Expanded(
//       //         flex: 2,
//       //         child: transaction.type == TransactionType.received
//       //             ? Column(
//       //                 children: [
//       //                   Text(
//       //                     "₹${transaction.amount.toStringAsFixed(0)}",
//       //                     style: const TextStyle(
//       //                       color: Color(0xFF00901B),
//       //                       fontWeight: FontWeight.bold,
//       //                       fontSize: 13,
//       //                     ),
//       //                   ),
//       //                   const SizedBox(height: 2),
//       //                   Text(
//       //                     transaction.description.isEmpty
//       //                         ? "Payment Received"
//       //                         : transaction.description,
//       //                     textAlign: TextAlign.center,
//       //                     style: const TextStyle(
//       //                       fontSize: 9,
//       //                       color: Colors.black,
//       //                     ),
//       //                   ),
//       //                 ],
//       //               )
//       //             : const Center(
//       //                 child: Text("-"),
//       //               ),
//       //       ),

//       //       /// Balance
//       //       Expanded(
//       //         flex: 2,
//       //         child: Align(
//       //           alignment: Alignment.centerRight,
//       //           child: Text(
//       //             "₹${balance.toStringAsFixed(0)}",
//       //             style: const TextStyle(
//       //               fontWeight: FontWeight.w600,
//       //               fontSize: 13,
//       //               color: Colors.black,
//       //             ),
//       //           ),
//       //         ),
//       //       ),
//       //     ],
//       //   ),
//       // ),

//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.symmetric(
//           horizontal: 8,
//           vertical: 10,
//         ),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFFF8F0),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: const Color(0xFFAAB9CF),
//           ),
//         ),
//         child: Column(
//           children: [

//             // =========================
//             // MAIN TRANSACTION ROW
//             // =========================

//             Row(
//               children: [
//                 /// Date
//                 // Expanded(
//                 //   flex: 3,
//                 //   child: Text(
//                 //     DateFormat("dd MMM yyyy")
//                 //         .format(transaction.date),
//                 //     style: const TextStyle(
//                 //       fontSize: 12,
//                 //       color: Colors.black87,
//                 //     ),
//                 //   ),
//                 // ),

//                 Expanded(
//   flex: 3,
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Text(
//         DateFormat("dd MMM yyyy").format(transaction.date),
//         style: const TextStyle(
//           fontSize: 11,
//           color: Colors.black87,
//         ),
//       ),
//       const SizedBox(height: 3),
//       Text(
//         transaction.description.isEmpty
//             ? "Description ........"
//             : transaction.description,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style: const TextStyle(
//           fontSize: 8,
//           color: Color(0xff8A93A6),
//         ),
//       ),
//     ],
//   ),
// ),

//                 /// Given
//                 Expanded(
//                   flex: 2,
//                   child: transaction.type == TransactionType.gave
//                       ? Text(
//                           "₹${transaction.amount.toStringAsFixed(0)}",
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             color: Color(0xFFC74C4C),
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13,
//                           ),
//                         )
//                       : const Center(
//                           child: Text("-"),
//                         ),
//                 ),

//                 /// Received
//                 Expanded(
//                   flex: 2,
//                   child: transaction.type ==
//                           TransactionType.received
//                       ? Text(
//                           "₹${transaction.amount.toStringAsFixed(0)}",
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             color: Color(0xFF00901B),
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13,
//                           ),
//                         )
//                       : const Center(
//                           child: Text("-"),
//                         ),
//                 ),

//                 /// Balance
//                 Expanded(
//                   flex: 2,
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Text(
//                       "₹${balance.toStringAsFixed(0)}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 13,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 7),

//             // =========================
//             // COMPLETE DESCRIPTION
//             // =========================

//             // Align(
//             //   alignment: Alignment.centerLeft,
//             //   child: Text(
//             //     _getTransactionDescription(),
//             //     textAlign: TextAlign.left,
//             //     style: const TextStyle(
//             //       fontSize: 10,
//             //       color: Colors.black87,
//             //       height: 1.35,
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/widgets/transaction_details_bottom_sheet.dart';

class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final double balance;
  final VoidCallback? onChanged;
  final int customerId;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.balance,
    this.onChanged,
    required this.customerId,
  });

  // USER DESCRIPTION

  String _getDescription() {
    if (transaction.description.trim().isEmpty) {
      return "Description...";
    }

    return transaction.description;
  }

  // TRANSACTION TYPE

  String _getGivenDescription() {
    return "Loan Given";
  }

  String _getReceivedDescription() {
    return "Payment received";
  }

  String _getRowDescription() {
    final startDate = transaction.date;

    // Currently using today's date as the end date
    final endDate = DateTime.now();

    final formattedStart =
        DateFormat("dd MMM yyyy").format(startDate);

    final formattedEnd =
        DateFormat("dd MMM yyyy").format(endDate);

    final rate =
        transaction.interestRate.toStringAsFixed(0);

    final frequency =
        transaction.interestFrequency.isEmpty
            ? "Monthly"
            : transaction.interestFrequency;

    final interestType =
        transaction.interestType.isEmpty
            ? "Simple Interest"
            : transaction.interestType;

    return "$formattedStart → $formattedEnd "
        "$rate% $frequency $interestType";
  }

  @override
  Widget build(BuildContext context) {
    final bool isGiven =
        transaction.type == TransactionType.gave;

    final bool isReceived =
        transaction.type == TransactionType.received;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return TransactionDetailsScreen(
              transaction: transaction,
              customerId: customerId,
              onChanged: onChanged,
            );
          },
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 10),

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFAAB9CF),
          ),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ==================================
            // DATE + USER DESCRIPTION
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Date
                  Text(
                    DateFormat("dd MMM yyyy")
                        .format(transaction.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // User Description
                  Text(
                    _getDescription(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xff8A93A6),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================
            // GIVEN
            // ==================================

            Expanded(
              flex: 2,
              child: isGiven
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // Amount
                        Text(
                          "₹${transaction.amount.toStringAsFixed(0)}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFC74C4C),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Loan Given
                        const Text(
                          "Loan Given",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        "-",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
            ),

            // RECEIVED

            Expanded(
              flex: 2,
              child: isReceived
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // Amount
                        Text(
                          "₹${transaction.amount.toStringAsFixed(0)}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF00901B),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Payment Received
                        const Text(
                          "Payment received",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        "-",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
            ),

            // ==================================
            // BALANCE
            // ==================================

            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "₹${balance.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}