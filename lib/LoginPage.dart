import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:larkcoins/firebase_options.dart';
import 'BottomNavigation.dart';



void main() async {

   WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // Authenticates if the user is already logged in
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      runApp(user == null ? LogInPage() : NavigationBarApp());
    });
}


class LogInPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
      primarySwatch: Colors.blue,
      ),
        home: Page(),
    );
  }
}



class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient : LinearGradient(
            colors: [Color(0xffcdffd8), Color(0xff94b9ff), ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Clime Coin',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String email = _emailController.text;
                String password = _passwordController.text;
                
                // Now you can use 'email' and 'password' for signing up the user
                signInWithEmailAndPassword(email, password);
              },
              child: const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
  


//Signin occurs here
Future<void> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = userCredential.user;
    // Handle successful sign-in
  } catch (e) {
    // Handle sign-in errors
  }
}