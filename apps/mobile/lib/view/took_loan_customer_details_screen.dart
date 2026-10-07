
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:isar_community/isar.dart';
  import 'package:mychopdi/model/lender.dart'; // <-- USING LENDER
  import 'package:mychopdi/model/transaction.dart';
  import 'package:mychopdi/service/isar_service.dart';
  import 'package:mychopdi/utils/app_colors.dart';
  import 'package:mychopdi/utils/interest_calculator.dart';
  import 'package:mychopdi/view/all_notes_screen.dart';
  import 'package:mychopdi/view/main_screen.dart';
  import 'package:mychopdi/service/phone_call_service.dart';

  import '../l10n/app_localizations.dart';

  // NOTE: Make sure these import paths match where your files are actually saved!
  import 'package:mychopdi/widgets/took_loan_money_gave_bottom_sheet.dart';
  import 'package:mychopdi/widgets/took_loan_money_received_bottom_sheet.dart';
  import 'package:mychopdi/widgets/took_loan_transaction_table.dart';

  import '../widgets/LenderOptionsBottomSheet.dart'; // Change this path if you saved your Lender bottom sheets in a different file

  class TookLoanCustomerDetailsScreen extends StatefulWidget {
    final Lender lender; // <-- USING LENDER
    final int? highlightTransactionId;


    const TookLoanCustomerDetailsScreen({
      super.key,
      required this.lender, // <-- USING LENDER
      this.highlightTransactionId,
    });

    @override
    State<TookLoanCustomerDetailsScreen> createState() =>
        _CustomerDetailsScreenState();
  }

  class _CustomerDetailsScreenState extends State<TookLoanCustomerDetailsScreen> {
    List<Transaction> transactions = [];

    late Lender lender; // <-- USING LENDER

    // ============================================================
    // LENDER (Previously Customer)
    // ============================================================

    Future<void> loadLender() async {
      final updatedLender = await IsarService.isar.lenders.get(widget.lender.id);

      if (updatedLender != null && mounted) {
        setState(() {
          lender = updatedLender;
        });
      }
    }

    // ============================================================
    // TRANSACTIONS (WITH THE UUID BUG FIX!)
    // ============================================================

    Future<void> loadTransactions() async {
      final loadedTransactions = await IsarService.isar.transactions
          .filter()
          .customerUuidEqualTo(widget.lender.uuid) // <-- BUG FIX: Uses globally unique UUID instead of local ID
          .voidedAtIsNull()
          .sortByDate()
          .findAll();

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

      lender = widget.lender;

      loadLender();
      loadTransactions();
    }

    // ============================================================
    // CHECK WHETHER MONEY WAS EVER TAKEN
    // ============================================================

    bool get hasTakenLoan {
      return transactions.any(
            (tx) => tx.type == TransactionType.took,
      );
    }

    // ============================================================
    // TOTAL TAKEN
    // ============================================================

    double get totalGiven {
      return transactions
          .where((e) => e.type == TransactionType.took)
          .fold(
        0.0,
            (sum, e) => sum + e.amount,
      );
    }

    // ============================================================
    // TOTAL PAID
    // ============================================================

    double get totalReceived {
      return transactions
          .where((e) => e.type == TransactionType.paid)
          .fold(
        0.0,
            (sum, e) => sum + e.amount,
      );
    }

    // ============================================================
    // TOTAL INTEREST
    // ============================================================

    double get totalInterest {
      return transactions
          .where((e) => e.type == TransactionType.took)
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
      return (totalGiven + totalInterest - totalReceived)
          .clamp(0.0, double.infinity);
    }

    // ============================================================
    // INTEREST CALCULATION
    // ============================================================

    // double calculateInterest(Transaction tx) {
    //   final days = DateTime.now().difference(tx.date).inDays;

    //   double time;

    //   if (tx.interestFrequency == "Monthly") {
    //     time = days / 30;
    //   } else {
    //     time = days / 365;
    //   }

    //   if (tx.interestType == "Simple Interest") {
    //     return tx.amount * tx.interestRate * time / 100;
    //   } else {
    //     return tx.amount *
    //         (pow(
    //           1 + tx.interestRate / 100,
    //           time,
    //         ) -
    //             1);
    //   }
    // }

    // ============================================================
    // LAST PAID TRANSACTION
    // ============================================================

    Transaction? get lastReceivedTransaction {
      final received = transactions
          .where((e) => e.type == TransactionType.paid)
          .toList();

      if (received.isEmpty) return null;

      received.sort(
            (a, b) => b.date.compareTo(a.date),
      );

      return received.first;
    }

    // ============================================================
    // FIRST TAKEN LOAN TRANSACTION
    // ============================================================

    Transaction? get firstLoanTransaction {
      final took = transactions
          .where((e) => e.type == TransactionType.took)
          .toList();

      if (took.isEmpty) return null;

      took.sort(
            (a, b) => a.date.compareTo(b.date),
      );

      return took.first;
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
    // COMMON BACK NAVIGATION
    // ============================================================

    void _goToHome() {
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainScreen(
            initialIndex: 0,
            initialGaveLoanSelected: false,
          ),
        ),
            (route) => false,
      );
    }

    // ============================================================
    // BUILD
    // ============================================================

    @override
    Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context);

      final size = MediaQuery.of(context).size;

      final width = size.width;
      final height = size.height;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _goToHome();
        },
        child: Scaffold(
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
                  onPressed: _goToHome,
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
                  // YOU TOOK
                  // ALWAYS VISIBLE
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
                              child: TookLoanMoneyGaveBottomSheet(
                                lender: widget.lender, // <-- PASSING LENDER
                                onSaved: loadTransactions,
                                isEdit: false,
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
                      child: Text(
                        l10n.youGot,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // ====================================================
                  // YOU PAID
                  // SHOW ONLY AFTER FIRST TOOK TRANSACTION
                  // ====================================================

                  if (hasTakenLoan) ...[
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
                                child: TookLoanMoneyReceivedBottomSheet(
                                  lender: widget.lender, // <-- PASSING LENDER
                                  onSaved: loadTransactions,
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
                        child: Text(
                          l10n.youGave,
                          style: const TextStyle(
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
                // LENDER HEADER
                // ======================================================

                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: ChopdiColors.lightGray,
                      child: Text(
                        lender.name.isNotEmpty
                            ? lender.name[0].toUpperCase()
                            : "?",
                        style: GoogleFonts.manrope(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ChopdiColors.navy,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lender.name, // <-- LENDER NAME
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: ChopdiColors.navy,
                            ),
                          ),

                          const SizedBox(height: 1),

                          Text(
                            lender.phone, // <-- LENDER PHONE
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: Colors.black54,
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
                          lender.phone, // <-- LENDER PHONE
                        );
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color.fromRGBO(
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
                          l10n.totalTaken,
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
                          l10n.interestDue,
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
                          l10n.outstanding,
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
                // ======================================================

                TookLoanTransactionTable(
                  transactions: transactions,
                  onChanged: loadTransactions,
                    lenderUuid: lender.uuid,
                  highlightTransactionId:
                  widget.highlightTransactionId,
                ),

                const SizedBox(height: 20),
              ],
            ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xFFFFD7BE),
              child: Image.asset(
                imagePath,
                width: 17,
                height: 17,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 5),

            SizedBox(
              height: 25,
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: ChopdiColors.navy,
                    height: 1.1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 2),

            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ============================================================
    // CUSTOMER OPTIONS (RE-ROUTED TO LENDER BOTTOM SHEETS)
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
          return LenderOptionsBottomSheet( // <-- CALLING NEW LENDER OPTIONS SHEET
            onEdit: () {
              Navigator.pop(context);

              Future.delayed(
                const Duration(milliseconds: 200),
                    () {
                  showEditLenderBottomSheet(context);
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
                          lastPayment: lastReceivedTransaction,
                          firstLoan: firstLoanTransaction,
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

            onDelete: () {
              Navigator.pop(context);

              Future.delayed(
                const Duration(milliseconds: 250),
                    () {
                  showDeleteLenderBottomSheet(context);
                },
              );
            },
          );
        },
      );
    }

    // ============================================================
    // EDIT LENDER
    // ============================================================

    void showEditLenderBottomSheet(BuildContext context) {
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
          return EditLenderBottomSheet( // <-- CALLING NEW LENDER EDIT SHEET
            lender: widget.lender,
            onSaved: () async {
              await loadLender();
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

    void showExportPdfBottomSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ExportLenderPdfBottomSheet( // <-- CALLING NEW LENDER PDF SHEET
          lender: lender,
          transactions: transactions,
          isTookLoan: true,
        ),
      );
    }

    // ============================================================
    // DELETE LENDER
    // ============================================================

    void showDeleteLenderBottomSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return DeleteLenderBottomSheet( // <-- CALLING NEW LENDER DELETE SHEET
            lenderName: widget.lender.name,
            onDelete: () async {
              await IsarService.isar.writeTxn(() async {
                await IsarService.isar.transactions
                    .filter()
                    .customerIdEqualTo(widget.lender.id)
                    .deleteAll();

                await IsarService.isar.lenders.delete(
                  widget.lender.id,
                );
              });

              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(
                      initialIndex: 0,
                      initialGaveLoanSelected: false,
                    ),
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