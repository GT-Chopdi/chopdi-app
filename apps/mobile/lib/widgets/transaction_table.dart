// import 'package:flutter/material.dart';
// import 'package:mychopdi/utils/app_colors.dart';

// class TransactionTable extends StatelessWidget {
//   const TransactionTable({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Color.fromRGBO(255, 248, 240, 1),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(
//         children: [

//           /// Header
//           Container(
//             height: 42,
//             decoration: BoxDecoration(
//               color: Color.fromRGBO(255, 248, 240, 1),
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(14),
//               ),
//             ),
//             child: const Row(
//               children: [

//                 _HeaderCell("Date", flex: 2),

//                 VerticalDivider(width: 1),

//                 _HeaderCell("Given"),

//                 VerticalDivider(width: 1),

//                 _HeaderCell("Received"),

//                 VerticalDivider(width: 1),

//                 _HeaderCell("Balance"),
//               ],
//             ),
//           ),

//           _row(
//             date: "10 May 2026",
//             given: "₹15,000",
//             givenSub: "Loan Given",
//             received: "-",
//             receivedSub: "",
//             balance: "₹15,000",
//           ),

//           _divider(),

//           _row(
//             date: "18 May 2026",
//             given: "-",
//             givenSub: "",
//             received: "₹1,000",
//             receivedSub: "Payment Received",
//             balance: "₹14,000",
//           ),

//           _divider(),

//           _row(
//             date: "20 May 2026",
//             given: "-",
//             givenSub: "",
//             received: "₹150",
//             receivedSub: "Interest Added",
//             balance: "₹14,150",
//           ),

//           _divider(),

//           _row(
//             date: "25 May 2026",
//             given: "-",
//             givenSub: "",
//             received: "₹2,000",
//             receivedSub: "Payment Received",
//             balance: "₹12,150",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _divider() {
//     return Divider(
//       height: 1,
//       color: Colors.grey.shade300,
//     );
//   }

//   Widget _row({
//     required String date,
//     required String given,
//     required String givenSub,
//     required String received,
//     required String receivedSub,
//     required String balance,
//   }) {
//     return IntrinsicHeight(
//       child: Row(
//         children: [

//           Expanded(
//             flex: 2,
//             child: Padding(
//               padding: const EdgeInsets.all(10),
//               child: Text(
//                 date,
//                 style: const TextStyle(fontSize: 11),
//               ),
//             ),
//           ),

//           VerticalDivider(width: 1, color: Colors.grey.shade300),

//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8),
//               child: Column(
//                 children: [

//                   Text(
//                     given,
//                     style: TextStyle(
//                       color: given == "-"
//                           ? Colors.black
//                           : Colors.red,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),

//                   if (givenSub.isNotEmpty)
//                     Text(
//                       givenSub,
//                       style: const TextStyle(
//                         fontSize: 9,
//                         color: Colors.grey,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           VerticalDivider(width: 1, color: Colors.grey.shade300),

//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8),
//               child: Column(
//                 children: [

//                   Text(
//                     received,
//                     style: TextStyle(
//                       color: received == "-"
//                           ? Colors.black
//                           : Colors.green,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),

//                   if (receivedSub.isNotEmpty)
//                     Text(
//                       receivedSub,
//                       style: const TextStyle(
//                         fontSize: 9,
//                         color: Colors.grey,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           VerticalDivider(width: 1, color: Colors.grey.shade300),

//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(10),
//               child: Text(
//                 balance,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HeaderCell extends StatelessWidget {
//   final String title;
//   final int flex;

//   const _HeaderCell(
//     this.title, {
//     this.flex = 1,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: flex,
//       child: Center(
//         child: Text(
//           title,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 11,
//             color: ChopdiColors.navy,
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:mychopdi/utils/app_colors.dart';

// class TransactionTable extends StatelessWidget {
//   const TransactionTable({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [

//         /// HEADER
//         Container(
//           height: 46,
//           decoration: BoxDecoration(
//             color: const Color(0xffFFF8F0),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: const Color(0xffC9D7E8),
//             ),
//           ),
//           child: const Row(
//             children: [
//               _HeaderCell("Date", flex: 2),
//               VerticalDivider(width: 1),
//               _HeaderCell("Given"),
//               VerticalDivider(width: 1),
//               _HeaderCell("Received"),
//               VerticalDivider(width: 1),
//               _HeaderCell("Balance"),
//             ],
//           ),
//         ),

