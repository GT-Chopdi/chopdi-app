import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/customer_card.dart';
import 'package:mychopdi/widgets/customer_filter_bottom_sheet.dart';
import 'package:mychopdi/widgets/sort_bottom_sheet.dart';
import 'package:isar_community/isar.dart';

import '../model/transaction.dart';
import '../service/isar_service.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

class CustomerListSection extends StatefulWidget {
  final List<Customer> customers;

  const CustomerListSection({
    super.key,
    required this.customers,
  });

  @override
  State<CustomerListSection> createState() =>
      _CustomerListSectionState();
}

class _CustomerListSectionState
    extends State<CustomerListSection> {
  final TextEditingController searchController =
  TextEditingController();

  late List<Customer> filteredCustomers;

  // ============================================================
  // FILTER VALUES
  // ============================================================

  String selectedStatus = "All";
  String selectedDate = "This Month";
  String selectedSort = "Recently Added";

  DateTime? fromDate;
  DateTime? toDate;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    filteredCustomers = List.from(widget.customers);

    applySortWithoutSetState();
  }

  // ============================================================
  // UPDATE WIDGET
  // ============================================================

  @override
  void didUpdateWidget(
      CustomerListSection oldWidget,
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
  // FILTERED CUSTOMERS
  // ============================================================

  Future<List<Customer>> _getFilteredCustomers() async {
    final search =
    searchController.text.toLowerCase().trim();

    final List<Customer> result = [];

    for (final customer in widget.customers) {
      // --------------------------------------------------------
      // SEARCH
      // --------------------------------------------------------

      final matchesSearch =
          search.isEmpty ||
              customer.name
                  .toLowerCase()
                  .contains(search) ||
              customer.phone.contains(search);

      if (!matchesSearch) {
        continue;
      }

      // --------------------------------------------------------
      // STATUS
      // --------------------------------------------------------

      bool matchesStatus = true;

      // --------------------------------------------------------
      // ALL CUSTOMERS
      // --------------------------------------------------------

      if (selectedStatus == "All") {
        matchesStatus = true;
      }

      // --------------------------------------------------------
      // PENDING
      // --------------------------------------------------------

      else if (selectedStatus == "Pending") {
        matchesStatus =
            customer.status.toLowerCase() ==
                "pending";
      }

      // --------------------------------------------------------
      // SETTLED
      //
      // Settled means the actual customer balance is zero.
      // --------------------------------------------------------

      else if (selectedStatus == "Settled") {
        final balance =
        await getCustomerBalance(
          customer.id,
        );

        matchesStatus = balance == 0;
      }

      // --------------------------------------------------------
      // DATE
      // --------------------------------------------------------

      bool matchesDate = true;

      // --------------------------------------------------------
      // THIS MONTH
      // --------------------------------------------------------

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
            customer.updatedAt.isAfter(
              firstDayOfMonth.subtract(
                const Duration(
                  seconds: 1,
                ),
              ),
            ) &&
                customer.updatedAt.isBefore(
                  nextMonth,
                );
      }

      // --------------------------------------------------------
      // CUSTOM DATE
      // --------------------------------------------------------

      if (selectedDate == "Custom") {
        // ------------------------------------------------------
        // FROM DATE
        // ------------------------------------------------------

        if (fromDate != null) {
          final startDate = DateTime(
            fromDate!.year,
            fromDate!.month,
            fromDate!.day,
          );

          matchesDate =
              matchesDate &&
                  !customer.updatedAt.isBefore(
                    startDate,
                  );
        }

        // ------------------------------------------------------
        // TO DATE
        // ------------------------------------------------------

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
                  !customer.updatedAt.isAfter(
                    endDate,
                  );
        }
      }

      // --------------------------------------------------------
      // FINAL MATCH
      // --------------------------------------------------------

      if (matchesStatus && matchesDate) {
        result.add(customer);
      }
    }

    return result;
  }

  // ============================================================
  // APPLY SEARCH + FILTER
  // ============================================================

  Future<void> applyFilters() async {
    final customers =
    await _getFilteredCustomers();

    _applySortToList(customers);

    if (!mounted) return;

    setState(() {
      filteredCustomers = customers;
    });
  }

  // ============================================================
  // SORT
  // ============================================================

  void _applySortToList(
      List<Customer> customers,
      ) {
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
  // INITIAL SORT
  // ============================================================

  void applySortWithoutSetState() {
    _applySortToList(
      filteredCustomers,
    );
  }

  // ============================================================
  // APPLY SORT
  // ============================================================

  Future<void> applySort() async {
    // ----------------------------------------------------------
    // NAME A-Z
    // ----------------------------------------------------------

    if (selectedSort == "Name (A-Z)") {
      setState(() {
        filteredCustomers.sort(
              (a, b) => a.name
              .toLowerCase()
              .compareTo(
            b.name.toLowerCase(),
          ),
        );
      });

      return;
    }

    // ----------------------------------------------------------
    // NAME Z-A
    // ----------------------------------------------------------

    if (selectedSort == "Name (Z-A)") {
      setState(() {
        filteredCustomers.sort(
              (a, b) => b.name
              .toLowerCase()
              .compareTo(
            a.name.toLowerCase(),
          ),
        );
      });

      return;
    }

    // ----------------------------------------------------------
    // RECENTLY ADDED
    // ----------------------------------------------------------

    if (selectedSort == "Recently Added") {
      setState(() {
        filteredCustomers.sort(
              (a, b) => b.updatedAt.compareTo(
            a.updatedAt,
          ),
        );
      });

      return;
    }

    // ----------------------------------------------------------
    // LOAN AMOUNT SORT
    // ----------------------------------------------------------

    if (selectedSort ==
        "Loan Amount (High to Low)" ||
        selectedSort ==
            "Loan Amount (Low to High)") {
      final balances = <int, double>{};

      for (final customer
      in filteredCustomers) {
        balances[customer.id] =
        await getCustomerBalance(
          customer.id,
        );
      }

      if (!mounted) return;

      setState(() {
        filteredCustomers.sort(
              (a, b) {
            final balanceA =
                balances[a.id] ?? 0;

            final balanceB =
                balances[b.id] ?? 0;

            if (selectedSort ==
                "Loan Amount (High to Low)") {
              return balanceB.compareTo(
                balanceA,
              );
            } else {
              return balanceA.compareTo(
                balanceB,
              );
            }
          },
        );
      });
    }
  }

  // ============================================================
  // LOCALIZED SORT NAME
  // ============================================================

  String getLocalizedSortName(
      BuildContext context,
      String sort,
      ) {
    final l10n =
    AppLocalizations.of(context);

    switch (sort) {
      case "Name (A-Z)":
        return l10n.sortNameAZ;

      case "Name (Z-A)":
        return l10n.sortNameZA;

      case "Recently Added":
        return l10n.sortRecentlyAdded;

      case "Loan Amount (High to Low)":
        return l10n.sortLoanAmountHighToLow;

      case "Loan Amount (Low to High)":
        return l10n.sortLoanAmountLowToHigh;

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
    await showModalBottomSheet<
        Map<String, dynamic>>(
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
  // CUSTOMER BALANCE
  // ============================================================

  Future<double> getCustomerBalance(
      int customerId,
      ) async {
    final transactions =
    await IsarService
        .isar
        .transactions
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
  // SORT BOTTOM SHEET
  // ============================================================

  Future<void> showSortSheet() async {
    final result =
    await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) =>
      const SortBottomSheet(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedSort = result;
    });

    await applySort();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n =
    AppLocalizations.of(context);

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
                  l10n.customersTitle,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    ChopdiColors.navy,
                  ),
                ),
                Text(
                  l10n.manageAllCustomers,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color:
                    const Color.fromRGBO(
                      34,
                      58,
                      94,
                      0.62,
                    ),
                    fontWeight:
                    FontWeight.w700,
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
                decoration:
                BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(
                    30,
                  ),
                  border: Border.all(
                    color:
                    const Color.fromRGBO(
                      170,
                      185,
                      207,
                      1,
                    ),
                  ),
                ),
                child: TextField(
                  controller:
                  searchController,
                  onChanged:
                  searchCustomer,
                  decoration:
                  InputDecoration(
                    prefixIcon:
                    Padding(
                      padding:
                      const EdgeInsets.all(
                        12,
                      ),
                      child: Image.asset(
                        'assets/search_option.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                    prefixIconConstraints:
                    const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                      maxWidth: 44,
                      maxHeight: 44,
                    ),
                    hintText:
                    l10n
                        .searchByNameAndPhone,
                    hintStyle:
                    const TextStyle(
                      fontSize: 12,
                    ),
                    border:
                    InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // FILTER BUTTON
            InkWell(
              onTap:
              showFilterSheet,
              borderRadius:
              BorderRadius.circular(
                25,
              ),
              child: Container(
                height: 46,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 16,
                ),
                decoration:
                BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(
                    25,
                  ),
                  border: Border.all(
                    color:
                    const Color.fromRGBO(
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
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      l10n.filter,
                      style:
                      const TextStyle(
                        fontSize: 13,
                      ),
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
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                l10n.customersCount(
                  filteredCustomers.length,
                ),
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: showSortSheet,
                behavior:
                HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.swap_vert,
                      size: 16,
                    ),

                    const SizedBox(
                      width: 4,
                    ),

                    Expanded(
                      child: Text(
                        '${l10n.sortBy} : $localizedSort',
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        textAlign:
                        TextAlign.end,
                        style:
                        const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.arrow_drop_down,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ========================================================
        // CUSTOMER LIST
        // ========================================================

        if (filteredCustomers.isEmpty)
          Padding(
            padding:
            const EdgeInsets
                .symmetric(
              vertical: 30,
            ),
            child: Center(
              child: Text(
                l10n.noCustomersFound,
                style:
                const TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),
          )
        else
          ...List.generate(
            filteredCustomers.length,
                (index) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 10,
                ),
                child: CustomerCard(
                  customer:
                  filteredCustomers[
                  index],
                ),
              );
            },
          ),
      ],
    );
  }
}