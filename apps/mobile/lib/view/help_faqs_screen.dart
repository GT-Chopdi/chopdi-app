import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpFaqsScreen extends StatefulWidget {
  const HelpFaqsScreen({
    super.key,
    this.onContactSupport,
  });

  final VoidCallback? onContactSupport;

  @override
  State<HelpFaqsScreen> createState() => _HelpFaqsScreenState();
}

class _HelpFaqsScreenState extends State<HelpFaqsScreen> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color backgroundColor = Color.fromRGBO(253, 237, 217, 1);
  static const Color cardColor = Color(0xFFFFFAF3);

  static const Color darkBlue = Color.fromRGBO(34, 58, 94, 1);
  static const Color secondaryText = Color(0xFF68778B);

  static const Color borderColor = Color.fromRGBO(170, 185, 207, 1);

  static const Color supportBackground = Color.fromRGBO(255, 215, 190, 0.6);
  static const Color supportBorder = Color.fromRGBO(177, 95, 39, 0.23);

  static const Color supportRed = Color.fromRGBO(199, 76, 76, 1);
  static const Color supportIconBackground = Color(0xFFF8D1C5);

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  // ===========================================================================
  // EXPANDED FAQ
  // ===========================================================================

  int? _expandedIndex;

  // ===========================================================================
  // FAQ DATA
  // ===========================================================================

  final List<Map<String, String>> _faqs = [
    {
      'question': 'What is Chopdi?',
      'answer':
          'Chopdi is a digital ledger that helps you keep track of customers, loans, payments and interest in one place. It replaces traditional paper ledgers with an easy-to-manage digital record.',
    },
    {
      'question': 'How do I add a new customer?',
      'answer':
          'Tap Add Customer from the Home screen. You can either select a customer from your phone contacts or add a new customer manually. After adding the customer, you can start recording loan and payment entries.',
    },
    {
      'question': 'Can I edit customer details?',
      'answer':
          "Yes. Open the customer's profile, tap the three-dot menu (⋮) in the top-right corner and select Edit Customer to update the customer's name or phone number.",
    },
    {
      'question': 'How do I record a payment?',
      'answer':
          "Open the customer's ledger and tap You Gave ₹ to record a loan or You Got ₹ to record a payment. Enter the required details and save the entry.",
    },
    {
      'question': 'Can I edit or delete a transaction?',
      'answer':
          "Yes. Tap any transaction in the customer's ledger to open its details. From there, you can Edit Transaction or Delete Transaction.",
    },
    {
      'question': 'How is interest calculated?',
      'answer':
          "Interest is calculated using the interest rate you enter while creating or editing a customer's loan. Each customer can have a different interest rate and calculation method (Simple Interest / Compound Interest).",
    },
    {
      'question': 'Can I export my ledger?',
      'answer':
          "Yes. Open any customer's ledger, tap the three dots on the top-right corner, and and tap Export PDF. You can share, print or save the ledger as a PDF file.",
    },
    {
      'question': 'Can I change my Chopdi details?',
      'answer':
          "Yes. Go to My Chopdi > Edit (pencil icon) to update your Chopdi name, description or ledger type.",
    },
    {
      'question': 'Will my data be lost if I change my phone?',
      'answer':
          "No. Your data is safe. As long as you are signed in with your account , you can restore it on your new phone.",
    },
  ];

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // FILTERED FAQS
  // ===========================================================================

  List<Map<String, String>> get _filteredFaqs {
    if (_searchText.trim().isEmpty) {
      return _faqs;
    }

    final query = _searchText.toLowerCase().trim();

    return _faqs.where((faq) {
      final question =
          faq['question']!.toLowerCase();

      final answer =
          faq['answer']!.toLowerCase();

      return question.contains(query) ||
          answer.contains(query);
    }).toList();
  }

  Future<void> _contactSupport() async {

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      // queryParameters: {
      //   'subject': 'MyChopdi Support Request',
      // },
    );

    try {
      final bool launched =
          await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'No email app is available on this device.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        '[HelpFaqs] Failed to open email: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open email app.',
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
    final keyboardVisible =
        MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: backgroundColor,

      resizeToAvoidBottomInset: true,

      body: SafeArea(
        bottom: false,

        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },

          child: Padding(
            // ===============================================================
            // SAME OUTER PADDING AS MY CHOPDI
            // ===============================================================

            padding: const EdgeInsets.all(14),

            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,

                    physics:
                        const BouncingScrollPhysics(),

                    // IMPORTANT:
                    // No additional horizontal padding here.
                    padding: EdgeInsets.only(
                      bottom:
                          keyboardVisible ? 30 : 14,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        // =====================================================
                        // HEADER
                        // =====================================================

                        _buildHeader(),

                        const SizedBox(
                          height: 18,
                        ),

                        // =====================================================
                        // SEARCH
                        // =====================================================

                        _buildSearchField(),

                        const SizedBox(
                          height: 18,
                        ),

                        // =====================================================
                        // FAQ TITLE
                        // =====================================================

                        Text(
                          'Frequently asked questions',

                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: secondaryText,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        // =====================================================
                        // FAQ LIST
                        // =====================================================

                        _buildFaqList(),
                      ],
                    ),
                  ),
                ),

                // =============================================================
                // SUPPORT CARD
                // =============================================================

                const SizedBox(
                  height: 7,
                ),

                _buildSupportCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },

          child: const Padding(
            padding: EdgeInsets.only(
              top: 1,
              right: 8,
            ),

            child: Icon(
              Icons.arrow_back,
              size: 19,
              color: darkBlue,
            ),
          ),
        ),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              'Help & FAQs',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: darkBlue,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Find answers to common questions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: secondaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // SEARCH FIELD
  // ===========================================================================

  Widget _buildSearchField() {
    return Container(
      width: double.infinity,
      height: 40,

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius:
            BorderRadius.circular(7),

        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),

      child: Row(
        children: [
          const SizedBox(width: 8),

          SizedBox(
            height: 24,
            width: 24,
            child: Image.asset('assets/search_option.png'),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: TextField(
              controller: _searchController,

              onChanged: (value) {
                setState(() {
                  _searchText = value;
                  _expandedIndex = null;
                });
              },

              textInputAction:
                  TextInputAction.search,

              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: darkBlue,
              ),

              decoration:
                  InputDecoration(
                hintText:
                    'Search for help...',

                hintStyle: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: secondaryText,
                ),

                border: InputBorder.none,

                isDense: true,

                contentPadding:
                    EdgeInsets.only(
                  bottom: 1,
                ),
              ),
            ),
          ),

          if (_searchText.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();

                setState(() {
                  _searchText = '';
                });
              },

              child: const Padding(
                padding:
                    EdgeInsets.only(
                  right: 7,
                ),

                child: Icon(
                  Icons.close,
                  size: 14,
                  color: secondaryText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FAQ LIST
  // ===========================================================================

  Widget _buildFaqList() {
    final faqs = _filteredFaqs;

    if (faqs.isEmpty) {
      return Container(
        width: double.infinity,
        height: 40,
        padding:
            const EdgeInsets.symmetric(
          vertical: 30,
        ),

        child: Center(
          child: Text(
            'No questions found.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: secondaryText,
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        faqs.length,
        (index) {
          final faq = faqs[index];

          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 9,
            ),

            child: _buildFaqItem(
              index: index,
              question: faq['question']!,
              answer: faq['answer']!,
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // FAQ ITEM
  // ===========================================================================

  Widget _buildFaqItem({
    required int index,
    required String question,
    required String answer,
  }) {
    final bool expanded =
        _expandedIndex == index;

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 180),

      width: double.infinity,

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),

      child: Column(
        children: [
          // ---------------------------------------------------------------
          // QUESTION
          // ---------------------------------------------------------------

          InkWell(
            borderRadius:
                BorderRadius.circular(10),

            onTap: () {
              setState(() {
                if (_expandedIndex ==
                    index) {
                  _expandedIndex = null;
                } else {
                  _expandedIndex = index;
                }
              });
            },

            child: Container(
              height: 40,

              padding:
                  const EdgeInsets.only(
                left: 8,
                right: 7,
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                        color: darkBlue,
                      ),
                    ),
                  ),

                  AnimatedRotation(
                    turns:
                        expanded ? 0.5 : 0,

                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),

                    child: const Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      size: 20,
                      color: darkBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------------------------------------------------------------
          // ANSWER
          // ---------------------------------------------------------------

          if (expanded)
            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.fromLTRB(
                9,
                0,
                9,
                10,
              ),

              child: Text(
                answer,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: secondaryText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SUPPORT CARD
  // ===========================================================================

  Widget _buildSupportCard() {
    return Container(
      width: double.infinity,
      height: 58,

      // Same outer spacing system as MyChopdi / Notification Settings.
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: supportBackground,

        borderRadius: BorderRadius.circular(8),

        border: Border.all(
          color: supportBorder,
          width: 0.8,
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          // ===============================================================
          // SUPPORT ICON
          // ===============================================================

          Container(
            width: 34,
            height: 34,

            decoration: const BoxDecoration(
              color: supportIconBackground,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.support_agent_outlined,
              size: 18,
              color: supportRed,
            ),
          ),

          const SizedBox(
            width: 9,
          ),

          // ===============================================================
          // SUPPORT TEXT
          // ===============================================================

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              mainAxisAlignment:
                  MainAxisAlignment.center,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Still need help?',

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkBlue,
                    height: 1.1,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  'Our Support team is here.',

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: secondaryText,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          // ===============================================================
          // CONTACT SUPPORT BUTTON
          // ===============================================================

          GestureDetector(
            // onTap: () {
            //   widget.onContactSupport?.call();
            // },
            onTap: _contactSupport,

            child: Container(
              height: 32,
              width: 126,

              decoration: BoxDecoration(
                color: const Color(
                  0xFFFFE9D8,
                ),

                borderRadius:
                    BorderRadius.circular(10),

                border: Border.all(
                  color: supportRed,
                  width: 1.0,
                ),
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  SizedBox(width: 5),
                  Icon(
                    Icons.mail_outline_rounded,
                    size: 15,
                    color: supportRed,
                  ),

                  SizedBox(
                    width: 5,
                  ),

                  Flexible(
                    child: Text(
                      'Contact Support',

                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                        color: supportRed,
                      ),
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