import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as PH;

class RegisterPage extends StatefulWidget {
  final String userType; // Get userType from Selection Page

  RegisterPage({required this.userType}); // Constructor

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to request location permission and get current location
  Future<Map<String, double>> _getCurrentLocation() async {
    double latitude = 0.0;
    double longitude = 0.0;
    // Use alias PH for permission_handler to avoid conflict
    PH.PermissionStatus permissionStatus = await PH.Permission.location.request();
    if (permissionStatus.isGranted) {
      Location location = Location();
      LocationData locationData = await location.getLocation();
      latitude = locationData.latitude ?? 0.0;
      longitude = locationData.longitude ?? 0.0;
    }
    return {'latitude': latitude, 'longitude': longitude};
  }

  void handleRegister() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      double latitude = 0.0;
      double longitude = 0.0;

      // If registering as a charity, get the current location
      if (widget.userType == "charities") {
        Map<String, double> locationData = await _getCurrentLocation();
        latitude = locationData['latitude']!;
        longitude = locationData['longitude']!;
      }

      // Save data to Firestore (including location for charities)
      await _firestore.collection(widget.userType).doc(userCredential.user!.uid).set({
        'email': email,
        'userType': widget.userType,
        'createdAt': DateTime.now().toIso8601String(),
        if (widget.userType == "charities") ...{
          'latitude': latitude,
          'longitude': longitude,
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registered successfully! Please login.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Register as ${widget.userType == "donors" ? "Donor" : "Charity"}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: emailController,
              decoration:
              InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: 'Password', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: 'Confirm Password', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleRegister,
              child: Text(
                  'Register as ${widget.userType == "donors" ? "Donor" : "Charity"}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Already have an account? Login here'),
            ),
          ],
        ),
      ),
    );
  }
}
