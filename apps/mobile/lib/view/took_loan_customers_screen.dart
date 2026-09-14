import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/customer_filter_bottom_sheet.dart';
import 'package:mychopdi/widgets/sort_bottom_sheet.dart';
import 'package:mychopdi/widgets/took_loan_customer_card.dart';

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
  final TextEditingController searchController = TextEditingController();

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

  String selectedSort = "Name (A-Z)";

  @override
  void initState() {
    super.initState();

    filteredCustomers = List.from(widget.customers);
  }

  @override
  void didUpdateWidget(
      TookLoanCustomerListSection oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.customers != widget.customers) {
      applyFilters();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // APPLY SEARCH + FILTER
  // ============================================================

  void applyFilters() {
    final search = searchController.text.toLowerCase().trim();

    final result = widget.customers.where((customer) {
      // ========================================================
      // SEARCH
      // ========================================================

      final matchesSearch =
          search.isEmpty ||
              customer.name.toLowerCase().contains(search) ||
              customer.phone.contains(search);

      // ========================================================
      // STATUS FILTER
      // ========================================================

      bool matchesStatus = true;

      if (selectedStatus != "All") {
        matchesStatus =
            customer.status.toLowerCase() ==
                selectedStatus.toLowerCase();
      }

      // ========================================================
      // DATE FILTER
      // ========================================================

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
            !customer.updatedAt.isBefore(firstDayOfMonth) &&
                customer.updatedAt.isBefore(nextMonth);
      }

      // --------------------------------------------------------
      // CUSTOM DATE
      // --------------------------------------------------------

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

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    // ============================================================
    // SORT RESULT
    // ============================================================

    if (selectedSort == "Name (A-Z)") {
      result.sort(
            (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
    } else if (selectedSort == "Name (Z-A)") {
      result.sort(
            (a, b) => b.name.toLowerCase().compareTo(
          a.name.toLowerCase(),
        ),
      );
    }

    setState(() {
      filteredCustomers = result;
    });
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

    // User closed without Apply
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

    applyFilters();
  }

  // ============================================================
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
                    hintText: "Search by name and phone number",
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
        // EMPTY STATE
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
        // ======================================================
        // TOOK LOAN CUSTOMER CARDS
        // ======================================================

          ...List.generate(
            filteredCustomers.length,
                (index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: TookLoanCustomerCard(
                  customer: filteredCustomers[index],
                ),
              );
            },
          ),
      ],
    );
  }
}