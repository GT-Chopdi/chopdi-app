// // // import 'package:flutter/material.dart';
// // // import '../model/transaction_model.dart';

// // // void showTransactionDetailsBottomSheet(
// // //     BuildContext context,
// // //     TransactionModel transaction,
// // // ) {
// // //   showModalBottomSheet(
// // //     context: context,
// // //     isScrollControlled: true,
// // //     backgroundColor: Colors.transparent,
// // //     builder: (_) {
// // //       return FractionallySizedBox(
// // //         heightFactor: 0.82,
// // //         child: TransactionDetailsBottomSheet(
// // //           transaction: transaction,
// // //         ),
// // //       );
// // //     },
// // //   );
// // // }

// // // class TransactionDetailsBottomSheet extends StatelessWidget {
// // //   final TransactionModel transaction;

// // //   const TransactionDetailsBottomSheet({
// // //     super.key,
// // //     required this.transaction,
// // //   });

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       decoration: const BoxDecoration(
// // //         color: Color(0xffFDF8F2),
// // //         borderRadius: BorderRadius.vertical(
// // //           top: Radius.circular(30),
// // //         ),
// // //       ),
// // //       child: Column(
// // //         children: [
// // //           const SizedBox(height: 12),

// // //           Container(
// // //             width: 60,
// // //             height: 5,
// // //             decoration: BoxDecoration(
// // //               color: Colors.grey.shade400,
// // //               borderRadius: BorderRadius.circular(20),
// // //             ),
// // //           ),

// // //           const SizedBox(height: 20),

// // //           CircleAvatar(
// // //             radius: 28,
// // //             backgroundColor: Color(0xffDDE7F7),
// // //             child: Icon(
// // //               Icons.currency_rupee,
// // //               color: Color(0xff243B67),
// // //             ),
// // //           ),

// // //           const SizedBox(height: 12),

// // //           const Text(
// // //             "Transaction Details",
// // //             style: TextStyle(
// // //               fontWeight: FontWeight.bold,
// // //               fontSize: 18,
// // //             ),
// // //           ),

// // //           const SizedBox(height: 8),

// // //           Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               horizontal: 12,
// // //               vertical: 6,
// // //             ),
// // //             decoration: BoxDecoration(
// // //               border: Border.all(
// // //                 color: Colors.red,
// // //               ),
// // //               borderRadius: BorderRadius.circular(20),
// // //             ),
// // //             child: Text(
// // //               transaction.given != null
// // //                   ? "Loan Given"
// // //                   : "Money Received",
// // //               style: TextStyle(
// // //                 color: Colors.red,
// // //                 fontWeight: FontWeight.w600,
// // //               ),
// // //             ),
// // //           ),

// // //           const SizedBox(height: 25),

// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 24),
// // //             child: Row(
// // //               children: [
// // //                 const Icon(Icons.calendar_today, size: 18),

// // //                 const SizedBox(width: 8),

// // //                 Text(transaction.date),

// // //                 const Spacer(),

// // //                 Text(
// // //                   transaction.given ??
// // //                       transaction.received ??
// // //                       "₹0",
// // //                   style: const TextStyle(
// // //                     fontSize: 28,
// // //                     fontWeight: FontWeight.bold,
// // //                     color: Color(0xffD94A4A),
// // //                   ),
// // //                 )
// // //               ],
// // //             ),
// // //           ),

// // //           const SizedBox(height: 20),

// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 24),
// // //             child: Text(
// // //               "Description goes here...",
// // //               style: TextStyle(
// // //                 color: Colors.grey.shade700,
// // //               ),
// // //             ),
// // //           ),

// // //           const SizedBox(height: 25),

// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 24),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: infoTile(
// // //                     "Interest Rate",
// // //                     "12%",
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 12),
// // //                 Expanded(
// // //                   child: infoTile(
// // //                     "Interest Type",
// // //                     "Simple",
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),

// // //           const SizedBox(height: 12),

// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 24),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: infoTile(
// // //                     "Frequency",
// // //                     "Monthly",
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 12),
// // //                 Expanded(
// // //                   child: infoTile(
// // //                     "Payment",
// // //                     "UPI",
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),

// // //           const Spacer(),

// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 24),
// // //             child: SizedBox(
// // //               width: double.infinity,
// // //               height: 52,
// // //               child: ElevatedButton.icon(
// // //                 onPressed: () {},
// // //                 icon: const Icon(Icons.edit),
// // //                 label: const Text("Edit Transaction"),
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: const Color(0xff243B67),
// // //                 ),
// // //               ),
// // //             ),
// // //           ),

// // //           const SizedBox(height: 14),

// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 24),
// // //             child: SizedBox(
// // //               width: double.infinity,
// // //               height: 52,
// // //               child: OutlinedButton.icon(
// // //                 onPressed: () {},
// // //                 icon: const Icon(
// // //                   Icons.delete,
// // //                   color: Colors.red,
// // //                 ),
// // //                 label: const Text(
// // //                   "Delete Transaction",
// // //                   style: TextStyle(color: Colors.red),
// // //                 ),
// // //               ),
// // //             ),
// // //           ),

// // //           const SizedBox(height: 24),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget infoTile(String title, String value) {
// // //     return Container(
// // //       padding: const EdgeInsets.all(12),
// // //       decoration: BoxDecoration(
// // //         color: Color(0xffFFF8F0),
// // //         borderRadius: BorderRadius.circular(12),
// // //       ),
// // //       child: Column(
// // //         children: [
// // //           const Icon(Icons.calendar_today,
// // //               color: Color(0xff243B67)),
// // //           const SizedBox(height: 6),
// // //           Text(
// // //             title,
// // //             style: const TextStyle(
// // //               fontSize: 12,
// // //               color: Colors.grey,
// // //             ),
// // //           ),
// // //           Text(
// // //             value,
// // //             style: const TextStyle(
// // //               fontWeight: FontWeight.bold,
// // //             ),
// // //           )
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // import 'package:flutter/material.dart';
// // // import 'package:mychopdi/utils/colors.dart';

