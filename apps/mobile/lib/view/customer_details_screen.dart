import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/customer_model.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/all_notes_screen.dart';
import 'package:mychopdi/widgets/customer_options_bottom_sheet.dart';
import 'package:mychopdi/widgets/money_gave_bottom_sheet.dart';
import 'package:mychopdi/widgets/money_received_bottom_sheet.dart';
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

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.background,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return FractionallySizedBox(
                          heightFactor: 0.82, // Change this value
                          child: const MoneyGaveBottomSheet(),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC74C4C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "You Gave ₹",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return FractionallySizedBox(
                          heightFactor: 0.82, // Change this value
                          child: const MoneyReceiveBottomSheet(),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00901B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "You Got ₹",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                  radius: 30,
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

                Column(
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

                      const SizedBox(height: 1),

                      Row(
                        children: [
                          Text(
                            customer.phone,
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 4),      
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color.fromRGBO(141, 208, 113, 0.34),
                    child: Image.asset('assets/call_logo.png')
                  ),
              ],
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 248, 240, 1),
                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: Color(0xFFAAB9CF),
                ),
              ),

              child: Row(
                children: [

                  Expanded(
                    child: _infoItem(
                      'assets/total_given.png',
                      "Total Given",
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
                      'assets/total_interest.png',
                      "Interest Rate",
                      "₹2,000",
                      Color(0xFF00901B),
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 55,
                    color: Colors.grey.shade300,
                  ),

                  Expanded(
                    child: _infoItem(
                      'assets/outstanding.png',
                      "Total Received",
                      "₹12,000",
                      Color(0xFFC74C4C),
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 55,
                    color: Colors.grey.shade300,
                  ),

                  Expanded(
                    child: _infoItem(
                      'assets/uil_calender.png',
                      "Outstanding",
                      "15 days",
                      ChopdiColors.navy,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 12),

            const TransactionTable(),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(
    String imagePath,
    String title,
    String value,
    Color valueColor,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Color.fromRGBO(255, 215, 190, 1),
          child: Image.asset(
            imagePath,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: ChopdiColors.navy,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: 18,
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
}