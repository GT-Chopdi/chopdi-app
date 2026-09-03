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

      // ============================================================
      // FLOATING ACTION BUTTON
      // ============================================================
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
                  isGaveLoanSelected ? "Add Customer" : "Add Loan",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),

      // ============================================================
      // BODY
      // ============================================================
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

              // ======================================================
              // CONTENT
              // ======================================================
              Expanded(
                child: isGaveLoanSelected
                    ? _buildGaveLoanContent()
                    : _buildTookLoanContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // I GAVE LOAN CONTENT
  // ===========================================================================

  Widget _buildGaveLoanContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          if (notification.direction == ScrollDirection.reverse) {
            // Scrolling DOWN → small FAB
            if (!_isFabSmall) {
              setState(() {
                _isFabSmall = true;
              });
            }
          } else if (notification.direction == ScrollDirection.forward) {
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
                final allCustomers = snapshot.data ?? [];

                // ONLY customers belonging to
                // I GAVE LOAN
                final customers = allCustomers
                    .where(
                      (customer) => customer.loanType == "gave",
                    )
                    .toList();

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    bottom: 100,
                  ),
                  children: [
                    SummaryCard(
                      chopdiId: currentChopdi!.id,
                      isGaveLoanSelected: isGaveLoanSelected,
                    ),

                    const SizedBox(height: 18),

                    if (customers.isEmpty)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth.isFinite
                              ? constraints.maxWidth
                              : MediaQuery.of(context).size.width;

                          const emptyStateHeight = 350.0;

                          return SizedBox(
                            height: emptyStateHeight,
                            child: _buildEmptyState(
                              width,
                              emptyStateHeight,
                            ),
                          );
                        },
                      )
                    else
                      CustomerListSection(
                        customers: customers,
                      ),
                  ],
                );
              },
            ),
    );
  }

  // ===========================================================================
  // I TOOK LOAN CONTENT
  // ===========================================================================

  Widget _buildTookLoanContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          if (notification.direction == ScrollDirection.reverse) {
            // Scrolling DOWN → small FAB
            if (!_isFabSmall) {
              setState(() {
                _isFabSmall = true;
              });
            }
          } else if (notification.direction == ScrollDirection.forward) {
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
          : TookLoanHomeContent(
              chopdiId: currentChopdi!.id,
              isGaveLoanSelected: isGaveLoanSelected,
            ),
    );
  }

  // ===========================================================================
  // EMPTY STATE HEIGHT
  // ===========================================================================

  double _emptyStateHeight(double availableHeight) {
    // Never allow the empty state to become too small.
    if (availableHeight < 250) {
      return 250;
    }

    // Give the empty state the available remaining area.
    return availableHeight;
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================

  Widget _buildEmptyState(
    double width,
    double height,
  ) {
    // Responsive scale.
    //
    // Small phone:
    // around 0.85
    //
    // Normal phone:
    // around 1.0
    //
    // Large phone:
    // around 1.10
    final scale = (width / 390).clamp(
      0.82,
      1.10,
    );

    final imageWidth = (82 * scale).clamp(
      68.0,
      92.0,
    );

    final imageHeight = (74 * scale).clamp(
      62.0,
      84.0,
    );

    final titleFontSize = (22 * scale).clamp(
      18.0,
      23.0,
    );

    final descriptionFontSize = (16 * scale).clamp(
      13.0,
      17.0,
    );

    final horizontalPadding = (width * 0.05).clamp(
      12.0,
      28.0,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 55,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: imageWidth,
            height: imageHeight,
            child: Image.asset(
              'assets/home_screen_book.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'No customers yet!',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: ChopdiColors.navy,
              fontSize: titleFontSize,
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
              fontSize: descriptionFontSize,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 12),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: width * 0.65,
            ),
            child: Image.asset(
              'assets/line_home.png',
              height: 125,
              width: 65,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CUSTOMERS
  // ===========================================================================

  Widget _buildCustomers(List<Customer> customers) {
    return CustomerListSection(
      customers: customers,
    );
  }
}

