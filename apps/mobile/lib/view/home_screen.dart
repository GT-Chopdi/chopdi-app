// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:isar_community/isar.dart';
// import 'package:mychopdi/model/customer.dart';
// import 'package:mychopdi/service/isar_service.dart';
// import 'package:mychopdi/utils/app_colors.dart';
// import 'package:mychopdi/view/customers_screen.dart';
// import 'package:mychopdi/view/add_customer_screen.dart';
// import 'package:mychopdi/view/took_loan_add_lender_screen.dart';
// import 'package:mychopdi/view/took_loan_home_screen.dart';
// import 'package:mychopdi/widgets/home_header.dart';
// import 'package:mychopdi/widgets/loan_toggle.dart';
// import 'package:mychopdi/widgets/summary_card.dart';
// import 'package:mychopdi/model/chopdi.dart';
// import 'package:mychopdi/service/chopdi_service.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _isFabSmall = false;
//   Chopdi? currentChopdi;
//   bool isGaveLoan = true;
//   bool isGaveLoanSelected = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentChopdi();
//   }

//   Future<void> _loadCurrentChopdi() async {
//     final chopdi = await ChopdiService.getCurrentChopdi();

//     if (!mounted) return;

//     setState(() {
//       currentChopdi = chopdi;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ChopdiColors.cream,

//       floatingActionButton: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 250),
//         transitionBuilder: (child, animation) {
//           return ScaleTransition(
//             scale: animation,
//             child: child,
//           );
//         },

//         child: _isFabSmall
//             ? FloatingActionButton(
//                 key: ValueKey(
//                   isGaveLoanSelected ? "small-gave" : "small-took",
//                 ),
//                 backgroundColor: const Color(0xff243B67),
//                 elevation: 2,

//                 onPressed: () async {
//                   if (currentChopdi == null) return;

