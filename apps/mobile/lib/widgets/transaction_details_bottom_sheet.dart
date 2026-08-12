// // import 'package:flutter/material.dart';
// // import '../model/transaction_model.dart';

// // void showTransactionDetailsBottomSheet(
// //     BuildContext context,
// //     TransactionModel transaction,
// // ) {
// //   showModalBottomSheet(
// //     context: context,
// //     isScrollControlled: true,
// //     backgroundColor: Colors.transparent,
// //     builder: (_) {
// //       return FractionallySizedBox(
// //         heightFactor: 0.82,
// //         child: TransactionDetailsBottomSheet(
// //           transaction: transaction,
// //         ),
// //       );
// //     },
// //   );
// // }

// // class TransactionDetailsBottomSheet extends StatelessWidget {
// //   final TransactionModel transaction;

// //   const TransactionDetailsBottomSheet({
// //     super.key,
// //     required this.transaction,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: const BoxDecoration(
// //         color: Color(0xffFDF8F2),
// //         borderRadius: BorderRadius.vertical(
// //           top: Radius.circular(30),
// //         ),
// //       ),
// //       child: Column(
// //         children: [
// //           const SizedBox(height: 12),

// //           Container(
// //             width: 60,
// //             height: 5,
// //             decoration: BoxDecoration(
// //               color: Colors.grey.shade400,
// //               borderRadius: BorderRadius.circular(20),
// //             ),
// //           ),

// //           const SizedBox(height: 20),

// //           CircleAvatar(
// //             radius: 28,
// //             backgroundColor: Color(0xffDDE7F7),
// //             child: Icon(
// //               Icons.currency_rupee,
// //               color: Color(0xff243B67),
// //             ),
// //           ),

// //           const SizedBox(height: 12),

// //           const Text(
// //             "Transaction Details",
// //             style: TextStyle(
// //               fontWeight: FontWeight.bold,
// //               fontSize: 18,
// //             ),
// //           ),

// //           const SizedBox(height: 8),

// //           Container(
// //             padding: const EdgeInsets.symmetric(
// //               horizontal: 12,
// //               vertical: 6,
// //             ),
// //             decoration: BoxDecoration(
// //               border: Border.all(
// //                 color: Colors.red,
// //               ),
// //               borderRadius: BorderRadius.circular(20),
// //             ),
// //             child: Text(
// //               transaction.given != null
// //                   ? "Loan Given"
// //                   : "Money Received",
// //               style: TextStyle(
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 25),

// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 24),
// //             child: Row(
// //               children: [
// //                 const Icon(Icons.calendar_today, size: 18),

// //                 const SizedBox(width: 8),

// //                 Text(transaction.date),

// //                 const Spacer(),

// //                 Text(
// //                   transaction.given ??
// //                       transaction.received ??
// //                       "₹0",
// //                   style: const TextStyle(
// //                     fontSize: 28,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xffD94A4A),
// //                   ),
// //                 )
// //               ],
// //             ),
// //           ),

// //           const SizedBox(height: 20),

// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 24),
// //             child: Text(
// //               "Description goes here...",
// //               style: TextStyle(
// //                 color: Colors.grey.shade700,
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 25),

// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 24),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: infoTile(
// //                     "Interest Rate",
// //                     "12%",
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: infoTile(
// //                     "Interest Type",
// //                     "Simple",
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           const SizedBox(height: 12),

// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 24),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: infoTile(
// //                     "Frequency",
// //                     "Monthly",
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: infoTile(
// //                     "Payment",
// //                     "UPI",
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           const Spacer(),

// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 24),
// //             child: SizedBox(
// //               width: double.infinity,
// //               height: 52,
// //               child: ElevatedButton.icon(
// //                 onPressed: () {},
// //                 icon: const Icon(Icons.edit),
// //                 label: const Text("Edit Transaction"),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xff243B67),
// //                 ),
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 14),

// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 24),
// //             child: SizedBox(
// //               width: double.infinity,
// //               height: 52,
// //               child: OutlinedButton.icon(
// //                 onPressed: () {},
// //                 icon: const Icon(
// //                   Icons.delete,
// //                   color: Colors.red,
// //                 ),
// //                 label: const Text(
// //                   "Delete Transaction",
// //                   style: TextStyle(color: Colors.red),
// //                 ),
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 24),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget infoTile(String title, String value) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Color(0xffFFF8F0),
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Column(
// //         children: [
// //           const Icon(Icons.calendar_today,
// //               color: Color(0xff243B67)),
// //           const SizedBox(height: 6),
// //           Text(
// //             title,
// //             style: const TextStyle(
// //               fontSize: 12,
// //               color: Colors.grey,
// //             ),
// //           ),
// //           Text(
// //             value,
// //             style: const TextStyle(
// //               fontWeight: FontWeight.bold,
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:mychopdi/utils/colors.dart';

// // class TransactionDetailsScreen extends StatelessWidget {
// //   const TransactionDetailsScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppColors.background,
// //       body: SafeArea(
// //         child: Stack(
// //           children: [

// //             const Positioned(
// //               left: 20,
// //               top: 10,
// //               child: Text(
// //                 "Transaction Details",
// //                 style: TextStyle(
// //                   color: Colors.white70,
// //                   fontWeight: FontWeight.w500,
// //                   fontSize: 18,
// //                 ),
// //               ),
// //             ),

// //             Align(
// //               alignment: Alignment.bottomCenter,
// //               child: Container(
// //                 height: MediaQuery.of(context).size.height * .90,
// //                 width: double.infinity,
// //                 decoration: const BoxDecoration(
// //                   color: AppColors.sheetColor,
// //                   borderRadius: BorderRadius.vertical(
// //                     top: Radius.circular(32),
// //                   ),
// //                 ),
// //                 child: const TransactionBody(),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class TransactionBody extends StatelessWidget {
// //   const TransactionBody({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 22),
// //       child: Column(
// //         children: [

// //           const SizedBox(height: 10),

// //           Container(
// //             width: 55,
// //             height: 5,
// //             decoration: BoxDecoration(
// //               color: Colors.grey.shade500,
// //               borderRadius: BorderRadius.circular(50),
// //             ),
// //           ),

// //           const SizedBox(height: 20),

// //           CircleAvatar(
// //             radius: 28,
// //             backgroundColor: AppColors.lightBlue,
// //             child: Icon(
// //               Icons.currency_rupee,
// //               color: AppColors.primary,
// //               size: 30,
// //             ),
// //           ),

// //           const SizedBox(height: 14),

// //           const Text(
// //             "Transaction Details",
// //             style: TextStyle(
// //               fontWeight: FontWeight.w700,
// //               fontSize: 17,
// //             ),
// //           ),

// //           const SizedBox(height: 12),

// //           Container(
// //             padding: const EdgeInsets.symmetric(
// //               horizontal: 12,
// //               vertical: 5,
// //             ),
// //             decoration: BoxDecoration(
// //               color: AppColors.chipBg,
// //               borderRadius: BorderRadius.circular(25),
// //               border: Border.all(
// //                 color: AppColors.chipBorder,
// //               ),
// //             ),
// //             child: const Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(
// //                   Icons.arrow_upward,
// //                   size: 15,
// //                   color: Colors.red,
// //                 ),
// //                 SizedBox(width: 5),
// //                 Text(
// //                   "Loan Given",
// //                   style: TextStyle(
// //                     color: Colors.red,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           const SizedBox(height: 22),

// //           Row(
// //             children: [

// //               const Icon(Icons.calendar_month,
// //                   color: Colors.blue),

// //               const SizedBox(width: 6),

// //               const Text(
// //                 "10 May 2026",
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),

// //               const Spacer(),

