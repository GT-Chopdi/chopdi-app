// // // // import 'package:flutter/material.dart';
// // // // import 'package:mychopdi/model/customer_model.dart';
// // // // import 'package:mychopdi/utils/app_colors.dart';
// // // // import 'package:mychopdi/widgets/add_customer_button.dart';
// // // // import 'package:mychopdi/widgets/home_header.dart';
// // // // import 'package:mychopdi/widgets/loan_toggle.dart';
// // // // import 'package:mychopdi/widgets/summary_card.dart';
// // // // import 'package:mychopdi/view/customers_screen.dart';

// // // // class HomeScreen extends StatefulWidget {

// // // //   const HomeScreen({super.key});

// // // //   @override
// // // //   State<HomeScreen> createState() => _HomeScreenState();

// // // // }

// // // // class _HomeScreenState extends State<HomeScreen> {

// // // //   final customers = [

// // // //     CustomerModel(
// // // //       name: "Rahul",
// // // //       loan: "₹12,000",
// // // //       interest: "12%",
// // // //       amount: "₹12,000",
// // // //       received: false,
// // // //       phone: "+91 7539412369",
// // // //       status: "Pending"
// // // //     ),

// // // //     CustomerModel(
// // // //       name: "Khushi",
// // // //       loan: "₹8,500",
// // // //       interest: "10%",
// // // //       amount: "₹8,500",
// // // //       received: false,
// // // //       phone: "+91 9631457694",
// // // //       status: "Completed"
// // // //     ),

// // // //     CustomerModel(
// // // //       name: "Dada",
// // // //       loan: "₹6,000",
// // // //       interest: "9%",
// // // //       amount: "₹1,000",
// // // //       received: true,
// // // //       phone: "+91 8463988453",
// // // //       status: ""
// // // //     ),
// // // //   ];

// // // //   @override
// // // //   Widget build(BuildContext context) {

// // // //     return Scaffold(
// // // //       backgroundColor: ChopdiColors.cream,
// // // //       // floatingActionButton: AddCustomerButton(onCustomerAdded: (customers) {
// // // //       //   Navigator.push(
// // // //       //     context,
// // // //       //     MaterialPageRoute(
// // // //       //       builder: (_) => CustomerListSection(customers: customers),
// // // //       //     ),
// // // //       //   );
// // // //       // },),

// // // //       floatingActionButton: AddCustomerButton(
// // // //         onCustomerAdded: (customer) {

// // // //           setState(() {
// // // //             customers.add(customer);
// // // //           });

// // // //           Navigator.push(
// // // //             context,
// // // //             MaterialPageRoute(
// // // //               builder: (_) => CustomerListSection(
// // // //                 customers: customers,
// // // //               ),
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),

// // // //       body: SafeArea(
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(14),
// // // //           child: Column(
// // // //             crossAxisAlignment: CrossAxisAlignment.start,
// // // //             children: [
// // // //               const HomeHeader(),
// // // //               const SizedBox(height: 18),
// // // //               const LoanToggle(),
// // // //               const SizedBox(height: 18),
// // // //               const SummaryCard(),
// // // //               const SizedBox(height: 18),

// // // //               SizedBox(height: 18),

// // // //               // Center(
// // // //               //   child: Column(
// // // //               //     mainAxisAlignment: MainAxisAlignment.center,
// // // //               //     children: [
// // // //               //       SizedBox(
// // // //               //         height: 74,
// // // //               //         width: 82,
// // // //               //         child: Image.asset('assets/home_screen_book.png'),
// // // //               //       ),
                
// // // //               //       SizedBox(height: 6),
                
// // // //               //       Text(
// // // //               //         'No customers yet!',
// // // //               //         style: GoogleFonts.manrope(
// // // //               //           color: ChopdiColors.navy,
// // // //               //           fontSize: 22,
// // // //               //           fontWeight: FontWeight.w700,
// // // //               //         ),
// // // //               //       ),
                
// // // //               //       SizedBox(height: 3),
                
// // // //               //       Text(
// // // //               //         'Start by adding a customer and\n\tkeep track of your loans easily',
// // // //               //         style: GoogleFonts.manrope(
// // // //               //           color: ChopdiColors.navy,
// // // //               //           fontSize: 16,
// // // //               //           fontWeight: FontWeight.w700,
// // // //               //         ),
// // // //               //       ),

// // // //               //       SizedBox(height: 11),

