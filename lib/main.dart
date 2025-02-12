import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/Auth/login_page.dart';
import 'firebase_options.dart';

Future<void> main() async {await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp(

  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Donor App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginPage(), // Redirect to Login Page
      debugShowCheckedModeBanner: false, // Removes debug banner
    );
  }
}
