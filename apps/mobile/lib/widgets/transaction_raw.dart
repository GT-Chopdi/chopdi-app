import 'package:flutter/material.dart';
import 'package:mychopdi/model/transaction_model.dart';
import 'package:mychopdi/widgets/transaction_details_bottom_sheet.dart';

class TransactionRow extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionRow({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   showTransactionDetailsBottomSheet(context, transaction);
      // },
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return TransactionDetailsScreen();
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        child: Row(
          children: [
            /// Date
            Expanded(
              flex: 3,
              child: Text(
                transaction.date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
      
            /// Given
            Expanded(
              flex: 2,
              child: transaction.given == null
                  ? const Center(child: Text("-"))
                  : Column(
                      children: [
                        Text(
                          transaction.given!,
                          style: const TextStyle(
                            color: Color(0xFFC74C4C),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.subtitle,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
            ),
      
            /// Received
            Expanded(
              flex: 2,
              child: transaction.received == null
                  ? const Center(child: Text("-"))
                  : Column(
                      children: [
                        Text(
                          transaction.received!,
                          style: const TextStyle(
                            color: Color(0xFF00901B),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.subtitle,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
            ),
      
            /// Balance
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  transaction.balance,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF000000),
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