import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/chopdi_service.dart';
import 'package:mychopdi/utils/app_colors.dart';

import 'package:mychopdi/view/customers_screen.dart';
import 'package:mychopdi/view/add_customer_screen.dart';
import 'package:mychopdi/view/took_loan_add_lender_screen.dart';
import 'package:mychopdi/view/took_loan_home_screen.dart';

import 'package:mychopdi/widgets/home_header.dart';
import 'package:mychopdi/widgets/loan_toggle.dart';
import 'package:mychopdi/widgets/summary_card.dart';

import 'customer_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool initialGaveLoanSelected;

  const HomeScreen({
    super.key,
    this.initialGaveLoanSelected = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isFabSmall = false;

  Chopdi? currentChopdi;

  bool isGaveLoan = true;

  late bool isGaveLoanSelected;

  @override
  void initState() {
    super.initState();

    isGaveLoanSelected = widget.initialGaveLoanSelected;

    _loadCurrentChopdi();
  }

  Future<void> _loadCurrentChopdi() async {
    final chopdi = await ChopdiService.getCurrentChopdi();

    if (!mounted) return;

    setState(() {
      currentChopdi = chopdi;
    });
  }

  // ==========================================================
  // SWIPE BETWEEN LOAN SECTIONS
  // ==========================================================

  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    // Swipe right → I Gave Loan
    if (details.primaryVelocity! > 0) {
      if (!isGaveLoanSelected) {
        setState(() {
          isGaveLoanSelected = true;
        });
      }
    }

    // Swipe left → I Took Loan
    else if (details.primaryVelocity! < 0) {
      if (isGaveLoanSelected) {
        setState(() {
          isGaveLoanSelected = false;
        });
      }
    }
  }

  // ==========================================================
  // ADD CUSTOMER / ADD LOAN
  // ==========================================================

  Future<void> _openAddScreen() async {
    if (currentChopdi == null) return;

    if (isGaveLoanSelected) {
      final Customer? customer = await Navigator.push<Customer>(
        context,
        MaterialPageRoute(
          builder: (_) => AddCustomerScreen(
            chopdiId: currentChopdi!.id,
          ),
        ),
      );

      if (!mounted || customer == null) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerDetailsScreen(
            customer: customer,
          ),
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TookLoanAddLenderScreen(
            chopdiId: currentChopdi!.id,
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ChopdiColors.cream,

      // ========================================================
      // FLOATING ACTION BUTTON
      // ========================================================

      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: _isFabSmall ? 56 : 150,
        height: 56,
        child: FloatingActionButton(
          backgroundColor: const Color(0xff243B67),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onPressed: _openAddScreen,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Icon(
                Icons.add,
                color: Colors.white,
              ),

              if (!_isFabSmall) ...[
                const SizedBox(width: 8),

                Flexible(
                  child: Text(
                    isGaveLoanSelected
                        ? l10n.homeAddCustomer
                        : l10n.homeAddLoan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              HomeHeader(
                currentChopdi: currentChopdi,
                onChopdiChanged: (chopdi) {
                  setState(() {
                    currentChopdi = chopdi;
                  });
                },
              ),

              const SizedBox(height: 18),

              // ==================================================
              // LOAN TOGGLE
              // ==================================================

              LoanToggle(
                isGaveLoanSelected: isGaveLoanSelected,
                onChanged: (value) {
                  setState(() {
                    isGaveLoanSelected = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              // ==================================================
              // CONTENT WITH SWIPE SUPPORT
              // ==================================================

              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragEnd: _handleSwipe,
                  child: isGaveLoanSelected
                      ? _buildGaveLoanContent()
                      : _buildTookLoanContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GAVE LOAN CONTENT
  // ============================================================

  Widget _buildGaveLoanContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (!_isFabSmall) {
              setState(() {
                _isFabSmall = true;
              });
            }
          } else if (notification.direction == ScrollDirection.forward) {
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
            .chopdiIdEqualTo(currentChopdi!.id)
            .deletedAtIsNull()
            .watch(
          fireImmediately: true,
        ),
        builder: (context, snapshot) {
          final allCustomers = snapshot.data ?? [];

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
              // ==========================================
              // SUMMARY CARD
              // ==========================================

              SummaryCard(
                chopdiId: currentChopdi!.id,
                isGaveLoanSelected: isGaveLoanSelected,
              ),

              const SizedBox(height: 18),

              // ==========================================
              // EMPTY STATE
              // ==========================================

              if (customers.isEmpty)
                Container(
                  margin: const EdgeInsets.only(
                    top: 40,
                  ),
                  alignment: Alignment.center,
                  child: _buildEmptyState(context),
                )

              // ==========================================
              // CUSTOMER LIST
              // ==========================================

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

  // ============================================================
  // TOOK LOAN CONTENT
  // ============================================================

  Widget _buildTookLoanContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (!_isFabSmall) {
              setState(() {
                _isFabSmall = true;
              });
            }
          } else if (notification.direction == ScrollDirection.forward) {
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

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final scale = (width / 390).clamp(
      0.82,
      1.10,
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

    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 100,
            child: Image.asset(
              'assets/home_screen_book.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            l10n.homeNoCustomersYet,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: ChopdiColors.navy,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            l10n.homeStartAddingCustomer,
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
              height: 105,
              width: 65,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}