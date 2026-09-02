import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mychopdi/data/repository/repositories.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/local_notification_service.dart';
import 'package:mychopdi/service/sync_service.dart';
import 'package:mychopdi/view/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await IsarService.init(); // IMPORTANT
  await Repositories.migrateLegacyCustomers();
  await LocalNotificationService.instance.initialize();
  await dotenv.load(fileName: 'env/staging.env');

  // Starts the outbox draining. Not awaited: the first drain needs the network
  // and blocking startup on it would leave a user with no signal staring at a
  // splash screen, for data that is already safely on the device.
  unawaited(SyncService.instance.start());

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