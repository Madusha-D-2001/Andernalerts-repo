import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 7, 7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/brandix logo.png',
                width: 100, // adjust the width as necessary
                height: 100, // adjust the height as necessary
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white,
                ],
                tileMode: TileMode.mirror,
              ).createShader(bounds),
              child: const Text(
                'Andern Alerts',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'digital-7',
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Set the text color to white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
