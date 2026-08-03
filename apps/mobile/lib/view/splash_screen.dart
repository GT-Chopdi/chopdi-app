import 'package:flutter/material.dart';
import 'package:mychopdi/service/auth_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/login_screen.dart';
import 'package:mychopdi/view/main_screen.dart';
import 'package:mychopdi/widgets/page_peel_painter.dart';
import 'package:mychopdi/widgets/red_intro_content.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.nextScreen,
    this.onFinished,
  });

  final Widget? nextScreen;
  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Timings for each phase of the animation
  static const Duration _hold1 = Duration(milliseconds: 1000); // Stop 1: fully closed
  static const Duration _peel1 = Duration(milliseconds: 600);  // Transit to midway
  static const Duration _hold2 = Duration(milliseconds: 1000); // Stop 2: midway (Screen 11)
  static const Duration _peel2 = Duration(milliseconds: 600);  // Transit to almost open
  static const Duration _hold3 = Duration(milliseconds: 1000); // Stop 3: almost open (Screen 12)
  static const Duration _peel3 = Duration(milliseconds: 400);  // Transit to fully open
  static const Duration _finalHold = Duration(milliseconds: 300); // Final navy hold

  static final Duration _computedTotal =
      _hold1 + _peel1 + _hold2 + _peel2 + _hold3 + _peel3 + _finalHold;

  double get _totalMs => _computedTotal.inMilliseconds.toDouble();

  late final double _t1 = _hold1.inMilliseconds / _totalMs;
  late final double _t2 = (_hold1 + _peel1).inMilliseconds / _totalMs;
  late final double _t3 = (_hold1 + _peel1 + _hold2).inMilliseconds / _totalMs;
  late final double _t4 = (_hold1 + _peel1 + _hold2 + _peel2).inMilliseconds / _totalMs;
  late final double _t5 = (_hold1 + _peel1 + _hold2 + _peel2 + _hold3).inMilliseconds / _totalMs;
  late final double _t6 = (_hold1 + _peel1 + _hold2 + _peel2 + _hold3 + _peel3).inMilliseconds / _totalMs;

  void checkLogin() async {
    bool isLogged = await AuthService.isLoggedIn();
    if (!mounted) return;
    if (isLogged) {
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
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 3),
      checkLogin,
    );
    _controller = AnimationController(
      vsync: this,
      duration: _computedTotal,
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onFinished != null) {
          widget.onFinished!();
        } else {
          final next = widget.nextScreen ?? const ChopdiOnboardingScreen();
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => next,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _localProgress(double v, double from, double to) {
    if (v <= from) return 0;
    if (v >= to) return 1;
    return (v - from) / (to - from);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChopdiColors.navy,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final v = _controller.value;

          double peelProgress;
          if (v <= _t1) {
            peelProgress = 0.0;
          } else if (v > _t1 && v <= _t2) {
            final localT = _localProgress(v, _t1, _t2);
            peelProgress = 0.45 * Curves.easeInOutCubic.transform(localT);
          } else if (v > _t2 && v <= _t3) {
            peelProgress = 0.45;
          } else if (v > _t3 && v <= _t4) {
            final localT = _localProgress(v, _t3, _t4);
            peelProgress = 0.45 + 0.37 * Curves.easeInOutCubic.transform(localT);
          } else if (v > _t4 && v <= _t5) {
            peelProgress = 0.82;
          } else if (v > _t5 && v <= _t6) {
            final localT = _localProgress(v, _t5, _t6);
            peelProgress = 0.82 + 0.18 * Curves.easeInOutCubic.transform(localT);
          } else {
            peelProgress = 1.0;
          }

          final showRedLayer = v < _t6;

          return Stack(
            fit: StackFit.expand,
            children: [
              Container(color: ChopdiColors.navy),
              if (v < 1.0)
                CustomPaint(
                  size: Size.infinite,
                  painter: PagePeelPainter(progress: peelProgress),
                ),
              if (showRedLayer)
                ClipPath(
                  clipper: _RedRegionClipper(peelProgress),
                  child: const RedIntroContent(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RedRegionClipper extends CustomClipper<Path> {
  const _RedRegionClipper(this.progress);

  final double progress;

  @override
  Path getClip(Size size) {
    final t = PagePeelPainter.creaseT(size, progress);
    final points = <Offset>[
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ];
    final clipped = _clipHalfPlane(points, t);
    final path = Path();
    if (clipped.isNotEmpty) {
      path.moveTo(clipped.first.dx, clipped.first.dy);
      for (final p in clipped.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      path.close();
    }
    return path;
  }

  List<Offset> _clipHalfPlane(List<Offset> poly, double t) {
    final result = <Offset>[];
    for (var i = 0; i < poly.length; i++) {
      final current = poly[i];
      final next = poly[(i + 1) % poly.length];
      final curVal = current.dy - current.dx - t; // y - x - t
      final nextVal = next.dy - next.dx - t;     // y - x - t
      final curInside = curVal <= 0;
      final nextInside = nextVal <= 0;

      if (curInside) result.add(current);
      if (curInside != nextInside) {
        final tt = curVal / (curVal - nextVal);
        result.add(Offset.lerp(current, next, tt)!);
      }
    }
    return result;
  }

  @override
  bool shouldReclip(covariant _RedRegionClipper oldClipper) =>
      oldClipper.progress != progress;
}
