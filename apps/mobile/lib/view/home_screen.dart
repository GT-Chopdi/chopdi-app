import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/chopdi_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

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
  // ============================================================
  // CONTROLLERS & NOTIFIERS
  // ============================================================

  Chopdi? currentChopdi;
  late final PageController _pageController;
  late final ValueNotifier<double> _pageOffsetNotifier;
  final ValueNotifier<bool> _isFabSmallNotifier = ValueNotifier<bool>(false);

  int _selectedTabIndex = 0;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _selectedTabIndex = widget.initialGaveLoanSelected ? 0 : 1;

    _pageOffsetNotifier = ValueNotifier<double>(
      widget.initialGaveLoanSelected ? 0.0 : 1.0,
    );

    _pageController = PageController(
      initialPage: widget.initialGaveLoanSelected ? 0 : 1,
    );

    _pageController.addListener(_handlePageScroll);
    _loadCurrentChopdi();
  }

  // ============================================================
  // LIVE PAGE POSITION (Driven purely by ValueNotifier)
  // ============================================================

  void _handlePageScroll() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page;
    if (page == null) return;

    _pageOffsetNotifier.value = page.clamp(0.0, 1.0).toDouble();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    _pageOffsetNotifier.dispose();
    _isFabSmallNotifier.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD CURRENT CHOPDI
  // ============================================================

  Future<void> _loadCurrentChopdi() async {
    final chopdi = await ChopdiService.getCurrentChopdi();
    if (!mounted) return;

    setState(() {
      currentChopdi = chopdi;
    });
  }

  // ============================================================
  // ADD CUSTOMER / ADD LOAN
  // ============================================================

  Future<void> _openAddScreen(bool isGaveLoan) async {
    if (currentChopdi == null) return;

    if (isGaveLoan) {
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

  // ============================================================
  // SCROLL NOTIFICATION HANDLER (FAB only - no setState)
  // ============================================================

  bool _handleScrollNotification(ScrollNotification notification) {
    // Check depth == 0 so horizontal PageView swiping doesn't affect the FAB
    if (notification is UserScrollNotification && notification.depth == 0) {
      if (notification.direction == ScrollDirection.reverse) {
        if (!_isFabSmallNotifier.value) {
          _isFabSmallNotifier.value = true;
        }
      } else if (notification.direction == ScrollDirection.forward) {
        if (_isFabSmallNotifier.value) {
          _isFabSmallNotifier.value = false;
        }
      }
    }
    return false;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool isGaveLoan = _selectedTabIndex == 0;

    return Scaffold(
      backgroundColor: ChopdiColors.cream,

      // ========================================================
      // FLOATING ACTION BUTTON (Zero Screen Rebuilds)
      // ========================================================
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _isFabSmallNotifier,
        builder: (context, isFabSmall, _) {
          return RepaintBoundary(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isFabSmall ? 56 : 150,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff243B67).withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: const Color(0xff243B67),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
                onPressed: () => _openAddScreen(isGaveLoan),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: isFabSmall
                      ? const Icon(
                    Icons.add_rounded,
                    key: ValueKey('small_fab'),
                    color: Colors.white,
                    size: 25,
                  )
                      : Row(
                    key: const ValueKey('large_fab'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isGaveLoan
                              ? l10n.homeAddCustomer
                              : l10n.homeAddLoan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
              HomeHeader(
                currentChopdi: currentChopdi,
                onChopdiChanged: (chopdi) {
                  setState(() {
                    currentChopdi = chopdi;
                  });
                },
              ),
              const SizedBox(height: 18),
              _buildPremiumTabSwitcher(),
              const SizedBox(height: 18),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    if (!mounted) return;
                    if (_selectedTabIndex != index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    }
                    _pageOffsetNotifier.value = index.toDouble();
                  },
                  children: [
                    _KeepAliveTab(child: _buildGaveLoanContent()),
                    _KeepAliveTab(child: _buildTookLoanContent()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PREMIUM MORPHING TAB SWITCHER (Optimized Layout pass)
  // ============================================================

  Widget _buildPremiumTabSwitcher() {
    const double outerPadding = 5.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double availableWidth = totalWidth - (outerPadding * 2);
        final double tabWidth = availableWidth / 2;

        return Container(
          height: 78,
          padding: const EdgeInsets.all(outerPadding),
          decoration: BoxDecoration(
            color: const Color(0xffF7F8FC),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xff243B67).withValues(alpha: 0.07),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff243B67).withValues(alpha: 0.075),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: RepaintBoundary(
            child: ValueListenableBuilder<double>(
              valueListenable: _pageOffsetNotifier,
              builder: (context, pageOffset, _) {
                final l10n = AppLocalizations.of(context);
                final double progress = pageOffset.clamp(0.0, 1.0);

                final double distance = (progress - progress.round()).abs();
                final double movement = (distance * 2).clamp(0.0, 1.0);
                final double stretch = Curves.easeOutCubic.transform(movement);

                final double capsuleWidth = tabWidth + (stretch * 16);
                final double capsuleLeft =
                    (progress * tabWidth) - (stretch * 8);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ===========================================
                    // ACTIVE CAPSULE
                    // ===========================================
                    Positioned(
                      left: capsuleLeft,
                      top: 0,
                      bottom: 0,
                      width: capsuleWidth,
                      child: _buildMorphingCapsule(movement: movement),
                    ),

                    // ===========================================
                    // TAB LABELS & ICONS
                    // ===========================================
                    Row(
                      children: [
                        Expanded(
                          child: _buildPremiumAnimatedTab(
                            index: 0,
                            title: l10n.iGaveLoan,
                            subtitle: l10n.moneyToReceive,
                            iconAsset: 'assets/home_blue_loan_new.png',
                            progress: (1.0 - progress).clamp(0.0, 1.0),
                          ),
                        ),
                        Expanded(
                          child: _buildPremiumAnimatedTab(
                            index: 1,
                            title: l10n.iTookLoan,
                            subtitle: l10n.moneyToPay,
                            iconAsset: 'assets/home_cream_loan_new.png',

                            progress: progress.clamp(0.0, 1.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MORPHING CAPSULE
  // ============================================================

  Widget _buildMorphingCapsule({required double movement}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff536DAA),
            Color(0xff243B67),
            Color(0xff142747),
          ],
        ),
        borderRadius: BorderRadius.circular(20 + (movement * 4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff243B67).withValues(alpha: 0.27),
            blurRadius: 13 + (movement * 7),
            spreadRadius: movement,
            offset: Offset(0, 5 + (movement * 2)),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 18,
            right: 18,
            top: 5,
            height: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.00),
                    Colors.white.withValues(alpha: 0.17),
                    Colors.white.withValues(alpha: 0.00),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 5,
            height: 8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withValues(alpha: 0.025),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB ITEM
  // ============================================================

// ============================================================
  // PREMIUM ANIMATED TAB
  // ============================================================

  Widget _buildPremiumAnimatedTab({
    required int index,
    required String title,
    required String subtitle,
    required String iconAsset, // Changed from IconData to String
    required double progress,
  }) {
    final bool active = progress > 0.5;

    // ==========================================================
    // COLORS
    // ==========================================================

    final Color iconColor = Color.lerp(
      const Color(0xff667085),
      Colors.white,
      progress,
    )!;

    final Color titleColor = Color.lerp(
      const Color(0xff344054),
      Colors.white,
      progress,
    )!;

    final Color subtitleColor = Color.lerp(
      const Color(0xff98A2B3),
      Colors.white.withValues(alpha: 0.70),
      progress,
    )!;

    // ==========================================================
    // SCALE & ROTATION
    // ==========================================================

    final double contentScale = 0.94 + (progress * 0.06);
    final double iconScale = 0.86 + (progress * 0.14);
    final double rotation = index == 0
        ? -0.10 * (1.0 - progress)
        : 0.10 * (1.0 - progress);
    final double verticalOffset = -3.0 * progress;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_selectedTabIndex == index) {
          return;
        }

        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      },
      child: Center(
        child: Transform.scale(
          scale: contentScale,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, verticalOffset),
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: iconScale,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white.withValues(alpha: 0.13)
                            : const Color(0xffEEF1F6),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: active
                            ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      // =================================================
                      // ASSET IMAGE
                      // =================================================
                      child: Image.asset(
                        iconAsset,
                        width: 24,
                        height: 24,
                        color: iconColor, // Tints the image (Grey to White)
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      color: titleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.1,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      color: subtitleColor,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GAVE LOAN CONTENT (Sliver Lazy Rendering)
  // ============================================================

  Widget _buildGaveLoanContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: currentChopdi == null
          ? const Center(child: CircularProgressIndicator())
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

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: SummaryCard(
                    chopdiId: currentChopdi!.id,
                    isGaveLoanSelected: true,
                  ),
                ),
              ),
              if (customers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: _buildEmptyState(context),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: CustomerListSection(customers: customers),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
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
      onNotification: _handleScrollNotification,
      child: currentChopdi == null
          ? const Center(child: CircularProgressIndicator())
          : TookLoanHomeContent(
        chopdiId: currentChopdi!.id,
        isGaveLoanSelected: false,
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double scale = (width / 390).clamp(0.82, 1.10);
    final double titleFontSize = (22 * scale).clamp(18.0, 23.0);
    final double descriptionFontSize = (16 * scale).clamp(13.0, 17.0);
    final double horizontalPadding = (width * 0.05).clamp(12.0, 28.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
            constraints: BoxConstraints(maxWidth: width * 0.65),
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

// ==================================================================
// KEEP ALIVE TAB WRAPPER
// ==================================================================

class _KeepAliveTab extends StatefulWidget {
  final Widget child;

  const _KeepAliveTab({required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}