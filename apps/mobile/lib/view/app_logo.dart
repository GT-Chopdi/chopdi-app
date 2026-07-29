import 'package:flutter/material.dart';

class ChopdiLogo extends StatelessWidget {
  const ChopdiLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xffAAB9CF),
                  width: 6,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          Positioned(
            right: 0,
            child: Container(
              width: 35,
              height: 80,
              color: const Color(0xff223A5E),
            ),
          ),

          Positioned(
            top: 30,
            right: 15,
            child: Container(
              width: 22,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xffAAB9CF),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            right: 15,
            child: Container(
              width: 22,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xffAAB9CF),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const Text(
            "₹",
            style: TextStyle(
              color: Color(0xffC74C4C),
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}