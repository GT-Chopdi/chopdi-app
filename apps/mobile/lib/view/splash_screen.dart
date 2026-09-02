import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/service/auth_service.dart';
import 'package:mychopdi/view/login_screen.dart';
import 'package:mychopdi/view/main_screen.dart';

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


      _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.3, // Entire screen zooms
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () async {
      _controller.forward();

      await Future.delayed(const Duration(milliseconds: 1050));

      if (!mounted) return;

      checkLogin();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void checkLogin() async {
    // Keyed on the presence of a real refresh token in secure storage, not on
    // the local `isLoggedIn` flag this used to read. That flag lived in the
    // database alongside ordinary data: on a rooted device it was a one-value
    // edit away from a bypassed login, and it could also go stale — surviving
    // a server-side sign-out or a revoked device and dropping the user into a
    // session whose every request would 401.
    final loggedIn = await AuthService.instance.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );
    } else {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => const ChopdiOnboardingScreen(),
      //   ),
      // );
      await AuthService.instance.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ChopdiOnboardingScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Positioned.fill(
              child: Container(
                color: const Color(0xFFC74C4C),
              ),
            ),

            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  "assets/frame_overlay.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// Logo
            Center(
              child: Text(
                "Chopdi",
                style: GoogleFonts.styleScript(
                  fontSize: 96,
                  color: Color(0XFF223A5E),
                  height: 1,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            /// Bottom Badge
            Positioned(
              bottom: 70,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/secure.png",
                    width: 108,
                    height: 114,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "SECURE • SIMPLE",
                    style: GoogleFonts.manrope(
                      color: Color(0xFFFDEDD9),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "YOUR LEDGER, ALWAYS SAFE",
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFFFF8F0),
                      fontSize: 14,
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