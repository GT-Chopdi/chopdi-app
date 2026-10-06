import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/lender.dart'; // <-- IMPORT LENDER
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
import 'package:mychopdi/widgets/customer_filter_bottom_sheet.dart';
import 'package:mychopdi/widgets/sort_bottom_sheet.dart';
import 'package:mychopdi/widgets/took_loan_customer_card.dart';
import 'package:isar_community/isar.dart';

import '../l10n/app_localizations.dart';
import '../model/transaction.dart';
import '../service/isar_service.dart';

class TookLoanCustomerListSection extends StatefulWidget {
  final List<Lender> lenders; // <-- CHANGED TO LENDER

  const TookLoanCustomerListSection({
    super.key,
    required this.lenders, // <-- CHANGED TO LENDER
  });

  @override
  State<TookLoanCustomerListSection> createState() =>
      _TookLoanCustomerListSectionState();
}

class _TookLoanCustomerListSectionState
    extends State<TookLoanCustomerListSection> {
  final TextEditingController searchController = TextEditingController();

  late List<Lender> filteredLenders; // <-- CHANGED TO LENDER

  // ============================================================
  // FILTER VALUES
  // ============================================================

  String selectedStatus = "All";
  String selectedSort = "Most Recent";

  // ============================================================
  // SORT
  // ============================================================

  // Keep internal value in English because sorting logic
  // depends on these exact values.
  // String selectedSort = "Recently Added";

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    filteredLenders = List.from(widget.lenders);

    applyFilters();
  }

  Future<void> _initializeFilters() async {
    final result = await _getFilteredLenders();

    _applySortToList(result);

    if (!mounted) return;

    setState(() {
      filteredLenders = result;
    });
  }

  // ============================================================
  // UPDATE WIDGET
  // ============================================================

  @override
  void didUpdateWidget(
      TookLoanCustomerListSection oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    applyFilters();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // GET LENDER BALANCE
  // ============================================================

  //Lender balance calculation is wrong.

  // Future<double> getLenderBalance(int lenderId) async {
  //   final transactions = await IsarService.isar.transactions
  //       .filter()
  //       .customerIdEqualTo(lenderId) // Transaction table still uses customerId
  //       .voidedAtIsNull()
  //       .findAll();
  //   double balance = 0;
  //   for (final tx in transactions) {
  //     // Replaced 'gave' with 'took' because this is the Took Loan section
  //     if (tx.type == TransactionType.took) {
  //       balance += tx.amount;
  //     } else {
  //       balance -= tx.amount;
  //     }
  //   }
  //   return balance;
  // }

  Future<double> getLenderBalance(int lenderId) async {
    final transactions = await IsarService.isar.transactions
        .filter()
        .customerIdEqualTo(lenderId)
        .voidedAtIsNull()
        .findAll();

    double totalLoanTaken = 0;
    double totalPaid = 0;
    double totalInterest = 0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.took) {
        totalLoanTaken += tx.amount;

        try {
          totalInterest += InterestCalculator.calculate(
            principal: tx.amount,
            rate: tx.interestRate,
            startDate: tx.date,
            interestType: tx.interestType,
            frequency: tx.interestFrequency,
          );
        } catch (_) {
          // Keep interest as 0 if calculation fails.
        }
      } else if (tx.type == TransactionType.paid) {
        totalPaid += tx.amount;
      }
    }

    final outstanding =
        totalLoanTaken + totalInterest - totalPaid;

    return outstanding.clamp(0.0, double.infinity);
  }

  // ============================================================
  // FILTERED LENDERS
  // ============================================================

  Future<List<Lender>> _getFilteredLenders() async {
  final search = searchController.text.toLowerCase().trim();

  final List<Lender> result = [];

  for (final lender in widget.lenders) {
    // SEARCH
    final matchesSearch =
        search.isEmpty ||
        lender.name.toLowerCase().contains(search) ||
        lender.phone.contains(search);

    if (!matchesSearch) {
      continue;
    }

    // STATUS
    bool matchesStatus = true;

    if (selectedStatus == "All") {
      matchesStatus = true;
    } else if (selectedStatus == "Settled") {
      final balance = await getLenderBalance(lender.id);

      matchesStatus = balance == 0;
    }

    if (!matchesStatus) {
      continue;
    }

    result.add(lender);
  }

  return result;
}

  // ============================================================
  // APPLY SEARCH + FILTER
  // ============================================================
