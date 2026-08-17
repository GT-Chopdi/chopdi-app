// import 'package:flutter/material.dart';
// import 'package:mychopdi/model/customer.dart';
// import 'package:mychopdi/service/chopdi_service.dart';
// import 'package:mychopdi/view/main_screen.dart';

// class InitialScreen extends StatefulWidget {
//   const InitialScreen({super.key});

//   @override
//   State<InitialScreen> createState() =>
//       _InitialScreenState();
// }

// class _InitialScreenState
//     extends State<InitialScreen> {

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _openInitialChopdi();
//     });
//   }

//   Future<void> _openInitialChopdi() async {
//     final chopdis =
//         await ChopdiService.getAllChopdis();

//     if (!mounted) return;

//     if (chopdis.isEmpty) {
//       return;
//     }

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => MainScreen(
//           chopdiId: chopdis.first.id, customer: Customer(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       backgroundColor: Color(0xffFFF8F0),
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }