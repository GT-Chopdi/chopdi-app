import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/customer_details_screen.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({
    super.key,
    required this.customer,
  });

  Future<double> getBalance(int customerId) async {
    final list = await IsarService.isar.transactions
        .filter()
        .customerIdEqualTo(customerId)
        // Deleted entries are voided, not removed.
        // Exclude them from the balance.
        .voidedAtIsNull()
        .findAll();

    double balance = 0;

    for (final tx in list) {
      if (tx.type == TransactionType.gave) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }

    return balance;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: IsarService.isar.transactions
          .filter()
          .customerIdEqualTo(customer.id)
          .voidedAtIsNull()
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

        // ============================================================
        // AMOUNT COLOR
        // ============================================================

        final Color balanceColor = balance == 0
            ? Colors.black
            : balance > 0
                ? ChopdiColors.red
                : Colors.green;

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
              color: const Color.fromRGBO(
                170,
                185,
                207,
                0.2,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color.fromRGBO(
                  170,
                  185,
                  207,
                  1,
                ),
              ),
            ),
            child: Row(
              children: [
                // ======================================================
                // CUSTOMER AVATAR
                // ======================================================

                CircleAvatar(
                  radius: 22,
                  backgroundColor: ChopdiColors.lightGray,
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ChopdiColors.navy,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ======================================================
                // CUSTOMER DETAILS
                // ======================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ==================================================
                      // LOAN CHIP
                      // ==================================================

                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _chip(
                            "Loan: ₹${balance.toStringAsFixed(0)}",
                            const Color(0xffEEF3FA),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ======================================================
                // BALANCE
                // ======================================================

                Text(
                  "₹${balance.toStringAsFixed(0)}",
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: balanceColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CHIP
  // ============================================================

  Widget _chip(
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: ChopdiColors.navy,
        ),
      ),
    );
  }
}