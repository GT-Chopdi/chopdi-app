import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/customer_model.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/add_customer_button.dart';
import 'package:mychopdi/widgets/home_header.dart';
import 'package:mychopdi/widgets/loan_toggle.dart';
import 'package:mychopdi/widgets/summary_card.dart';


class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final customers = [

    CustomerModel(
      name: "Rahul",
      loan: "₹12,000",
      interest: "12%",
      amount: "₹12,000",
      received: false,
      phone: "+91 7539412369",
      status: "Pending"
    ),

    CustomerModel(
      name: "Khushi",
      loan: "₹8,500",
      interest: "10%",
      amount: "₹8,500",
      received: false,
      phone: "+91 9631457694",
      status: "Completed"
    ),

    CustomerModel(
      name: "Dada",
      loan: "₹6,000",
      interest: "9%",
      amount: "₹1,000",
      received: true,
      phone: "+91 8463988453",
      status: ""
    ),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ChopdiColors.cream,
      floatingActionButton: const AddCustomerButton(),
      // bottomNavigationBar: const BottomNavbar(
      //   currentIndex: 1,
      // ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 18),
              const LoanToggle(),
              const SizedBox(height: 18),
              const SummaryCard(),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const Text(
                  //   "Recent Customers",
                  //   style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 17),
                  // ),

                  // TextButton(
                  //     onPressed: () {},
                  //     child: const Text("View All"))
                ],
              ),

              // Expanded(
              //   child: ListView.builder(
              //     itemCount: customers.length,
              //     itemBuilder: (_, index) {
              //       return CustomerTile(
              //         customer: customers[index],
              //       );
              //     },
              //   ),
              // )

              SizedBox(height: 30),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 74,
                      width: 82,
                      child: Image.asset('assets/home_screen_book.png'),
                    ),
                
                    SizedBox(height: 6),
                
                    Text(
                      'No customers yet!',
                      style: GoogleFonts.manrope(
                        color: ChopdiColors.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                
                    SizedBox(height: 3),
                
                    Text(
                      'Start by adding a customer and\n\tkeep track of your loans easily',
                      style: GoogleFonts.manrope(
                        color: ChopdiColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 11),

                    Row(
                      children: [
                        SizedBox(width:190),
                        Image.asset('assets/line_home.png'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}