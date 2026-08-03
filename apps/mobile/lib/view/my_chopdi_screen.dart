import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_colors.dart';

class MyChopdiScreen extends StatefulWidget{
  
  const MyChopdiScreen({super.key});

  @override
  State createState() => _MyChopdiScreenState();
}

class _MyChopdiScreenState extends State {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChopdiColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsGeometry.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Chopdi",
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ChopdiColors.navy
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}