// //               Text(
// //                 "₹15,000",
// //                 style: TextStyle(
// //                   color: AppColors.amountRed,
// //                   fontSize: 32,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               )
// //             ],
// //           ),

// //           const SizedBox(height: 18),

// //           const Align(
// //             alignment: Alignment.centerLeft,
// //             child: Text(
// //               "Descriptiondwqwerthcsbsjbsdcjbdcdjcjcjdbbdjbjdjdjdjdjdjhsc",
// //               style: TextStyle(
// //                 color: Colors.grey,
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 22),

// //           const Divider(),

// //           const SizedBox(height: 10),

// //           Expanded(
// //             child: GridView.count(
// //               physics: NeverScrollableScrollPhysics(),
// //               crossAxisCount: 2,
// //               childAspectRatio: 2.8,
// //               crossAxisSpacing: 20,
// //               mainAxisSpacing: 12,
// //               children: const [

// //                 DetailTile(
// //                   title: "Interest Rate",
// //                   value: "12%",
// //                 ),

// //                 DetailTile(
// //                   title: "Interest Type",
// //                   value: "Simple Interest",
// //                 ),

// //                 DetailTile(
// //                   title: "Interest Frequency",
// //                   value: "Monthly",
// //                 ),

// //                 DetailTile(
// //                   title: "Payment Method",
// //                   value: "UPI",
// //                 ),
// //               ],
// //             ),
// //           ),

// //           FilledButton(
// //             style: FilledButton.styleFrom(
// //               backgroundColor: AppColors.primary,
// //               minimumSize: const Size(double.infinity, 54),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //             ),
// //             onPressed: () {},
// //             child: const Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.edit),
// //                 SizedBox(width: 8),
// //                 Text("Edit Transaction"),
// //               ],
// //             ),
// //           ),

// //           const SizedBox(height: 16),

// //           OutlinedButton(
// //             style: OutlinedButton.styleFrom(
// //               minimumSize: const Size(double.infinity, 54),
// //               side: const BorderSide(color: Colors.red),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //             ),
// //             onPressed: () {},
// //             child: const Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.delete_outline,color: Colors.red),
// //                 SizedBox(width: 8),
// //                 Text(
// //                   "Delete Transaction",
// //                   style: TextStyle(color: Colors.red),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           const SizedBox(height: 20),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class DetailTile extends StatelessWidget {
// //   final String title;
// //   final String value;

// //   const DetailTile({
// //     super.key,
// //     required this.title,
// //     required this.value,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [

// //         Container(
// //           padding: const EdgeInsets.all(7),
// //           decoration: BoxDecoration(
// //             color: AppColors.lightBlue,
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: const Icon(
// //             Icons.calendar_month,
// //             size: 18,
// //             color: Colors.blue,
// //           ),
// //         ),

// //         const SizedBox(width: 10),

// //         Expanded(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [

// //               Text(
// //                 title,
// //                 style: TextStyle(
// //                   fontSize: 12,
// //                   color: Colors.grey.shade600,
// //                 ),
// //               ),

// //               const SizedBox(height: 3),

// //               Text(
// //                 value,
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         )
// //       ],
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mychopdi/model/transaction.dart';
// import 'package:mychopdi/service/isar_service.dart';
// import 'package:mychopdi/utils/colors.dart';
// import 'package:mychopdi/widgets/edit_transaction_details.dart';

// class TransactionDetailsScreen extends StatelessWidget {
//   final Transaction transaction;
//   final VoidCallback? onChanged;

//   const TransactionDetailsScreen({
//     super.key,
//     required this.transaction,
//     this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             const Positioned(
//               left: 20,
//               top: 10,
//               child: Text(
//                 "Transaction Details",
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontWeight: FontWeight.w500,
//                   fontSize: 18,
//                 ),
//               ),
//             ),

