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

  // Filter values
  String selectedStatus = "All";
  String selectedDate = "This Month";
  // String selectedSort = "Name (A-Z)";
  String selectedSort = "Recently Added";
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();

    // filteredCustomers = List.from(widget.customers);
      filteredCustomers = List.from(widget.customers);
      applySortWithoutSetState();
  }

  @override
  void didUpdateWidget(CustomerListSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    filteredCustomers = _getFilteredCustomers();
    applySortWithoutSetState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Customer> _getFilteredCustomers() {
  final search = searchController.text.toLowerCase().trim();

  return widget.customers.where((customer) {
    // Search
    final matchesSearch =
        search.isEmpty ||
        customer.name.toLowerCase().contains(search) ||
        customer.phone.contains(search);

    // Status
    bool matchesStatus = true;

    if (selectedStatus != "All") {
      matchesStatus =
          customer.status.toLowerCase() ==
          selectedStatus.toLowerCase();
    }

    // Date
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
          customer.updatedAt.isAfter(
            firstDayOfMonth.subtract(
              const Duration(seconds: 1),
            ),
          ) &&
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

    return matchesSearch &&
        matchesStatus &&
        matchesDate;
  }).toList();
}


  // ============================================================
  // APPLY SEARCH + FILTER
  // ============================================================

  void applyFilters() {
    final customers = _getFilteredCustomers();

    setState(() {
      filteredCustomers = customers;
      applySortWithoutSetState();
    });
  }

  void applySortWithoutSetState() {
    if (selectedSort == "Name (A-Z)") {
      filteredCustomers.sort(
        (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
    } else if (selectedSort == "Name (Z-A)") {
      filteredCustomers.sort(
        (a, b) => b.name.toLowerCase().compareTo(
          a.name.toLowerCase(),
        ),
      );
    } else if (selectedSort == "Recently Added") {
      filteredCustomers.sort(
        (a, b) => b.updatedAt.compareTo(a.updatedAt),
      );
    }
  }

  Future<void> applySort() async {
    if (selectedSort == "Name (A-Z)") {
      setState(() {
        filteredCustomers.sort(
              (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
        );
      });
      return;
    }

    if (selectedSort == "Name (Z-A)") {
      setState(() {
        filteredCustomers.sort(
              (a, b) => b.name.toLowerCase().compareTo(
            a.name.toLowerCase(),
          ),
        );
      });
      return;
    }

    if (selectedSort == "Recently Added") {
      setState(() {
        filteredCustomers.sort(
              (a, b) => b.updatedAt.compareTo(a.updatedAt),
        );
      });
      return;
    }

    if (selectedSort == "Loan Amount (High to Low)" ||
        selectedSort == "Loan Amount (Low to High)") {

      final balances = <int, double>{};

      for (final customer in filteredCustomers) {
        balances[customer.id] =
        await getCustomerBalance(customer.id);
      }

      setState(() {
        filteredCustomers.sort((a, b) {
          final balanceA = balances[a.id] ?? 0;
          final balanceB = balances[b.id] ?? 0;

          if (selectedSort == "Loan Amount (High to Low)") {
            return balanceB.compareTo(balanceA);
          } else {
            return balanceA.compareTo(balanceB);
          }
        });
      });
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
    final result = await showModalBottomSheet<Map<String, dynamic>>(
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

    // User closed sheet without Apply
    if (result == null) {
      return;
    }

    setState(() {
      selectedStatus = result["status"] ?? "All";
      selectedDate = result["date"] ?? "This Month";

      fromDate = result["from"];
      toDate = result["to"];
    });

    applyFilters();
  }
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
  // SORT
  // ============================================================

  Future<void> showSortSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SortBottomSheet(),
    );

    if (result == null) return;

    selectedSort = result;

    await applySort();
  } // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
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
                  "Customers",
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ChopdiColors.navy,
                  ),
                ),
                Text(
                  "Manage all your customers",
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
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                      maxWidth: 44,
                      maxHeight: 44,
                    ),
                    hintText:
                    "Search by name and phone number",
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
                    const Text(
                      "Filter",
                      style: TextStyle(
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
          children: [
            Text(
              "${filteredCustomers.length} Customers",
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
                    "Sort by : $selectedSort",
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
        // CUSTOMER LIST
        // ========================================================

        if (filteredCustomers.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 30,
            ),
            child: Center(
              child: Text(
                "No customers found",
                style: TextStyle(
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