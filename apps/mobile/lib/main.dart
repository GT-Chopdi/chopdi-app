import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/view/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await IsarService.init(); // IMPORTANT
  await dotenv.load(fileName: 'env/staging.env');
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