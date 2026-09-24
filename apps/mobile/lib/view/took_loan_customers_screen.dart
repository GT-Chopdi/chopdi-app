import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/customer_filter_bottom_sheet.dart';
import 'package:mychopdi/widgets/sort_bottom_sheet.dart';
import 'package:mychopdi/widgets/took_loan_customer_card.dart';
import 'package:isar_community/isar.dart';

import '../l10n/app_localizations.dart';
import '../model/transaction.dart';
import '../service/isar_service.dart';

class TookLoanCustomerListSection extends StatefulWidget {
  final List<Customer> customers;

  const TookLoanCustomerListSection({
    super.key,
    required this.customers,
  });

  @override
  State<TookLoanCustomerListSection> createState() =>
      _TookLoanCustomerListSectionState();
}

class _TookLoanCustomerListSectionState
    extends State<TookLoanCustomerListSection> {
  final TextEditingController searchController =
  TextEditingController();

  late List<Customer> filteredCustomers;

  // ============================================================
  // FILTER VALUES
  // ============================================================

  String selectedStatus = "All";
  String selectedDate = "This Month";

  DateTime? fromDate;
  DateTime? toDate;

  // ============================================================
  // SORT
  // ============================================================

  // Keep internal value in English because sorting logic
  // depends on these exact values.
  String selectedSort = "Recently Added";

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    filteredCustomers = List.from(widget.customers);

    _initializeFilters();
  }

  Future<void> _initializeFilters() async {
    final result = await _getFilteredCustomers();

    _applySortToList(result);

    if (!mounted) return;

    setState(() {
      filteredCustomers = result;
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
  // GET CUSTOMER BALANCE
  // ============================================================

  Future<double> getCustomerBalance(int customerId) async {
    final transactions = await IsarService.isar.transactions
        .filter()
        .customerIdEqualTo(customerId)
        .voidedAtIsNull()
        .findAll();

    double balance = 0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.gave) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }

    return balance;
  }

  // ============================================================
  // FILTERED CUSTOMERS
  // ============================================================

  Future<List<Customer>> _getFilteredCustomers() async {
    final search =
    searchController.text.toLowerCase().trim();

    final List<Customer> result = [];

    for (final customer in widget.customers) {
      // ========================================================
      // SEARCH
      // ========================================================

      final matchesSearch =
          search.isEmpty ||
              customer.name.toLowerCase().contains(search) ||
              customer.phone.contains(search);

      if (!matchesSearch) {
        continue;
      }

      // ========================================================
      // STATUS
      // ========================================================

      bool matchesStatus = true;

      if (selectedStatus == "Pending") {
        // Pending continues to use the customer's stored status.
        matchesStatus =
            customer.status.toLowerCase() == "pending";
      } else if (selectedStatus == "Settled") {
        // IMPORTANT:
        // Settled is calculated from the actual ledger balance.
        //
        // A customer is settled when:
        // Gave amount - Got amount = 0
        //
        // This avoids depending on customer.status being exactly
        // "Settled".
        final balance =
        await getCustomerBalance(customer.id);

        matchesStatus = balance == 0;
      }

      if (!matchesStatus) {
        continue;
      }

      // ========================================================
      // DATE
      // ========================================================

      bool matchesDate = true;

      if (selectedDate == "This Month") {
        final now = DateTime.now();

        final firstDayOfMonth = DateTime(
          now.year,
          now.month,
          1,
        );

        final nextMonth = DateTime(
          now.year,
          now.month + 1,
          1,
        );

        matchesDate =
            !customer.updatedAt.isBefore(firstDayOfMonth) &&
                customer.updatedAt.isBefore(nextMonth);
      }

      if (selectedDate == "Custom") {
        if (fromDate != null) {
          final startDate = DateTime(
            fromDate!.year,
            fromDate!.month,
            fromDate!.day,
          );

          matchesDate =
              matchesDate &&
                  !customer.updatedAt.isBefore(startDate);
        }

        if (toDate != null) {
          final endDate = DateTime(
            toDate!.year,
            toDate!.month,
            toDate!.day,
            23,
            59,
            59,
          );

          matchesDate =
              matchesDate &&
                  !customer.updatedAt.isAfter(endDate);
        }
      }

      if (!matchesDate) {
        continue;
      }

      result.add(customer);
    }

    return result;
  }

  // ============================================================
  // APPLY SEARCH + FILTER
  // ============================================================

  Future<void> applyFilters() async {
    final result = await _getFilteredCustomers();

    _applySortToList(result);

    if (!mounted) return;

    setState(() {
      filteredCustomers = result;
    });
  }

  // ============================================================
  // SORT
  // ============================================================

  void _applySortToList(List<Customer> customers) {
    if (selectedSort == "Name (A-Z)") {
      customers.sort(
            (a, b) => a.name
            .toLowerCase()
            .compareTo(
          b.name.toLowerCase(),
        ),
      );
    } else if (selectedSort == "Name (Z-A)") {
      customers.sort(
            (a, b) => b.name
            .toLowerCase()
            .compareTo(
          a.name.toLowerCase(),
        ),
      );
    } else if (selectedSort == "Recently Added") {
      customers.sort(
            (a, b) => b.updatedAt.compareTo(
          a.updatedAt,
        ),
      );
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
      case "Name (A-Z)":
        return l10n.sortNameAZ;

      case "Name (Z-A)":
        return l10n.sortNameZA;

      case "Recently Added":
        return l10n.sortRecentlyAdded;

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
          selectedDate: selectedDate,
          fromDate: fromDate,
          toDate: toDate,
        );
      },
    );

    // User closed without Apply
    if (result == null) {
      return;
    }

    setState(() {
      selectedStatus =
          result["status"] ?? "All";

      selectedDate =
          result["date"] ?? "This Month";

      fromDate = result["from"];
      toDate = result["to"];
    });

    await applyFilters();
  }

  // ============================================================
  // SORT BOTTOM SHEET
  // ============================================================

  Future<void> showSortSheet() async {
    final result =
    await showModalBottomSheet<String>(
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

    final localizedSort =
    getLocalizedSortName(
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
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  // "Lender",
                  l10n.lender,
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
                    color: const Color.fromRGBO(
                      34,
                      58,
                      94,
                      0.62,
                    ),
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
                  borderRadius:
                  BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color.fromRGBO(
                      170,
                      185,
                      207,
                      1,
                    ),
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: searchCustomer,
                  textAlignVertical:
                  TextAlignVertical.center,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding:
                      const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/search_option.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                    hintText:
                    l10n.searchByNameAndPhone,
                    hintStyle:
                    const TextStyle(
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.zero,
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
              borderRadius:
              BorderRadius.circular(25),
              child: Container(
                height: 46,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color.fromRGBO(
                      170,
                      185,
                      207,
                      1,
                    ),
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

                    Text(
                      l10n.filter,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // ========================================================
        // COUNT + SORT
        // ========================================================

        Row(
          children: [
            Text(
              l10n.customersCount(
                filteredCustomers.length,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            GestureDetector(
              onTap: showSortSheet,
              child: Row(
                children: [
                  const Icon(
                    Icons.swap_vert,
                    size: 16,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    '${l10n.sortBy} : $localizedSort',
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),

                  const Icon(
                    Icons.arrow_drop_down,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ========================================================
        // EMPTY STATE
        // ========================================================

        if (filteredCustomers.isEmpty)
          Padding(
            padding:
            const EdgeInsets.symmetric(
              vertical: 30,
            ),
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
        // TOOK LOAN CUSTOMER CARDS
        // ======================================================

          ...List.generate(
            filteredCustomers.length,
                (index) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 10,
                ),
                child: TookLoanCustomerCard(
                  customer:
                  filteredCustomers[index],
                ),
              );
            },
          ),
      ],
    );
  }
}