// // // //               //       Row(
// // // //               //         children: [
// // // //               //           SizedBox(width:190),
// // // //               //           Image.asset('assets/line_home.png'),
// // // //               //         ],
// // // //               //       ),
// // // //               //     ],
// // // //               //   ),
// // // //               // ),
// // // //               Expanded(
// // // //                 child: CustomerListSection(customers: [],),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // import 'package:flutter/material.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:isar_community/isar.dart';
// // // import 'package:mychopdi/model/customer.dart';
// // // import 'package:mychopdi/service/isar_service.dart';
// // // import 'package:mychopdi/utils/app_colors.dart';
// // // import 'package:mychopdi/view/customers_screen.dart';
// // // import 'package:mychopdi/widgets/add_customer_button.dart';
// // // import 'package:mychopdi/widgets/home_header.dart';
// // // import 'package:mychopdi/widgets/loan_toggle.dart';
// // // import 'package:mychopdi/widgets/summary_card.dart';

// // // class HomeScreen extends StatefulWidget {
// // //   const HomeScreen({super.key});

// // //   @override
// // //   State<HomeScreen> createState() => _HomeScreenState();
// // // }

// // // class _HomeScreenState extends State<HomeScreen> {

// // //   List<Customer> customers = [];

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     loadCustomers();
// // //   }

// // //   Future<void> loadCustomers() async {
// // //     customers = await IsarService.isar.customers.where().findAll();

// // //     setState(() {});
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: ChopdiColors.cream,
// // //       floatingActionButton: AddCustomerButton(
// // //         onCustomerAdded: (_) async{
// // //           await loadCustomers();
// // //         },
// // //       ),

// // //       body: SafeArea(
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(14),
// // //           child: Column(
// // //             children: [

// // //               const HomeHeader(),
// // //               const SizedBox(height: 18),
// // //               const LoanToggle(),
// // //               const SizedBox(height: 18),
// // //               const SummaryCard(),
// // //               const SizedBox(height: 18),

// // //               // Expanded(
// // //               //   child: customers.isEmpty
// // //               //       ? _buildEmptyState()
// // //               //       : CustomerListSection(
// // //               //           customers: customers,
// // //               //         ),
// // //               // ),
// // //               Expanded(
// // //                 child: StreamBuilder<List<Customer>>(
// // //                   stream: IsarService.isar.customers
// // //                       .where()
// // //                       .watch(fireImmediately: true),
// // //                   builder: (context, snapshot) {

// // //                     final customers = snapshot.data ?? [];

// // //                     if (customers.isEmpty) {
// // //                       return _buildEmptyState();
// // //                     }

// // //                     return CustomerListSection(
// // //                       customers: customers,
// // //                     );
// // //                   },
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildEmptyState() {
// // //     return Center(
// // //       child: Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           SizedBox(
// // //             height: 74,
// // //             width: 82,
// // //             child: Image.asset('assets/home_screen_book.png'),
// // //           ),
// // //           const SizedBox(height: 6),
// // //           Text(
// // //             'No customers yet!',
// // //             style: GoogleFonts.manrope(
// // //               color: ChopdiColors.navy,
// // //               fontSize: 22,
// // //               fontWeight: FontWeight.w700,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 3),
// // //           Text(
// // //             'Start by adding a customer and\nkeep track of your loans easily',
// // //             textAlign: TextAlign.center,
// // //             style: GoogleFonts.manrope(
// // //               color: ChopdiColors.navy,
// // //               fontSize: 16,
// // //               fontWeight: FontWeight.w700,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 12),
// // //           Row(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Image.asset('assets/line_home.png'),
// // //             ],
// // //           )
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:flutter/rendering.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:isar_community/isar.dart';
// // import 'package:mychopdi/model/customer.dart';
// // import 'package:mychopdi/service/isar_service.dart';
// // import 'package:mychopdi/utils/app_colors.dart';
// // import 'package:mychopdi/view/customers_screen.dart';
// // import 'package:mychopdi/view/add_customer_screen.dart';
// // import 'package:mychopdi/widgets/home_header.dart';
// // import 'package:mychopdi/widgets/loan_toggle.dart';
// // import 'package:mychopdi/widgets/summary_card.dart';
// // import 'package:mychopdi/model/chopdi.dart';
// // import 'package:mychopdi/service/chopdi_service.dart';

// // class TookLoanHomeScreen extends StatefulWidget {
// //   final int chopdiId;
// //   const TookLoanHomeScreen({super.key, required this.chopdiId,});

// //   @override
// //   State<TookLoanHomeScreen> createState() => _HomeScreenState();
// // }

// // class _HomeScreenState extends State<TookLoanHomeScreen> {
// //   bool _isFabSmall = false;
// //   Chopdi? currentChopdi;
// //   bool isGaveLoan = true;
// //   bool isGaveLoanSelected = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCurrentChopdi();
// //   }

// //   Future<void> _loadCurrentChopdi() async {
// //     final chopdi = await ChopdiService.getCurrentChopdi();

// //     if (!mounted) return;

// //     setState(() {
// //       currentChopdi = chopdi;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: ChopdiColors.cream,
// //       floatingActionButton: AnimatedSwitcher(
// //         duration: const Duration(milliseconds: 250),
// //         transitionBuilder: (child, animation) {
// //           return ScaleTransition(
// //             scale: animation,
// //             child: child,
// //           );
// //         },
// //         child: _isFabSmall
// //             ? FloatingActionButton(
// //                 key: const ValueKey("small"),
// //                 backgroundColor: const Color(0xff243B67),
// //                 elevation: 2,
// //                 onPressed: () async {
// //                   await Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                       builder: (_) => AddCustomerScreen(
// //                         chopdiId: currentChopdi!.id,
// //                       ),
// //                     ),
// //                   );
// //                 },
// //                 child: const Icon(
// //                   Icons.add,
// //                   color: Colors.white,
// //                 ),
// //               )
// //             : FloatingActionButton.extended(
// //                 key: const ValueKey("large"),
// //                 backgroundColor: const Color(0xff243B67),
// //                 elevation: 2,
// //                 onPressed: () async {
// //                   if (currentChopdi == null) return;
// //                   await Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                       builder: (_) => AddCustomerScreen(
// //                         chopdiId: currentChopdi!.id,
// //                       ),
// //                     ),
// //                   );
// //                 },
// //                 icon: const Icon(
// //                   Icons.add,
// //                   color: Colors.white,
// //                 ),
// //                 label: const Text(
// //                   "Add Loan",
// //                   style: TextStyle(
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ),
// //       ),

// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.all(2),

// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [

// //               // const HomeHeader(),
// //               // HomeHeader(
// //               //   currentChopdi: currentChopdi,
// //               //   onChopdiChanged: (chopdi) {
// //               //     setState(() {
// //               //       currentChopdi = chopdi;
// //               //     });
// //               //   },
// //               // ),

// //               // const SizedBox(height: 18),

// //               // // const LoanToggle(),
// //               // LoanToggle(
// //               //   isGaveLoanSelected: isGaveLoanSelected,
// //               //   onChanged: (value) {
// //               //     setState(() {
// //               //       isGaveLoanSelected = value;
// //               //     });
// //               //   },
// //               // ),

// //               // const SizedBox(height: 18),


// //               Expanded(
// //                 child: NotificationListener<ScrollNotification>(
// //                   onNotification: (notification) {
// //                     if (notification is UserScrollNotification) {
// //                       if (notification.direction == ScrollDirection.reverse) {
// //                         // Scrolling DOWN → small FAB
// //                         if (!_isFabSmall) {
// //                           setState(() {
// //                             _isFabSmall = true;
// //                           });
// //                         }
// //                       } else if (notification.direction == ScrollDirection.forward) {
// //                         // Scrolling UP → large FAB
// //                         if (_isFabSmall) {
// //                           setState(() {
// //                             _isFabSmall = false;
// //                           });
// //                         }
// //                       }
// //                     }

// //                     return false;
// //                   },
// //                   child: currentChopdi == null
// //                 ? const Center(
// //                     child: CircularProgressIndicator(),
// //                   )
// //                 : StreamBuilder<List<Customer>>(
// //                     stream: IsarService.isar.customers
// //                         .filter()
// //                         .chopdiIdEqualTo(currentChopdi!.id)
// //                         .watch(fireImmediately: true),

// //                     builder: (context, snapshot) {
// //                       final customers = snapshot.data ?? [];

// //                       return ListView(
// //                         physics: const BouncingScrollPhysics(),
// //                         padding: const EdgeInsets.only(bottom: 100),
// //                         children: [
// //                           // const SummaryCard(),
// //                           SummaryCard(
// //                             chopdiId: currentChopdi!.id,
// //                             isGaveLoanSelected: isGaveLoanSelected,
// //                           ),

// //                           const SizedBox(height: 18),

