import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:mychopdi/model/user_session.dart';
import 'package:mychopdi/view/splash_screen.dart';
import 'package:path_provider/path_provider.dart';

late Isar isar;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  isar = await Isar.open(
    [
      UserSessionSchema,
    ],
    directory: dir.path,
  );

  runApp(const ChopdiApp());
}

class ChopdiApp extends StatelessWidget {
  const ChopdiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chopdi',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}