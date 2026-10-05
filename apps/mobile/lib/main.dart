import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- ADDED
import 'package:intl/date_symbol_data_local.dart';
import 'package:mychopdi/view/customer_details_screen.dart';
import 'package:mychopdi/view/took_loan_customer_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mychopdi/data/repository/repositories.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/local_notification_service.dart';
import 'package:mychopdi/service/sync_service.dart';
import 'package:mychopdi/view/splash_screen.dart';

import 'model/customer.dart';
import 'model/lender.dart';

// ============================================================
// GLOBAL NAVIGATOR KEY
// ============================================================

final GlobalKey<NavigatorState> appNavigatorKey =
GlobalKey<NavigatorState>();

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------------------
  // Pre-load Google Fonts
  // Resolves the first-launch font pop / style flicker on Splash
  // ------------------------------------------------------------
  GoogleFonts.styleScript();
  GoogleFonts.manrope();
  await GoogleFonts.pendingFonts();

  // ------------------------------------------------------------
  // Initialize date formatting
  // ------------------------------------------------------------

  await initializeDateFormatting('en');
  await initializeDateFormatting('hi');

  // ------------------------------------------------------------
  // Initialize local database
  // ------------------------------------------------------------

  await IsarService.init();

  await Repositories.migrateLegacyCustomers();

  // ------------------------------------------------------------
  // Initialize local notifications
  //
  // IMPORTANT:
  // LocalNotificationService.initialize() is responsible for
  // checking whether the app was launched from a notification.
  // If yes, it stores the payload in:
  //
  // LocalNotificationService.pendingNotificationPayload
  //
  // We DO NOT navigate here because SplashScreen has not finished.
  // ------------------------------------------------------------

  final localNotificationService =
      LocalNotificationService.instance;

  await localNotificationService.initialize();

  await localNotificationService.syncNotifications(
    database: IsarService.isar,
  );

  // ------------------------------------------------------------
  // Load environment
  // ------------------------------------------------------------

  await dotenv.load(
    fileName: 'env/staging.env',
  );

  // ------------------------------------------------------------
  // Start background sync
  // ------------------------------------------------------------

  unawaited(
    SyncService.instance.start(),
  );

  // ------------------------------------------------------------
  // Load saved language
  // ------------------------------------------------------------

  final prefs = await SharedPreferences.getInstance();

  final savedLanguage = prefs.getString('app_language');

  Locale? initialLocale;

  if (savedLanguage != null && savedLanguage.isNotEmpty) {
    initialLocale = Locale(savedLanguage);
  }

  // ------------------------------------------------------------
  // Start application
  // ------------------------------------------------------------

  runApp(
    ChopdiApp(
      initialLocale: initialLocale,
    ),
  );
}

// ============================================================
// CHOPDI APP
// ============================================================

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

// ============================================================
// CHOPDI APP STATE
// ============================================================

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

  // ============================================================
  // CHANGE LANGUAGE
  // ============================================================

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

  // ============================================================
  // CURRENT LOCALE
  // ============================================================

  Locale? get currentLocale => _locale;

  // ============================================================
  // HANDLE BACK BUTTON
  // ============================================================

  Future<bool> _handleBackPress() async {
    final now = DateTime.now();

    // ------------------------------------------------------------
    // First back press
    // ------------------------------------------------------------

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

    // ------------------------------------------------------------
    // Reset timer
    // ------------------------------------------------------------

    _lastBackPress = null;

    // ------------------------------------------------------------
    // Second back press
    // ------------------------------------------------------------

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ----------------------------------------------------------
      // GLOBAL NAVIGATOR
      // ----------------------------------------------------------

      navigatorKey: appNavigatorKey,

      // ----------------------------------------------------------
      // NOTIFICATION DEEP-LINK ROUTES
      // ----------------------------------------------------------

      onGenerateRoute: (settings) {
        if (settings.name == '/customer_details') {
          final customer = settings.arguments as Customer;

          return MaterialPageRoute(
            builder: (_) => CustomerDetailsScreen(
              customer: customer,
            ),
          );
        }

        if (settings.name == '/took_loan_customer_details') {
          final lender = settings.arguments as Lender;

          return MaterialPageRoute(
            builder: (_) => TookLoanCustomerDetailsScreen(
              lender: lender,
            ),
          );
        }

        return null;
      },

      // ----------------------------------------------------------
      // GENERAL SETTINGS
      // ----------------------------------------------------------

      debugShowCheckedModeBanner: false,

      locale: _locale,

      // ----------------------------------------------------------
      // LOCALIZATION
      // ----------------------------------------------------------

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      supportedLocales: AppLocalizations.supportedLocales,

      // ----------------------------------------------------------
      // SPLASH SCREEN
      // ----------------------------------------------------------

      home: PopScope(
        canPop: false,
        onPopInvokedWithResult: (
            bool didPop,
            Object? result,
            ) async {
          if (didPop) {
            return;
          }

          final shouldExit = await _handleBackPress();

          if (shouldExit) {
            await SystemNavigator.pop();
          }
        },
        child: const SplashScreen(),
      ),
    );
  }
}