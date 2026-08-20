import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomerSummaryCard extends StatelessWidget {
  const CustomerSummaryCard({super.key});

  Widget _item({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
    bool showDivider = true,
  }) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: valueColor.withValues(alpha: .12),
                  child: Icon(
                    icon,
                    color: valueColor,
                    size: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),

          if (showDivider)
            Container(
              height: 52,
              width: 1,
              color: AppColors.border,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          _item(
            icon: Icons.account_balance_wallet_outlined,
            title: "Total Given",
            value: "₹15,000",
            valueColor: AppColors.primary,
          ),
          _item(
            icon: Icons.percent,
            title: "Total Interest",
            value: "₹2,000",
            valueColor: AppColors.green,
          ),
          _item(
            icon: Icons.currency_rupee,
            title: "Outstanding",
            value: "₹12,000",
            valueColor: AppColors.red,
          ),
          _item(
            icon: Icons.calendar_today,
            title: "Since",
            value: "15 days",
            valueColor: AppColors.primary,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}