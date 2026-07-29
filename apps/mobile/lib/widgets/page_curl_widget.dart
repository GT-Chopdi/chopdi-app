import 'package:flutter/material.dart';

import 'page_curl_painter.dart';

class PageCurlWidget extends AnimatedWidget {
  final Widget front;
  final Widget back;

  const PageCurlWidget({
    super.key,
    required Animation<double> animation,
    required this.front,
    required this.back,
  }) : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [

            /// Screen underneath
            back,

            /// Curl animation
            CustomPaint(
              painter: PageCurlPainter(
                progress: animation.value,
              ),
              child: front,
            ),
          ],
        );
      },
    );
  }
}