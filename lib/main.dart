import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/Auth/selection_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Donor App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: AnimatedHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ✅ Animated HomePage with All Animations
class AnimatedHomePage extends StatefulWidget {
  @override
  _AnimatedHomePageState createState() => _AnimatedHomePageState();
}

class _AnimatedHomePageState extends State<AnimatedHomePage> {
  double _opacity = 0.0;  // For fade-in effect
  double _slidePosition = -50;  // For slide-in effect
  double _scale = 0.5;  // For zoom-in effect
  double _rotation = -0.2;  // For rotation effect

  @override
  void initState() {
    super.initState();

    // Delay animations for smooth transition
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
        _slidePosition = 0;
        _scale = 1.0;
        _rotation = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(seconds: 1),
          child: AnimatedContainer(
            duration: Duration(seconds: 1),
            transform: Matrix4.translationValues(0, _slidePosition, 0)
              ..scale(_scale)
              ..rotateZ(_rotation),
            child: Text(
              'Welcome to Apna भोजन Food - BY RISHI BHARDWAJ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SelectionPage()),
            );
          },
          child: Text(
            "Go to Selection Page",
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.green,
          ),
        ),
      ),
    );
  }
}
