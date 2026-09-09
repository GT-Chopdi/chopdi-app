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
  static const Color darkBlue = Color(0xFF223A5E);
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

      final chopdi = await ChopdiService.getCurrentChopdi();

      final customers = await IsarService.isar.customers
          .filter()
          .chopdiIdEqualTo(chopdi.id)
          .deletedAtIsNull()
          .findAll();

      final transactions = await IsarService.isar.transactions
          .filter()
          .chopdiIdEqualTo(chopdi.id)
          .voidedAtIsNull()
          .findAll();

      double totalGave = 0;
      double totalReceived = 0;
      double totalTook = 0;
      double totalPaid = 0;
      double totalInterestEarned = 0;

      for (final transaction in transactions) {
        final amount = transaction.amount;
        switch (transaction.type) {
          case TransactionType.gave:
            totalGave += amount;
            totalInterestEarned += transaction.interest;
            break;
          case TransactionType.received:
            totalReceived += amount;
            break;
          case TransactionType.took:
            totalTook += amount;
            break;
          case TransactionType.paid:
            totalPaid += amount;
            break;
        }
      }

      final totalLoan = totalGave + totalTook;
      final gaveOutstanding = totalGave - totalReceived;
      final tookOutstanding = totalTook - totalPaid;
      double totalOutstanding = gaveOutstanding + tookOutstanding;

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
      debugPrint('[MyChopdiScreen] Failed to load Chopdi data: $error\n$stackTrace');
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
              onPressed: () => Navigator.pop(context, false),
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
              onPressed: () => Navigator.pop(context, true),
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
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ChopdiOnboardingScreen()),
            (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint('[MyChopdiScreen] Logout failed: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to logout. Please try again.',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
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
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                          color: const Color.fromRGBO(34, 58, 94, 0.62),
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
                          color: const Color.fromRGBO(34, 58, 94, 1),
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
                              builder: (context) => const NotificationSettingsScreen(),
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
                          color: const Color.fromRGBO(34, 58, 94, 1),
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
                              builder: (context) => const HelpFaqsScreen(),
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
                              builder: (context) => const TermsPrivacyScreen(),
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
  // CHOPDI CARD (Responsive Refactor)
  // ===========================================================================

  Widget _buildChopdiCard(BuildContext context) {
    final chopdi = _currentChopdi;
    final chopdiName = chopdi?.name ?? 'My Chopdi';
    final createdDate = chopdi == null ? '—' : _formatDate(chopdi.createdAt);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 248, 240, 1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color.fromRGBO(170, 185, 207, 1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Book Image + Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side: Book Image inside Arch Background
                    SizedBox(
                      width: 130,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: 190,
                            height: 190,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFE6CF),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(100),
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/chopdibook.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildBookPlaceholder(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right Side: Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Title & Edit Button
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chopdiName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color.fromRGBO(34, 58, 94, 1),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _onEditChopdiTapped,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                      color: const Color.fromRGBO(255, 215, 190, 1),
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(
                                        color: const Color.fromRGBO(34, 58, 94, 1), // Stroke around edit icon
                                        width: 0.8,
                                      )
                                  ),
                                  child: Center(
                                    child: Icon(Icons.edit_outlined, size: 16, color: darkBlue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Description
                          Text(
                            chopdi?.description ?? 'My personal lending ledger\nto track loans and interest.',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromRGBO(34, 58, 94, 1),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Created Date
                          Row(
                            children: [
                              _buildSmallInfoIcon(Icons.calendar_today_outlined),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Created On',
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF7B8796),
                                    ),
                                  ),
                                  Text(
                                    createdDate,
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Color.fromRGBO(170, 185, 207, 1)),
                          const SizedBox(height: 8),

                          // Total Customers
                          Row(
                            children: [
                              _buildSmallInfoIcon(Icons.people_alt_outlined),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Customers',
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF7B8796),
                                    ),
                                  ),
                                  Text(
                                    _totalCustomers.toString(),
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bottom Statistics Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(253, 237, 217, 1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color.fromRGBO(170, 185, 207, 1),
                      width: 0.8,
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildAmount(
                            title: 'Total Loan Given',
                            amount: _formatCurrency(_totalLoan),
                            amountColor: darkBlue,
                          ),
                        ),
                        const VerticalDivider(
                          color: Color.fromRGBO(170, 185, 207, 1),
                          thickness: 1,
                          width: 16,
                        ),
                        Expanded(
                          child: _buildAmount(
                            title: 'Total Interest Earned',
                            amount: _formatCurrency(_totalInterestEarned),
                            amountColor: greenColor,
                          ),
                        ),
                        const VerticalDivider(
                          color: Color.fromRGBO(170, 185, 207, 1),
                          thickness: 1,
                          width: 16,
                        ),
                        Expanded(
                          child: _buildAmount(
                            title: 'Total Outstanding',
                            amount: _formatCurrency(_totalOutstanding),
                            amountColor: greenColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 248, 240, 0.75),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Logic extracted to keep UI cleaner
  Future<void> _onEditChopdiTapped() async {
    if (_currentChopdi == null) return;
    final chopdi = _currentChopdi!;

    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => EditChopdiScreen(
          initialName: chopdi.name,
          initialDescription: chopdi.description.trim().isEmpty
              ? 'My personal lending ledger\nto track loans and interest.'
              : chopdi.description,
        ),
      ),
    );

    if (!mounted || result == null) return;

    if (result is ChopdiDeleteResult && result.deleted) {
      final remainingChopdis = await ChopdiService.getAllChopdis();
      if (!mounted) return;

      if (remainingChopdis.length == 1) {
        await ChopdiService.setActiveChopdi(remainingChopdis.first);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
        return;
      }

      final selectedChopdi = await showModalBottomSheet<Chopdi>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const ChopdiBottomSheet(),
      );

      if (!mounted) return;
      if (selectedChopdi != null) {
        await ChopdiService.setActiveChopdi(selectedChopdi);
        if (!mounted) return;
        await _loadChopdiData();
      }
      return;
    }

    if (result is Chopdi) {
      await ChopdiService.setActiveChopdi(result);
      if (!mounted) return;
      await _loadChopdiData();
    }
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
                  color: Colors.white.withValues(alpha: 0.9),
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

  Widget _buildSmallInfoIcon(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 16,
        color: const Color(0xFF3B5D87),
      ),
    );
  }

  // ===========================================================================
  // AMOUNT BUILDER
  // ===========================================================================

// ===========================================================================
  // AMOUNT BUILDER
  // ===========================================================================

// ===========================================================================
  // AMOUNT BUILDER
  // ===========================================================================

  Widget _buildAmount({
    required String title,
    required String amount,
    required Color amountColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.max, // Fills the IntrinsicHeight of the Row
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes title UP, amount DOWN
      children: [
        Text(
          title,
          maxLines: 2, // Allows long text to wrap instead of shrink
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 10,
            height: 1.2, // Tighter line spacing for wrapped text
            fontWeight: FontWeight.w600,
            color: const Color.fromRGBO(34, 58, 94, 1),
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            amount,
            maxLines: 1, // Amounts should never wrap, only shrink if massive
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: amountColor,
            ),
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
          color: const Color.fromRGBO(253, 237, 217, 1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color.fromRGBO(170, 185, 207, 1),
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
                color: Color.fromRGBO(170, 185, 207, 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: const Color(0xFF3D5F8B),
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
                      color: Color(0xFF58687A),
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ===========================================================================
  // CURRENCY FORMAT
  // ===========================================================================

  String _formatCurrency(double amount) {
    if (amount == 0) return '₹0';
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
      } else if (count > 3 && (count - 3) % 2 == 0 && i != 0) {
        result = ',$result';
      }
    }
    return '₹$result';
  }
}