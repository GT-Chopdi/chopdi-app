import 'package:flutter/material.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/view/add_customer_screen.dart';

class SelectCustomerScreen extends StatefulWidget {
  final int chopdiId;

  const SelectCustomerScreen({
    super.key,
    required this.chopdiId,
  });

  @override
  State<SelectCustomerScreen> createState() => _SelectCustomerScreenState();
}

class _SelectCustomerScreenState extends State<SelectCustomerScreen> {
  static const Color primary = Color(0xFF223A5E);
  static const Color secondary = Color(0xFFAAB9CF);
  static const Color accent = Color(0xFFC74C4C);
  static const Color background = Color(0xFFFAF8F5);

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _openAddCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomerScreen(
          chopdiId: widget.chopdiId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: Text(
          l10n.customersTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchCustomer,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: primary,
                  ),
                  suffixIcon: const Icon(
                    Icons.mic_none,
                    color: primary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                l10n.quickActions,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),

              const SizedBox(height: 15),

              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _openAddCustomer,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: secondary,
                        child: Icon(
                          Icons.person_add,
                          color: primary,
                        ),
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.addNewCustomer,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: primary,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              l10n.createCustomerAndTrackTransactions,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: _openAddCustomer,
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: primary,
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
}