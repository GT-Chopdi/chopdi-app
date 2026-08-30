import 'package:flutter/material.dart';

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

  static const Color backgroundColor = Color(0xFFFFEEDB);
  static const Color cardColor = Color(0xFFFFFAF3);

  static const Color darkBlue = Color(0xFF203E68);
  static const Color secondaryText = Color(0xFF68778B);

  static const Color borderColor = Color(0xFFB8C8DA);

  static const Color supportBackground = Color(0xFFFFDFC8);
  static const Color supportBorder = Color(0xFFFFC49D);

  static const Color supportRed = Color(0xFFE35B55);
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
          'Chopdi is your personal lending ledger where you can manage customers, loans, payments and interest.',
    },
    {
      'question': 'How do I add a new customer?',
      'answer':
          'Open the customer section and select the option to add a new customer. Enter the required customer details and save.',
    },
    {
      'question': 'Can I edit customer details?',
      'answer':
          'Yes. Open the customer profile, select edit, update the required information and save the changes.',
    },
    {
      'question': 'How do I record a payment?',
      'answer':
          'Open the customer account, select the payment option, enter the payment amount and save the transaction.',
    },
    {
      'question': 'Can I edit or delete a transaction?',
      'answer':
          'Yes. Open the transaction details and use the edit or delete option to manage the transaction.',
    },
    {
      'question': 'How is interest calculated?',
      'answer':
          'Interest is calculated according to the interest rate and the loan details configured for the customer.',
    },
    {
      'question': 'Can I export my ledger?',
      'answer':
          'Yes. You can export your ledger data from the available export option in your Chopdi.',
    },
    {
      'question': 'Can I change my Chopdi details?',
      'answer':
          'Yes. Go to My Chopdi and select Edit Chopdi to update your Chopdi name and description.',
    },
    {
      'question': 'Will my data be lost if I change my phone?',
      'answer':
          'Your data will remain available when you use the same account and supported backup or synchronization options.',
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

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },

          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,

                  physics:
                      const BouncingScrollPhysics(),

                  padding: const EdgeInsets.fromLTRB(
                    30,
                    47,
                    18,
                    20,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =======================================================
                      // HEADER
                      // =======================================================

                      _buildHeader(),

                      const SizedBox(height: 14),

                      // =======================================================
                      // SEARCH
                      // =======================================================

                      _buildSearchField(),

                      const SizedBox(height: 19),

                      // =======================================================
                      // FAQ TITLE
                      // =======================================================

                      const Text(
                        'Frequently asked questions',
                        style: TextStyle(
                          fontSize: 9,
                          color: secondaryText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 11),

                      // =======================================================
                      // FAQ LIST
                      // =======================================================

                      _buildFaqList(),
                    ],
                  ),
                ),
              ),

              // =============================================================
              // BOTTOM SUPPORT
              // =============================================================

              _buildSupportCard(),
            ],
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
          CrossAxisAlignment.start,
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

        const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              'Help & FAQs',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkBlue,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Find answers to common questions',
              style: TextStyle(
                fontSize: 8.5,
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
      height: 30,

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius:
            BorderRadius.circular(7),

        border: Border.all(
          color: borderColor,
          width: 0.9,
        ),
      ),

      child: Row(
        children: [
          const SizedBox(width: 8),

          const Icon(
            Icons.search,
            size: 17,
            color: darkBlue,
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

              style: const TextStyle(
                fontSize: 9,
                color: darkBlue,
              ),

              decoration:
                  const InputDecoration(
                hintText:
                    'Search for help...',

                hintStyle: TextStyle(
                  fontSize: 9,
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
        padding:
            const EdgeInsets.symmetric(
          vertical: 30,
        ),

        child: const Center(
          child: Text(
            'No questions found.',
            style: TextStyle(
              fontSize: 10,
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
            BorderRadius.circular(7),

        border: Border.all(
          color: borderColor,
          width: 0.9,
        ),
      ),

      child: Column(
        children: [
          // ---------------------------------------------------------------
          // QUESTION
          // ---------------------------------------------------------------

          InkWell(
            borderRadius:
                BorderRadius.circular(7),

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
              height: 29,

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
                          const TextStyle(
                        fontSize: 9.5,
                        fontWeight:
                            FontWeight.w500,
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
                style: const TextStyle(
                  fontSize: 8,
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
    return SafeArea(
      top: false,

      child: Container(
        width: double.infinity,
        height: 70,

        margin:
            const EdgeInsets.fromLTRB(
          30,
          0,
          18,
          0,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 9,
        ),

        decoration: BoxDecoration(
          color: supportBackground,

          borderRadius:
              BorderRadius.circular(8),

          border: Border.all(
            color: supportBorder,
            width: 0.8,
          ),
        ),

        child: Row(
          children: [
            // -------------------------------------------------------------
            // SUPPORT ICON
            // -------------------------------------------------------------

            Container(
              width: 33,
              height: 33,

              decoration:
                  const BoxDecoration(
                color:
                    supportIconBackground,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.support_agent_outlined,
                size: 18,
                color: supportRed,
              ),
            ),

            const SizedBox(width: 9),

            // -------------------------------------------------------------
            // TEXT
            // -------------------------------------------------------------

            const Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'Still need help?',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight:
                          FontWeight.w600,
                      color: darkBlue,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'Our Support team is here.',
                    style: TextStyle(
                      fontSize: 7.5,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // -------------------------------------------------------------
            // CONTACT SUPPORT
            // -------------------------------------------------------------

            GestureDetector(
              onTap: () {
                widget.onContactSupport?.call();
              },

              child: Container(
                height: 32,
                width: 101,

                decoration: BoxDecoration(
                  color: const Color(
                    0xFFFFE9D8,
                  ),

                  borderRadius:
                      BorderRadius.circular(6),

                  border: Border.all(
                    color: supportRed,
                    width: 0.8,
                  ),
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    const Icon(
                      Icons
                          .mail_outline_rounded,
                      size: 15,
                      color: supportRed,
                    ),

                    const SizedBox(width: 5),

                    const Text(
                      'Contact Support',
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight:
                            FontWeight.w500,
                        color: supportRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}