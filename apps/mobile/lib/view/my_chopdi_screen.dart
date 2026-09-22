import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:intl/intl.dart';
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
import 'package:mychopdi/l10n/app_localizations.dart';

import '../main.dart';

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

      double totalOutstanding =
          gaveOutstanding + tookOutstanding;

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

  // ===========================================================================
  // LOGOUT
  // ===========================================================================

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context);

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            l10n.logout,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: darkBlue,
            ),
          ),
          content: Text(
            l10n.areYouSureLogout,
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
                l10n.cancel,
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
                l10n.logout,
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
        MaterialPageRoute(
          builder: (_) => const ChopdiOnboardingScreen(),
        ),
            (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[MyChopdiScreen] Logout failed: '
            '$error\n$stackTrace',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.unableToLogout,
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
    final l10n = AppLocalizations.of(context);

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
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // =======================================================
                      // HEADER
                      // =======================================================

                      Text(
                        _currentChopdi?.name.trim().isNotEmpty == true
                            ? _currentChopdi!.name
                            : l10n.myChopdi,
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
                        l10n.manageCurrentChopdi,
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

                      // =======================================================
                      // CHOPDI CARD
                      // =======================================================

                      _buildChopdiCard(context),

                      const SizedBox(height: 18),

                      // =======================================================
                      // PREFERENCES
                      // =======================================================

                      Text(
                        l10n.preferences,
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
                        icon:
                        Icons.notifications_none_rounded,
                        title: l10n.notificationsSettings,
                        subtitle:
                        l10n.manageAppNotifications,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const NotificationSettingsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      _buildMenuCard(
                        icon: Icons.language_rounded,
                        title: l10n.language,
                        subtitle: _getCurrentLanguageName(),
                        onTap: _showLanguageSheet,
                      ),

                      const SizedBox(height: 18),

                      // =======================================================
                      // SUPPORT
                      // =======================================================

                      Text(
                        l10n.support,
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
                        title: l10n.helpFaqs,
                        subtitle:
                        l10n.getAnswersCommonQuestions,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const HelpFaqsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      _buildMenuCard(
                        icon:
                        Icons.verified_user_outlined,
                        title: l10n.termsPrivacy,
                        subtitle: l10n.readOurPolicies,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const TermsPrivacyScreen(),
                            ),
                          );
                        },
                      ),


                      const SizedBox(height: 10),

                      _buildMenuCard(
                        icon: Icons.logout_rounded,
                        title: l10n.logout,
                        subtitle: l10n.signOutOfAccount,
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
    final l10n = AppLocalizations.of(context);

    final chopdi = _currentChopdi;

    final chopdiName =
    chopdi?.name.trim().isNotEmpty == true
        ? chopdi!.name
        : l10n.myChopdi;

    final createdDate = chopdi == null
        ? '—'
        : _formatDate(chopdi.createdAt, context);

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
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // =============================================================
                // TOP ROW
                // =============================================================

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ---------------------------------------------------------
                    // BOOK IMAGE
                    // ---------------------------------------------------------

                    SizedBox(
                      width: 130,
                      height: 160,
                      child: Stack(
                        alignment:
                        Alignment.bottomCenter,
                        children: [
                          Container(
                            width: 190,
                            height: 190,
                            decoration:
                            const BoxDecoration(
                              color: Color(0xFFFFE6CF),
                              borderRadius:
                              BorderRadius.vertical(
                                top: Radius.circular(100),
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/chopdibook.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                _buildBookPlaceholder(
                                  context,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ---------------------------------------------------------
                    // DETAILS
                    // ---------------------------------------------------------

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Title & Edit Button
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chopdiName,
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style:
                                  GoogleFonts.manrope(
                                    fontSize: 20,
                                    fontWeight:
                                    FontWeight.w700,
                                    color:
                                    const Color.fromRGBO(
                                      34,
                                      58,
                                      94,
                                      1,
                                    ),
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap:
                                _onEditChopdiTapped,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    const Color.fromRGBO(
                                      255,
                                      215,
                                      190,
                                      1,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(
                                      3,
                                    ),
                                    border: Border.all(
                                      color:
                                      const Color.fromRGBO(
                                        34,
                                        58,
                                        94,
                                        1,
                                      ),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons
                                          .edit_outlined,
                                      size: 16,
                                      color: darkBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Description
                          Text(
                            chopdi?.description
                                .trim()
                                .isNotEmpty ==
                                true
                                ? chopdi!.description
                                : l10n
                                .myPersonalLendingLedger,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              height: 1.3,
                              fontWeight:
                              FontWeight.w600,
                              color:
                              const Color.fromRGBO(
                                34,
                                58,
                                94,
                                1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Created Date
                          Row(
                            children: [
                              _buildSmallInfoIcon(
                                Icons
                                    .calendar_today_outlined,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    l10n.createdOn,
                                    style:
                                    GoogleFonts.manrope(
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.w600,
                                      color:
                                      const Color(
                                        0xFF7B8796,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    createdDate,
                                    style:
                                    GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight:
                                      FontWeight.w700,
                                      color: darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          const Divider(
                            height: 1,
                            color: Color.fromRGBO(
                              170,
                              185,
                              207,
                              1,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Total Customers
                          Row(
                            children: [
                              _buildSmallInfoIcon(
                                Icons
                                    .people_alt_outlined,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    l10n.totalCustomers,
                                    style:
                                    GoogleFonts.manrope(
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.w600,
                                      color:
                                      const Color(
                                        0xFF7B8796,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _totalCustomers
                                        .toString(),
                                    style:
                                    GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight:
                                      FontWeight.w700,
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

                // =============================================================
                // BOTTOM STATISTICS BAR
                // =============================================================

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(
                      253,
                      237,
                      217,
                      1,
                    ),
                    borderRadius:
                    BorderRadius.circular(8),
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
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildAmount(
                            title:
                            l10n.homeTotalLoanGiven,
                            amount:
                            _formatCurrency(
                              _totalLoan,
                            ),
                            amountColor: darkBlue,
                          ),
                        ),

                        const VerticalDivider(
                          color: Color.fromRGBO(
                            170,
                            185,
                            207,
                            1,
                          ),
                          thickness: 1,
                          width: 16,
                        ),

                        Expanded(
                          child: _buildAmount(
                            title: l10n
                                .homeTotalInterestEarned,
                            amount:
                            _formatCurrency(
                              _totalInterestEarned,
                            ),
                            amountColor: greenColor,
                          ),
                        ),

                        const VerticalDivider(
                          color: Color.fromRGBO(
                            170,
                            185,
                            207,
                            1,
                          ),
                          thickness: 1,
                          width: 16,
                        ),

                        Expanded(
                          child: _buildAmount(
                            title: l10n
                                .homeTotalOutstandingAmount,
                            amount:
                            _formatCurrency(
                              _totalOutstanding,
                            ),
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

          // =============================================================
          // LOADING OVERLAY
          // =============================================================

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
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  String _getCurrentLanguageName() {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'hi':
        return 'हिन्दी';
      case 'en':
      default:
        return 'English';
    }
  }

  // ===========================================================================
  // EDIT CHOPDI
  // ===========================================================================
  Future<void> _showLanguageSheet() async {
    final currentLocale = Localizations.localeOf(context);

    // Capture the app state BEFORE the async gap.
    final appState = ChopdiApp.of(context);

    final selectedLocale = await showModalBottomSheet<Locale>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            28,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8F0),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.language_rounded,
                    color: darkBlue,
                    size: 25,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(sheetContext).language,
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: darkBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildLanguageOption(
                context: sheetContext,
                locale: const Locale('en'),
                title: 'English',
                subtitle: 'English',
                currentLocale: currentLocale,
              ),

              const SizedBox(height: 10),

              _buildLanguageOption(
                context: sheetContext,
                locale: const Locale('hi'),
                title: 'हिन्दी',
                subtitle: 'Hindi',
                currentLocale: currentLocale,
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedLocale == null) {
      return;
    }

    await appState?.changeLanguage(selectedLocale);
  }

  Future<void> _onEditChopdiTapped() async {
    if (_currentChopdi == null) return;

    final chopdi = _currentChopdi!;
    final l10n = AppLocalizations.of(context);

    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => EditChopdiScreen(
          initialName: chopdi.name,
          initialDescription:
          chopdi.description.trim().isEmpty
              ? l10n.myPersonalLendingLedger
              : chopdi.description,
        ),
      ),
    );

    if (!mounted || result == null) return;

    // =============================================================
    // CHOPDI DELETED
    // =============================================================

    if (result is ChopdiDeleteResult &&
        result.deleted) {
      final remainingChopdis =
      await ChopdiService.getAllChopdis();

      if (!mounted) return;

      if (remainingChopdis.length == 1) {
        await ChopdiService.setActiveChopdi(
          remainingChopdis.first,
        );

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
        );

        return;
      }

      final selectedChopdi =
      await showModalBottomSheet<Chopdi>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) =>
        const ChopdiBottomSheet(),
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

    // =============================================================
    // CHOPDI UPDATED
    // =============================================================

    if (result is Chopdi) {
      await ChopdiService.setActiveChopdi(
        result,
      );

      if (!mounted) return;

      await _loadChopdiData();
    }
  }

  // ===========================================================================
  // BOOK PLACEHOLDER
  // ===========================================================================

  Widget _buildBookPlaceholder(
      BuildContext context,
      ) {
    final l10n = AppLocalizations.of(context);

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
            mainAxisAlignment:
            MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.currency_rupee_rounded,
                color: Color(0xFFF6D68A),
                size: 28,
              ),

              const SizedBox(height: 4),

              Text(
                l10n.chopdi,
                style: GoogleFonts.manrope(
                  color: Colors.white
                      .withValues(alpha: 0.9),
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

  Widget _buildAmount({
    required String title,
    required String amount,
    required Color amountColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment:
      CrossAxisAlignment.start,
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 11,
            height: 1.1,
            fontWeight: FontWeight.w600,
            color: const Color.fromRGBO(
              34,
              58,
              94,
              1,
            ),
          ),
        ),

        const SizedBox(height: 6),

        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            amount,
            maxLines: 1,
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
          crossAxisAlignment:
          CrossAxisAlignment.center,
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
                color: const Color(0xFF3D5F8B),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w700,
                      color: darkBlue,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w600,
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
  Widget _buildLanguageOption({
    required BuildContext context,
    required Locale locale,
    required String title,
    required String subtitle,
    required Locale currentLocale,
  }) {
    final isSelected =
        currentLocale.languageCode == locale.languageCode;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context, locale);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? lightBlue
              : const Color(0xFFFFEEDB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? darkBlue
                : const Color(0xFFAAC0D8),
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: darkBlue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF58687A),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: darkBlue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(
      DateTime date,
      BuildContext context,
      ) {
    final locale = Localizations.localeOf(context).languageCode;

    return DateFormat(
      'd MMMM yyyy',
      locale,
    ).format(date);
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

    for (int i = formatted.length - 1;
    i >= 0;
    i--) {
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