//                   if (isGaveLoanSelected) {
//                     // =========================
//                     // I GAVE LOAN
//                     // =========================
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => AddCustomerScreen(
//                           chopdiId: currentChopdi!.id,
//                         ),
//                       ),
//                     );
//                   } else {
//                     // Add your Add Loan screen here
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => TookLoanAddLenderScreen(
//                           chopdiId: currentChopdi!.id,
//                         ),
//                       ),
//                     );
//                   }
//                 },

//                 child: const Icon(
//                   Icons.add,
//                   color: Colors.white,
//                 ),
//               )

//             : FloatingActionButton.extended(
//                 key: ValueKey(
//                   isGaveLoanSelected ? "large-gave" : "large-took",
//                 ),
//                 backgroundColor: const Color(0xff243B67),
//                 elevation: 2,

//                 onPressed: () async {
//                   if (currentChopdi == null) return;

//                   if (isGaveLoanSelected) {
//                     // =========================
//                     // I GAVE LOAN
//                     // =========================
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => AddCustomerScreen(
//                           chopdiId: currentChopdi!.id,
//                         ),
//                       ),
//                     );
//                   } else {
//                     // =========================
//                     // I TOOK LOAN
//                     // =========================
//                     // Add your Add Loan screen here
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => TookLoanAddLenderScreen(
//                           chopdiId: currentChopdi!.id,
//                         ),
//                       ),
//                     );
//                   }
//                 },

//                 icon: const Icon(
//                   Icons.add,
//                   color: Colors.white,
//                 ),

//                 label: Text(
//                   isGaveLoanSelected
//                       ? "Add Customer"
//                       : "Add Loan",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//       ),

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(14),

//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               // const HomeHeader(),
//               HomeHeader(
//                 currentChopdi: currentChopdi,
//                 onChopdiChanged: (chopdi) {
//                   setState(() {
//                     currentChopdi = chopdi;
//                   });
//                 }, 
//               ),

//               const SizedBox(height: 18),

//               // const LoanToggle(),
//               LoanToggle(
//                 isGaveLoanSelected: isGaveLoanSelected,
//                 onChanged: (value) {
//                   setState(() {
//                     isGaveLoanSelected = value;
//                   });
//                 },
//               ),

//               const SizedBox(height: 18),


//               Expanded(
//                 child: isGaveLoanSelected ? NotificationListener<ScrollNotification>(
//                   onNotification: (notification) {
//                     if (notification is UserScrollNotification) {
//                       if (notification.direction == ScrollDirection.reverse) {
//                         // Scrolling DOWN → small FAB
//                         if (!_isFabSmall) {
//                           setState(() {
//                             _isFabSmall = true;
//                           });
//                         }
//                       } else if (notification.direction == ScrollDirection.forward) {
//                         // Scrolling UP → large FAB
//                         if (_isFabSmall) {
//                           setState(() {
//                             _isFabSmall = false;
//                           });
//                         }
//                       }
//                     }

//                     return false;
//                   },
//                   child: currentChopdi == null
//                 ? const Center(
//                     child: CircularProgressIndicator(),
//                   )
//                 // : StreamBuilder<List<Customer>>(
//                 //     stream: IsarService.isar.customers
//                 //         .filter()
//                 //         .chopdiIdEqualTo(currentChopdi!.id)
//                 //         .watch(fireImmediately: true),

//                 //     builder: (context, snapshot) {
//                 //       final customers = snapshot.data ?? [];

//                 //       return ListView(
//                 //         physics: const BouncingScrollPhysics(),
//                 //         padding: const EdgeInsets.only(bottom: 100),
//                 //         children: [
//                 //           // const SummaryCard(),
//                 //           SummaryCard(
//                 //             chopdiId: currentChopdi!.id,
//                 //             isGaveLoanSelected: isGaveLoanSelected,
//                 //           ),

//                 //           const SizedBox(height: 18),

//                 //           if (customers.isEmpty)
//                 //             SizedBox(
//                 //               height: 350,
//                 //               child: _buildEmptyState(),
//                 //             )
//                 //           else
//                 //             CustomerListSection(
//                 //               customers: customers,
//                 //             ),
//                 //         ],
//                 //       );
//                 //     },
//                 //   ),
//                 : StreamBuilder<List<Customer>>(
//                   stream: IsarService.isar.customers
//                       .filter()
//                       .chopdiIdEqualTo(currentChopdi!.id)
//                       .watch(fireImmediately: true),

//                   builder: (context, snapshot) {
//                     final allCustomers = snapshot.data ?? [];

//                     // ONLY customers belonging to I GAVE LOAN
//                     final customers = allCustomers
//                         .where(
//                           (customer) => customer.loanType == "gave",
//                         )
//                         .toList();

//                     return ListView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.only(bottom: 100),
//                       children: [
//                         SummaryCard(
//                           chopdiId: currentChopdi!.id,
//                           isGaveLoanSelected: isGaveLoanSelected,
//                         ),

//                         const SizedBox(height: 18),

//                         if (customers.isEmpty)
//                           SizedBox(
//                             height: 350,
//                             child: _buildEmptyState(),
//                           )
//                         else
//                           CustomerListSection(
//                             customers: customers,
//                           ),
//                       ],
//                     );
//                   },
//                 )
//                 )
//                 // : TookLoanHomeContent(
//                 //     chopdiId: currentChopdi!.id,
//                 //     isGaveLoanSelected: isGaveLoanSelected,
//                 //   ),
//                 : NotificationListener<ScrollNotification>(
//                     onNotification: (notification) {
//                       if (notification is UserScrollNotification) {
//                         if (notification.direction == ScrollDirection.reverse) {
//                           // Scrolling DOWN → small FAB
//                           if (!_isFabSmall) {
//                             setState(() {
//                               _isFabSmall = true;
//                             });
//                           }
//                         } else if (notification.direction == ScrollDirection.forward) {
//                           // Scrolling UP → large FAB
//                           if (_isFabSmall) {
//                             setState(() {
//                               _isFabSmall = false;
//                             });
//                           }
//                         }
//                       }

//                       return false;
//                     },
//                     child: TookLoanHomeContent(
//                       chopdiId: currentChopdi!.id,
//                       isGaveLoanSelected: isGaveLoanSelected,
//                     ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomers(List<Customer> customers) {
//     return CustomerListSection(
//       customers: customers,
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
//             'No customers yet!',
//             style: GoogleFonts.manrope(
//               color: ChopdiColors.navy,
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//             ),
//           ),

//           const SizedBox(height: 3),

//           Text(
//             'Start by adding a customer and\n'
//             'keep track of your loans easily',
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
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/customers_screen.dart';
import 'package:mychopdi/view/add_customer_screen.dart';
import 'package:mychopdi/view/took_loan_add_lender_screen.dart';
import 'package:mychopdi/view/took_loan_home_screen.dart';
import 'package:mychopdi/widgets/home_header.dart';
import 'package:mychopdi/widgets/loan_toggle.dart';
import 'package:mychopdi/widgets/summary_card.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/service/chopdi_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isFabSmall = false;
  Chopdi? currentChopdi;

  bool isGaveLoan = true;
  bool isGaveLoanSelected = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentChopdi();
  }

  Future<void> _loadCurrentChopdi() async {
    final chopdi = await ChopdiService.getCurrentChopdi();

    if (!mounted) return;

    setState(() {
      currentChopdi = chopdi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChopdiColors.cream,

      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },

        child: _isFabSmall
            ? FloatingActionButton(
                key: ValueKey(
                  isGaveLoanSelected ? "small-gave" : "small-took",
                ),
                backgroundColor: const Color(0xff243B67),
                elevation: 2,

                onPressed: () async {
                  if (currentChopdi == null) return;

                  if (isGaveLoanSelected) {
                    // =========================
                    // I GAVE LOAN
                    // =========================
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddCustomerScreen(
                          chopdiId: currentChopdi!.id,
                        ),
                      ),
                    );
                  } else {
                    // =========================
                    // I TOOK LOAN
                    // =========================
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TookLoanAddLenderScreen(
                          chopdiId: currentChopdi!.id,
                        ),
                      ),
                    );
                  }
                },

                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              )

            : FloatingActionButton.extended(
                key: ValueKey(
                  isGaveLoanSelected ? "large-gave" : "large-took",
                ),
                backgroundColor: const Color(0xff243B67),
                elevation: 2,

                onPressed: () async {
                  if (currentChopdi == null) return;

                  if (isGaveLoanSelected) {
                    // =========================
                    // I GAVE LOAN
                    // =========================
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddCustomerScreen(
                          chopdiId: currentChopdi!.id,
                        ),
                      ),
                    );
                  } else {
                    // =========================
                    // I TOOK LOAN
                    // =========================
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TookLoanAddLenderScreen(
                          chopdiId: currentChopdi!.id,
                        ),
                      ),
                    );
                  }
                },

                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),

                label: Text(
                  isGaveLoanSelected
                      ? "Add Customer"
                      : "Add Loan",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =========================
              // HEADER
              // =========================
              HomeHeader(
                currentChopdi: currentChopdi,
                onChopdiChanged: (chopdi) {
                  setState(() {
                    currentChopdi = chopdi;
                  });
                },
              ),

              const SizedBox(height: 18),

              // =========================
              // LOAN TOGGLE
              // =========================
              LoanToggle(
                isGaveLoanSelected: isGaveLoanSelected,
                onChanged: (value) {
                  setState(() {
                    isGaveLoanSelected = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              Expanded(
                child: isGaveLoanSelected

                    // ======================================================
                    // I GAVE LOAN
                    // ======================================================
                    ? NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is UserScrollNotification) {
                            if (notification.direction ==
                                ScrollDirection.reverse) {

                              // Scrolling DOWN → small FAB
                              if (!_isFabSmall) {
                                setState(() {
                                  _isFabSmall = true;
                                });
                              }

                            } else if (notification.direction ==
                                ScrollDirection.forward) {

                              // Scrolling UP → large FAB
                              if (_isFabSmall) {
                                setState(() {
                                  _isFabSmall = false;
                                });
                              }
                            }
                          }

                          return false;
                        },

                        child: currentChopdi == null
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )

                            : StreamBuilder<List<Customer>>(
                                stream: IsarService.isar.customers
                                    .filter()

                                    // Current Chopdi only
                                    .chopdiIdEqualTo(
                                      currentChopdi!.id,
                                    )

                                    // IMPORTANT:
                                    // Do not show soft-deleted customers.
                                    .deletedAtIsNull()

                                    .watch(
                                      fireImmediately: true,
                                    ),

                                builder: (context, snapshot) {
                                  final allCustomers =
                                      snapshot.data ?? [];

                                  // ONLY customers belonging to
                                  // I GAVE LOAN
                                  final customers = allCustomers
                                      .where(
                                        (customer) =>
                                            customer.loanType == "gave",
                                      )
                                      .toList();

                                  return ListView(
                                    physics:
                                        const BouncingScrollPhysics(),
                                    padding:
                                        const EdgeInsets.only(
                                      bottom: 100,
                                    ),
                                    children: [

                                      SummaryCard(
                                        chopdiId:
                                            currentChopdi!.id,
                                        isGaveLoanSelected:
                                            isGaveLoanSelected,
                                      ),

                                      const SizedBox(height: 18),

                                      if (customers.isEmpty)
                                        SizedBox(
                                          height: 350,
                                          child:
                                              _buildEmptyState(),
                                        )
                                      else
                                        CustomerListSection(
                                          customers: customers,
                                        ),
                                    ],
                                  );
                                },
                              ),
                      )

                    // ======================================================
                    // I TOOK LOAN
                    // ======================================================
                    : NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification
                              is UserScrollNotification) {

                            if (notification.direction ==
                                ScrollDirection.reverse) {

                              // Scrolling DOWN → small FAB
                              if (!_isFabSmall) {
                                setState(() {
                                  _isFabSmall = true;
                                });
                              }

                            } else if (notification.direction ==
                                ScrollDirection.forward) {

                              // Scrolling UP → large FAB
                              if (_isFabSmall) {
                                setState(() {
                                  _isFabSmall = false;
                                });
                              }
                            }
                          }

                          return false;
                        },

                        child: TookLoanHomeContent(
                          chopdiId: currentChopdi!.id,
                          isGaveLoanSelected:
                              isGaveLoanSelected,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomers(List<Customer> customers) {
    return CustomerListSection(
      customers: customers,
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
            'No customers yet!',
            style: GoogleFonts.manrope(
              color: ChopdiColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            'Start by adding a customer and\n'
            'keep track of your loans easily',
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