import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/customer_details_screen.dart';

class TookLoanCustomerCard extends StatelessWidget {
  final Customer customer;

  const TookLoanCustomerCard({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: IsarService.isar.transactions
          .filter()
          .customerIdEqualTo(customer.id)
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? [];

        double balance = 0;

        for (final tx in transactions) {
          if (tx.type == TransactionType.gave) {
            balance += tx.amount;
          } else {
            balance -= tx.amount;
          }
        }

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerDetailsScreen(
                  customer: customer,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(170, 185, 207, 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color.fromRGBO(170, 185, 207, 1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: ChopdiColors.lightGray,
                  child: Text(
                    customer.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ChopdiColors.navy,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: ChopdiColors.navy,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        customer.phone.isEmpty
                            ? "No phone number"
                            : customer.phone,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffEEF3FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Loan: ₹${balance.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: ChopdiColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${balance.toStringAsFixed(0)}",
                      style: GoogleFonts.manrope(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      balance >= 0 ? "Pending" : "Settled",
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}