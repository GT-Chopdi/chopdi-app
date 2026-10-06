import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
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
  State<CustomerListSection> createState() => _CustomerListSectionState();
}

class _CustomerListSectionState extends State<CustomerListSection> {
  final TextEditingController searchController = TextEditingController();

  late List<Customer> filteredCustomers;

  // ============================================================
  // FILTER VALUES
  // ============================================================

  String selectedStatus = "All";
  String selectedSort = "Most Recent";

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    filteredCustomers = List.from(widget.customers);

    applyFilters();
  }

  // ============================================================
  // UPDATE WIDGET
  // ============================================================

  @override
  void didUpdateWidget(
    CustomerListSection oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.customers != widget.customers) {
      applyFilters();
    }
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
    final search = searchController.text.toLowerCase().trim();

    final List<Customer> result = [];

    for (final customer in widget.customers) {
      // SEARCH
      final matchesSearch =
          search.isEmpty ||
          customer.name.toLowerCase().contains(search) ||
          customer.phone.contains(search);

      if (!matchesSearch) {
        continue;
      }

      // FILTER
      if (selectedStatus == "Settled") {
        final balance = await getCustomerBalance(customer.id);

        // Settled = balance is zero
        if (balance != 0) {
          continue;
        }
      }

      // If status is "All", DON'T filter anything.
      result.add(customer);
    }

    return result;
  }

  // ============================================================
  // APPLY SEARCH + FILTER
  // ============================================================

  Future<void> applyFilters() async {
    final customers = await _getFilteredCustomers();

    await _applySortToList(customers);

    if (!mounted) return;

    setState(() {
      filteredCustomers = customers;
    });
  }

  // ============================================================
  // SORT
  // ============================================================

  Future<void> _applySortToList(
    List<Customer> customers,
  ) async {
    switch (selectedSort) {
      case "Most Recent":
        customers.sort(
          (a, b) => b.updatedAt.compareTo(a.updatedAt),
        );
        break;

      case "Oldest":
        customers.sort(
          (a, b) => a.updatedAt.compareTo(b.updatedAt),
        );
        break;

      case "By Name (A-Z)":
        customers.sort(
          (a, b) => a.name
              .toLowerCase()
              .compareTo(b.name.toLowerCase()),
        );
        break;

      case "Highest Amount":
        final balances = <int, double>{};

        for (final customer in customers) {
          balances[customer.id] =
              await getCustomerBalance(customer.id);
        }

        customers.sort(
          (a, b) {
            final balanceA = balances[a.id] ?? 0;
            final balanceB = balances[b.id] ?? 0;

            return balanceB.compareTo(balanceA);
          },
        );
        break;

      case "Least Amount":
        final balances = <int, double>{};

        for (final customer in customers) {
          final balance = await getCustomerBalance(customer.id);

          balances[customer.id] = balance;

          debugPrint(
            "LEAST SORT -> ${customer.name} | "
            "ID: ${customer.id} | "
            "BALANCE: $balance",
          );
        }

        customers.sort(
          (a, b) {
            final balanceA = balances[a.id] ?? 0;
            final balanceB = balances[b.id] ?? 0;

            return balanceA.compareTo(balanceB);
          },
        );
        break;
    }

    // ----------------------------------------------------------
    // LOAN AMOUNT SORT
    // ----------------------------------------------------------

    if (selectedSort == "Loan Amount (High to Low)" ||
        selectedSort == "Loan Amount (Low to High)") {
      final balances = <int, double>{};

      for (final customer in customers) {
        balances[customer.id] =
            await getCustomerBalance(customer.id);
      }

      customers.sort(
        (a, b) {
          final balanceA = balances[a.id] ?? 0;
          final balanceB = balances[b.id] ?? 0;

          debugPrint(
            "COMPARE -> ${a.name}: $balanceA vs ${b.name}: $balanceB",
          );

          if (selectedSort == "Loan Amount (High to Low)") {
            return balanceB.compareTo(balanceA);
          } else {
            return balanceA.compareTo(balanceB);
          }
        },
      );

      debugPrint(
        "SORTED RESULT -> "
        "${customers.map((e) => e.name).toList()}",
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
  // CUSTOMER BALANCE
  // ============================================================

  //In this function it calculates the wrong balance of a customer.
  // ============================================================
  // CUSTOMER BALANCE
  // ============================================================

  // Future<double> getCustomerBalance(
  //   int customerId,
  // ) async {
  //   final transactions =
  //   await IsarService
  //       .isar
  //       .transactions
  //       .filter()
  //       .customerIdEqualTo(customerId)
  //       .voidedAtIsNull()
  //       .findAll();
  //   double balance = 0;
  //   for (final tx in transactions) {
  //     if (tx.type == TransactionType.gave) {
  //     balance += tx.amount;
  //     } else {
  //     balance -= tx.amount;
  //     }
  //   }
  //   return balance;
  // }

  Future<double> getCustomerBalance(int customerId) async {
    final transactions = await IsarService.isar.transactions
        .filter()
        .customerIdEqualTo(customerId)
        .voidedAtIsNull()
        .findAll();

    double totalGiven = 0;
    double totalReceived = 0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.gave) {
        totalGiven += tx.amount;
      } else if (tx.type == TransactionType.received) {
        totalReceived += tx.amount;
      }
    }

    return totalGiven - totalReceived;
  }

  // ============================================================
  // SORT BOTTOM SHEET
  // ============================================================

  Future<void> showSortSheet() async {
    final result =
        await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SortBottomSheet(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedSort = result;
    });

    await _applySortToList(filteredCustomers);

    if (!mounted) return;

    setState(() {});
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
                  l10n.customersTitle,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ChopdiColors.navy,
                  ),
                ),
                Text(
                  l10n.manageAllCustomers,
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
                  borderRadius: BorderRadius.circular(30),
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
                    prefixIconConstraints:
                        const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                      maxWidth: 44,
                      maxHeight: 44,
                    ),
                    hintText: l10n.searchByNameAndPhone,
                    hintStyle: const TextStyle(
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // FILTER BUTTON
            InkWell(
              onTap: showFilterSheet,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
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
                      style: const TextStyle(
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

        const SizedBox(height: 10),

        // ========================================================
        // CUSTOMER LIST
        // ========================================================

        if (filteredCustomers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
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
          ...List.generate(
            filteredCustomers.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: CustomerCard(
                  customer: filteredCustomers[index],
                ),
              );
            },
          ),
      ],
    );
  }
}