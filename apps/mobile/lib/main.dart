import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mychopdi/data/repository/repositories.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/local_notification_service.dart';
import 'package:mychopdi/service/sync_service.dart';
import 'package:mychopdi/view/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize intl date formatting for supported languages.
  await initializeDateFormatting('en');
  await initializeDateFormatting('hi');

  await IsarService.init();

  await Repositories.migrateLegacyCustomers();

  final localNotificationService =
      LocalNotificationService.instance;

  await localNotificationService.initialize();

  await localNotificationService.syncNotifications(
    database: IsarService.isar,
  );

  await dotenv.load(
    fileName: 'env/staging.env',
  );

  // Start background sync without blocking app startup.
  unawaited(
    SyncService.instance.start(),
  );

  // Load saved language.
  final prefs = await SharedPreferences.getInstance();

  final savedLanguage = prefs.getString('app_language');

  Locale? initialLocale;

  if (savedLanguage != null && savedLanguage.isNotEmpty) {
    initialLocale = Locale(savedLanguage);
  }

  runApp(
    ChopdiApp(
      initialLocale: initialLocale,
    ),
  );
}

class ChopdiApp extends StatefulWidget {
  final Locale? initialLocale;

  const ChopdiApp({
    super.key,
    this.initialLocale,
  });

  /// Access the application state from screens below ChopdiApp.
  static ChopdiAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<ChopdiAppState>();
  }

  @override
  State<ChopdiApp> createState() => ChopdiAppState();
}

class ChopdiAppState extends State<ChopdiApp> {
  Locale? _locale;

  // Used for double-back-to-exit.
  DateTime? _lastBackPress;

  // Time allowed between first and second back press.
  static const Duration _exitTimeout = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();

    _locale = widget.initialLocale;
  }

  /// Change application language globally.
  Future<void> changeLanguage(Locale locale) async {
    if (_locale?.languageCode == locale.languageCode) {
      return;
    }

    setState(() {
      _locale = locale;
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'app_language',
      locale.languageCode,
    );
  }

  /// Get currently selected locale.
  Locale? get currentLocale => _locale;

  /// Handles Android back button.
  ///
  /// First press:
  /// Shows "Press back again to exit".
  ///
  /// Second press within 2 seconds:
  /// Shows Exit App confirmation dialog.
  Future<bool> _handleBackPress() async {
    final now = DateTime.now();

    // First back press.
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > _exitTimeout) {
      _lastBackPress = now;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );

      return false;
    }

    // Reset so another back press starts the process again.
    _lastBackPress = null;

    // Second back press → show confirmation dialog.
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text(
            'Are you sure you want to exit the app?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Current application language.
      locale: _locale,

      // Flutter's built-in localization delegates
      // + MyChopdi localization.
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      // English + Hindi.
      supportedLocales: AppLocalizations.supportedLocales,

      home: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            return;
          }

          final shouldExit = await _handleBackPress();

          if (shouldExit) {
            // Close the application.
            await SystemNavigator.pop();
          }
        },
        child: const SplashScreen(),
      ),
    );
  }
}