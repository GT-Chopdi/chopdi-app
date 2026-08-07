// import 'package:flutter/material.dart';
// import 'package:mychopdi/model/customer_model.dart';
// import 'package:mychopdi/view/add_customer_screen.dart';

// class AddCustomerButton extends StatelessWidget {

//   final Function(Customer) onCustomerAdded;

//   const AddCustomerButton({super.key, required this.onCustomerAdded,});

//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton.extended(
//       backgroundColor: const Color(0xff243B67),
//       elevation: 2,
//       onPressed: () async{
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const AddCustomerScreen(),
//           ),
//         );

        

//         final customer = await Navigator.push<Customer>(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const AddCustomerScreen(),
//           ),
//         );

//         if (customer != null) {
//            onCustomerAdded(customer);
//         }
//       },
//       icon: const Icon(
//         Icons.add,
//         color: Colors.white,
//       ),
//       label: const Text(
//         "Add Customer",
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/view/add_customer_screen.dart';

class AddCustomerButton extends StatelessWidget {
  final Function(Customer) onCustomerAdded;

  const AddCustomerButton({
    super.key,
    required this.onCustomerAdded,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xff243B67),
      elevation: 2,
      onPressed: () async {
        await Navigator.push(
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