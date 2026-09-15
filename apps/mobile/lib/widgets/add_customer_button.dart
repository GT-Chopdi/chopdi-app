import 'package:flutter/material.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/view/add_customer_screen.dart';

class AddCustomerButton extends StatefulWidget {
  final int chopdiId;
  final Function(Customer) onCustomerAdded;

  const AddCustomerButton({
    super.key,
    required this.onCustomerAdded,
    required this.chopdiId,
  });

  @override
  State<AddCustomerButton> createState() => _AddCustomerButtonState();
}

class _AddCustomerButtonState extends State<AddCustomerButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xff243B67),
      elevation: 2,
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddCustomerScreen(
              chopdiId: widget.chopdiId,
            ),
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