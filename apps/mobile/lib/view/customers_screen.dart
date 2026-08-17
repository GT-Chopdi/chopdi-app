import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/customer_card.dart';
import 'package:mychopdi/widgets/customer_filter_bottom_sheet.dart';
import 'package:mychopdi/widgets/sort_bottom_sheet.dart';

class CustomerListSection extends StatefulWidget {

  final List<Customer> customers;
  const CustomerListSection({super.key,required this.customers,});

  @override
  State<CustomerListSection> createState() => _CustomerListSectionState();
}

class _CustomerListSectionState extends State<CustomerListSection> {
  final TextEditingController searchController = TextEditingController();

  late List<Customer> customers;
  late List<Customer> filteredCustomers;

  @override
  void initState() {
    super.initState();
    filteredCustomers = List.from(widget.customers);
  }

  @override
  void didUpdateWidget(CustomerListSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    filteredCustomers = List.from(widget.customers);
  }


  void searchCustomer(String value) {
    setState(() {
      filteredCustomers = widget.customers.where((customer) {
        return customer.name
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            customer.phone.contains(value);
      }).toList();
    });
  }

  void showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomerFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Header
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
                    color: Color.fromRGBO(34, 58, 94, 0.62),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),

        const SizedBox(height: 20),

        /// Search
        Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Color.fromRGBO(170, 185, 207, 1)),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: searchCustomer,
                  decoration: InputDecoration(
                    prefixIcon: Image.asset('assets/search_option.png'),
                    hintText: "Search by name and phone number",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: showFilterSheet,
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Color.fromRGBO(170, 185, 207, 1)),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/filter.png'),
                    SizedBox(width: 5),
                    Text("Filter"),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Text(
              "${filteredCustomers.length} Customers",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const SortBottomSheet(),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.swap_vert, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "Sort by : Name (A-Z)",
                    style: TextStyle(fontSize: 11),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            )
          ],
        ),

        const SizedBox(height: 10),

        ...List.generate(
          filteredCustomers.length,
          (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
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