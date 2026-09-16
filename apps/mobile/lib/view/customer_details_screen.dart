import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/phone_call_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
import 'package:mychopdi/view/all_notes_screen.dart';
import 'package:mychopdi/view/main_screen.dart';
import 'package:mychopdi/widgets/customer_options_bottom_sheet.dart';
import 'package:mychopdi/widgets/money_gave_bottom_sheet.dart';
import 'package:mychopdi/widgets/money_received_bottom_sheet.dart';
import 'package:mychopdi/widgets/transaction_table.dart';
import 'package:mychopdi/data/repository/repositories.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerDetailsScreen> createState() =>
      _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  List<Transaction> transactions = [];

  late Customer customer;

  // ============================================================
  // CUSTOMER
  // ============================================================

  Future<void> loadCustomer() async {
    final updatedCustomer = await IsarService.isar.customers.get(
      widget.customer.id,
    );

    if (updatedCustomer != null && mounted) {
      setState(() {
        customer = updatedCustomer;
      });
    }
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Future<void> loadTransactions() async {
    final loadedTransactions = await IsarService.isar.transactions
        .filter()
        .customerIdEqualTo(widget.customer.id)
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

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    customer = widget.customer;

    loadCustomer();
    loadTransactions();
  }

  // ============================================================
  // CHECK WHETHER CUSTOMER HAS EVER TAKEN MONEY
  // ============================================================

  bool get hasLoanTransaction {
    return transactions.any(
          (tx) => tx.type == TransactionType.gave,
    );
  }

  // ============================================================
  // TOTAL GIVEN
  // ============================================================

  double get totalGiven {
    return transactions
        .where((e) => e.type == TransactionType.gave)
        .fold(
      0.0,
          (sum, e) => sum + e.amount,
    );
  }

  // ============================================================
  // TOTAL RECEIVED
  // ============================================================

  double get totalReceived {
    return transactions
        .where((e) => e.type == TransactionType.received)
        .fold(
      0.0,
          (sum, e) => sum + e.amount,
    );
  }

  // ============================================================
  // INTEREST
  // ============================================================

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

  // ============================================================
  // OUTSTANDING
  // ============================================================

  double get outstanding {
    return totalGiven + totalInterest - totalReceived;
  }

  // ============================================================
  // INTEREST CALCULATION
  // ============================================================

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
          (pow(
            1 + tx.interestRate / 100,
            time,
          ) -
              1);
    }
  }

  // ============================================================
  // LAST RECEIVED TRANSACTION
  // ============================================================

  Transaction? get lastReceivedTransaction {
    final received = transactions
        .where(
          (e) => e.type == TransactionType.received,
    )
        .toList();

    if (received.isEmpty) return null;

    received.sort(
          (a, b) => b.date.compareTo(a.date),
    );

    return received.first;
  }

  // ============================================================
  // FIRST LOAN TRANSACTION
  // ============================================================

  Transaction? get firstLoanTransaction {
    final gave = transactions
        .where(
          (e) => e.type == TransactionType.gave,
    )
        .toList();

    if (gave.isEmpty) return null;

    gave.sort(
          (a, b) => a.date.compareTo(b.date),
    );

    return gave.first;
  }

  // ============================================================
  // LOAN DAYS
  // ============================================================

  int get loanDays {
    if (firstLoanTransaction == null) return 0;

    return DateTime.now()
        .difference(firstLoanTransaction!.date)
        .inDays;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: ChopdiColors.cream,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: ChopdiColors.cream,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: ChopdiColors.navy,
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(),
                  ),
                      (route) => false,
                );
              },
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

      // ==========================================================
      // BOTTOM ACTION BUTTONS
      // ==========================================================

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.background,
          child: Row(
            children: [
              // ====================================================
              // YOU GAVE
              // ====================================================

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return FractionallySizedBox(
                          heightFactor: 0.82,
                          child: MoneyGaveBottomSheet(
                            customer: widget.customer,
                            onSaved: loadTransactions,
                            isEdit: false,
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC74C4C),
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

              // ====================================================
              // YOU GOT
              //
              // Show ONLY after at least one GAVE transaction.
              // ====================================================

              if (hasLoanTransaction) ...[
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
                            heightFactor: 0.82,
                            child: MoneyReceiveBottomSheet(
                              customer: widget.customer,
                              onSaved: loadTransactions,
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00901B),
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
            ],
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // CUSTOMER HEADER
            // ======================================================

            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: ChopdiColors.lightGray,
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : "?",
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
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: ChopdiColors.navy,
                        ),
                      ),

                      const SizedBox(height: 1),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              customer.phone,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
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
                    radius: 22,
                    backgroundColor:
                    const Color.fromRGBO(
                      141,
                      208,
                      113,
                      0.34,
                    ),
                    child: Image.asset(
                      'assets/call_logo.png',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ======================================================
            // SUMMARY
            // ======================================================

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02,
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
                      const Color(0xFF00901B),
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
                      const Color(0xFFC74C4C),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ======================================================
            // TRANSACTION TABLE
            //
            // NO I GAVE / I GOT TABS HERE.
            // Show all transactions.
            // ======================================================

            TransactionTable(
              transactions: transactions,
              onChanged: loadTransactions,
              customerId: customer.id,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

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

  // ============================================================
  // CUSTOMER OPTIONS
  // ============================================================

  void showCustomerOptionsBottomSheet(
      BuildContext context,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
      const Color.fromRGBO(253, 237, 217, 1),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return CustomerOptionsBottomSheet(
          onEdit: () {
            Navigator.pop(context);

            Future.delayed(
              const Duration(milliseconds: 200),
                  () {
                showEditCustomerBottomSheet(context);
              },
            );
          },

          onSummary: () {
            Navigator.pop(context);

            Future.delayed(
              const Duration(milliseconds: 200),
                  () {
                return showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) =>
                      AccountSummaryBottomSheet(
                        totalGiven: totalGiven,
                        totalOutstanding: outstanding,
                        totalInterest: totalInterest,
                        lastPayment:
                        lastReceivedTransaction,
                        firstLoan:
                        firstLoanTransaction,
                      ),
                );
              },
            );
          },

          onExport: () {
            Navigator.pop(context);

            Future.delayed(
              const Duration(milliseconds: 250),
                  () {
                showExportPdfBottomSheet(context);
              },
            );
          },

          onDelete: () async {
            Navigator.pop(context);

            Future.delayed(
              const Duration(milliseconds: 250),
                  () {
                showDeleteCustomerBottomSheet(context);
              },
            );
          },
        );
      },
    );
  }

  // ============================================================
  // EDIT CUSTOMER
  // ============================================================

  void showEditCustomerBottomSheet(
      BuildContext context,
      ) {
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

            if (mounted) {
              setState(() {});
            }
          },
        );
      },
    );
  }

  // ============================================================
  // EXPORT PDF
  // ============================================================

  void showExportPdfBottomSheet(
      BuildContext context,
      ) {
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

  // ============================================================
  // DELETE CUSTOMER
  // ============================================================

  void showDeleteCustomerBottomSheet(
      BuildContext context,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DeleteCustomerBottomSheet(
          customerName: widget.customer.name,
          onDelete: () async {
            await Repositories.customers
                .softDeleteWithEntries(
              widget.customer,
            );

            if (mounted) {
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

  // ============================================================
  // ALL NOTES
  // ============================================================

  void showAllNotesBottomSheet(
      BuildContext context,
      ) {
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