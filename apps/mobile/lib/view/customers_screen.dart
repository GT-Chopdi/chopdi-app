import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/customer_model.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/customer_card.dart';
import 'package:mychopdi/widgets/customer_filter_bottom_sheet.dart';
import 'package:mychopdi/widgets/sort_bottom_sheet.dart';

class CustomerListSection extends StatefulWidget {

  final List<CustomerModel> customers;
  const CustomerListSection({super.key,required this.customers,});

  @override
  State<CustomerListSection> createState() => _CustomerListSectionState();
}

class _CustomerListSectionState extends State<CustomerListSection> {
  final TextEditingController searchController = TextEditingController();

  late List<CustomerModel> customers;
  late List<CustomerModel> filteredCustomers;

  @override
  void initState() {
    super.initState();

    customers = List.generate(
      10,
      (index) => CustomerModel(
        name: index.isEven ? "Rahul" : "Amit",
        phone: "+91 986754567$index",
        amount: "${(index + 1) * 2000}",
        interest: "12",
        status: index.isEven ? "Pending" : "Received",
        received: index.isOdd,
        loan: "12000",
      ),
    );

    filteredCustomers = List.from(customers);
    // customers = widget.customers;
    // filteredCustomers = List.from(customers);
  }

  void searchCustomer(String value) {
    setState(() {
      filteredCustomers = customers.where((customer) {
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
            // SizedBox(
            //   height: 42,
            //   child: ElevatedButton.icon(
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: ChopdiColors.navy,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(25),
            //       ),
            //     ),
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (_) => const AddCustomerScreen(),
            //         ),
            //       );
            //     },
            //     icon: const Icon(Icons.add, color: Colors.white),
            //     label: const Text(
            //       "Add Customer",
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            // ),
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

        Expanded(
          child: ListView.separated(
            itemCount: filteredCustomers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              return CustomerCard(
                customer: filteredCustomers[index],
              );
            },
          ),
        ),
      ],
    );
  }
}