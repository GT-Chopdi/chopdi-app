import 'package:flutter/material.dart';
import 'package:mychopdi/model/customer_model.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/add_entry_bottom_sheet.dart';
import 'package:mychopdi/view/all_notes_screen.dart';
import 'package:mychopdi/view/main_screen.dart';
import 'package:mychopdi/widgets/bottom_nav_bar.dart';
import 'package:mychopdi/widgets/customer_options_bottom_sheet.dart';
import 'package:mychopdi/widgets/overview_widget.dart';
import 'package:mychopdi/widgets/transaction_table.dart';

class CustomerDetailsScreen extends StatefulWidget {

  final CustomerModel customer;

  const CustomerDetailsScreen({
    super.key,
    required this.customer,
  });

  @override
  State createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {

  int selectedTab = 0;
  int bottomIndex = 1; 

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    return Scaffold(
      backgroundColor: ChopdiColors.cream,

      appBar: AppBar(
        backgroundColor: ChopdiColors.cream,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: ChopdiColors.navy),
              onPressed: () => Navigator.pop(context),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: ChopdiColors.navy,
              ),
              onPressed: () {
                showCustomerOptionsBottomSheet(context);
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                CircleAvatar(
                  radius: 26,
                  backgroundColor: ChopdiColors.lightGray,
                  child: Text(
                    customer.name[0],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ChopdiColors.navy,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: ChopdiColors.navy,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Text(
                            customer.phone,
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // const Icon(
                          //   Icons.call_outlined,
                          //   size: 18,
                          //   color: ChopdiColors.navy,
                          // )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            /// SUMMARY CARD
            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 248, 240, 1),
                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),

              child: Row(
                children: [

                  Expanded(
                    child: _infoItem(
                      Icons.account_balance_wallet_outlined,
                      "Loan Amount",
                      "₹15,000",
                      ChopdiColors.navy,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 55,
                    color: Colors.grey.shade300,
                  ),

                  Expanded(
                    child: _infoItem(
                      Icons.percent,
                      "Interest Rate",
                      "12%",
                      ChopdiColors.navy,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 55,
                    color: Colors.grey.shade300,
                  ),

                  Expanded(
                    child: _infoItem(
                      Icons.check_circle_outline,
                      "Total Received",
                      "₹3,000",
                      Colors.green,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 55,
                    color: Colors.grey.shade300,
                  ),

                  Expanded(
                    child: _infoItem(
                      Icons.warning_amber_rounded,
                      "Outstanding",
                      "₹12,150",
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: ChopdiColors.cream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xffFFB5A5),
                  width: 1,
                ),
              ),
              child: Column(
                children: [

                  /// Header
                  Row(
                    children: [

                      Image.asset(
                        "assets/note_logo.png",
                        width: 22,
                        height: 22,
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        "Important Note",
                        style: TextStyle(
                          color: Color(0xffF25B42),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        "24 July 2026",
                        style: TextStyle(
                          color: Color(0xffA8A8A8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      const Expanded(
                        child: Text(
                          "Customer requested payment\nextension until 30 July 2026",
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.25,
                            color: Color(0xff2D2D2D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const AllNotesScreen(),
                          //   ),
                          // );
                          showAllNotesBottomSheet(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            "View all notes >",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff5A4AA6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedTab = 0;
                          });
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.compare_arrows,
                                  size: 16,
                                  color: selectedTab == 0
                                      ? ChopdiColors.navy
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Transactions",
                                  style: TextStyle(
                                    color: selectedTab == 0
                                        ? ChopdiColors.navy
                                        : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 120, 
                              height: 3,
                              decoration: BoxDecoration(
                                color: selectedTab == 0
                                    ? ChopdiColors.navy
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedTab = 1;
                          });
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  size: 16,
                                  color: selectedTab == 1
                                      ? ChopdiColors.navy
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Overview",
                                  style: TextStyle(
                                    color: selectedTab == 1
                                        ? ChopdiColors.navy
                                        : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 100,
                              height: 3,
                              decoration: BoxDecoration(
                                color: selectedTab == 1
                                    ? ChopdiColors.navy
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade300,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // const TransactionTable(),
            selectedTab == 0
              ? const TransactionTable()
              : const OverviewWidget(),

            const SizedBox(height: 120),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ChopdiColors.navy,
        foregroundColor: ChopdiColors.cream,
        onPressed: () {
          showAddEntryBottomSheet(context);
        },
        icon: const Icon(Icons.add),
        label: Text("Add Entry",
          style: TextStyle(
            color: ChopdiColors.cream,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      bottomNavigationBar: BottomNavbar(
        currentIndex: bottomIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainScreen(),
                ),
              );
              break;

            case 1:
              Navigator.pop(context);
              break;

            case 2:
              // Open My Chopdi page
              break;
          }
        },
      ),
    );
  }
  
  Widget _infoItem(
      IconData icon,
      String title,
      String value,
      Color valueColor) {
    return Column(
      children: [

        CircleAvatar(
          radius: 16,
          backgroundColor:
              const Color(0xffFFF1E8),
          child: Icon(
            icon,
            size: 16,
            color: Colors.orange,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void showCustomerOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color.fromRGBO(253, 237, 217, 1),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return CustomerOptionsBottomSheet(

          onEdit: () {
            Navigator.pop(context); // Close first bottom sheet

            Future.delayed(const Duration(milliseconds: 200), () {
              showEditCustomerBottomSheet(context);
            });
          },

          onWhatsapp: () {
            Navigator.pop(context);
            // Open WhatsApp
          },

          onExport: () {
            Navigator.pop(context);

            Future.delayed(const Duration(milliseconds: 250), () {
              showExportPdfBottomSheet(context);
            });
          },

          onDelete: () {
            Navigator.pop(context);

            Future.delayed(const Duration(milliseconds: 250), () {
              showDeleteCustomerBottomSheet(context);
            });
          },
        );
      },
    );
  }

  void showEditCustomerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xffFDF8F2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (_) {
        return const EditCustomerBottomSheet();
      },
    );
  }

  void showExportPdfBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExportPdfBottomSheet(),
    );
  }

  void showDeleteCustomerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DeleteCustomerBottomSheet(
          customerName: "Rahul",
          onDelete: () {

            Navigator.pop(context);

            // Delete customer from database

          },
        );
      },
    );
  }

  void showAllNotesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const AllNotesBottomSheet();
      },
    );
  }

  void showAddEntryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEntryBottomSheet(),
    );
  }
}