// // // class TransactionDetailsScreen extends StatelessWidget {
// // //   const TransactionDetailsScreen({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: AppColors.background,
// // //       body: SafeArea(
// // //         child: Stack(
// // //           children: [

// // //             const Positioned(
// // //               left: 20,
// // //               top: 10,
// // //               child: Text(
// // //                 "Transaction Details",
// // //                 style: TextStyle(
// // //                   color: Colors.white70,
// // //                   fontWeight: FontWeight.w500,
// // //                   fontSize: 18,
// // //                 ),
// // //               ),
// // //             ),

// // //             Align(
// // //               alignment: Alignment.bottomCenter,
// // //               child: Container(
// // //                 height: MediaQuery.of(context).size.height * .90,
// // //                 width: double.infinity,
// // //                 decoration: const BoxDecoration(
// // //                   color: AppColors.sheetColor,
// // //                   borderRadius: BorderRadius.vertical(
// // //                     top: Radius.circular(32),
// // //                   ),
// // //                 ),
// // //                 child: const TransactionBody(),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class TransactionBody extends StatelessWidget {
// // //   const TransactionBody({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 22),
// // //       child: Column(
// // //         children: [

// // //           const SizedBox(height: 10),

// // //           Container(
// // //             width: 55,
// // //             height: 5,
// // //             decoration: BoxDecoration(
// // //               color: Colors.grey.shade500,
// // //               borderRadius: BorderRadius.circular(50),
// // //             ),
// // //           ),

// // //           const SizedBox(height: 20),

// // //           CircleAvatar(
// // //             radius: 28,
// // //             backgroundColor: AppColors.lightBlue,
// // //             child: Icon(
// // //               Icons.currency_rupee,
// // //               color: AppColors.primary,
// // //               size: 30,
// // //             ),
// // //           ),

// // //           const SizedBox(height: 14),

// // //           const Text(
// // //             "Transaction Details",
// // //             style: TextStyle(
// // //               fontWeight: FontWeight.w700,
// // //               fontSize: 17,
// // //             ),
// // //           ),

// // //           const SizedBox(height: 12),

// // //           Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               horizontal: 12,
// // //               vertical: 5,
// // //             ),
// // //             decoration: BoxDecoration(
// // //               color: AppColors.chipBg,
// // //               borderRadius: BorderRadius.circular(25),
// // //               border: Border.all(
// // //                 color: AppColors.chipBorder,
// // //               ),
// // //             ),
// // //             child: const Row(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 Icon(
// // //                   Icons.arrow_upward,
// // //                   size: 15,
// // //                   color: Colors.red,
// // //                 ),
// // //                 SizedBox(width: 5),
// // //                 Text(
// // //                   "Loan Given",
// // //                   style: TextStyle(
// // //                     color: Colors.red,
// // //                     fontWeight: FontWeight.w600,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),

// // //           const SizedBox(height: 22),

// // //           Row(
// // //             children: [

// // //               const Icon(Icons.calendar_month,
// // //                   color: Colors.blue),

// // //               const SizedBox(width: 6),

// // //               const Text(
// // //                 "10 May 2026",
// // //                 style: TextStyle(
// // //                   fontWeight: FontWeight.w500,
// // //                 ),
// // //               ),

// // //               const Spacer(),

// // //               Text(
// // //                 "₹15,000",
// // //                 style: TextStyle(
// // //                   color: AppColors.amountRed,
// // //                   fontSize: 32,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               )
// // //             ],
// // //           ),

// // //           const SizedBox(height: 18),

// // //           const Align(
// // //             alignment: Alignment.centerLeft,
// // //             child: Text(
// // //               "Descriptiondwqwerthcsbsjbsdcjbdcdjcjcjdbbdjbjdjdjdjdjdjhsc",
// // //               style: TextStyle(
// // //                 color: Colors.grey,
// // //               ),
// // //             ),
// // //           ),

// // //           const SizedBox(height: 22),

// // //           const Divider(),

// // //           const SizedBox(height: 10),

// // //           Expanded(
// // //             child: GridView.count(
// // //               physics: NeverScrollableScrollPhysics(),
// // //               crossAxisCount: 2,
// // //               childAspectRatio: 2.8,
// // //               crossAxisSpacing: 20,
// // //               mainAxisSpacing: 12,
// // //               children: const [

// // //                 DetailTile(
// // //                   title: "Interest Rate",
// // //                   value: "12%",
// // //                 ),

// // //                 DetailTile(
// // //                   title: "Interest Type",
// // //                   value: "Simple Interest",
// // //                 ),

// // //                 DetailTile(
// // //                   title: "Interest Frequency",
// // //                   value: "Monthly",
// // //                 ),

// // //                 DetailTile(
// // //                   title: "Payment Method",
// // //                   value: "UPI",
// // //                 ),
// // //               ],
// // //             ),
// // //           ),

// // //           FilledButton(
// // //             style: FilledButton.styleFrom(
// // //               backgroundColor: AppColors.primary,
// // //               minimumSize: const Size(double.infinity, 54),
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.circular(10),
// // //               ),
// // //             ),
// // //             onPressed: () {},
// // //             child: const Row(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 Icon(Icons.edit),
// // //                 SizedBox(width: 8),
// // //                 Text("Edit Transaction"),
// // //               ],
// // //             ),
// // //           ),

// // //           const SizedBox(height: 16),

// // //           OutlinedButton(
// // //             style: OutlinedButton.styleFrom(
// // //               minimumSize: const Size(double.infinity, 54),
// // //               side: const BorderSide(color: Colors.red),
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.circular(10),
// // //               ),
// // //             ),
// // //             onPressed: () {},
// // //             child: const Row(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 Icon(Icons.delete_outline,color: Colors.red),
// // //                 SizedBox(width: 8),
// // //                 Text(
// // //                   "Delete Transaction",
// // //                   style: TextStyle(color: Colors.red),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),