// //                           if (customers.isEmpty)
// //                             SizedBox(
// //                               height: 350,
// //                               child: _buildEmptyState(),
// //                             )
// //                           else
// //                             CustomerListSection(
// //                               customers: customers,
// //                             ),
// //                         ],
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCustomers(List<Customer> customers) {
// //     return CustomerListSection(
// //       customers: customers,
// //     );
// //   }


// //   Widget _buildEmptyState() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [

// //           SizedBox(
// //             height: 74,
// //             width: 82,
// //             child: Image.asset(
// //               'assets/home_screen_book.png',
// //             ),
// //           ),

// //           const SizedBox(height: 6),

// //           Text(
// //             'No customers yet!',
// //             style: GoogleFonts.manrope(
// //               color: ChopdiColors.navy,
// //               fontSize: 22,
// //               fontWeight: FontWeight.w700,
// //             ),
// //           ),

// //           const SizedBox(height: 3),

// //           Text(
// //             'Start by adding a loan to\n'
// //             'keep track of your borrowings easily',
// //             textAlign: TextAlign.center,
// //             style: GoogleFonts.manrope(
// //               color: ChopdiColors.navy,
// //               fontSize: 16,
// //               fontWeight: FontWeight.w700,
// //             ),
// //           ),

// //           const SizedBox(height: 12),

// //           Image.asset(
// //             'assets/line_home.png',
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:isar_community/isar.dart';

// import 'package:mychopdi/model/customer.dart';
// import 'package:mychopdi/service/isar_service.dart';
// import 'package:mychopdi/utils/app_colors.dart';
// import 'package:mychopdi/view/customers_screen.dart';
// import 'package:mychopdi/view/took_loan_customers_screen.dart';
// import 'package:mychopdi/widgets/took_loan_summary_card.dart';
// import 'package:mychopdi/widgets/took_loan_customer_card.dart';

// class TookLoanHomeContent extends StatelessWidget {
//   final int chopdiId;
//   final bool isGaveLoanSelected;

//   const TookLoanHomeContent({
//     super.key,
//     required this.chopdiId,
//     required this.isGaveLoanSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<Customer>>(
//       stream: IsarService.isar.customers
//           .filter()
//           .chopdiIdEqualTo(chopdiId)
//           .watch(fireImmediately: true),
//       builder: (context, snapshot) {
//         final customers = snapshot.data ?? [];

//         return ListView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.only(bottom: 20),
//           children: [
//             TookLoanSummaryCard(
//               chopdiId: chopdiId, 
//               isGaveLoanSelected: isGaveLoanSelected,
//             ),

//             const SizedBox(height: 18),

//             if (customers.isEmpty)
//               SizedBox(
//                 height: 350,
//                 child: _buildEmptyState(),
//               )
//             else
//               TookLoanCustomerListSection(
//                 customers: customers,
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             height: 74,
//             width: 82,
//             child: Image.asset(
//               'assets/home_screen_book.png',
//             ),
//           ),

//           const SizedBox(height: 6),

//           Text(
//             'No loans yet!',
//             style: GoogleFonts.manrope(
//               color: ChopdiColors.navy,
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//             ),
//           ),

//           const SizedBox(height: 3),

//           Text(
//             'Start by adding a loan to\n'
//             'keep track of your borrowings easily',
//             textAlign: TextAlign.center,
//             style: GoogleFonts.manrope(
//               color: ChopdiColors.navy,
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//             ),
//           ),

//           const SizedBox(height: 12),

//           Image.asset(
//             'assets/line_home.png',
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/took_loan_customers_screen.dart';
import 'package:mychopdi/widgets/took_loan_summary_card.dart';

class TookLoanHomeContent extends StatelessWidget {
  final int chopdiId;
  final bool isGaveLoanSelected;

  const TookLoanHomeContent({
    super.key,
    required this.chopdiId,
    required this.isGaveLoanSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      // Get ONLY took-loan transactions
      stream: IsarService.isar.transactions
          .filter()
          .chopdiIdEqualTo(chopdiId)
          .typeEqualTo(TransactionType.took)
          .watch(fireImmediately: true),

      builder: (context, transactionSnapshot) {
        final tookTransactions =
            transactionSnapshot.data ?? <Transaction>[];

        // Customer IDs that have a Took Loan transaction
        final tookLoanCustomerIds = tookTransactions
            .map((tx) => tx.customerId)
            .toSet();

        return StreamBuilder<List<Customer>>(
          stream: IsarService.isar.customers
              .filter()
              .chopdiIdEqualTo(chopdiId)
              .watch(fireImmediately: true),

          builder: (context, customerSnapshot) {
            final allCustomers =
                customerSnapshot.data ?? <Customer>[];

            // Only customers who have Took Loan transactions
            final tookLoanCustomers = allCustomers
                .where(
                  (customer) =>
                      tookLoanCustomerIds.contains(customer.id),
                )
                .toList();

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                TookLoanSummaryCard(
                  chopdiId: chopdiId,
                  // isGaveLoanSelected: isGaveLoanSelected,
                ),

                const SizedBox(height: 18),

                if (tookLoanCustomers.isEmpty)
                  SizedBox(
                    height: 350,
                    child: _buildEmptyState(),
                  )
                else
                  TookLoanCustomerListSection(
                    customers: tookLoanCustomers,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 74,
            width: 82,
            child: Image.asset(
              'assets/home_screen_book.png',
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'No loans yet!',
            style: GoogleFonts.manrope(
              color: ChopdiColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            'Start by adding a loan to\n'
            'keep track of your borrowings easily',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: ChopdiColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Image.asset(
            'assets/line_home.png',
          ),
        ],
      ),
    );
  }
}