//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 height: MediaQuery.of(context).size.height * .90,
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: AppColors.sheetColor,
//                   borderRadius: BorderRadius.vertical(
//                     top: Radius.circular(32),
//                   ),
//                 ),
//                 child: TransactionBody(
//                   transaction: transaction,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class TransactionBody extends StatelessWidget {
//   final Transaction transaction;
//   final VoidCallback? onChanged;

//   const TransactionBody({
//     super.key,
//     required this.transaction,
//     this.onChanged,
//   });

//   bool get isGiven => transaction.type == TransactionType.gave;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 22),
//       child: Column(
//         children: [
//           const SizedBox(height: 10),

//           Container(
//             width: 55,
//             height: 5,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade500,
//               borderRadius: BorderRadius.circular(50),
//             ),
//           ),

//           const SizedBox(height: 20),

//           CircleAvatar(
//             radius: 28,
//             backgroundColor: AppColors.lightBlue,
//             child: Icon(
//               Icons.currency_rupee,
//               color: isGiven ? Colors.red : Colors.green,
//               size: 30,
//             ),
//           ),

//           const SizedBox(height: 14),

//           const Text(
//             "Transaction Details",
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               fontSize: 17,
//             ),
//           ),

//           const SizedBox(height: 12),

//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 5,
//             ),
//             decoration: BoxDecoration(
//               color: AppColors.chipBg,
//               borderRadius: BorderRadius.circular(25),
//               border: Border.all(
//                 color: AppColors.chipBorder,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   isGiven
//                       ? Icons.arrow_upward
//                       : Icons.arrow_downward,
//                   size: 15,
//                   color: isGiven ? Colors.red : Colors.green,
//                 ),
//                 const SizedBox(width: 5),
//                 Text(
//                   isGiven
//                       ? "Loan Given"
//                       : "Payment Received",
//                   style: TextStyle(
//                     color: isGiven
//                         ? Colors.red
//                         : Colors.green,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 22),

//           Row(
//             children: [
//               const Icon(
//                 Icons.calendar_month,
//                 color: Colors.blue,
//               ),

//               const SizedBox(width: 6),

//               Text(
//                 DateFormat("dd MMM yyyy")
//                     .format(transaction.date),
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),

//               const Spacer(),

//               Text(
//                 "₹${transaction.amount.toStringAsFixed(0)}",
//                 style: TextStyle(
//                   color: isGiven
//                       ? AppColors.amountRed
//                       : Colors.green,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 18),

//           Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               transaction.description.isEmpty
//                   ? "No description added"
//                   : transaction.description,
//               style: const TextStyle(
//                 color: Colors.grey,
//               ),
//             ),
//           ),

//           const SizedBox(height: 22),

//           const Divider(),

//           const SizedBox(height: 12),

//           // Remaining Detail Tiles + Edit/Delete
//           // will be added in Part 2.

//           Expanded(
//             child: GridView.count(
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisCount: 2,
//               childAspectRatio: 2.8,
//               crossAxisSpacing: 20,
//               mainAxisSpacing: 12,
//               children: [

//                 DetailTile(
//                   icon: Icons.percent,
//                   title: "Interest Rate",
//                   value: "${transaction.interestRate} %",
//                 ),

//                 DetailTile(
//                   icon: Icons.account_balance,
//                   title: "Interest Type",
//                   value: transaction.interestType,
//                 ),

//                 DetailTile(
//                   icon: Icons.schedule,
//                   title: "Interest Frequency",
//                   value: transaction.interestFrequency,
//                 ),

//                 DetailTile(
//                   icon: Icons.payments_outlined,
//                   title: "Payment Mode",
//                   value: transaction.paymentMode.isEmpty
//                       ? "-"
//                       : transaction.paymentMode,
//                 ),
//               ],
//             ),
//           ),

//           FilledButton(
//             style: FilledButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               minimumSize: const Size(double.infinity, 54),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () {

