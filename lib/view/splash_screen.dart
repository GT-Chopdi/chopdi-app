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
      body: Center(
        child: Row(
          children: [
            SizedBox(width: 170),
            Text("Chopdi",style: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.bold,color: Colors.blueAccent)),
          ],
        ),
      ),
    );
  }
}