//         const SizedBox(height: 10),

//         _transactionCard(
//           date: "10 May 2026",
//           given: "₹15,000",
//           givenSub: "Loan Given",
//           received: "-",
//           receivedSub: "",
//           balance: "₹15,000",
//         ),

//         const SizedBox(height: 8),

//         _transactionCard(
//           date: "18 May 2026",
//           given: "-",
//           givenSub: "",
//           received: "₹1,000",
//           receivedSub: "Payment Received",
//           balance: "₹14,000",
//         ),

//         const SizedBox(height: 8),

//         _transactionCard(
//           date: "20 May 2026",
//           given: "-",
//           givenSub: "",
//           received: "₹150",
//           receivedSub: "Interest Added",
//           balance: "₹14,150",
//         ),

//         const SizedBox(height: 8),

//         _transactionCard(
//           date: "25 May 2026",
//           given: "-",
//           givenSub: "",
//           received: "₹2,000",
//           receivedSub: "Payment Received",
//           balance: "₹12,150",
//         ),
//       ],
//     );
//   }

//   Widget _transactionCard({
//     required String date,
//     required String given,
//     required String givenSub,
//     required String received,
//     required String receivedSub,
//     required String balance,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         vertical: 10,
//         horizontal: 8,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xffFFF8F0),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: const Color(0xffC9D7E8),
//         ),
//       ),
//       child: Row(
//         children: [

//           /// DATE
//           Expanded(
//             flex: 2,
//             child: Text(
//               date,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.black87,
//               ),
//             ),
//           ),

//           /// GIVEN
//           Expanded(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   given,
//                   style: TextStyle(
//                     color:
//                         given == "-" ? Colors.black : Colors.red,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13,
//                   ),
//                 ),
//                 if (givenSub.isNotEmpty)
//                   Text(
//                     givenSub,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 9,
//                       color: Colors.black54,
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           /// RECEIVED
//           Expanded(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   received,
//                   style: TextStyle(
//                     color:
//                         received == "-" ? Colors.black : Colors.green,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13,
//                   ),
//                 ),
//                 if (receivedSub.isNotEmpty)
//                   Text(
//                     receivedSub,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 9,
//                       color: Colors.black54,
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           /// BALANCE
//           Expanded(
//             child: Center(
//               child: Text(
//                 balance,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 13,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HeaderCell extends StatelessWidget {
//   final String title;
//   final int flex;

//   const _HeaderCell(
//     this.title, {
//     this.flex = 1,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: flex,
//       child: Center(
//         child: Text(
//           title,
//           style: const TextStyle(
//             color: ChopdiColors.navy,
//             fontWeight: FontWeight.w700,
//             fontSize: 12,
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mychopdi/model/transaction.dart';
// import 'package:mychopdi/utils/app_colors.dart';
// import 'package:mychopdi/widgets/transaction_raw.dart';

// class TransactionTable extends StatefulWidget {
  
//   final List<Transaction> transactions;

//   const TransactionTable({
//     super.key,
//     required this.transactions,
//   });


//   @override
//   State<TransactionTable> createState() => _TransactionTableState();
// }

// class _TransactionTableState extends State<TransactionTable> {

//   final List<Transaction> transactions = [];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _tableHeader(),
//         const SizedBox(height: 8),

//         ...transactions.map(
//       (tx) {

//         return Padding(
//           padding: const EdgeInsets.only(bottom: 8),
//           child: TransactionRow(
//             transaction: tx,
//           ),
//         );

//       },
//     ),

//         // _transactionRow(
//         //   date: "25 May 2026",
//         //   given: "-",
//         //   givenSub: "",
//         //   received: "₹2,000",
//         //   receivedSub: "Payment Received",
//         //   balance: "₹12,150",
//         // ),

//         // TransactionRow(
//         //   transaction: TransactionModel(
//         //     date: "25 May 2026",
//         //     given: null,
//         //     received: "₹2,000",
//         //     subtitle: "Payment Received",
//         //     balance: "₹12,150",
//         //   ),
//         // ),

//         // const SizedBox(height: 8),

//         // _transactionRow(
//         //   date: "20 May 2026",
//         //   given: "-",
//         //   givenSub: "",
//         //   received: "₹150",
//         //   receivedSub: "Interest Added",
//         //   balance: "₹14,150",
//         // ),