// // //           const SizedBox(height: 20),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // class DetailTile extends StatelessWidget {
// // //   final String title;
// // //   final String value;

// // //   const DetailTile({
// // //     super.key,
// // //     required this.title,
// // //     required this.value,
// // //   });

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Row(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [

// // //         Container(
// // //           padding: const EdgeInsets.all(7),
// // //           decoration: BoxDecoration(
// // //             color: AppColors.lightBlue,
// // //             borderRadius: BorderRadius.circular(8),
// // //           ),
// // //           child: const Icon(
// // //             Icons.calendar_month,
// // //             size: 18,
// // //             color: Colors.blue,
// // //           ),
// // //         ),

// // //         const SizedBox(width: 10),

// // //         Expanded(
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [

// // //               Text(
// // //                 title,
// // //                 style: TextStyle(
// // //                   fontSize: 12,
// // //                   color: Colors.grey.shade600,
// // //                 ),
// // //               ),

// // //               const SizedBox(height: 3),

// // //               Text(
// // //                 value,
// // //                 style: const TextStyle(
// // //                   fontWeight: FontWeight.w700,
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         )
// // //       ],
// // //     );
// // //   }
// // // }


// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:mychopdi/model/transaction.dart';
// // import 'package:mychopdi/service/isar_service.dart';
// // import 'package:mychopdi/utils/colors.dart';
// // import 'package:mychopdi/widgets/edit_transaction_details.dart';

// // class TransactionDetailsScreen extends StatelessWidget {
// //   final Transaction transaction;
// //   final VoidCallback? onChanged;

// //   const TransactionDetailsScreen({
// //     super.key,
// //     required this.transaction,
// //     this.onChanged,
// //   });

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
// //                 child: TransactionBody(
// //                   transaction: transaction,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class TransactionBody extends StatelessWidget {
// //   final Transaction transaction;
// //   final VoidCallback? onChanged;

// //   const TransactionBody({
// //     super.key,
// //     required this.transaction,
// //     this.onChanged,
// //   });

// //   bool get isGiven => transaction.type == TransactionType.gave;

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
// //               color: isGiven ? Colors.red : Colors.green,
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
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(
// //                   isGiven
// //                       ? Icons.arrow_upward
// //                       : Icons.arrow_downward,
// //                   size: 15,
// //                   color: isGiven ? Colors.red : Colors.green,
// //                 ),
// //                 const SizedBox(width: 5),
// //                 Text(
// //                   isGiven
// //                       ? "Loan Given"
// //                       : "Payment Received",
// //                   style: TextStyle(
// //                     color: isGiven
// //                         ? Colors.red
// //                         : Colors.green,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           const SizedBox(height: 22),

// //           Row(
// //             children: [
// //               const Icon(
// //                 Icons.calendar_month,
// //                 color: Colors.blue,
// //               ),

// //               const SizedBox(width: 6),

// //               Text(
// //                 DateFormat("dd MMM yyyy")
// //                     .format(transaction.date),
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),

// //               const Spacer(),

// //               Text(
// //                 "₹${transaction.amount.toStringAsFixed(0)}",
// //                 style: TextStyle(
// //                   color: isGiven
// //                       ? AppColors.amountRed
// //                       : Colors.green,
// //                   fontSize: 32,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),

// //           const SizedBox(height: 18),

// //           Align(
// //             alignment: Alignment.centerLeft,
// //             child: Text(
// //               transaction.description.isEmpty
// //                   ? "No description added"
// //                   : transaction.description,
// //               style: const TextStyle(
// //                 color: Colors.grey,
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 22),

// //           const Divider(),

// //           const SizedBox(height: 12),

// //           // Remaining Detail Tiles + Edit/Delete
// //           // will be added in Part 2.

// //           Expanded(
// //             child: GridView.count(
// //               physics: const NeverScrollableScrollPhysics(),
// //               crossAxisCount: 2,
// //               childAspectRatio: 2.8,
// //               crossAxisSpacing: 20,
// //               mainAxisSpacing: 12,
// //               children: [

// //                 DetailTile(
// //                   icon: Icons.percent,
// //                   title: "Interest Rate",
// //                   value: "${transaction.interestRate} %",
// //                 ),

// //                 DetailTile(
// //                   icon: Icons.account_balance,
// //                   title: "Interest Type",
// //                   value: transaction.interestType,
// //                 ),

// //                 DetailTile(
// //                   icon: Icons.schedule,
// //                   title: "Interest Frequency",
// //                   value: transaction.interestFrequency,
// //                 ),

// //                 DetailTile(
// //                   icon: Icons.payments_outlined,
// //                   title: "Payment Mode",
// //                   value: transaction.paymentMode.isEmpty
// //                       ? "-"
// //                       : transaction.paymentMode,
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
// //             onPressed: () {

// //               /// We'll open Edit BottomSheet in Part 3
// //               Navigator.pop(context);
// //               showModalBottomSheet(
// //                 context: context,
// //                 isScrollControlled: true,
// //                 backgroundColor: Colors.transparent,
// //                 builder: (_) {
// //                   return EditTransactionDetailsBottomSheet(
// //                     transaction: transaction,
// //                     isEdit: true,
// //                   );
// //                 },
// //               );
// //             },
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
// //               side: const BorderSide(
// //                 color: Colors.red,
// //               ),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //             ),
// //             onPressed: () async {

// //               /// Delete code in Part 3
// //               final delete = await showDialog<bool>(
// //                 context: context,
// //                 builder: (_) {
// //                   return AlertDialog(
// //                     title: const Text("Delete Transaction"),
// //                     content: const Text(
// //                       "Are you sure you want to delete this transaction?",
// //                     ),
// //                     actions: [

// //                       TextButton(
// //                         onPressed: (){
// //                           Navigator.pop(context,false);
// //                         },
// //                         child: const Text("Cancel"),
// //                       ),

// //                       ElevatedButton(
// //                         onPressed: (){
// //                           Navigator.pop(context,true);
// //                         },
// //                         child: const Text("Delete"),
// //                       )

// //                     ],
// //                   );
// //                 },
// //               );

// //               if(delete != true) return;

// //               await IsarService.isar.writeTxn(() async {

// //                 await IsarService.isar.transactions.delete(
// //                   transaction.id,
// //                 );

// //               });

// //               Navigator.pop(context);

// //               onChanged?.call();

// //             },
// //             child: const Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [

// //                 Icon(
// //                   Icons.delete_outline,
// //                   color: Colors.red,
// //                 ),

// //                 SizedBox(width: 8),

// //                 Text(
// //                   "Delete Transaction",
// //                   style: TextStyle(
// //                     color: Colors.red,
// //                   ),
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

// //   final IconData icon;
// //   final String title;
// //   final String value;

// //   const DetailTile({
// //     super.key,
// //     required this.icon,
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
// //           child: Icon(
// //             icon,
// //             size: 18,
// //             color: Colors.blue,
// //           ),
// //         ),

// //         const SizedBox(width: 10),

// //         Expanded(
// //           child: Column(
// //             crossAxisAlignment:
// //                 CrossAxisAlignment.start,
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
// //         ),

// //       ],
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mychopdi/model/customer.dart';
// import 'package:mychopdi/model/transaction.dart';
// import 'package:mychopdi/service/isar_service.dart';
// import 'package:mychopdi/service/transaction_service.dart';
// import 'package:mychopdi/widgets/delete_transaction_bottom_sheet.dart';
// import 'package:mychopdi/widgets/loan_gave_edit_transactions.dart';
// import 'package:mychopdi/widgets/loan_received_edit_transactions.dart';
// import 'package:mychopdi/widgets/money_gave_bottom_sheet.dart';
// import 'package:mychopdi/widgets/money_received_bottom_sheet.dart';

// class TransactionDetailsScreen extends StatelessWidget {
//   final Transaction transaction;
//   final VoidCallback? onChanged;
//   final Customer customer;

//   TransactionDetailsScreen({
//     super.key,
//     required this.transaction,
//     this.onChanged,
//     required this.customer,
//   });

//   // Future<void> _showDeleteDialog(BuildContext context) async {
//   //   showDialog(
//   //     context: context,
//   //     builder: (_) {
//   //       return AlertDialog(
//   //         backgroundColor: const Color(0xffFDF8F2),
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(20),
//   //         ),
//   //         title: const Text(
//   //           "Delete Transaction",
//   //           style: TextStyle(
//   //             fontWeight: FontWeight.bold,
//   //           ),
//   //         ),
//   //         content: const Text(
//   //           "Are you sure you want to delete this transaction?",
//   //         ),
//   //         actions: [

//   //           OutlinedButton(
//   //             onPressed: () {
//   //               Navigator.pop(context);
//   //             },
//   //             child: const Text("Cancel"),
//   //           ),

//   //           ElevatedButton(
//   //             style: ElevatedButton.styleFrom(
//   //               backgroundColor: Colors.red,
//   //             ),
//   //             onPressed: () async {

//   //               Navigator.pop(context);

//   //               await _deleteTransaction(context);
//   //             },
//   //             child: const Text(
//   //               "Delete",
//   //               style: TextStyle(color: Colors.white),
//   //             ),
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }

//   // Future<void> _deleteTransaction(BuildContext context) async {

//   //   await IsarService.isar.writeTxn(() async {

//   //     await IsarService.isar.transactions.delete(
//   //       transaction.id,
//   //     );

//   //   });

//   //   onChanged?.call();

//   //   if (context.mounted) {
//   //     Navigator.pop(context);
//   //   }
//   // }

//   TransactionService transactionService = TransactionService();

//   @override
//   Widget build(BuildContext context) {
//     final isLoan = transaction.type == TransactionType.gave;

//     const primaryColor = Color(0xFF233B63);

//     final amountColor =
//         isLoan ? const Color(0xFFC74C4C) : const Color(0xFF00901B);

//     final badgeColor =
//         isLoan ? const Color(0xFFFFEBEB) : const Color(0xFFE9F8ED);

//     final badgeBorder =
//         isLoan ? const Color(0xFFE57373) : const Color(0xFF4CAF50);

//     final badgeText = isLoan
//         ? "Loan Given"
//         : "Payment Received";

//     return SafeArea(
//       child: DraggableScrollableSheet(
//         expand: false,
//         initialChildSize: .88,
//         minChildSize: .65,
//         maxChildSize: .95,
//         builder: (_, controller) {
//           return Container(
//             decoration: const BoxDecoration(
//               color: Color(0xffFDF8F2),
//               borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(30),
//               ),
//             ),
//             child: SingleChildScrollView(
//               controller: controller,
//               padding: const EdgeInsets.fromLTRB(22, 16, 22, 30),
//               child: Column(
//                 children: [
//                   Container(
//                     width: 46,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade400,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),

//                   const SizedBox(height: 18),

