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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // showModalBottomSheet(
        //   context: context,
        //   isScrollControlled: true,
        //   backgroundColor: Colors.transparent,
        //   builder: (_) {
        //     return TransactionDetailsScreen(
        //       transaction: transaction,
        //     );
        //   },
        // );

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => TransactionDetailsScreen(
            transaction: transaction, customerId: customerId,
            // onChanged: onChanged, customer: Customer(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFAAB9CF),
          ),
        ),
        child: Row(
          children: [
            /// Date
            Expanded(
              flex: 3,
              child: Text(
                DateFormat("dd MMM yyyy").format(transaction.date),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),

            /// Given
            Expanded(
              flex: 2,
              child: transaction.type == TransactionType.gave
                  ? Column(
                      children: [
                        Text(
                          "₹${transaction.amount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Color(0xFFC74C4C),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.description.isEmpty
                              ? "Loan Given"
                              : transaction.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text("-"),
                    ),
            ),

            /// Received
            Expanded(
              flex: 2,
              child: transaction.type == TransactionType.received
                  ? Column(
                      children: [
                        Text(
                          "₹${transaction.amount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Color(0xFF00901B),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.description.isEmpty
                              ? "Payment Received"
                              : transaction.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text("-"),
                    ),
            ),

            /// Balance
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "₹${balance.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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