import 'package:flutter/material.dart';

// Firebase packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// If you are using the FlutterFire CLI, you might have a generated file like:
// import 'firebase_options.dart'; // Uncomment if needed

/// The entry point of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  /// If using a generated firebase_options.dart, do this:
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  /// Otherwise, for a manual config or older versions:
  await Firebase.initializeApp();

  runApp(MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Registration Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

/// A simple home page offering choices to register as a donor or a charity.
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Registration Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Register as:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to RegisterPage with userType = 'donor'
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterPage(userType: 'donor'),
                    ),
                  );
                },
                child: Text('Donor'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to RegisterPage with userType = 'charity'
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterPage(userType: 'charity'),
                    ),
                  );
                },
                child: Text('Charity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The registration page for either a donor or a charity.
class RegisterPage extends StatefulWidget {
  final String userType;

  RegisterPage({required this.userType});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Handles the registration logic
  void handleRegister() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Determine the Firestore collection based on userType
      // Note: Ensure widget.userType is exactly 'donor' or 'charity'
      // to match this condition below
      String collection =
      widget.userType == 'donor' ? 'donors' : 'charities';

      // Save user data to Firestore
      await _firestore.collection(collection).doc(userCredential.user!.uid).set({
        'email': email,
        'userType': widget.userType,
        'createdAt': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Registered successfully as ${widget.userType.toUpperCase()}')),
      );

      // After successful registration, pop back to HomePage or wherever needed
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      // Handle any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unknown error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register as ${widget.userType.toUpperCase()}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm Password'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: handleRegister,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
