import 'package:flutter/material.dart';
import 'package:mychopdi/model/customer_model.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/customer_details_screen.dart';


class CustomerCard extends StatelessWidget {
  final CustomerModel customer;

  const CustomerCard({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
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
        height: 92,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: ChopdiColors.lightGray,
                child: Text(
                  customer.name[0],
                  style: const TextStyle(
                    color: ChopdiColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
      
              const SizedBox(width: 12),
      
              // Customer Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: ChopdiColors.navy,
                      ),
                    ),
      
                    const SizedBox(height: 3),
      
                    Text(
                      customer.phone,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
      
                    const Spacer(),
      
                    Row(
                      children: [
                        _chip(
                          "Loan: ₹${customer.amount}",
                          const Color(0xffEEF3FA),
                        ),
                        const SizedBox(width: 6),
                        _chip(
                          "Interest: ${customer.interest}%",
                          const Color(0xffEEF3FA),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      
              const SizedBox(width: 10),
      
              // Amount + Status + Arrow
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "₹${customer.amount}",
                        style: const TextStyle(
                          color: ChopdiColors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                  
                      const SizedBox(height: 2),
                  
                      const Text(
                        "Pending",
                        style: TextStyle(
                          color: ChopdiColors.red,
                          fontSize: 11,
                        ),
                      ),
                  
                      const SizedBox(height: 6),
                    ],
                  ),
      
                  SizedBox(width: 7),
      
                  Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: ChopdiColors.navy,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
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

extension on String {
  void toInt() {}
}