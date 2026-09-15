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
import 'package:mychopdi/service/phone_call_service.dart';
import 'package:mychopdi/data/repository/repositories.dart';

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
    final loadedTransactions = await IsarService.isar.transactions
        .filter()
        .customerIdEqualTo(widget.customer.id)
        // Deleted entries are voided rather than removed so the deletion can
        // reach other devices; they must not appear here.
        .voidedAtIsNull()
        .findAll();

    // Newest transaction first
    loadedTransactions.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    if (!mounted) return;

    setState(() {
      transactions = loadedTransactions;
    });
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


  // double get totalInterest {
  //   return transactions
  //       .where((e) => e.type == TransactionType.gave)
  //       .fold(
  //         0.0,
  //         (sum, tx) =>
  //             sum +
  //             InterestCalculator.calculate(
  //               principal: tx.amount,
  //               rate: tx.interestRate,
  //               startDate: tx.date,
  //               interestType: tx.interestType,
  //               frequency: tx.interestFrequency,
  //             ),
  //       );
  // }

  double get totalInterest {
  return transactions
      .where(
        (e) => e.type == TransactionType.gave,
      )
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChopdiColors.cream,

      // ------------------------------------------------------------
      // TOP APP BAR
      // ------------------------------------------------------------
      appBar: AppBar(
        backgroundColor: ChopdiColors.cream,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: ChopdiColors.navy,
                ),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
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
                tooltip: 'Customer options',
              ),
            ],
          ),
        ),
      ),

      // ------------------------------------------------------------
      // BOTTOM ACTION BAR
      // ------------------------------------------------------------
      bottomNavigationBar: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = width < 360
                ? 10.0
                : width < 600
                    ? 16.0
                    : 24.0;

            final gap = width < 360 ? 8.0 : 14.0;

            final buttonFontSize = width < 360
                ? 15.0
                : width < 600
                    ? 18.0
                    : 20.0;

            return Container(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                10,
                horizontalPadding,
                10,
              ),
              color: AppColors.background,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: width < 360 ? 50 : 54,
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return MoneyGaveBottomSheet(
                                customer: widget.customer,
                                onSaved: loadTransactions,
                                isEdit: false,
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC74C4C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: width < 360 ? 4 : 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "You Gave ₹",
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: gap),

                  Expanded(
                    child: SizedBox(
                      height: width < 360 ? 50 : 54,
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return MoneyReceiveBottomSheet(
                                customer: widget.customer,
                                onSaved: loadTransactions,
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00901B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: width < 360 ? 4 : 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "You Got ₹",
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // ------------------------------------------------------------
      // BODY
      // ------------------------------------------------------------
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = width < 360
                ? 12.0
                : width < 600
                    ? 16.0
                    : 24.0;

            final avatarRadius = width < 360
                ? 25.0
                : width < 600
                    ? 30.0
                    : 34.0;

            final nameFontSize = width < 360
                ? 18.0
                : width < 600
                    ? 22.0
                    : 24.0;

            final phoneFontSize = width < 360 ? 11.0 : 13.0;

            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 700,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------
                      // CUSTOMER HEADER
                      // ------------------------------------------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: ChopdiColors.lightGray,
                            child: Text(
                              customer.name.isNotEmpty
                                  ? customer.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: avatarRadius * 0.9,
                                fontWeight: FontWeight.bold,
                                color: ChopdiColors.navy,
                              ),
                            ),
                          ),

                          SizedBox(
                            width: width < 360 ? 10 : 14,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  customer.name.isNotEmpty
                                      ? customer.name
                                      : "Customer",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: nameFontSize,
                                    color: ChopdiColors.navy,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                if (customer.phone.trim().isNotEmpty)
                                  Text(
                                    customer.phone,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: phoneFontSize,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          GestureDetector(
                            onTap: () {
                              PhoneCallService.makePhoneCall(
                                context,
                                customer.phone,
                              );
                            },
                            child: CircleAvatar(
                              radius: width < 360 ? 20 : 22,
                              backgroundColor:
                                  const Color.fromRGBO(
                                141,
                                208,
                                113,
                                0.34,
                              ),
                              child: Image.asset(
                                'assets/call_logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: width < 360 ? 16 : 22),

                      // ------------------------------------------------
                      // ACCOUNT SUMMARY CARD
                      // ------------------------------------------------
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: width < 360 ? 8 : 12,
                          vertical: width < 360 ? 10 : 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(
                            255,
                            248,
                            240,
                            1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFAAB9CF),
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, cardConstraints) {
                            // Keep all three values in a row. The content
                            // inside each Expanded item scales down rather
                            // than overflowing on small screens.
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
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
                                  height: width < 360 ? 48 : 55,
                                  color: Colors.grey.shade300,
                                ),

                                Expanded(
                                  child: _infoItem(
                                    'assets/total_interest.png',
                                    "Total Interest",
                                    "₹${totalInterest.toStringAsFixed(0)}",
                                    const Color(0xFF00901B),
                                  ),
                                ),

                                Container(
                                  width: 1,
                                  height: width < 360 ? 48 : 55,
                                  color: Colors.grey.shade300,
                                ),

                                Expanded(
                                  child: _infoItem(
                                    'assets/outstanding.png',
                                    "Outstanding",
                                    "₹${outstanding.toStringAsFixed(0)}",
                                    const Color(0xFFC74C4C),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      SizedBox(height: width < 360 ? 16 : 20),

                      // ------------------------------------------------
                      // TRANSACTIONS
                      // ------------------------------------------------
                      TransactionTable(
                        transactions: transactions,
                        onChanged: loadTransactions,
                        customerId: customer.id,
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final iconRadius = availableWidth < 85 ? 13.0 : 16.0;
        final iconSize = availableWidth < 85 ? 15.0 : 18.0;
        final titleSize = availableWidth < 85 ? 8.0 : 10.0;
        final valueSize = availableWidth < 85 ? 14.0 : 18.0;

        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: iconRadius,
                backgroundColor: const Color(0xFFFFD7BE),
                child: Image.asset(
                  imagePath,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 5),

              SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: ChopdiColors.navy,
                      height: 1.15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 2),

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

          onDelete: () async{
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) {
        return EditCustomerBottomSheet(
          customer: customer,
          onSaved: () {
            // refresh customer data
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

            // Customer and entries are voided together in one transaction,
            // each queued for sync. Deleting them separately would leave a
            // window where a crash orphans entries against a deleted parent.
            
            await Repositories.customers.softDeleteWithEntries(widget.customer);

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