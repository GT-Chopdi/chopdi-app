// import 'package:flutter/material.dart';
// import '../model/transaction_model.dart';

// void showTransactionDetailsBottomSheet(
//     BuildContext context,
//     TransactionModel transaction,
// ) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (_) {
//       return FractionallySizedBox(
//         heightFactor: 0.82,
//         child: TransactionDetailsBottomSheet(
//           transaction: transaction,
//         ),
//       );
//     },
//   );
// }

// class TransactionDetailsBottomSheet extends StatelessWidget {
//   final TransactionModel transaction;

//   const TransactionDetailsBottomSheet({
//     super.key,
//     required this.transaction,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Color(0xffFDF8F2),
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(30),
//         ),
//       ),
//       child: Column(
//         children: [
//           const SizedBox(height: 12),

//           Container(
//             width: 60,
//             height: 5,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade400,
//               borderRadius: BorderRadius.circular(20),
//             ),
//           ),

//           const SizedBox(height: 20),

//           CircleAvatar(
//             radius: 28,
//             backgroundColor: Color(0xffDDE7F7),
//             child: Icon(
//               Icons.currency_rupee,
//               color: Color(0xff243B67),
//             ),
//           ),

//           const SizedBox(height: 12),

//           const Text(
//             "Transaction Details",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),

//           const SizedBox(height: 8),

//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 6,
//             ),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: Colors.red,
//               ),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               transaction.given != null
//                   ? "Loan Given"
//                   : "Money Received",
//               style: TextStyle(
//                 color: Colors.red,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),

//           const SizedBox(height: 25),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Row(
//               children: [
//                 const Icon(Icons.calendar_today, size: 18),

//                 const SizedBox(width: 8),

//                 Text(transaction.date),

//                 const Spacer(),

//                 Text(
//                   transaction.given ??
//                       transaction.received ??
//                       "₹0",
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xffD94A4A),
//                   ),
//                 )
//               ],
//             ),
//           ),

//           const SizedBox(height: 20),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Text(
//               "Description goes here...",
//               style: TextStyle(
//                 color: Colors.grey.shade700,
//               ),
//             ),
//           ),

//           const SizedBox(height: 25),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: infoTile(
//                     "Interest Rate",
//                     "12%",
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: infoTile(
//                     "Interest Type",
//                     "Simple",
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 12),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: infoTile(
//                     "Frequency",
//                     "Monthly",
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: infoTile(
//                     "Payment",
//                     "UPI",
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const Spacer(),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.edit),
//                 label: const Text("Edit Transaction"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xff243B67),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 14),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: OutlinedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(
//                   Icons.delete,
//                   color: Colors.red,
//                 ),
//                 label: const Text(
//                   "Delete Transaction",
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }

//   Widget infoTile(String title, String value) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Color(0xffFFF8F0),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           const Icon(Icons.calendar_today,
//               color: Color(0xff243B67)),
//           const SizedBox(height: 6),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.grey,
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mychopdi/utils/colors.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [

            const Positioned(
              left: 20,
              top: 10,
              child: Text(
                "Transaction Details",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * .90,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.sheetColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: const TransactionBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionBody extends StatelessWidget {
  const TransactionBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [

          const SizedBox(height: 10),

          Container(
            width: 55,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
              borderRadius: BorderRadius.circular(50),
            ),
          ),

          const SizedBox(height: 20),

          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.lightBlue,
            child: Icon(
              Icons.currency_rupee,
              color: AppColors.primary,
              size: 30,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            "Transaction Details",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.chipBorder,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 15,
                  color: Colors.red,
                ),
                SizedBox(width: 5),
                Text(
                  "Loan Given",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [

              const Icon(Icons.calendar_month,
                  color: Colors.blue),

              const SizedBox(width: 6),

              const Text(
                "10 May 2026",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              Text(
                "₹15,000",
                style: TextStyle(
                  color: AppColors.amountRed,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),

          const SizedBox(height: 18),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Descriptiondwqwerthcsbsjbsdcjbdcdjcjcjdbbdjbjdjdjdjdjdjhsc",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 22),

          const Divider(),

          const SizedBox(height: 10),

          Expanded(
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 20,
              mainAxisSpacing: 12,
              children: const [

                DetailTile(
                  title: "Interest Rate",
                  value: "12%",
                ),

                DetailTile(
                  title: "Interest Type",
                  value: "Simple Interest",
                ),

                DetailTile(
                  title: "Interest Frequency",
                  value: "Monthly",
                ),

                DetailTile(
                  title: "Payment Method",
                  value: "UPI",
                ),
              ],
            ),
          ),

          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text("Edit Transaction"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline,color: Colors.red),
                SizedBox(width: 8),
                Text(
                  "Delete Transaction",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class DetailTile extends StatelessWidget {
  final String title;
  final String value;

  const DetailTile({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.calendar_month,
            size: 18,
            color: Colors.blue,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}