//                   CircleAvatar(
//                     radius: 30,
//                     backgroundColor: const Color(0xffD7E3F4),
//                     child: Icon(
//                       Icons.currency_rupee,
//                       color: primaryColor,
//                       size: 30,
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   const Text(
//                     "Transaction Details",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: primaryColor,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       color: badgeColor,
//                       border: Border.all(color: badgeBorder),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           isLoan
//                               ? Icons.arrow_upward
//                               : Icons.arrow_downward,
//                           color: amountColor,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 5),
//                         Text(
//                           badgeText,
//                           style: TextStyle(
//                             color: amountColor,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   Row(
//                     children: [

//                       Icon(
//                         Icons.calendar_month_outlined,
//                         size: 20,
//                         color: primaryColor,
//                       ),

//                       const SizedBox(width: 8),

//                       Text(
//                         DateFormat("dd MMM yyyy").format(transaction.date),
//                         style: const TextStyle(
//                           fontSize: 13,
//                         ),
//                       ),

//                       const Spacer(),

//                       Text(
//                         "₹${transaction.amount.toStringAsFixed(0)}",
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: amountColor,
//                         ),
//                       )
//                     ],
//                   ),

//                   const SizedBox(height: 10),

//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       transaction.description.isEmpty
//                           ? "No Description"
//                           : transaction.description,
//                       style: const TextStyle(
//                         color: Colors.black54,
//                         height: 1.4,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 14),

//                   Divider(),

//                   GridView.count(
//                     crossAxisCount: 2,
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                     childAspectRatio: 2.3,
//                     children: [

//                       _infoCard(
//                         "Interest Rate",
//                         "${transaction.interestRate}%",
//                       ),

//                       _infoCard(
//                         "Interest Type",
//                         transaction.interestType,
//                       ),

//                       _infoCard(
//                         "Interest Frequency",
//                         transaction.interestFrequency,
//                       ),

//                       _infoCard(
//                         "Payment Method",
//                         transaction.paymentMode,
//                       ),

//                     ],
//                   ),

//                   const SizedBox(height: 25),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.edit),
//                       label: const Text("Edit Transaction"),
//                       onPressed: () async{

//                           final parentContext = context;

//                           Navigator.pop(context);

//                           await Future.delayed(
//                             const Duration(milliseconds: 250),
//                           );

//                           if (!parentContext.mounted) return;

//                           showModalBottomSheet(
//                             context: parentContext,
//                             isScrollControlled: true,
//                             backgroundColor: Colors.transparent,
//                             builder: (_) {
//                               if (transaction.type == TransactionType.gave) {
//                                 return FractionallySizedBox(
//                                   heightFactor: .82,
//                                   child: LoanGaveEditTransactions(
//                                     customer: customer,
//                                     isEdit: true,
//                                     transaction: transaction,
//                                     onSaved:() async{
//                                       await IsarService.isar.writeTxn(() async {
//                                         await IsarService.isar.transactions.delete(transaction.id);
//                                       });

//                                       onChanged?.call();

//                                       if (context.mounted) {
//                                         Navigator.pop(context);
//                                       }
//                                     },
//                                   ),
//                                 );
//                               }

//                               return FractionallySizedBox(
//                                 heightFactor: .82,
//                                 child: LoanReceivedEditTransactions(
//                                   customer: customer, 
//                                   onSaved: () async{
//                                     await IsarService.isar.writeTxn(() async {
//                                         await IsarService.isar.transactions.delete(transaction.id);
//                                       });

//                                       onChanged?.call();

//                                       if (context.mounted) {
//                                         Navigator.pop(context);
//                                       }
//                                   }
//                                 ),
//                               );
//                             },
//                           );
//                       },
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: OutlinedButton.icon(
//                       icon: const Icon(
//                         Icons.delete,
//                         color: Colors.red,
//                       ),
//                       label: const Text(
//                         "Delete Transaction",
//                         style: TextStyle(color: Colors.red),
//                       ),
//                       onPressed: () {
//                         //   showDeleteTransactionBottomSheet(
//                         //   context,
//                         //   title: "Delete Transaction?",
//                         //   subtitle: "This action cannot be undone",
//                         //   onDelete: () async {
//                         //     // Delete logic
//                         //   },
//                         // );
//                         Navigator.pop(context);
//                         showDeleteTransactionBottomSheet(
//                           context,
//                           title: "Delete Transaction?",
//                           subtitle: "This action cannot be undone",
//                           onDelete: () async {
//                             await transactionService.deleteTransaction(
//                               transactionId: transaction.id,
//                               customerId: customer.id,
//                             );

//                             if (context.mounted) {
//                               Navigator.pop(context); // Close bottom sheet
//                             }

//                             if (context.mounted) {
//                               showDialog(
//                                 context: context,
//                                 barrierDismissible: false,
//                                 builder: (_) => AlertDialog(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   content: const Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(
//                                         Icons.check_circle,
//                                         color: Colors.green,
//                                         size: 60,
//                                       ),
//                                       SizedBox(height: 15),
//                                       Text(
//                                         "Transaction Deleted",
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       SizedBox(height: 8),
//                                       Text(
//                                         "Transaction deleted successfully.",
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );

//                               Future.delayed(const Duration(seconds: 2), () {
//                                 if (context.mounted) {
//                                   Navigator.pop(context); // Close dialog
//                                 }
//                               });
//                             }
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _infoCard(String title, String value) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: const Color(0xffD8E2F0),
//         ),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.calendar_today_outlined,
//             color: Color(0xFF4A6FA5),
//             size: 18,
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               mainAxisAlignment:
//                   MainAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   } 
// }             

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mychopdi/model/transaction.dart';
// import 'package:mychopdi/utils/app_colors.dart';

// class TransactionDetailsScreen extends StatelessWidget {
//   final Transaction transaction;

//   const TransactionDetailsScreen({
//     super.key,
//     required this.transaction,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: const Color(0xFF393536),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Top title
//             Padding(
//               padding: const EdgeInsets.only(
//                 left: 16,
//                 top: 4,
//                 bottom: 8,
//               ),
//               child: Text(
//                 "Transaction Details",
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.55),
//                   fontSize: 15,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),

//             Expanded(
//               child: Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Container(
//                   width: double.infinity,
//                   height: MediaQuery.of(context).size.height * 0.53,
//                   margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
//                   padding: const EdgeInsets.fromLTRB(
//                     30,
//                     10,
//                     30,
//                     20,
//                   ),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFFFF9F1),
//                     borderRadius: BorderRadius.all(
//                       Radius.circular(24),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       // Drag handle
//                       Container(
//                         width: 38,
//                         height: 3,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF85817D),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       // Rupee icon
//                       Container(
//                         width: 52,
//                         height: 52,
//                         decoration: BoxDecoration(
//                           color: Color.fromRGBO(170, 185, 207, 0.6),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: SizedBox(
//                             height: 30,
//                             width: 30,
//                             child: Image.asset('assets/currency_rupee_circle.png'),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 7),

//                       Text(
//                         "Transaction Details",
//                         style: GoogleFonts.manrope(
//                           color: Color(0xFF233E67),
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),

//                       const SizedBox(height: 6),

//                       // Loan Given
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 9,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Color.fromRGBO(199, 76, 76, 0.19),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: Color.fromRGBO(199, 76, 76, 1),
//                             width: 0.8,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Image.asset('assets/arrow_up.png'),
//                             SizedBox(width: 4),
//                             Text(
//                               "Loan Given",
//                               style: GoogleFonts.manrope(
//                                 color: Color.fromRGBO(199, 76, 76, 1),
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 14),

//                       // Date + Amount
//                       Row(
//                         children: [
//                           _smallIcon('assets/calender_check.png'),

//                           const SizedBox(width: 6),

//                           Text(
//                             "10 May 2026",
//                             style: GoogleFonts.manrope(
//                               color: ChopdiColors.navy,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),

//                           const Spacer(),

//                           Text(
//                             "₹15,000",
//                             style: GoogleFonts.manrope(
//                               color: Color.fromRGBO(199, 76, 76, 1),
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 10),

//                       // Description
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           "Descriptiondwdqwerthscsbcjsdcbjcjddcjjdcbdbjdjdjdjdjdjdjd\n"
//                           "jdjdhc",
//                           style: GoogleFonts.manrope(
//                             color: Colors.grey.shade500,
//                             fontSize: 12,
//                             height: 1.3,
//                             fontWeight: FontWeight.w500
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 14),

//                       // First row
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _detailItem(
//                               path: 'assets/calender_check.png',
//                               title: "Interest Rate",
//                               value: "12%",
//                             ),
//                           ),
//                           const SizedBox(width: 18),
//                           Expanded(
//                             child: _detailItem(
//                               path: 'assets/calender_check.png',
//                               title: "Interest Type",
//                               value: "Simple Interest",
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 13),

//                       // Second row
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _detailItem(
//                               path: 'assets/calender_check.png',
//                               title: "Interest Frequency",
//                               value: "Monthly",
//                             ),
//                           ),
//                           const SizedBox(width: 18),
//                           Expanded(
//                             child: _detailItem(
//                               path: 'assets/calender_check.png',
//                               title: "Payment Method",
//                               value: "UPI",
//                             ),
//                           ),
//                         ],
//                       ),

//                       const Spacer(),

//                       // Edit button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 39,
//                         child: ElevatedButton.icon(
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF213F68),
//                             foregroundColor: ChopdiColors.cream,
//                             elevation: 0,
//                             minimumSize: const Size(double.infinity, 40),
//                             padding: EdgeInsets.zero,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                           ),
//                           icon: Image.asset('assets/edit_outline_rounded_transactions.png'),
//                           label: Text(
//                             "Edit Transaction",
//                             style: GoogleFonts.manrope(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 9),

//                       // Delete button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 39,
//                         child: OutlinedButton.icon(
//                           onPressed: () {},
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Color.fromRGBO(199, 76, 76, 1),
//                             minimumSize: const Size(double.infinity, 40),
//                             padding: EdgeInsets.zero,
//                             side: const BorderSide(
//                               color: Color.fromRGBO(199, 76, 76, 1),
//                               width: 0.8,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                           ),
//                           icon: Image.asset('assets/delete_outline_rounded_transactions.png'),
//                           label: Text(
//                             "Delete Transaction",
//                             style: GoogleFonts.manrope(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Small calendar/icon box
//   static Widget _smallIcon(String path) {
//     return Container(
//       width: 30,
//       height: 30,
//       decoration: BoxDecoration(
//         color: Color.fromRGBO(170, 185, 207, 0.6),
//         borderRadius: BorderRadius.circular(3),
//       ),
//       child: Image.asset(
//         path,
//       ),
//     );
//   }


//   static Widget _detailItem({
//     required String path,
//     required String title,
//     required String value,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 30,
//           height: 30,
//           decoration: BoxDecoration(
//             color: const Color(0xFFDCE4EF),
//             borderRadius: BorderRadius.circular(3),
//           ),
//           child: Image.asset(
//             path
//           ),
//         ),

//         const SizedBox(width: 7),

//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: GoogleFonts.manrope(
//                   color: Colors.grey.shade500,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               const SizedBox(height: 2),

//               Text(
//                 value,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: GoogleFonts.manrope(
//                   color: Color(0xFF233E67),
//                   fontSize: 12,
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
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// import 'package:mychopdi/service/transaction_service.dart';
// import 'package:mychopdi/widgets/delete_transaction_bottom_sheet.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
import 'package:mychopdi/view/edit_transaction_bottom_sheet.dart';
import 'package:mychopdi/widgets/delete_transactions_bottom_sheet.dart';
import 'package:mychopdi/data/repository/repositories.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;
  final int customerId;
   final VoidCallback? onChanged;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
    required this.customerId,
    required this.onChanged,
  });

  String _getFullDescription() {
  final startDate =
      DateFormat("dd MMM yyyy").format(transaction.date);

  final endDate =
      DateFormat("dd MMM yyyy").format(DateTime.now());

  final rate =
      transaction.interestRate.toStringAsFixed(0);

  final frequency =
      transaction.interestFrequency.isEmpty
          ? "Monthly"
          : transaction.interestFrequency;

  final interestType =
      transaction.interestType.isEmpty
          ? "Simple Interest"
          : transaction.interestType;

  return "$startDate → $endDate "
      "$rate% $frequency $interestType";
}

