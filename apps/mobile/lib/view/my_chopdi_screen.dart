import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/auth_service.dart';

import 'package:mychopdi/service/chopdi_service.dart';
import 'package:mychopdi/service/isar_service.dart';

import 'package:mychopdi/view/edit_chopdi_screen.dart';
import 'package:mychopdi/view/help_faqs_screen.dart';
import 'package:mychopdi/view/login_screen.dart';
import 'package:mychopdi/view/main_screen.dart';
import 'package:mychopdi/view/notifications_setting_screen.dart';
import 'package:mychopdi/view/terms_privacy_screen.dart';
import 'package:mychopdi/widgets/chopdi_bottom_sheet.dart';

class MyChopdiScreen extends StatefulWidget {
  const MyChopdiScreen({super.key});

  @override
  State<MyChopdiScreen> createState() => _MyChopdiScreenState();
}

class _MyChopdiScreenState extends State<MyChopdiScreen> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color backgroundColor = Color(0xFFFFEEDB);
  static const Color darkBlue = Color(0xFF18345C);
  static const Color lightBlue = Color(0xFFDCE6F2);
  static const Color greenColor = Color(0xFF159447);
  static const Color orangeColor = Color(0xFFFF7A32);

  // ===========================================================================
  // STATE
  // ===========================================================================

  Chopdi? _currentChopdi;

  int _totalCustomers = 0;

  double _totalLoan = 0;
  double _totalInterestEarned = 0;
  double _totalOutstanding = 0;

  bool _isLoading = true;

  

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    _loadChopdiData();
  }

  // ===========================================================================
  // LOAD CURRENT CHOPDI + DATA
  // ===========================================================================

  Future<void> _loadChopdiData() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      // -----------------------------------------------------------------------
      // Get currently active Chopdi.
      // -----------------------------------------------------------------------

      final chopdi = await ChopdiService.getCurrentChopdi();

      // -----------------------------------------------------------------------
      // Get customers belonging ONLY to this Chopdi.
      //
      // Soft-deleted customers are excluded.
      // -----------------------------------------------------------------------

      final customers = await IsarService.isar.customers
          .filter()
          .chopdiIdEqualTo(chopdi.id)
          .deletedAtIsNull()
          .findAll();

      // -----------------------------------------------------------------------
      // Get transactions belonging ONLY to this Chopdi.
      //
      // Voided transactions are excluded.
      // -----------------------------------------------------------------------

      final transactions = await IsarService.isar.transactions
          .filter()
          .chopdiIdEqualTo(chopdi.id)
          .voidedAtIsNull()
          .findAll();

      // -----------------------------------------------------------------------
      // Calculate statistics.
      // -----------------------------------------------------------------------

      double totalGave = 0;
      double totalReceived = 0;

      double totalTook = 0;
      double totalPaid = 0;

      double totalInterestEarned = 0;

      for (final transaction in transactions) {
        final amount = transaction.amount;

        switch (transaction.type) {
          // ===================================================================
          // I GAVE LOAN
          // ===================================================================

          case TransactionType.gave:
            totalGave += amount;

            // Interest earned from money that I gave.
            totalInterestEarned += transaction.interest;

            break;

          // ===================================================================
          // I RECEIVED MONEY
          // ===================================================================

          case TransactionType.received:
            totalReceived += amount;

            break;

          // ===================================================================
          // I TOOK LOAN
          // ===================================================================

          case TransactionType.took:
            totalTook += amount;

            break;

          // ===================================================================
          // I PAID BACK LOAN
          // ===================================================================

          case TransactionType.paid:
            totalPaid += amount;

            break;
        }
      }

      // -----------------------------------------------------------------------
      // TOTAL LOAN
      //
      // Includes BOTH:
      //
      //     Gave + Took
      //
      // Example:
      //
      //     Gave = ₹30,000
      //     Took = ₹15,000
      //
      //     Total Loan = ₹45,000
      // -----------------------------------------------------------------------

      final totalLoan = totalGave + totalTook;

      // -----------------------------------------------------------------------
      // OUTSTANDING FOR LOANS GIVEN
      //
      // Money given minus money received back.
      // -----------------------------------------------------------------------

      final gaveOutstanding = totalGave - totalReceived;

      // -----------------------------------------------------------------------
      // OUTSTANDING FOR LOANS TAKEN
      //
      // Money taken minus money paid back.
      // -----------------------------------------------------------------------

      final tookOutstanding = totalTook - totalPaid;

      // -----------------------------------------------------------------------
      // TOTAL OUTSTANDING
      //
      // Both Gave Loan and Took Loan are included.
      // -----------------------------------------------------------------------

      double totalOutstanding =
          gaveOutstanding + tookOutstanding;

      // -----------------------------------------------------------------------
      // Protect against negative value.
      // -----------------------------------------------------------------------

      if (totalOutstanding < 0) {
        totalOutstanding = 0;
      }

      if (!mounted) return;

      setState(() {
        _currentChopdi = chopdi;

        _totalCustomers = customers.length;

        _totalLoan = totalLoan;

        _totalInterestEarned = totalInterestEarned;

        _totalOutstanding = totalOutstanding;

        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        '[MyChopdiScreen] Failed to load Chopdi data: '
        '$error\n$stackTrace',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } 
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: darkBlue,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF58687A),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: darkBlue,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                'Logout',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: orangeColor,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    try {
      // Logout from API and clear local session.
      await AuthService.instance.logout();

      if (!mounted) return;

      // Navigate directly to LoginScreen.
      // Remove all previous routes so the user cannot
      // press the back button and return to the app.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const ChopdiOnboardingScreen(),
        ),
        (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[MyChopdiScreen] Logout failed: $error\n$stackTrace',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to logout. Please try again.',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        bottom: false,

        child: Padding(
          // -------------------------------------------------------------------
          // SAME OUTER PADDING
          // -------------------------------------------------------------------

          padding: const EdgeInsets.all(14),

          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),

                  // ----------------------------------------------------------------
                  // IMPORTANT:
                  // No additional 18 px padding here.
                  // The outer 14 px padding controls the screen margin.
                  // ----------------------------------------------------------------

                  padding: EdgeInsets.zero,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // =========================================================
                      // HEADER
                      // =========================================================

                      Text(
                        _currentChopdi?.name.trim().isNotEmpty == true
                            ? _currentChopdi!.name
                            : 'My Chopdi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      const SizedBox(height: 2),

                      Text(
                        'Manage your current chopdi',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromRGBO(
                            34,
                            58,
                            94,
                            0.62,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =========================================================
                      // CHOPDI CARD
                      // =========================================================

                      _buildChopdiCard(context),

                      const SizedBox(height: 18),

                      // =========================================================
                      // PREFERENCES
                      // =========================================================

                      Text(
                        'Preferences',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromRGBO(
                            34,
                            58,
                            94,
                            1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      _buildMenuCard(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications Settings',
                        subtitle: 'Manage app notifications',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NotificationSettingsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // =========================================================
                      // SUPPORT
                      // =========================================================

                      Text(
                        'Support',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromRGBO(
                            34,
                            58,
                            94,
                            1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      _buildMenuCard(
                        icon: Icons.support_agent_rounded,
                        title: 'Help & FAQs',
                        subtitle: 'Get answers to common questions',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HelpFaqsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      _buildMenuCard(
                        icon: Icons.verified_user_outlined,
                        title: 'Terms & Privacy',
                        subtitle: 'Read our policies',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TermsPrivacyScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      _buildMenuCard(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        onTap: _handleLogout,
                      ),

                      const SizedBox(height: 10),
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

  // ===========================================================================
  // CHOPDI CARD
  // ===========================================================================

  Widget _buildChopdiCard(BuildContext context) {
    final chopdi = _currentChopdi;

    final chopdiName = chopdi?.name ?? 'My Chopdi';

    final createdDate = chopdi == null
        ? '—'
        : _formatDate(chopdi.createdAt);

    return Container(
      width: double.infinity,
      height: 231,

      decoration: BoxDecoration(
        color: const Color.fromRGBO(
          255,
          248,
          240,
          1,
        ),

        borderRadius: BorderRadius.circular(15),

        border: Border.all(
          color: const Color.fromRGBO(
            170,
            185,
            207,
            1,
          ),
          width: 1,
        ),
      ),

      child: Stack(
        children: [
          // ===================================================================
          // BOOK IMAGE
          // ===================================================================

          Positioned(
            left: 8,
            top: 20,

            child: SizedBox(
              width: 130,
              height: 180,

              child: Stack(
                alignment: Alignment.center,

                children: [
                  Container(
                    width: 98,
                    height: 98,

                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE6CF),
                      shape: BoxShape.circle,
                    ),
                  ),

                  Image.asset(
                    'assets/chopdi_book.png',
                    width: 104,
                    height: 128,
                    fit: BoxFit.contain,

                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return _buildBookPlaceholder();
                    },
                  ),
                ],
              ),
            ),
          ),

          // ===================================================================
          // ACTIVE CHOPDI BADGE
          // ===================================================================

          Positioned(
            top: 10,
            right: 122,

            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 3,
              ),

              decoration: BoxDecoration(
                color: const Color.fromRGBO(
                  141,
                  208,
                  113,
                  0.34,
                ),

                borderRadius: BorderRadius.circular(10),

                border: Border.all(
                  color: const Color.fromRGBO(
                    0,
                    144,
                    27,
                    1,
                  ),
                  width: 0.8,
                ),
              ),

              child: Text(
                'ACTIVE CHOPDI •',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: greenColor,
                ),
              ),
            ),
          ),

          // ===================================================================
          // CHOPDI TITLE + EDIT BUTTON
          // ===================================================================

          Positioned(
            top: 37,
            left: 143,
            right: 10,

            child: Row(
              children: [
                Expanded(
                  child: Text(
                    chopdiName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color.fromRGBO(
                        34,
                        58,
                        94,
                        1,
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () async {
                    if (_currentChopdi == null) return;

                    final chopdi = _currentChopdi!;

                    final result = await Navigator.push<Object?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditChopdiScreen(
                          initialName: chopdi.name,
                          initialDescription:
                              chopdi.description.trim().isEmpty
                                  ? 'My personal lending ledger\n'
                                    'to track loans and interest.'
                                  : chopdi.description,
                        ),
                      ),
                    );

                    if (!mounted || result == null) return;

                    // ----------------------------------------------------------
                    // DELETE COMPLETED
                    // ----------------------------------------------------------
                    // Delete returns ChopdiDeleteResult so we can distinguish
                    // delete navigation from a normal edit/save operation.
                    // ----------------------------------------------------------

                    if (result is ChopdiDeleteResult && result.deleted) {
                      final remainingChopdis =
                          await ChopdiService.getAllChopdis();

                      if (!mounted) return;

                      // --------------------------------------------------------
                      // ONLY ONE CHOPDI REMAINS
                      // --------------------------------------------------------
                      // The deleted Chopdi was the only user Chopdi. The service
                      // keeps/creates the default Chopdi. Make it active and
                      // return to MyChopdi/Home without opening the selector.
                      // --------------------------------------------------------

                      if (remainingChopdis.length == 1) {
                        // The deleted Chopdi was the only user Chopdi.
                        // Make the remaining default Chopdi active first.
                        await ChopdiService.setActiveChopdi(
                          remainingChopdis.first,
                        );

                        if (!mounted) return;

                        // Go directly to HomeScreen.
                        // HomeScreen loads the active Chopdi, so the
                        // default "My Chopdi" will be displayed there.
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const MainScreen(),
                          ),
                        );

                        return;
                      }

                      // --------------------------------------------------------
                      // MULTIPLE CHOPDIS REMAIN
                      // --------------------------------------------------------
                      // Whether the deleted Chopdi was the default/active one
                      // or another selected Chopdi, let the user choose the
                      // Chopdi that should become active.
                      // --------------------------------------------------------

                      final selectedChopdi =
                          await showModalBottomSheet<Chopdi>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) {
                          return const ChopdiBottomSheet();
                        },
                      );

                      if (!mounted) return;

                      if (selectedChopdi != null) {
                        await ChopdiService.setActiveChopdi(
                          selectedChopdi,
                        );

                        if (!mounted) return;

                        await _loadChopdiData();
                      }

                      return;
                    }

                    // ----------------------------------------------------------
                    // NORMAL EDIT/SAVE COMPLETED
                    // ----------------------------------------------------------
                    // Do NOT open ChopdiBottomSheet after an edit. The edited
                    // Chopdi remains active.
                    // ----------------------------------------------------------

                    if (result is Chopdi) {
                      await ChopdiService.setActiveChopdi(result);

                      if (!mounted) return;

                      await _loadChopdiData();
                    }
                  },

                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(
                        255,
                        215,
                        190,
                        1,
                      ),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: const Color.fromRGBO(
                          177,
                          95,
                          39,
                          1,
                        ),
                        width: 0.8,
                      ),
                    ),
                    child: Image.asset(
                      'assets/edit_chopdi_icon.png',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===================================================================
          // DESCRIPTION
          // ===================================================================

          Positioned(
            top: 65,
            left: 143,
            right: 12,

            child: Text(
              "${chopdi?.description}",

              style: GoogleFonts.manrope(
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: const Color.fromRGBO(
                  34,
                  58,
                  94,
                  1,
                ),
              ),
            ),
          ),

          // ===================================================================
          // CREATED DATE
          // ===================================================================

          Positioned(
            top: 103,
            left: 143,
            right: 12,

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                _buildSmallInfoIcon(
                  Icons.calendar_month_outlined,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Created On',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(
                            0xFF7B8796,
                          ),
                        ),
                      ),

                      const SizedBox(height: 1),

                      Text(
                        createdDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromRGBO(
                            34,
                            58,
                            94,
                            0.62,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===================================================================
          // DIVIDER
          // ===================================================================

          Positioned(
            top: 132,
            left: 143,
            right: 12,

            child: Container(
              height: 0.7,

              color: const Color.fromRGBO(
                170,
                185,
                207,
                1,
              ),
            ),
          ),

          // ===================================================================
          // TOTAL CUSTOMERS
          // ===================================================================

          Positioned(
            top: 140,
            left: 143,
            right: 12,

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                _buildSmallInfoIcon(
                  Icons.people_outline_rounded,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Total Customers',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(
                            0xFF7B8796,
                          ),
                        ),
                      ),

                      const SizedBox(height: 1),

                      Text(
                        _totalCustomers.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===================================================================
          // BOTTOM STATISTICS
          // ===================================================================

          Positioned(
            left: 6,
            right: 6,
            bottom: 6,

            child: Container(
              height: 49,

              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color: const Color.fromRGBO(
                  253,
                  237,
                  217,
                  1,
                ),

                borderRadius: BorderRadius.circular(8),

                border: Border.all(
                  color: const Color.fromRGBO(
                    170,
                    185,
                    207,
                    1,
                  ),
                  width: 0.8,
                ),
              ),

              child: Row(
                children: [
                  // ===========================================================
                  // TOTAL LOAN
                  // ===========================================================

                  Expanded(
                    child: _buildAmount(
                      title: 'Total Loan',
                      amount: _formatCurrency(
                        _totalLoan,
                      ),
                      amountColor: darkBlue,
                    ),
                  ),

                  // ===========================================================
                  // TOTAL INTEREST EARNED
                  // ===========================================================

                  Expanded(
                    child: _buildAmount(
                      title: 'Total Interest Earned',
                      amount: _formatCurrency(
                        _totalInterestEarned,
                      ),
                      amountColor: greenColor,
                    ),
                  ),

                  // ===========================================================
                  // TOTAL OUTSTANDING
                  // ===========================================================

                  Expanded(
                    child: _buildAmount(
                      title: 'Total Outstanding',
                      amount: _formatCurrency(
                        _totalOutstanding,
                      ),
                      amountColor: greenColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===================================================================
          // LOADING
          // ===================================================================

          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(
                    255,
                    248,
                    240,
                    0.75,
                  ),

                  borderRadius: BorderRadius.circular(15),
                ),

                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,

                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOOK PLACEHOLDER
  // ===========================================================================

  Widget _buildBookPlaceholder() {
    return Transform.rotate(
      angle: -0.04,

      child: Container(
        width: 72,
        height: 102,

        decoration: BoxDecoration(
          color: const Color(0xFFB82222),

          borderRadius: BorderRadius.circular(5),

          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 5,
              offset: Offset(2, 4),
            ),
          ],
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(
                Icons.currency_rupee_rounded,
                color: Color(0xFFF6D68A),
                size: 28,
              ),

              const SizedBox(height: 4),

              Text(
                'Chopdi',
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(
                    alpha: 0.9,
                  ),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SMALL INFO ICON
  // ===========================================================================

  Widget _buildSmallInfoIcon(
    IconData icon,
  ) {
    return Container(
      width: 22,
      height: 22,

      decoration: BoxDecoration(
        color: lightBlue,

        borderRadius: BorderRadius.circular(4),
      ),

      child: Icon(
        icon,
        size: 13,
        color: const Color(0xFF3B5D87),
      ),
    );
  }

  // ===========================================================================
  // AMOUNT
  // ===========================================================================

  Widget _buildAmount({
    required String title,
    required String amount,
    required Color amountColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,

      crossAxisAlignment: CrossAxisAlignment.start,

      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: GoogleFonts.manrope(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: const Color.fromRGBO(
              34,
              58,
              94,
              1,
            ),
          ),
        ),

        const SizedBox(height: 2),

        Text(
          amount,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // PREFERENCE / SUPPORT CARD
  // ===========================================================================

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,
        height: 60,

        decoration: BoxDecoration(
          color: const Color.fromRGBO(
            253,
            237,
            217,
            1,
          ),

          borderRadius: BorderRadius.circular(8),

          border: Border.all(
            color: const Color.fromRGBO(
              170,
              185,
              207,
              1,
            ),
            width: 0.9,
          ),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            const SizedBox(width: 9),

            Container(
              width: 28,
              height: 28,

              decoration: const BoxDecoration(
                color: Color.fromRGBO(
                  170,
                  185,
                  207,
                  0.6,
                ),
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                size: 16,
                color: const Color(
                  0xFF3D5F8B,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                mainAxisAlignment: MainAxisAlignment.center,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkBlue,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(
                        0xFF58687A,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 21,
              color: darkBlue,
            ),

            const SizedBox(width: 7),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DATE FORMAT
  // ===========================================================================

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ===========================================================================
  // CURRENCY FORMAT
  // ===========================================================================

  String _formatCurrency(double amount) {
    if (amount == 0) {
      return '₹0';
    }

    final roundedAmount = amount.round();

    final formatted = roundedAmount.toString();

    String result = '';

    int count = 0;

    for (int i = formatted.length - 1; i >= 0; i--) {
      result = formatted[i] + result;

      count++;

      if (count == 3 && i != 0) {
        result = ',$result';
        count = 0;
      } else if (
          count > 3 &&
          (count - 3) % 2 == 0 &&
          i != 0) {
        result = ',$result';
      }
    }

    return '₹$result';
  }
}