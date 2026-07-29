import 'package:flutter/material.dart';
import 'package:mychopdi/view/add_customer_screen.dart';

class AddCustomerButton extends StatelessWidget {
  const AddCustomerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xff243B67),
      elevation: 2,
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
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}