import 'package:flutter/material.dart';
import 'package:mychopdi/view/edit_chopdi_screen.dart';

class MyChopdiScreen extends StatelessWidget {
  const MyChopdiScreen({super.key});

  // Colors from the design
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(23, 43, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------------------------------------------------
                    // HEADER
                    // ---------------------------------------------------------
                    const Text(
                      'My Chopdi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: darkBlue,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      'Manage your current chopdi',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5C6B80),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ---------------------------------------------------------
                    // CHOPDI CARD
                    // ---------------------------------------------------------
                    _buildChopdiCard(context),

                    const SizedBox(height: 14),

                    // ---------------------------------------------------------
                    // PREFERENCES
                    // ---------------------------------------------------------
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: darkBlue,
                      ),
                    ),

                    const SizedBox(height: 5),

                    _buildMenuCard(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications Settings',
                      subtitle: 'Manage app notifications',
                      onTap: () {},
                    ),

                    const SizedBox(height: 7),

                    // ---------------------------------------------------------
                    // SUPPORT
                    // ---------------------------------------------------------
                    const Text(
                      'Support',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: darkBlue,
                      ),
                    ),

                    const SizedBox(height: 5),

                    _buildMenuCard(
                      icon: Icons.support_agent_rounded,
                      title: 'Help & FAQs',
                      subtitle: 'Get answers to common questions',
                      onTap: () {},
                    ),

                    const SizedBox(height: 7),

                    _buildMenuCard(
                      icon: Icons.verified_user_outlined,
                      title: 'Terms & Privacy',
                      subtitle: 'Read our policies',
                      onTap: () {},
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // ---------------------------------------------------------------
            // BOTTOM NAVIGATION
            // ---------------------------------------------------------------
            // _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // CHOPDI CARD
  // =========================================================================

  Widget _buildChopdiCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 231,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // ---------------------------------------------------------------
          // BOOK IMAGE AREA
          // ---------------------------------------------------------------
          Positioned(
            left: 8,
            top: 20,
            child: SizedBox(
              width: 128,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative circle
                  Container(
                    width: 98,
                    height: 98,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE6CF),
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Book image
                  Image.asset(
                    'assets/chopdi_book.png',
                    width: 104,
                    height: 128,
                    fit: BoxFit.contain,

                    // If image is not available, this will still
                    // keep the layout stable.
                    errorBuilder: (context, error, stackTrace) {
                      return _buildBookPlaceholder();
                    },
                  ),
                ],
              ),
            ),
          ),

          // ---------------------------------------------------------------
          // ACTIVE CHOPDI BADGE
          // ---------------------------------------------------------------
          Positioned(
            top: 10,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: greenColor,
                  width: 0.8,
                ),
              ),
              child: const Text(
                'ACTIVE CHOPDI •',
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w500,
                  color: greenColor,
                ),
              ),
            ),
          ),

          // ---------------------------------------------------------------
          // CHOPDI TITLE
          // ---------------------------------------------------------------
          Positioned(
            top: 37,
            left: 143,
            right: 10,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'My Chopdi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: darkBlue,
                    ),
                  ),
                ),

                // Edit button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditChopdiScreen(
                          initialName: 'My Chopdi',
                          initialDescription:
                              'My personal lending ledger to track loans and interest.',
                          onSave: (name, description) async {
                            // Update your Isar / Firebase data here.
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
                    width: 19,
                    height: 19,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE3D0),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: orangeColor,
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 11,
                      color: Color(0xFF24405F),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------------------------------------------------------------
          // DESCRIPTION
          // ---------------------------------------------------------------
          const Positioned(
            top: 65,
            left: 143,
            right: 12,
            child: Text(
              'My personal lending ledger\n'
              'to track loans and interest.',
              style: TextStyle(
                fontSize: 8.5,
                height: 1.3,
                color: Color(0xFF273B56),
              ),
            ),
          ),

          // ---------------------------------------------------------------
          // CREATED DATE
          // ---------------------------------------------------------------
          Positioned(
            top: 103,
            left: 143,
            right: 12,
            child: Row(
              children: [
                _buildSmallInfoIcon(
                  Icons.calendar_month_outlined,
                ),

                const SizedBox(width: 7),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created On',
                        style: TextStyle(
                          fontSize: 7,
                          color: Color(0xFF7B8796),
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        '12 July 2026',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Positioned(
            top: 132,
            left: 143,
            right: 12,
            child: Container(
              height: 0.7,
              color: borderColor,
            ),
          ),

          // ---------------------------------------------------------------
          // CUSTOMERS
          // ---------------------------------------------------------------
          Positioned(
            top: 140,
            left: 143,
            right: 12,
            child: Row(
              children: [
                _buildSmallInfoIcon(
                  Icons.people_outline_rounded,
                ),

                const SizedBox(width: 7),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Customers',
                        style: TextStyle(
                          fontSize: 7,
                          color: Color(0xFF7B8796),
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        '12',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---------------------------------------------------------------
          // BOTTOM STATISTICS
          // ---------------------------------------------------------------
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
                color: const Color(0xFFFFF8ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: borderColor,
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
                      title: 'Total Interest Earned',
                      amount: '₹1,25,000',
                      amountColor: greenColor,
                    ),
                  ),

                  Expanded(
                    child: _buildAmount(
                      title: 'Total Outstanding',
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

  // =========================================================================
  // BOOK PLACEHOLDER
  // =========================================================================

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
            children: [
              const Icon(
                Icons.currency_rupee_rounded,
                color: Color(0xFFF6D68A),
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                'Chopdi',
                style: TextStyle(
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

  // =========================================================================
  // SMALL INFO ICON
  // =========================================================================

  Widget _buildSmallInfoIcon(IconData icon) {
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

  // =========================================================================
  // AMOUNT
  // =========================================================================

  Widget _buildAmount({
    required String title,
    required String amount,
    required Color amountColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 6.8,
            color: Color(0xFF58687A),
          ),
        ),

        const SizedBox(height: 2),

        Text(
          amount,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // PREFERENCE / SUPPORT CARD
  // =========================================================================

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
        height: 43,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5E7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: 0.9,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 9),

            // Icon circle
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: const Color(0xFF3D5F8B),
              ),
            ),

            const SizedBox(width: 10),

            // Text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: darkBlue,
                    ),
                  ),

                  const SizedBox(height: 1),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 7.8,
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

  // =========================================================================
  // BOTTOM NAVIGATION
  // =========================================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF6),
        border: Border(
          top: BorderSide(
            color: Color(0xFFF2E7DA),
            width: 0.7,
          ),
        ),
      ),
      child: Row(
        children: [
          // HOME
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.home_outlined,
                    size: 21,
                    color: Color(0xFF718096),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 8,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // MY CHOPDI
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 25,
                    height: 22,
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'My Chopdi',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: darkBlue,
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
}