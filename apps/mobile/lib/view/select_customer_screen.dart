import 'package:flutter/material.dart';
import 'package:mychopdi/view/add_customer_screen.dart';

class SelectCustomerScreen extends StatefulWidget {
  const SelectCustomerScreen({super.key});

  @override
  State<SelectCustomerScreen> createState() => _SelectCustomerScreenState();
}

class _SelectCustomerScreenState extends State<SelectCustomerScreen> {

  static const Color primary = Color(0xFF223A5E);
  static const Color secondary = Color(0xFFAAB9CF);
  static const Color accent = Color(0xFFC74C4C);
  static const Color background = Color(0xFFFAF8F5);

  final TextEditingController searchController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,

        title: const Text(
          "Customers",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: const [

          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),

        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 25),

              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search customer",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: primary,
                  ),

                  suffixIcon: const Icon(
                    Icons.mic_none,
                    color: primary,
                  ),

                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),

              const SizedBox(height: 15),

              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {

                  //Open Add Customer

                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 10,
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: secondary,
                        child: const Icon(
                          Icons.person_add,
                          color: primary,
                        ),
                      ),

                      const SizedBox(width: 18),

                      const Expanded(
                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(

                              "Add New Customer",

                              style: TextStyle(

                                fontWeight: FontWeight.bold,

                                fontSize: 18,

                                color: primary,

                              ),

                            ),

                            SizedBox(height: 5),

                            Text(

                              "Create a customer and start tracking transactions.",

                              style: TextStyle(

                                color: Colors.grey,

                              ),

                            ),

                          ],

                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddCustomerScreen(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: primary,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}