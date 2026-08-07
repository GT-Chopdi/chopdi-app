import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/user_session.dart';
import 'package:mychopdi/service/isar_service.dart';
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
    final session = await IsarService.isar.userSessions.where().findFirst();

    if (!mounted) return;

    if (session != null && session.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ChopdiOnboardingScreen(),
        ),
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