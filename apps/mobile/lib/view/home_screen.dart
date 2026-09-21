import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

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

  late final PageController _pageController;

  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _pageOffset =
    widget.initialGaveLoanSelected ? 0.0 : 1.0;

    _pageController = PageController(
      initialPage:
      widget.initialGaveLoanSelected ? 0 : 1,
    );

    // Live tab animation while swiping
    _pageController.addListener(_onPageScroll);

    _loadCurrentChopdi();
  }

  void _onPageScroll() {
    if (!_pageController.hasClients) return;

    final page = _pageController.page;

    if (page == null) return;

    if (!mounted) return;

    setState(() {
      _pageOffset = page.clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD CURRENT CHOPDI
  // ============================================================

  Future<void> _loadCurrentChopdi() async {
    final chopdi =
    await ChopdiService.getCurrentChopdi();

    if (!mounted) return;

    setState(() {
      currentChopdi = chopdi;
    });
  }

  // ============================================================
  // OPEN ADD SCREEN
  // ============================================================

  Future<void> _openAddScreen(
      bool isGaveLoan,
      ) async {
    if (currentChopdi == null) return;

    if (isGaveLoan) {
      final Customer? customer =
      await Navigator.push<Customer>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AddCustomerScreen(
                chopdiId:
                currentChopdi!.id,
              ),
        ),
      );

      if (!mounted || customer == null) {
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CustomerDetailsScreen(
                customer: customer,
              ),
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TookLoanAddLenderScreen(
                chopdiId:
                currentChopdi!.id,
              ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // FAB SCROLL
  // ============================================================

  bool _handleScrollNotification(
      ScrollNotification notification,
      ) {
    if (notification is UserScrollNotification) {
      if (notification.direction ==
          ScrollDirection.reverse &&
          !_isFabSmall) {
        setState(() {
          _isFabSmall = true;
        });
      } else if (notification.direction ==
          ScrollDirection.forward &&
          _isFabSmall) {
        setState(() {
          _isFabSmall = false;
        });
      }
    }

    return false;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isGaveLoan =
        _pageOffset < 0.5;

    return Scaffold(
      backgroundColor:
      ChopdiColors.cream,

      // ========================================================
      // FAB
      // ========================================================

      floatingActionButton:
      AnimatedContainer(
        duration:
        const Duration(milliseconds: 320),
        curve:
        Curves.easeOutBack,

        width:
        _isFabSmall ? 56 : 150,

        height: 56,

        decoration:
        BoxDecoration(
          borderRadius:
          BorderRadius.circular(19),

          boxShadow: [
            BoxShadow(
              color:
              const Color(0xff243B67)
                  .withValues(
                alpha: 0.22,
              ),
              blurRadius: 14,
              offset:
              const Offset(0, 6),
            ),
          ],
        ),

        child: FloatingActionButton(
          backgroundColor:
          const Color(0xff243B67),

          elevation: 0,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(19),
          ),

          onPressed: () =>
              _openAddScreen(
                isGaveLoan,
              ),

          child: AnimatedSwitcher(
            duration:
            const Duration(
              milliseconds: 240,
            ),

            switchInCurve:
            Curves.easeOutBack,

            switchOutCurve:
            Curves.easeIn,

            transitionBuilder:
                (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },

            child: _isFabSmall
                ? const Icon(
              Icons.add_rounded,
              key: ValueKey(
                'small_fab',
              ),
              color: Colors.white,
              size: 25,
            )
                : Row(
              key: const ValueKey(
                'large_fab',
              ),

              mainAxisAlignment:
              MainAxisAlignment
                  .center,

              children: [
                const Icon(
                  Icons.add_rounded,
                  color:
                  Colors.white,
                  size: 23,
                ),

                const SizedBox(
                  width: 8,
                ),

                Flexible(
                  child: Text(
                    isGaveLoan
                        ? 'Add Customer'
                        : 'Add Loan',

                    maxLines: 1,

                    overflow:
                    TextOverflow
                        .ellipsis,

                    style:
                    GoogleFonts
                        .manrope(
                      color:
                      Colors.white,
                      fontWeight:
                      FontWeight
                          .w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.all(14),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER
              // ==================================================

              HomeHeader(
                currentChopdi:
                currentChopdi,

                onChopdiChanged:
                    (chopdi) {
                  setState(() {
                    currentChopdi =
                        chopdi;
                  });
                },
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // ANIMATED TAB
              // ==================================================

              _buildPremiumTabSwitcher(),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // PAGE VIEW
              // ==================================================

              Expanded(
                child:
                NotificationListener<
                    ScrollNotification>(
                  onNotification:
                  _handleScrollNotification,

                  child: PageView(
                    controller:
                    _pageController,

                    physics:
                    const BouncingScrollPhysics(),

                    onPageChanged:
                        (index) {
                      if (!mounted) return;

                      setState(() {
                        _pageOffset =
                            index.toDouble();
                      });
                    },

                    children: [
                      // ==========================================
                      // I GAVE
                      // ==========================================

                      _KeepAliveTab(
                        child:
                        currentChopdi ==
                            null
                            ? const Center(
                          child:
                          CircularProgressIndicator(),
                        )
                            : _GaveLoanContent(
                          currentChopdi:
                          currentChopdi!,
                          isGaveLoanSelected:
                          true,
                        ),
                      ),

                      // ==========================================
                      // I TOOK
                      // ==========================================

                      _KeepAliveTab(
                        child:
                        currentChopdi ==
                            null
                            ? const Center(
                          child:
                          CircularProgressIndicator(),
                        )
                            : TookLoanHomeContent(
                          chopdiId:
                          currentChopdi!
                              .id,
                          isGaveLoanSelected:
                          false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PREMIUM TAB SWITCHER
  // ============================================================

  Widget _buildPremiumTabSwitcher() {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        final totalWidth =
            constraints.maxWidth;

        const double outerPadding =
        5.0;

        final availableWidth =
            totalWidth -
                (outerPadding * 2);

        final tabWidth =
            availableWidth / 2;

        final progress =
        _pageOffset.clamp(
          0.0,
          1.0,
        );

        // How much we are currently moving
        final distance =
        (progress -
            progress.round())
            .abs();

        final movement =
        (distance * 2)
            .clamp(
          0.0,
          1.0,
        );

        // Liquid stretch effect
        final stretch =
        Curves.easeOut.transform(
          movement,
        );

        final capsuleWidth =
            tabWidth +
                (stretch * 18);

        final capsuleLeft =
            outerPadding +
                (progress *
                    tabWidth) -
                (stretch * 9);

        return Container(
          height: 76,

          padding:
          const EdgeInsets.all(
            outerPadding,
          ),

          decoration:
          BoxDecoration(
            color:
            const Color(
              0xffF7F8FB,
            ),

            borderRadius:
            BorderRadius.circular(
              24,
            ),

            border:
            Border.all(
              color:
              const Color(
                0xff243B67,
              ).withValues(
                alpha: 0.07,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color:
                const Color(
                  0xff243B67,
                ).withValues(
                  alpha: 0.075,
                ),
                blurRadius: 20,
                offset:
                const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),

          child: Stack(
            clipBehavior:
            Clip.none,

            children: [
              // =================================================
              // MOVING ACTIVE PILL
              // =================================================

              Positioned(
                left:
                capsuleLeft -
                    outerPadding,

                top: 0,

                width:
                capsuleWidth,

                height: 66,

                child:
                _buildLiquidCapsule(
                  stretch:
                  stretch,
                ),
              ),

              // =================================================
              // TAB CONTENT
              // =================================================

              Row(
                children: [
                  Expanded(
                    child:
                    _buildAnimatedLoanTab(
                      index: 0,

                      title:
                      'I Gave',

                      subtitle:
                      'Money to receive',

                      icon:
                      Icons
                          .north_east_rounded,

                      progress:
                      (1.0 -
                          progress)
                          .clamp(
                        0.0,
                        1.0,
                      ),
                    ),
                  ),

                  Expanded(
                    child:
                    _buildAnimatedLoanTab(
                      index: 1,

                      title:
                      'I Took',

                      subtitle:
                      'Money to pay',

                      icon:
                      Icons
                          .south_west_rounded,

                      progress:
                      progress.clamp(
                        0.0,
                        1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // LIQUID ACTIVE CAPSULE
  // ============================================================

  Widget _buildLiquidCapsule({
    required double stretch,
  }) {
    return Container(
      decoration:
      BoxDecoration(
        gradient:
        const LinearGradient(
          begin:
          Alignment.topLeft,

          end:
          Alignment.bottomRight,

          colors: [
            Color(0xff536DAA),
            Color(0xff213861),
            Color(0xff030A19),
          ],
        ),

        borderRadius:
        BorderRadius.circular(
          20 + (stretch * 3),
        ),

        boxShadow: [
          BoxShadow(
            color:
            const Color(
              0xff243B67,
            ).withValues(
              alpha: 0.26,
            ),

            blurRadius:
            14 + (stretch * 5),

            spreadRadius:
            stretch * 0.5,

            offset:
            Offset(
              0,
              5 + (stretch * 2),
            ),
          ),
        ],
      ),

      child: Stack(
        children: [
          // =====================================================
          // TOP GLASS HIGHLIGHT
          // =====================================================

          Positioned(
            left: 18,
            right: 18,
            top: 5,
            height: 2,

            child: Container(
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  10,
                ),

                gradient:
                LinearGradient(
                  colors: [
                    Colors.white
                        .withValues(
                      alpha: 0.0,
                    ),

                    Colors.white
                        .withValues(
                      alpha: 0.18,
                    ),

                    Colors.white
                        .withValues(
                      alpha: 0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // =====================================================
          // INNER GLOW
          // =====================================================

          Positioned(
            left: 12,
            right: 12,
            bottom: 5,
            height: 8,

            child: Container(
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  20,
                ),

                gradient:
                LinearGradient(
                  begin:
                  Alignment.topCenter,

                  end:
                  Alignment.bottomCenter,

                  colors: [
                    Colors.transparent,

                    Colors.black
                        .withValues(
                      alpha: 0.06,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // =====================================================
          // MOVING LIGHT
          // =====================================================

          Positioned(
            left:
            25 + (stretch * 10),

            top: 8,

            child: Container(
              width: 28,
              height: 4,

              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  10,
                ),

                color: Colors.white
                    .withValues(
                  alpha: 0.07,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANIMATED TAB
  // ============================================================

  Widget _buildAnimatedLoanTab({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required double progress,
  }) {
    final bool active =
        progress > 0.5;

    // ==========================================================
    // COLORS
    // ==========================================================

    final iconColor =
    Color.lerp(
      const Color(0xff667085),
      Colors.white,
      progress,
    )!;

    final titleColor =
    Color.lerp(
      const Color(0xff344054),
      Colors.white,
      progress,
    )!;

    final subtitleColor =
    Color.lerp(
      const Color(0xff98A2B3),
      Colors.white
          .withValues(
        alpha: 0.72,
      ),
      progress,
    )!;

    // ==========================================================
    // SCALE
    // ==========================================================

    final contentScale =
        0.94 +
            (progress * 0.06);

    final iconScale =
        0.88 +
            (progress * 0.12);

    // ==========================================================
    // ROTATION
    // ==========================================================

    final rotation =
    index == 0
        ? (1.0 - progress) *
        -0.12
        : (1.0 - progress) *
        0.12;

    // ==========================================================
    // VERTICAL MOVEMENT
    // ==========================================================

    final verticalOffset =
        -2.5 * progress;

    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

      onTap: () {
        if (_pageOffset.round() ==
            index) {
          return;
        }

        _pageController
            .animateToPage(
          index,

          duration:
          const Duration(
            milliseconds: 520,
          ),

          curve:
          Curves.easeOutBack,
        );
      },

      child: Center(
        child: Transform.scale(
          scale:
          contentScale,

          child: Row(
            mainAxisAlignment:
            MainAxisAlignment
                .center,

            children: [
              // =================================================
              // ICON
              // =================================================

              Transform.translate(
                offset:
                Offset(
                  0,
                  verticalOffset,
                ),

                child:
                Transform.rotate(
                  angle:
                  rotation,

                  child:
                  Transform.scale(
                    scale:
                    iconScale,

                    child:
                    AnimatedContainer(
                      duration:
                      const Duration(
                        milliseconds: 180,
                      ),

                      curve:
                      Curves.easeOutCubic,

                      width: 41,

                      height: 41,

                      decoration:
                      BoxDecoration(
                        color: active
                            ? Colors.white
                            .withValues(
                          alpha:
                          0.13,
                        )
                            : const Color(
                          0xffEEF1F6,
                        ),

                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),

                        boxShadow:
                        active
                            ? [
                          BoxShadow(
                            color: Colors
                                .black
                                .withValues(
                              alpha:
                              0.08,
                            ),

                            blurRadius:
                            6,

                            offset:
                            const Offset(
                              0,
                              2,
                            ),
                          ),
                        ]
                            : null,
                      ),

                      child:
                      Icon(
                        icon,

                        size: 21,

                        color:
                        iconColor,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 9,
              ),

              // =================================================
              // TEXT
              // =================================================

              Transform.translate(
                offset:
                Offset(
                  (progress -
                      0.5) *
                      3,

                  0,
                ),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Text(
                      title,

                      style:
                      GoogleFonts
                          .manrope(
                        color:
                        titleColor,

                        fontSize: 14,

                        fontWeight:
                        FontWeight
                            .w800,

                        letterSpacing:
                        0.1,

                        height: 1.1,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      subtitle,

                      style:
                      GoogleFonts
                          .manrope(
                        color:
                        subtitleColor,

                        fontSize: 9.5,

                        fontWeight:
                        FontWeight
                            .w600,

                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ================================================================
// KEEP ALIVE
// ================================================================

class _KeepAliveTab extends StatefulWidget {
  final Widget child;

  const _KeepAliveTab({
    required this.child,
  });

  @override
  State<_KeepAliveTab> createState() =>
      _KeepAliveTabState();
}

class _KeepAliveTabState
    extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.child;
  }
}

// ================================================================
// GAVE LOAN CONTENT
// ================================================================

class _GaveLoanContent extends StatelessWidget {
  final Chopdi currentChopdi;
  final bool isGaveLoanSelected;

  const _GaveLoanContent({
    required this.currentChopdi,
    required this.isGaveLoanSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Customer>>(
      stream: IsarService.isar.customers
          .filter()
          .chopdiIdEqualTo(currentChopdi.id)
          .deletedAtIsNull()
          .watch(
        fireImmediately: true,
      ),
      builder: (context, snapshot) {
        // Prevent empty state flash.
        if (snapshot.connectionState ==
            ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final allCustomers =
            snapshot.data ?? [];

        final customers = allCustomers
            .where(
              (customer) =>
          customer.loanType == 'gave',
        )
            .toList();

        return ListView(
          physics:
          const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            bottom: 100,
          ),
          children: [
            // ==================================================
            // SUMMARY CARD
            // ==================================================
            SummaryCard(
              chopdiId: currentChopdi.id,
              isGaveLoanSelected:
              isGaveLoanSelected,
            ),

            const SizedBox(height: 18),

            // ==================================================
            // CUSTOMERS / EMPTY STATE
            // ==================================================
            if (customers.isEmpty)
              Container(
                margin: const EdgeInsets.only(
                  top: 40,
                ),
                alignment: Alignment.center,
                child: _buildEmptyState(
                  context,
                ),
              )
            else
              CustomerListSection(
                customers: customers,
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
      BuildContext context,
      ) {
    final width =
        MediaQuery.of(context).size.width;

    final scale =
    (width / 390).clamp(
      0.82,
      1.10,
    );

    final titleFontSize =
    (22 * scale).clamp(
      18.0,
      23.0,
    );

    final descriptionFontSize =
    (16 * scale).clamp(
      13.0,
      17.0,
    );

    final horizontalPadding =
    (width * 0.05).clamp(
      12.0,
      28.0,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ==================================================
          // BOOK
          // ==================================================
          SizedBox(
            width: 120,
            height: 100,
            child: Image.asset(
              'assets/home_screen_book.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 6),

          // ==================================================
          // TITLE
          // ==================================================
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

          // ==================================================
          // DESCRIPTION
          // ==================================================
          Text(
            'Start by adding a customer and\n'
                'keep track of your loans easily',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: ChopdiColors.navy,
              fontSize:
              descriptionFontSize,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 12),

          // ==================================================
          // LINE
          // ==================================================
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