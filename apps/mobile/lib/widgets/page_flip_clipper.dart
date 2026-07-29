import 'package:flutter/material.dart';

class PeelClipper extends CustomClipper<Path> {

  final double value;

  PeelClipper(this.value);

  @override
  Path getClip(Size size) {

    double cut = size.width * value;

    Path path = Path();

    path.moveTo(0, 0);

    path.lineTo(size.width, 0);

    path.lineTo(size.width - cut, size.height);

    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}