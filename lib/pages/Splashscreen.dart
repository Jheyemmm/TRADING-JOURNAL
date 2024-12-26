import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  final Widget? child;
  const Splashscreen({super.key, this.child});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
      () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => widget.child!),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color:
            const Color(0xFF00C98E), // Background color for the splash screen
        child: Center(
          child: Image.asset(
            'lib/assets/FULL.png', // Path to your logo image
            height: 200, // Larger size for the logo
            fit: BoxFit.contain, // Ensures the image scales proportionally
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Splashscreen(
      child: const Placeholder(), // Replace with your actual home widget
    ),
  ));
}
