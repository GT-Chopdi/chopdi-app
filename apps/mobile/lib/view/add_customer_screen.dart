import 'package:flutter/material.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/view/add_new_customer_screen.dart';
import 'package:mychopdi/view/customer_detail_add.dart';
import 'package:mychopdi/view/customers_screen.dart';
import '../widgets/add_new_customer_card.dart';
import '../widgets/alphabet_index.dart';
import '../widgets/contact_tile.dart';
import '../widgets/search_box.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController searchController = TextEditingController();

  final Customer customer = Customer();

  final List<Map<String, String>> contacts = List.generate(
    20,
    (index) => {
      "name": "Rahul",
      "phone": "+91 98675 45673",
    },
  );
  // List<Customer> customers = [];
  // List<Customer> filteredCustomers = [];

  List<Map<String, String>> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = contacts;
  }

  // @override
  // void initState() {
  //   super.initState();
  //   loadCustomers();
  // }

  // Future<void> loadCustomers() async {
  //   customers = await IsarService.getCustomers();

  //   filteredCustomers = customers;

  //   setState(() {});
  // }

  void search(String value) {
    setState(() {
      filtered = contacts.where((e) {
        return e["name"]!
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            e["phone"]!.contains(value);
      }).toList();
    });
  }

  // void search(String value) {
  //   setState(() {
  //     filteredCustomers = customers.where((customer) {
  //       return customer.name
  //               .toLowerCase()
  //               .contains(value.toLowerCase()) ||
  //           customer.phone.contains(value);
  //     }).toList();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xffF8EEDC),

      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Color(0xff223A5E),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        "Add Customer",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff223A5E),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 24),

                  SearchBox(
                    controller: searchController,
                    onChanged: search,
                  ),

                  const SizedBox(height: 18),

                  AddNewCustomerCard(
                    onTap: () async{
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddNewCustomerScreen(),
                        ),
                      );
                    //   final result = await Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (_) => const AddNewCustomerScreen(),
                    //     ),
                    //   );

                    //   if (result == true) {
                    //     loadCustomers();
                    //   }
                    },
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "All Contacts",
                    style: TextStyle(
                      color: Color(0xff223A5E),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, index) {
                        return ContactTile(
                          name: filtered[index].values.first,
                          phone: filtered[index].values.last,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerDetailsAdd(customer: customer),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 6,
              top: 260,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.62,
                child: const AlphabetIndex(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}