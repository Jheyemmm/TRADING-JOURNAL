import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tradermind/pages/Calendar.dart';
import 'package:tradermind/pages/EditEntryPage.dart';
import 'package:tradermind/pages/Favourite.dart';
import 'package:tradermind/pages/Home.dart';
import 'package:tradermind/pages/Signup.dart';
import 'firebase_options.dart'; // Make sure this file exists and is correctly generated
import 'package:tradermind/pages/Login.dart';
import 'package:tradermind/pages/Splashscreen.dart';
import 'package:tradermind/pages/EditEntryPage.dart';

// Ensure that all widgets are initialized before running the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tradermind',
      initialRoute: '/',
      routes: {
        '/': (context) => Splashscreen(child: LoginPage()),
        '/Login': (context) => LoginPage(),
        '/Home': (context) => const HomePage(),
        '/Signup': (context) => RegisterPage(),

        // Add route for HomePage
      },
    );
  }
}
