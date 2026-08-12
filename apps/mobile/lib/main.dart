// import 'package:flutter/material.dart';
// import 'package:isar_community/isar.dart';
// import 'package:mychopdi/service/isar_service.dart';
// import 'package:mychopdi/view/splash_screen.dart';

// late Isar isar;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await IsarService.init();

//   runApp(const ChopdiApp());
// }

// class ChopdiApp extends StatelessWidget {
//   const ChopdiApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Chopdi',
//       theme: ThemeData(
//         useMaterial3: true,
//       ),
//       home: SplashScreen(),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/view/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await IsarService.init(); // IMPORTANT

  runApp(const ChopdiApp());
}

class ChopdiApp extends StatelessWidget {
  const ChopdiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}