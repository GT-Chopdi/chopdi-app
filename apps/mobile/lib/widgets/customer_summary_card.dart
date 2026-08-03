// import 'package:flutter/material.dart';

// class CustomerSummaryCard extends StatelessWidget {
//   const CustomerSummaryCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 84,
//       decoration: BoxDecoration(
//         color: const Color(0xffFFFDF9),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(
//           color: const Color(0xffBFCBDA),
//           width: 1,
//         ),
//       ),
//       child: IntrinsicHeight(
//         child: Row(
//           children: [

//             Expanded(
//               child: _item(
//                 icon: Icons.account_balance_wallet_outlined,
//                 iconColor: const Color(0xffF28C4B),
//                 title: "Total Given",
//                 value: "₹15,000",
//                 valueColor: const Color(0xff223A5E),
//               ),
//             ),

//             _divider(),

//             Expanded(
//               child: _item(
//                 icon: Icons.percent,
//                 iconColor: const Color(0xffF28C4B),
//                 title: "Total Interest",
//                 value: "₹2,000",
//                 valueColor: const Color(0xff16A34A),
//               ),
//             ),

//             _divider(),

//             Expanded(
//               child: _item(
//                 icon: Icons.currency_rupee,
//                 iconColor: const Color(0xffF28C4B),
//                 title: "Outstanding",
//                 value: "₹12,000",
//                 valueColor: const Color(0xffE74C3C),
//               ),
//             ),

//             _divider(),

//             Expanded(
//               child: _item(
//                 icon: Icons.calendar_today_outlined,
//                 iconColor: const Color(0xffF28C4B),
//                 title: "Since",
//                 value: "15 days",
//                 valueColor: const Color(0xff223A5E),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _divider() {
//     return Container(
//       width: 1,
//       margin: const EdgeInsets.symmetric(vertical: 14),
//       color: const Color(0xffCBD5E1),
//     );
//   }

//   Widget _item({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String value,
//     required Color valueColor,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 6,
//         vertical: 8,
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [

//           Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               color: const Color(0xffFFF2E7),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               color: iconColor,
//               size: 16,
//             ),
//           ),

//           const SizedBox(height: 5),

//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 9,
//               color: Color(0xff7B8794),
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),

//           const SizedBox(height: 3),

//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 15,
//               color: valueColor,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

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