//               /// We'll open Edit BottomSheet in Part 3
//               Navigator.pop(context);
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 builder: (_) {
//                   return EditTransactionDetailsBottomSheet(
//                     transaction: transaction,
//                     isEdit: true,
//                   );
//                 },
//               );
//             },
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [

//                 Icon(Icons.edit),

//                 SizedBox(width: 8),

//                 Text("Edit Transaction"),

//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           OutlinedButton(
//             style: OutlinedButton.styleFrom(
//               minimumSize: const Size(double.infinity, 54),
//               side: const BorderSide(
//                 color: Colors.red,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () async {

//               /// Delete code in Part 3
//               final delete = await showDialog<bool>(
//                 context: context,
//                 builder: (_) {
//                   return AlertDialog(
//                     title: const Text("Delete Transaction"),
//                     content: const Text(
//                       "Are you sure you want to delete this transaction?",
//                     ),
//                     actions: [

//                       TextButton(
//                         onPressed: (){
//                           Navigator.pop(context,false);
//                         },
//                         child: const Text("Cancel"),
//                       ),

//                       ElevatedButton(
//                         onPressed: (){
//                           Navigator.pop(context,true);
//                         },
//                         child: const Text("Delete"),
//                       )

//                     ],
//                   );
//                 },
//               );

//               if(delete != true) return;

//               await IsarService.isar.writeTxn(() async {

//                 await IsarService.isar.transactions.delete(
//                   transaction.id,
//                 );

//               });

//               Navigator.pop(context);

//               onChanged?.call();

//             },
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [

//                 Icon(
//                   Icons.delete_outline,
//                   color: Colors.red,
//                 ),

//                 SizedBox(width: 8),

//                 Text(
//                   "Delete Transaction",
//                   style: TextStyle(
//                     color: Colors.red,
//                   ),
//                 ),

//               ],
//             ),
//           ),

//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }

// class DetailTile extends StatelessWidget {

//   final IconData icon;
//   final String title;
//   final String value;

//   const DetailTile({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [

//         Container(
//           padding: const EdgeInsets.all(7),
//           decoration: BoxDecoration(
//             color: AppColors.lightBlue,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             size: 18,
//             color: Colors.blue,
//           ),
//         ),

//         const SizedBox(width: 10),

//         Expanded(
//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [

//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                 ),
//               ),

//               const SizedBox(height: 3),

//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),

//             ],
//           ),
//         ),

//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/transaction_service.dart';
import 'package:mychopdi/widgets/delete_transaction_bottom_sheet.dart';
import 'package:mychopdi/widgets/loan_gave_edit_transactions.dart';
import 'package:mychopdi/widgets/loan_received_edit_transactions.dart';
import 'package:mychopdi/widgets/money_gave_bottom_sheet.dart';
import 'package:mychopdi/widgets/money_received_bottom_sheet.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onChanged;
  final Customer customer;

  TransactionDetailsScreen({
    super.key,
    required this.transaction,
    this.onChanged,
    required this.customer,
  });

  // Future<void> _showDeleteDialog(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     builder: (_) {
  //       return AlertDialog(
  //         backgroundColor: const Color(0xffFDF8F2),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: const Text(
  //           "Delete Transaction",
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         content: const Text(
  //           "Are you sure you want to delete this transaction?",
  //         ),
  //         actions: [

  //           OutlinedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text("Cancel"),
  //           ),

  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red,
  //             ),
  //             onPressed: () async {

  //               Navigator.pop(context);

  //               await _deleteTransaction(context);
  //             },
  //             child: const Text(
  //               "Delete",
  //               style: TextStyle(color: Colors.white),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Future<void> _deleteTransaction(BuildContext context) async {

  //   await IsarService.isar.writeTxn(() async {

  //     await IsarService.isar.transactions.delete(
  //       transaction.id,
  //     );

  //   });

  //   onChanged?.call();

  //   if (context.mounted) {
  //     Navigator.pop(context);
  //   }
  // }

  TransactionService transactionService = TransactionService();

  @override
  Widget build(BuildContext context) {
    final isLoan = transaction.type == TransactionType.gave;

    const primaryColor = Color(0xFF233B63);

    final amountColor =
        isLoan ? const Color(0xFFC74C4C) : const Color(0xFF00901B);

    final badgeColor =
        isLoan ? const Color(0xFFFFEBEB) : const Color(0xFFE9F8ED);

    final badgeBorder =
        isLoan ? const Color(0xFFE57373) : const Color(0xFF4CAF50);

    final badgeText = isLoan
        ? "Loan Given"
        : "Payment Received";

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .88,
        minChildSize: .65,
        maxChildSize: .95,
        builder: (_, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xffFDF8F2),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 30),
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 18),

                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xffD7E3F4),
                    child: Icon(
                      Icons.currency_rupee,
                      color: primaryColor,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Transaction Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      border: Border.all(color: badgeBorder),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLoan
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: amountColor,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          badgeText,
                          style: TextStyle(
                            color: amountColor,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Icon(
                        Icons.calendar_month_outlined,
                        size: 20,
                        color: primaryColor,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        DateFormat("dd MMM yyyy").format(transaction.date),
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        "₹${transaction.amount.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      transaction.description.isEmpty
                          ? "No Description"
                          : transaction.description,
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Divider(),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.3,
                    children: [

                      _infoCard(
                        "Interest Rate",
                        "${transaction.interestRate}%",
                      ),

                      _infoCard(
                        "Interest Type",
                        transaction.interestType,
                      ),

                      _infoCard(
                        "Interest Frequency",
                        transaction.interestFrequency,
                      ),

                      _infoCard(
                        "Payment Method",
                        transaction.paymentMode,
                      ),

                    ],
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Transaction"),
                      onPressed: () async{

                          final parentContext = context;

                          Navigator.pop(context);

                          await Future.delayed(
                            const Duration(milliseconds: 250),
                          );

                          if (!parentContext.mounted) return;

                          showModalBottomSheet(
                            context: parentContext,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) {
                              if (transaction.type == TransactionType.gave) {
                                return FractionallySizedBox(
                                  heightFactor: .82,
                                  child: LoanGaveEditTransactions(
                                    customer: customer,
                                    isEdit: true,
                                    transaction: transaction,
                                    onSaved:() async{
                                      await IsarService.isar.writeTxn(() async {
                                        await IsarService.isar.transactions.delete(transaction.id);
                                      });

                                      onChanged?.call();

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                );
                              }

                              return FractionallySizedBox(
                                heightFactor: .82,
                                child: LoanReceivedEditTransactions(
                                  customer: customer, 
                                  onSaved: () async{
                                    await IsarService.isar.writeTxn(() async {
                                        await IsarService.isar.transactions.delete(transaction.id);
                                      });

                                      onChanged?.call();

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                  }
                                ),
                              );
                            },
                          );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      label: const Text(
                        "Delete Transaction",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        //   showDeleteTransactionBottomSheet(
                        //   context,
                        //   title: "Delete Transaction?",
                        //   subtitle: "This action cannot be undone",
                        //   onDelete: () async {
                        //     // Delete logic
                        //   },
                        // );
                        Navigator.pop(context);
                        showDeleteTransactionBottomSheet(
                          context,
                          title: "Delete Transaction?",
                          subtitle: "This action cannot be undone",
                          onDelete: () async {
                            await transactionService.deleteTransaction(
                              transactionId: transaction.id,
                              customerId: customer.id,
                            );

                            if (context.mounted) {
                              Navigator.pop(context); // Close bottom sheet
                            }

                            if (context.mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  content: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 60,
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        "Transaction Deleted",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Transaction deleted successfully.",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              Future.delayed(const Duration(seconds: 2), () {
                                if (context.mounted) {
                                  Navigator.pop(context); // Close dialog
                                }
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffD8E2F0),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF4A6FA5),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  } 
}             