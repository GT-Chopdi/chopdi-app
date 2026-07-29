import 'package:flutter/material.dart';
import 'package:mychopdi/model/customer_model.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/add_customer_screen.dart';
import 'package:mychopdi/widgets/customer_card.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {

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
        phone: "+91 98675 4567$index",
        amount: "${(index + 1) * 2000}",
        interest: "12",
        status: index.isEven ? "Pending" : "Received",
        received: index.isOdd,
        loan: "12000",
      ),
    );

    filteredCustomers = List.from(customers);
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

  void sortAZ() {
    setState(() {
      filteredCustomers.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void sortAmountHigh() {
    setState(() {
      filteredCustomers.sort(
        (a, b) =>
            int.parse(b.amount).compareTo(int.parse(a.amount)),
      );
    });
  }

  void sortAmountLow() {
    setState(() {
      filteredCustomers.sort(
        (a, b) =>
            int.parse(a.amount).compareTo(int.parse(b.amount)),
      );
    });
  }

  void filterPending() {
    setState(() {
      filteredCustomers = customers
          .where((e) => e.status == "Pending")
          .toList();
    });
  }

  void filterReceived() {
    setState(() {
      filteredCustomers = customers
          .where((e) => e.status == "Received")
          .toList();
    });
  }

  void clearFilter() {
    setState(() {
      filteredCustomers = List.from(customers);
    });
  }

  void showFilterSheet() async {
    final result = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [

              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Filter Customers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text("Name A-Z"),
                onTap: () => Navigator.pop(context, "name"),
              ),

              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: const Text("Amount Low to High"),
                onTap: () => Navigator.pop(context, "low"),
              ),

              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: const Text("Amount High to Low"),
                onTap: () => Navigator.pop(context, "high"),
              ),

              ListTile(
                leading: const Icon(Icons.pending_actions),
                title: const Text("Pending"),
                onTap: () => Navigator.pop(context, "pending"),
              ),

              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text("Received"),
                onTap: () => Navigator.pop(context, "received"),
              ),

              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text("Clear Filter"),
                onTap: () => Navigator.pop(context, "clear"),
              ),
            ],
          ),
        );
      },
    );

    switch (result) {
      case "name":
        sortAZ();
        break;

      case "low":
        sortAmountLow();
        break;

      case "high":
        sortAmountHigh();
        break;

      case "pending":
        filterPending();
        break;

      case "received":
        filterReceived();
        break;

      case "clear":
        clearFilter();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChopdiColors.cream,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: Column(
            children: [

              const SizedBox(height: 18),

              /// Header
              Row(
                children: [

                  const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Customers",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ChopdiColors.navy,
                        ),
                      ),

                      Text(
                        "Manage all your customers",
                        style: TextStyle(
                          fontSize: 12,
                          // color: ChopdiColors.lightBlue,
                          color: Color.fromRGBO(34, 58, 94, 0.62),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            ChopdiColors.navy,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddCustomerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Add Customer",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Search + Filter
              Row(
                children: [

                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: searchCustomer,
                        decoration:
                            const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText:
                              "Search by name or phone",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

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
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.filter_alt_outlined),
                          SizedBox(width: 6),
                          Text("Filter"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  Text(
                    "${filteredCustomers.length} Customers",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: sortAZ,
                    child: Row(
                      children: [
                        Icon(Icons.swap_vert,size:16),
                        SizedBox(width:4),
                        Text(
                          "Sort by : Name (A-Z)",
                          style: TextStyle(fontSize: 11),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down_outlined)
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.separated(
                  itemCount: filteredCustomers.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    return CustomerCard(
                      customer:
                          filteredCustomers[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}