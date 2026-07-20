import 'package:flutter/material.dart';
import 'package:mychopdi/view/home_screen.dart';
import 'dart:async';
import 'package:pinput/pinput.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool otpSent = false;

  Color primaryColor = Color(0xFF223A5E);
  Color secondaryColor = Color(0xFFAAB9CF);
  Color accentColor = Color(0xFFC74C4C);
  Color backgroundColor = Color(0xFFFAF8F5);

  Timer? timer;
  int secondsRemaining = 30;
  bool canResend = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Container(
            height: 330,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  secondaryColor,
                ],
              ),
            ),
          ),

          Positioned(
            top: 100,
            left: 120,
            right: 20,
            child: Container(
              height: 105,
              width: 105,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  "assets/images/chopdiLogo.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 18, top: 10),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),

          const Positioned(
            left: 22,
            top: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MyChopdi",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Login with Mobile OTP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * .68,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Enter Mobile Number",
                        prefixIcon: Icon(
                          Icons.mail_outline,
                          color: secondaryColor,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              BorderSide(color: backgroundColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              BorderSide(color: primaryColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (otpSent)
                      Column(
                        children: [
                          Pinput(
                            controller: otpController,
                            length: 6,
                            keyboardType: TextInputType.number,

                            defaultPinTheme: PinTheme(
                              width: 50,
                              height: 55,
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),

                            focusedPinTheme: PinTheme(
                              width: 50,
                              height: 55,
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),

                            submittedPinTheme: PinTheme(
                              width: 50,
                              height: 55,
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryColor),
                              ),
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: canResend
                                ? TextButton(
                                    onPressed: resendOTP,
                                    child: Text(
                                      "Resend OTP",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Text(
                                      "Resend OTP in 00:${secondsRemaining.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 25),

                    SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          if (!otpSent) {

                            setState(() {
                              otpSent = true;
                            });
                            startTimer();
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen())
                            );
                          }
                        },
                        child: Text(
                          otpSent ? "Verify OTP" : "Send OTP",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey.shade300),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("Or"),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey.shade300),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: secondaryColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/icon.jpg",
                            height: 22,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Continue with Google",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startTimer() {
    secondsRemaining = 30;
    canResend = false;

    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void resendOTP() {
    // Call resend OTP API 

    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }
}