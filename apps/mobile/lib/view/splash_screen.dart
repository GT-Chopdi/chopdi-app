
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/service/auth_service.dart';
import 'package:mychopdi/view/login_screen.dart';
import 'package:mychopdi/view/main_screen.dart';
import 'package:mychopdi/service/local_notification_service.dart';
import 'package:mychopdi/view/otp_screen.dart';

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key});

@override
State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _scaleAnimation;

@override
void initState() {
super.initState();

// ------------------------------------------------------------
// Request notification permission
// ------------------------------------------------------------

LocalNotificationService.instance.requestPermission();

// ------------------------------------------------------------
// Splash animation
// ------------------------------------------------------------

_controller = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 1200),
);

_scaleAnimation = Tween<double>(
begin: 1.0,
end: 2.1,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeInOutCubic,
),
);

// ------------------------------------------------------------
// Start splash
// ------------------------------------------------------------

Future.delayed(
const Duration(seconds: 1),
() async {
if (!mounted) return;

_controller.forward();

await Future.delayed(
const Duration(milliseconds: 1050),
);

if (!mounted) return;

await checkLogin();
},
);
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

// ============================================================
// CHECK LOGIN
// ============================================================

  Future<void> checkLogin() async {
    final loggedIn = await AuthService.instance.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      final pendingPayload =
          LocalNotificationService.pendingNotificationPayload;

      if (pendingPayload != null &&
          pendingPayload.isNotEmpty) {
        debugPrint(
          '[LocalNotification] Pending cold-start payload: '
              '$pendingPayload',
        );

        LocalNotificationService.pendingNotificationPayload = null;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );

      // Wait until MainScreen is mounted.
      if (pendingPayload != null &&
          pendingPayload.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback(
              (_) async {
            await Future.delayed(
              const Duration(milliseconds: 500),
            );

            debugPrint(
              '[LocalNotification] Routing pending notification: '
                  '$pendingPayload',
            );

            await LocalNotificationService
                .handleNotificationRouting(
              pendingPayload,
            );
          },
        );
      }

      return;
    }

    await AuthService.instance.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        // builder: (_) => const ChopdiOnboardingScreen(),
        builder: (_) => const OTPScreen(phoneNumber: '7741939556', challengeId: '123456',),
      ),
          (route) => false,
    );
  }
// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
final l10n = AppLocalizations.of(context);

final size = MediaQuery.of(context).size;

final bottomSafeArea =
MediaQuery.of(context).padding.bottom;

return Scaffold(
backgroundColor: const Color(0xFFC74C4C),
body: AnimatedBuilder(
animation: _controller,
builder: (context, child) {
return Transform.scale(
scale: _scaleAnimation.value,
child: child,
);
},
child: Stack(
children: [
// ------------------------------------------------------
// Background
// ------------------------------------------------------

Positioned.fill(
child: Container(
color: const Color(0xFFC74C4C),
),
),

// ------------------------------------------------------
// Frame overlay
// ------------------------------------------------------

Positioned.fill(
child: Padding(
padding: EdgeInsets.all(
size.width * 0.03,
),
child: Image.asset(
'assets/frame_overlay.png',
fit: BoxFit.cover,
),
),
),

// ------------------------------------------------------
// Logo
// ------------------------------------------------------

Center(
child: Text(
'Chopdi',
style: GoogleFonts.styleScript(
fontSize:
(size.width * 0.20).clamp(
60.0,
100.0,
),
color: const Color(0xFF223A5E),
height: 1,
fontWeight: FontWeight.w400,
),
),
),

// ------------------------------------------------------
// Bottom badge
// ------------------------------------------------------

Positioned(
bottom:
bottomSafeArea +
(size.height * 0.06),
left: 0,
right: 0,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Image.asset(
'assets/secure.png',
width:
(size.width * 0.20).clamp(
80.0,
120.0,
),
height:
(size.width * 0.20).clamp(
85.0,
125.0,
),
),

SizedBox(
height: size.height * 0.015,
),

Text(
l10n.secureSimple,
style: GoogleFonts.manrope(
color: const Color(0xFFFDEDD9),
fontSize:
(size.width * 0.048).clamp(
16.0,
22.0,
),
fontWeight: FontWeight.w800,
letterSpacing: 0.0,
),
),

const SizedBox(height: 4),

Text(
l10n.yourLedgerAlwaysSafe,
style: GoogleFonts.manrope(
color: const Color(0xFFFFF8F0),
fontSize:
(size.width * 0.035).clamp(
12.0,
16.0,
),
fontWeight: FontWeight.w800,
letterSpacing: 0.0,
),
),
],
),
),
],
),
),
);
}
}