Future<void> applyFilters() async {
  final result = await _getFilteredLenders();

  await _applySortToList(result);

  if (!mounted) return;

  setState(() {
    filteredLenders = result;
  });
}

  // ============================================================
  // SORT
  // ============================================================

Future<void> _applySortToList(
  List<Lender> lenders,
) async {
  switch (selectedSort) {
    case "Most Recent":
      lenders.sort(
        (a, b) => b.updatedAt.compareTo(a.updatedAt),
      );
      break;

    case "Oldest":
      lenders.sort(
        (a, b) => a.updatedAt.compareTo(b.updatedAt),
      );
      break;

    case "By Name (A-Z)":
      lenders.sort(
        (a, b) => a.name
            .toLowerCase()
            .compareTo(b.name.toLowerCase()),
      );
      break;

    case "Highest Amount":
      final balances = <int, double>{};

      for (final lender in lenders) {
        balances[lender.id] =
            await getLenderBalance(lender.id);
      }

      lenders.sort(
        (a, b) {
          final balanceA = balances[a.id] ?? 0;
          final balanceB = balances[b.id] ?? 0;

          return balanceB.compareTo(balanceA);
        },
      );
      break;

    case "Least Amount":
      final balances = <int, double>{};

      for (final lender in lenders) {
        balances[lender.id] =
            await getLenderBalance(lender.id);
      }

      lenders.sort(
        (a, b) {
          final balanceA = balances[a.id] ?? 0;
          final balanceB = balances[b.id] ?? 0;

          return balanceA.compareTo(balanceB);
        },
      );
      break;
  }
}

  // ============================================================
  // LOCALIZED SORT NAME
  // ============================================================

 String getLocalizedSortName(
  BuildContext context,
  String sort,
) {
  final l10n = AppLocalizations.of(context);

  switch (sort) {
    case "Most Recent":
      return l10n.mostRecent;

    case "Oldest":
      return l10n.oldest;

    case "By Name (A-Z)":
      return l10n.byNameAZ;

    case "Highest Amount":
      return l10n.highestAmount;

    case "Least Amount":
      return l10n.leastAmount;

    default:
      return sort;
  }
}

  // ============================================================
  // SEARCH
  // ============================================================

  void searchCustomer(String value) {
    applyFilters();
  }

  // ============================================================
  // FILTER BOTTOM SHEET
  // ============================================================
Future<void> showFilterSheet() async {
  final result =
      await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return CustomerFilterBottomSheet(
        selectedStatus: selectedStatus,
        selectedSort: selectedSort,
      );
    },
  );

  if (result == null) {
    return;
  }

  setState(() {
    selectedStatus = result["status"] ?? "All";
    selectedSort = result["sort"] ?? "Most Recent";
  });

  await applyFilters();
}

  // ============================================================
  // SORT BOTTOM SHEET
  // ============================================================

  Future<void> showSortSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const SortBottomSheet();
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedSort = result;
    });

    await applyFilters();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final localizedSort = getLocalizedSortName(
      context,
      selectedSort,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ========================================================
        // HEADER
        // ========================================================

        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lender1,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ChopdiColors.navy,
                  ),
                ),
                Text(
                  l10n.manageAllLender,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color.fromRGBO(34, 58, 94, 0.62),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),

        const SizedBox(height: 20),

        // ========================================================
        // SEARCH + FILTER
        // ========================================================

        Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color.fromRGBO(170, 185, 207, 1),
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: searchCustomer,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/search_option.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                    hintText: l10n.searchByNameAndPhone,
                    hintStyle: const TextStyle(
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // ==================================================
            // FILTER BUTTON
            // ==================================================

            InkWell(
              onTap: showFilterSheet,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color.fromRGBO(170, 185, 207, 1),
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/filter.png',
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 5),
                    Text(l10n.filter),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        const SizedBox(height: 10),

        // ========================================================
        // EMPTY STATE
        // ========================================================

        if (filteredLenders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Text(
                l10n.noCustomersFound,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else

        // ======================================================
        // TOOK LOAN LENDER CARDS
        // ======================================================

          ...List.generate(
            filteredLenders.length,
                (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TookLoanCustomerCard(
                  lender: filteredLenders[index], // <-- FIXED INSTANTIATION
                ),
              );
            },
          ),
      ],
    );
  }
}