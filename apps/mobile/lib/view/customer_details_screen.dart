import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
import 'package:mychopdi/view/all_notes_screen.dart';
import 'package:mychopdi/view/main_screen.dart';
import 'package:mychopdi/widgets/customer_options_bottom_sheet.dart';
import 'package:mychopdi/widgets/money_gave_bottom_sheet.dart';
import 'package:mychopdi/widgets/money_received_bottom_sheet.dart';
import 'package:mychopdi/widgets/transaction_table.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailsScreen extends StatefulWidget {

  final Customer customer;

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
  List<Transaction> transactions = [];
  late Customer customer;

  Future<void> loadCustomer() async {
    final updatedCustomer =
        await IsarService.isar.customers.get(widget.customer.id);

    if (updatedCustomer != null) {
      setState(() {
        customer = updatedCustomer;
      });
    }
  }

  Future<void> loadTransactions() async {
      transactions = await IsarService.isar.transactions
          .filter()
          .customerIdEqualTo(widget.customer.id)
          .sortByDate()
          .findAll();

      for (final tx in transactions) {
        print("----------------");
        print("Amount: ${tx.amount}");
        print("Rate: ${tx.interestRate}");
        print("Type: ${tx.interestType}");
        print("Frequency: ${tx.interestFrequency}");
        print("Date: ${tx.date}");
        print("Calculated Interest: ${calculateInterest(tx)}");
      }

      setState(() {});

  }


  @override
  void initState() {
    super.initState();
    customer = widget.customer;

    loadCustomer();
    loadTransactions();
  }

  double get totalGiven {
    return transactions
        .where((e) => e.type == TransactionType.gave)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalReceived {
    return transactions
        .where((e) => e.type == TransactionType.received)
        .fold(0.0, (sum, e) => sum + e.amount);
  }


  double get totalInterest {
    return transactions
        .where((e) => e.type == TransactionType.gave)
        .fold(
          0.0,
          (sum, tx) =>
              sum +
              InterestCalculator.calculate(
                principal: tx.amount,
                rate: tx.interestRate,
                startDate: tx.date,
                interestType: tx.interestType,
                frequency: tx.interestFrequency,
              ),
        );
  }

  double get outstanding {
    return totalGiven + totalInterest - totalReceived;
  }

  double calculateInterest(Transaction tx) {
    final days = DateTime.now().difference(tx.date).inDays;

    double time;

    if (tx.interestFrequency == "Monthly") {
      time = days / 30;
    } else {
      time = days / 365;
    }

    if (tx.interestType == "Simple Interest") {
      return tx.amount * tx.interestRate * time / 100;
    } else {
      return tx.amount *
              (pow(1 + tx.interestRate / 100, time) - 1);
    }
  }
  
  Transaction? get lastReceivedTransaction {
    final received = transactions
        .where((e) => e.type == TransactionType.received)
        .toList();

    if (received.isEmpty) return null;

    received.sort((a, b) => b.date.compareTo(a.date));

    return received.first;
  }

  Transaction? get firstLoanTransaction {
    final gave = transactions
        .where((e) => e.type == TransactionType.gave)
        .toList();

    if (gave.isEmpty) return null;

    gave.sort((a, b) => a.date.compareTo(b.date));

    return gave.first;
  }

  int get loanDays {
    if (firstLoanTransaction == null) return 0;

    return DateTime.now()
        .difference(firstLoanTransaction!.date)
        .inDays;
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open phone dialer'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;

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
                          child: MoneyGaveBottomSheet(
                            customer:widget.customer,
                            onSaved:loadTransactions,
                            isEdit:false,
                          ),
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
                          child: MoneyReceiveBottomSheet(
                            customer: widget.customer,
                            onSaved: loadTransactions,
                          ),
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

                  GestureDetector(
                    onTap: () {
                      makePhoneCall(customer.phone);
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Color.fromRGBO(141, 208, 113, 0.34),
                      child: Image.asset('assets/call_logo.png')
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 22),

            Container(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02,),

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
                      "₹${totalGiven.toStringAsFixed(0)}",
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
                      "Total Interest",
                      "₹${totalInterest.toStringAsFixed(0)}",
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
                      "Outstanding",
                      "₹${outstanding.toStringAsFixed(0)}",
                      Color(0xFFC74C4C),
                    ),
                  ),

                  // Container(
                  //   width: 1,
                  //   height: 55,
                  //   color: Colors.grey.shade300,
                  // ),

                  // Expanded(
                  //   child: _infoItem(
                  //     'assets/uil_calender.png',
                  //     "Since",
                  //     "$loanDays Days",
                  //     ChopdiColors.navy,
                  //   ),
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 12),

            TransactionTable(transactions:transactions, onChanged: loadTransactions, customerId: customer.id,),
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
    return SizedBox(
      height: 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFFFD7BE),
            child: Image.asset(
              imagePath,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(
            height: 30,
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ChopdiColors.navy,
                  height: 1.2,
                ),
              ),
            ),
          ),

          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
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

          onSummary: () {
            Navigator.pop(context); // Close first bottom sheet

            Future.delayed(const Duration(milliseconds: 200), () {
              return showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AccountSummaryBottomSheet(
                  totalGiven: totalGiven,
                  totalOutstanding: outstanding,
                  totalInterest: totalInterest,
                  lastPayment: lastReceivedTransaction,
                  firstLoan: firstLoanTransaction,
                ),
              );
            });
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
        return EditCustomerBottomSheet(
          customer: widget.customer,
          onSaved: () async {
            await loadCustomer();
            await loadTransactions();
            setState(() {});
          },
        );
      },
    );
  }

  void showExportPdfBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportPdfBottomSheet(
        customer: customer,
        transactions: transactions,
      ),
    );
  }

  void showDeleteCustomerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DeleteCustomerBottomSheet(
          customerName: widget.customer.name,
          onDelete: () async{

            // Navigator.pop(context);

            // Delete customer from database
            await IsarService.isar.writeTxn(() async {

              await IsarService.isar.transactions
                  .filter()
                  .customerIdEqualTo(widget.customer.id)
                  .deleteAll();

              await IsarService.isar.customers.delete(
                  widget.customer.id);

            });

            if (mounted) {
              // Navigator.pop(context); // Close delete sheet
              // Navigator.pop(context); // Back to home
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const MainScreen(),
                ),
                (route) => false,
              );
            }

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