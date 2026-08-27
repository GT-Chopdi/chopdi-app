import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/view/edit_chopdi_screen.dart';
import 'package:mychopdi/view/help_faqs_screen.dart';
import 'package:mychopdi/view/notifications_setting_screen.dart';
import 'package:mychopdi/view/terms_privacy_screen.dart';

class MyChopdiScreen extends StatelessWidget {
  const MyChopdiScreen({super.key});

  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color backgroundColor = Color(0xFFFFEEDB);
  static const Color darkBlue = Color(0xFF18345C);
  static const Color lightBlue = Color(0xFFDCE6F2);
  static const Color borderColor = Color(0xFFB7C7DA);
  static const Color greenColor = Color(0xFF159447);
  static const Color orangeColor = Color(0xFFFF7A32);

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
          
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    18,
                  ),
          
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
          
                    children: [
                      // =========================================================
                      // HEADER
                      // =========================================================
          
                      Image.asset(
                        'assets/MyChopdi.png',
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
          
                      const SizedBox(height: 15),
          
                      // =========================================================
                      // CHOPDI CARD
                      // =========================================================
          
                      _buildChopdiCard(context),
          
                      const SizedBox(height: 14),
          
                      // =========================================================
                      // PREFERENCES
                      // =========================================================
          
                      Text(
                        'Preferences',
          
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(34, 58, 94, 1),
                        ),
                      ),
          
                      const SizedBox(height: 8),
          
                      _buildMenuCard(
                        icon:
                            Icons.notifications_none_rounded,
          
                        title:
                            'Notifications Settings',
          
                        subtitle:
                            'Manage app notifications',
          
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
          
                      const SizedBox(height: 10),
          
                      // =========================================================
                      // SUPPORT
                      // =========================================================
          
                      Text(
                        'Support',
          
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(34, 58, 94, 1),
                        ),
                      ),
          
                      const SizedBox(height: 5),
          
                      _buildMenuCard(
                        icon:
                            Icons.support_agent_rounded,
          
                        title:
                            'Help & FAQs',
          
                        subtitle:
                            'Get answers to common questions',
          
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HelpFaqsScreen(),
                            ),
                          );
                        },
                      ),
          
                      const SizedBox(height: 7),
          
                      _buildMenuCard(
                        icon:
                            Icons.verified_user_outlined,
          
                        title:
                            'Terms & Privacy',
          
                        subtitle:
                            'Read our policies',
          
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TermsPrivacyScreen(),
                            ),
                          );
                        },
                      ),
          
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
          
              // ===============================================================
              // BOTTOM NAVIGATION
              // ===============================================================
          
              // _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CHOPDI CARD
  // ===========================================================================

  Widget _buildChopdiCard(
    BuildContext context,
  ) {
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

        borderRadius:
            BorderRadius.circular(15),

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
          // =================================================================
          // BOOK IMAGE AREA
          // =================================================================

          Positioned(
            left: 8,
            top: 20,

            child: SizedBox(
              width: 130,
              height: 180,

              child: Stack(
                alignment: Alignment.center,

                children: [
                  // ---------------------------------------------------------
                  // DECORATIVE CIRCLE
                  // ---------------------------------------------------------

                  Container(
                    width: 98,
                    height: 98,

                    decoration:
                        const BoxDecoration(
                      color: Color(0xFFFFE6CF),
                      shape: BoxShape.circle,
                    ),
                  ),

                  // ---------------------------------------------------------
                  // BOOK IMAGE
                  // ---------------------------------------------------------

                  Image.asset(
                    'assets/chopdi_book.png',

                    width: 104,
                    height: 128,

                    fit: BoxFit.contain,

                    errorBuilder:
                        (context, error, stackTrace) {
                      return _buildBookPlaceholder();
                    },
                  ),
                ],
              ),
            ),
          ),

          // =================================================================
          // ACTIVE CHOPDI BADGE
          // =================================================================

          Positioned(
            top: 10,
            right: 122,

            child: Container(
              padding:
                  const EdgeInsets.symmetric(
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

                borderRadius:
                    BorderRadius.circular(10),

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

          // =================================================================
          // CHOPDI TITLE + EDIT BUTTON
          // =================================================================

          Positioned(
            top: 37,
            left: 143,
            right: 10,

            child: Row(
              children: [
                // -----------------------------------------------------------
                // TITLE
                // -----------------------------------------------------------

                Expanded(
                  child: Text(
                    'My Chopdi',

                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

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

                // -----------------------------------------------------------
                // EDIT BUTTON
                // -----------------------------------------------------------

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (context) =>
                            EditChopdiScreen(
                          initialName:
                              'My Chopdi',

                          initialDescription:
                              'My personal lending ledger to track loans and interest.',

                          onSave:
                              (name, description) async {
                            // Update your Isar /
                            // Firebase data here.

                            print(name);
                            print(description);
                          },

                          onDelete: () {
                            // Delete your Chopdi here.
                          },
                        ),
                      ),
                    );
                  },

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
                          BorderRadius.circular(3),

                      border: Border.all(
                        color:
                            const Color.fromRGBO(
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

          // =================================================================
          // DESCRIPTION
          // =================================================================

          Positioned(
            top: 65,
            left: 143,
            right: 12,

            child: Text(
              'My personal lending ledger\n'
              'to track loans and interest.',

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

          // =================================================================
          // CREATED DATE
          // =================================================================

          Positioned(
            top: 103,
            left: 143,
            right: 12,

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,

              children: [
                _buildSmallInfoIcon(
                  Icons.calendar_month_outlined,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Created On',

                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              const Color(
                            0xFF7B8796,
                          ),
                        ),
                      ),

                      const SizedBox(height: 1),

                      Text(
                        '12 July 2026',

                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              const Color.fromRGBO(
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

          // =================================================================
          // DIVIDER
          // =================================================================

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

          // =================================================================
          // CUSTOMERS
          // =================================================================

          Positioned(
            top: 140,
            left: 143,
            right: 12,

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,

              children: [
                _buildSmallInfoIcon(
                  Icons.people_outline_rounded,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Total Customers',

                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              const Color(
                            0xFF7B8796,
                          ),
                        ),
                      ),

                      const SizedBox(height: 1),

                      Text(
                        '12',

                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight:
                              FontWeight.w700,
                          color: darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // =================================================================
          // BOTTOM STATISTICS
          // =================================================================

          Positioned(
            left: 6,
            right: 6,
            bottom: 6,

            child: Container(
              height: 49,

              padding:
                  const EdgeInsets.symmetric(
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

                borderRadius:
                    BorderRadius.circular(8),

                border: Border.all(
                  color:
                      const Color.fromRGBO(
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
                  Expanded(
                    child: _buildAmount(
                      title: 'Total Loan',
                      amount: '₹10,00,000',
                      amountColor: darkBlue,
                    ),
                  ),

                  Expanded(
                    child: _buildAmount(
                      title:
                          'Total Interest Earned',
                      amount: '₹1,25,000',
                      amountColor: greenColor,
                    ),
                  ),

                  Expanded(
                    child: _buildAmount(
                      title:
                          'Total Outstanding',
                      amount: '₹1,25,000',
                      amountColor: greenColor,
                    ),
                  ),
                ],
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

          borderRadius:
              BorderRadius.circular(5),

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

            mainAxisSize:
                MainAxisSize.min,

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
                  color: Colors.white
                      .withValues(alpha: 0.9),

                  fontSize: 9,
                  fontWeight:
                      FontWeight.w600,
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

        borderRadius:
            BorderRadius.circular(4),
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

      crossAxisAlignment:
          CrossAxisAlignment.start,

      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        Text(
          title,

          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,

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
          overflow:
              TextOverflow.ellipsis,

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
          color: Color.fromRGBO(253, 237, 217, 1),

          borderRadius:
              BorderRadius.circular(8),

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

            // ===============================================================
            // ICON CIRCLE
            // ===============================================================

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

            // ===============================================================
            // TEXT
            //
            // IMPORTANT:
            // The previous 16 + 12 font sizes were too large for a
            // 43px-high card and caused the RenderFlex overflow.
            // ===============================================================

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

                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      color: Color(
                        0xFF58687A,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===============================================================
            // ARROW
            // ===============================================================

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
}