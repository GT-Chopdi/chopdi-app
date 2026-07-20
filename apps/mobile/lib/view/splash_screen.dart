import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget{

  const SplashScreen({super.key});

  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF223A5E),
      body: Center(
        child: Row(
          children: [
            SizedBox(width: 170),
            Text("Chopdi",style: GoogleFonts.roboto(fontSize: 34, fontWeight: FontWeight.bold,color: Colors.white)),
          ],
        ),
      ),
    );
  }
}