//         // TransactionRow(
//         //   transaction: TransactionModel(
//         //     date: "20 May 2026",
//         //     given: "-",
//         //     received: "₹150",
//         //     subtitle: "Interest Added",
//         //     balance: "₹14,150",
//         //   ),
//         // ),

//         // const SizedBox(height: 8),

//         // TransactionRow(
//         //   transaction: TransactionModel(
//         //     date: "18 May 2026",
//         //     given: "-",
//         //     received: "₹1,000",
//         //     subtitle: "Payment Received",
//         //     balance: "₹14,000",
//         //   ),
//         // ),

//         // const SizedBox(height: 8),

//         // TransactionRow(
//         //   transaction: TransactionModel(
//         //     date: "10 May 2026",
//         //     given: "₹15,000",
//         //     received: "-",
//         //     subtitle: "",
//         //     balance: "₹15,000",
//         //   ),
//         // ),
//       ],
//     );
//   }

//   Widget _tableHeader() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Color(0xFFFFF8F0),
//         border: Border.all(color: Color(0xFFAAB9CF)),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Table(
//         border: TableBorder.symmetric(
//           inside: const BorderSide(
//             color: Color(0xffC8D6E8),
//           ),
//         ),
//         columnWidths: const {
//           0: FlexColumnWidth(1.8),
//           1: FlexColumnWidth(1.2),
//           2: FlexColumnWidth(1.2),
//           3: FlexColumnWidth(1.2),
//         },
//         children: const [
//           TableRow(
//             children: [
//               _Header("Date"),
//               _Header("Given"),
//               _Header("Received"),
//               _Header("Balance"),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _transactionRow({
//     required String date,
//     required String given,
//     required String givenSub,
//     required String received,
//     required String receivedSub,
//     required String balance,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Color.fromRGBO(255, 248, 240, 1),
//         border: Border.all(color: Color.fromRGBO(170, 185, 207, 1)),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Table(
//         columnWidths: const {
//           0: FlexColumnWidth(1.8),
//           1: FlexColumnWidth(1.2),
//           2: FlexColumnWidth(1.2),
//           3: FlexColumnWidth(1.2),
//         },
//         children: [
//           TableRow(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                     vertical: 12, horizontal: 10),
//                 child: Text(
//                   date,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),

//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Column(
//                   children: [
//                     Text(
//                       given,
//                       style: TextStyle(
//                         color: given == "-" ? Colors.black : Colors.red,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 13,
//                       ),
//                     ),
//                     if (givenSub.isNotEmpty)
//                       Text(
//                         givenSub,
//                         style: const TextStyle(
//                           fontSize: 9,
//                           color: Color(0xFF000000),
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                   ],
//                 ),
//               ),

//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Column(
//                   children: [
//                     Text(
//                       received,
//                       style: TextStyle(
//                         color: received == "-" ? Colors.black : Colors.green,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 13,
//                       ),
//                     ),
//                     if (receivedSub.isNotEmpty)
//                       Text(
//                         receivedSub,
//                         style: const TextStyle(
//                           fontSize: 9,
//                           color: Colors.grey,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                   ],
//                 ),
//               ),

//               Center(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   child: Text(
//                     balance,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _Header extends StatelessWidget {
//   final String title;

//   const _Header(this.title);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Center(
//         child: Text(
//           title,
//           style: GoogleFonts.manrope(
//             fontWeight: FontWeight.bold,
//             fontSize: 13,
//             color: ChopdiColors.navy,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/transaction_raw.dart';

class TransactionTable extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onChanged;

  const TransactionTable({
    super.key,
    required this.transactions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    double runningBalance = 0;

    return Column(
      children: [
        _tableHeader(),
        const SizedBox(height: 8),

        ...transactions.map((tx) {
          for (final tx in transactions) {

            if (tx.type == TransactionType.gave) {
              runningBalance += tx.amount;
            } else {
              runningBalance -= tx.amount;
            }

          }

          return TransactionRow(
            transaction: tx,
            balance: runningBalance,
            onChanged: onChanged,
          );
        }),
      ],
    );
  }

  Widget _tableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        border: Border.all(
          color: const Color(0xFFAAB9CF),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(
            color: Color(0xffC8D6E8),
          ),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.8),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.2),
        },
        children: const [
          TableRow(
            children: [
              _Header("Date"),
              _Header("Given"),
              _Header("Received"),
              _Header("Balance"),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: ChopdiColors.navy,
          ),
        ),
      ),
    );
  }
}