String _getInterestDescription() {
  final startDate = transaction.date;

  final endDate = DateTime.now();

  final start =
      DateFormat("dd MMM yyyy").format(startDate);

  final end =
      DateFormat("dd MMM yyyy").format(endDate);

  final rate =
      transaction.interestRate.toStringAsFixed(0);

  final frequency =
      transaction.interestFrequency.isEmpty
          ? "Monthly"
          : transaction.interestFrequency;

  final interestType =
      transaction.interestType.isEmpty
          ? "Simple Interest"
          : transaction.interestType;

  return "$start → $end\n"
      "$rate% $frequency $interestType";
}

// String _getTransactionDescription() {
//   final now = DateTime.now();

//   final days = now.difference(transaction.date).inDays;

//   // No interest calculation if the transaction date
//   // is today or in the future.
//   if (days <= 0) {
//     return transaction.description.isEmpty
//         ? "No interest calculated yet."
//         : transaction.description;
//   }

//   final interest = InterestCalculator.calculate(
//     principal: transaction.amount,
//     rate: transaction.interestRate,
//     startDate: transaction.date,
//     interestType: transaction.interestType,
//     frequency: transaction.interestFrequency,
//   );

//   final startDate =
//       DateFormat("dd MMM yyyy").format(transaction.date);

//   final endDate =
//       DateFormat("dd MMM yyyy").format(now);

//   final rate =
//       transaction.interestRate.toStringAsFixed(0);

//   final frequency =
//       transaction.interestFrequency.toLowerCase();

//   final interestType =
//       transaction.interestType
//           .replaceAll(" Interest", "")
//           .toLowerCase();

