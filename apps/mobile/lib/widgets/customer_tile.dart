import 'package:flutter/material.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;
  final Transaction transaction;

  const CustomerTile({
    super.key,
    required this.customer,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xffD8E2F2),
            child: Text(
              customer.name[0],
              style: const TextStyle(
                color: Color(0xff243B67),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  customer.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  "Loan: ₹${transaction.amount.toStringAsFixed(0)} • Rate: ${transaction.interestRate}%",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              Text(
                "₹${transaction.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: customer.received
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                customer.received
                    ? "Received"
                    : "Pending",
                style: TextStyle(
                  color: customer.received
                      ? Colors.green
                      : Colors.red,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.chevron_right,
            color: Color(0xff243B67),
          )
        ],
      ),
    );
  }
}