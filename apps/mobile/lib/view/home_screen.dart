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
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: _isFabSmall ? 56 : 150,
        height: 56,
        child: FloatingActionButton(
          backgroundColor: const Color(0xff243B67),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () async {
            if (currentChopdi == null) return;

            if (isGaveLoanSelected) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCustomerScreen(
                    chopdiId: currentChopdi!.id,
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
          },
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
                    isGaveLoanSelected ? "Add Customer" : "Add Loan",
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                currentChopdi: currentChopdi,
                onChopdiChanged: (chopdi) {
                  setState(() {
                    currentChopdi = chopdi;
                  });
                },
              ),
              const SizedBox(height: 18),
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
                    ? _buildGaveLoanContent()
                    : _buildTookLoanContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            .watch(fireImmediately: true),
        builder: (context, snapshot) {
          final allCustomers = snapshot.data ?? [];
          final customers = allCustomers
              .where((customer) => customer.loanType == "gave")
              .toList();

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              SummaryCard(
                chopdiId: currentChopdi!.id,
                isGaveLoanSelected: isGaveLoanSelected,
              ),
              const SizedBox(height: 18),

              // ==========================================
              // CLEAN EMPTY STATE
              // ==========================================
              if (customers.isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 40), // Gives spacing below the card
                  alignment: Alignment.center,
                  child: _buildEmptyState(context),
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

  Widget _buildEmptyState(BuildContext context) {
    // Safely get screen width without LayoutBuilder
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 390).clamp(0.82, 1.10);

    final titleFontSize = (22 * scale).clamp(18.0, 23.0);
    final descriptionFontSize = (16 * scale).clamp(13.0, 17.0);
    final horizontalPadding = (width * 0.05).clamp(12.0, 28.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Prevents infinite height issues
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