//   return "₹${interest.toStringAsFixed(0)} interest "
//       "from $startDate to $endDate at $rate% "
//       "$frequency $interestType interest.";
// }

  String _getTransactionDescription() {
    final startDate =
        DateFormat("dd MMM yyyy").format(transaction.date);

    final endDate =
        DateFormat("dd MMM yyyy").format(DateTime.now());

    // PAYMENT RECEIVED

    if (transaction.type == TransactionType.received) {
      return "Payment received from $startDate to $endDate.";
    }

    // LOAN GIVEN

    final days = DateTime.now()
        .difference(transaction.date)
        .inDays;

    if (days <= 0) {
      return transaction.description.isEmpty
          ? "Loan given."
          : transaction.description;
    }

    final interest = InterestCalculator.calculate(
      principal: transaction.amount,
      rate: transaction.interestRate,
      startDate: transaction.date,
      interestType: transaction.interestType,
      frequency: transaction.interestFrequency,
    );

    final rate =
        transaction.interestRate.toStringAsFixed(0);

    final frequency =
        transaction.interestFrequency.toLowerCase();

    final interestType =
        transaction.interestType
            .replaceAll(" Interest", "")
            .toLowerCase();

    return "₹${interest.toStringAsFixed(0)} interest "
        "from $startDate to $endDate at $rate% "
        "$frequency $interestType interest.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF393536),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                top: 4,
                bottom: 8,
              ),
              child: Text(
                "Transaction Details",
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.53,
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  padding: const EdgeInsets.fromLTRB(
                    30,
                    10,
                    30,
                    20,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF9F1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(24),
                    ),
                  ),
                  child: transaction.type == TransactionType.received
                    ? _buildPaymentReceivedDetails(context)
                    : _buildLoanGivenDetails(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _transactionType() {
    final bool isGiven =
        transaction.type == TransactionType.gave;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(
          199,
          76,
          76,
          0.19,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromRGBO(
            199,
            76,
            76,
            1,
          ),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isGiven
                ? 'assets/arrow_up.png'
                : 'assets/arrow_down.png',
            height: 14,
            width: 14,
          ),

          const SizedBox(width: 4),

          Text(
            isGiven
                ? "Loan Given"
                : "Payment Received",
            style: GoogleFonts.manrope(
              color: const Color.fromRGBO(
                199,
                76,
                76,
                1,
              ),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }


  static Widget _smallIcon(String path) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(
          170,
          185,
          207,
          0.6,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Image.asset(
        path,
        fit: BoxFit.contain,
      ),
    );
  }

  static Widget _detailItem({
    required String path,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFDCE4EF),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Image.asset(
            path,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF233E67),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatAmount(double amount) {
    return '₹${NumberFormat('#,##0.##').format(amount)}';
  }

  Widget _buildLoanGivenDetails(BuildContext context) {
    return Column(
      children: [
        // Drag handle
        Container(
          width: 38,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF85817D),
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        const SizedBox(height: 16),

        // Rupee icon
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(170, 185, 207, 0.6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: Image.asset(
                'assets/currency_rupee_circle.png',
              ),
            ),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          "Transaction Details",
          style: GoogleFonts.manrope(
            color: const Color(0xFF233E67),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        // Loan Given
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(
              199,
              76,
              76,
              0.19,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromRGBO(
                199,
                76,
                76,
                1,
              ),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/arrow_up.png',
                height: 14,
                width: 14,
              ),

              const SizedBox(width: 4),

              Text(
                "Loan Given",
                style: GoogleFonts.manrope(
                  color: const Color.fromRGBO(
                    199,
                    76,
                    76,
                    1,
                  ),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Date + Amount
        Row(
          children: [
            _smallIcon(
              'assets/calender_check.png',
            ),

            const SizedBox(width: 6),

            Text(
              DateFormat(
                'dd MMM yyyy',
              ).format(transaction.date),
              style: GoogleFonts.manrope(
                color: ChopdiColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),

            const Spacer(),

            Text(
              _formatAmount(transaction.amount),
              style: GoogleFonts.manrope(
                color: const Color.fromRGBO(
                  199,
                  76,
                  76,
                  1,
                ),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Description
        Align(
          alignment: Alignment.centerLeft,
          // child: Text(
          //   transaction.description.isEmpty
          //       ? "No description"
          //       : transaction.description,
          //   maxLines: 2,
          //   overflow: TextOverflow.ellipsis,
          //   style: GoogleFonts.manrope(
          //     color: Colors.grey.shade500,
          //     fontSize: 12,
          //     height: 1.3,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
          child:Text(
            _getTransactionDescription(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: Colors.grey.shade500,
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Interest details
        Row(
          children: [
            Expanded(
              child: _detailItem(
                path: 'assets/calender_check.png',
                title: "Interest Rate",
                value: "${transaction.interestRate}%",
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: _detailItem(
                path: 'assets/calender_check.png',
                title: "Interest Type",
                value: transaction.interestType.isEmpty
                    ? "Not specified"
                    : transaction.interestType,
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        Row(
          children: [
            Expanded(
              child: _detailItem(
                path: 'assets/calender_check.png',
                title: "Interest Frequency",
                value: transaction.interestFrequency.isEmpty
                    ? "Not specified"
                    : transaction.interestFrequency,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: _detailItem(
                path: 'assets/calender_check.png',
                title: "Payment Method",
                value: transaction.paymentMode.isEmpty
                    ? "Not specified"
                    : transaction.paymentMode,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Edit
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () {
              // Edit transaction
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return EditTransactionBottomSheet(
                    transaction: transaction,
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF213F68),
              foregroundColor: ChopdiColors.cream,
              elevation: 0,
              minimumSize: const Size(
                double.infinity,
                40,
              ),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/edit_outline_rounded_transactions.png',
            ),
            label: Text(
              "Edit Transaction",
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 9),

        // Delete
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton.icon(
            onPressed: () async {
              final result = await showDeleteTransactionBottomSheet(
                context,
                title: "Delete Transaction?",
                subtitle: "This action cannot be undone",
                onDelete: () async {
                  // Voided, not removed: a hard delete cannot reach another
                  // device and destroys the audit history. Every read filters
                  // voidedAt, so it disappears from the UI just the same.
                  await Repositories.ledger.voidEntry(
                    transaction,
                    reason: 'Deleted by user',
                  );

                  onChanged?.call();
                },
              );

              if (result == true && context.mounted) {
                Navigator.pop(context);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color.fromRGBO(
                199,
                76,
                76,
                1,
              ),
              minimumSize: const Size(
                double.infinity,
                40,
              ),
              padding: EdgeInsets.zero,
              side: const BorderSide(
                color: Color.fromRGBO(
                  199,
                  76,
                  76,
                  1,
                ),
                width: 0.8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/delete_outline_rounded_transactions.png',
            ),
            label: Text(
              "Delete Transaction",
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentReceivedDetails(BuildContext context) {
    return Column(
      children: [
        // Drag handle
        Container(
          width: 38,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF85817D),
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        const SizedBox(height: 16),

        // Rupee icon
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(170, 185, 207, 0.6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: Image.asset(
                'assets/currency_rupee_circle.png',
              ),
            ),
          ),
        ),

        const SizedBox(height: 7),

        // Transaction Details
        Text(
          "Transaction Details",
          style: GoogleFonts.manrope(
            color: const Color(0xFF233E67),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        // Payment Received badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(
              60,
              180,
              80,
              0.15,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF21A83A),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/arrow_down.png',
                height: 14,
                width: 14,
              ),

              const SizedBox(width: 4),

              Text(
                "Payment Received",
                style: GoogleFonts.manrope(
                  color: const Color(0xFF159B2D),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Date + Amount
        Row(
          children: [
            _smallIcon(
              'assets/calender_check.png',
            ),

            const SizedBox(width: 6),

            Text(
              DateFormat(
                'dd MMM yyyy',
              ).format(transaction.date),
              style: GoogleFonts.manrope(
                color: ChopdiColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),

            const Spacer(),

            Text(
              _formatAmount(transaction.amount),
              style: GoogleFonts.manrope(
                color: const Color(0xFF159B2D),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Description
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: Text(
        //     transaction.description.isEmpty
        //         ? "No description"
        //         : transaction.description,
        //     maxLines: 2,
        //     overflow: TextOverflow.ellipsis,
        //     style: GoogleFonts.manrope(
        //       color: Colors.grey.shade500,
        //       fontSize: 12,
        //       height: 1.3,
        //       fontWeight: FontWeight.w500,
        //     ),
        //   ),
        // ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
          _getTransactionDescription(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            color: Colors.grey.shade500,
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
        ),

        const SizedBox(height: 60),

        // Edit button
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () {
              // Edit transaction
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF213F68),
              foregroundColor: ChopdiColors.cream,
              elevation: 0,
              minimumSize: const Size(
                double.infinity,
                40,
              ),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/edit_outline_rounded_transactions.png',
            ),
            label: Text(
              "Edit Transaction",
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 9),

        // Delete button
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton.icon(
            onPressed: () async {
            final result = await showDeleteTransactionBottomSheet(
              context,
              title: "Delete Transaction?",
              subtitle: "This action cannot be undone",
              onDelete: () async {
                await Repositories.ledger.voidEntry(
                  transaction,
                  reason: 'Deleted by user',
                );

                onChanged?.call();
              },
            );

            if (result == true && context.mounted) {
              Navigator.pop(context);
            }
          },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color.fromRGBO(
                199,
                76,
                76,
                1,
              ),
              minimumSize: const Size(
                double.infinity,
                40,
              ),
              padding: EdgeInsets.zero,
              side: const BorderSide(
                color: Color.fromRGBO(
                  199,
                  76,
                  76,
                  1,
                ),
                width: 0.8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: Image.asset(
              'assets/delete_outline_rounded_transactions.png',
            ),
            label: Text(
              "Delete Transaction",
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

