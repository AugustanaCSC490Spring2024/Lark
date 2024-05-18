import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:larkcoins/firebase_options.dart';
import 'BottomNavigation.dart';
import 'sign_up_page.dart';
import 'package:larkcoins/raining_coins.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LogInPage());
}

class LogInPage extends StatelessWidget {
  const LogInPage({Key? key}) : super(key: key);

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
  double _logoOpacity = 0.0;
  double _cloudOpacity = 0.0;

@override
void initState() {
  super.initState();
  // Set opacity to 1 gradually after 1 second
  Future.delayed(const Duration(seconds: 1), () {
    if (mounted) {
      setState(() {
        _cloudOpacity = 1.0;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _logoOpacity = 1.0;
          });
        }
      });
    }
  });
}

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffcdffd8), Color(0xff94b9ff)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(20.0),
          ),

          Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: AnimatedOpacity(
                duration: const Duration(seconds: 2),
                opacity: _cloudOpacity,
                child: Image.asset(
                  'assets/cloud7.gif',
                  width: MediaQuery.of(context).size.width * 0.25, // Adjust the width percentage as needed
                  height: MediaQuery.of(context).size.width * 0.25 , // Adjust the height proportionally
                  fit: BoxFit.contain, // Use BoxFit.contain to prevent cutting the image
                ),
              ),
          ),

          Positioned.fill(
            child: RainingCoins(),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedOpacity(
                  duration: const Duration(seconds: 2),
                  opacity: _logoOpacity,
                  child: const Text(
                    'CLIMECOIN',
                    style: TextStyle(
                      fontSize: 70,
                      fontFamily: 'Casino3D',
                      color: Color(0xffff8884),
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Color(0xffff8884),
                          offset: Offset(-5, -5),
                        ),
                        Shadow(
                          blurRadius: 10,
                          color: Color(0xffffcbc8),
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
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
                    signInWithEmailAndPassword(email, password, context);
                  },
                  child: const Text('Log In'),
                ),
                GestureDetector(
                  onTap: () {
                    runApp(SignUpPageApp());
                  },
                  child: const Text(
                    'New to the lark world?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],

      ),
    );
  }
}

// Signin occurs here
Future<void> signInWithEmailAndPassword(String email, String password, BuildContext context) async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    _showNoInternetDialog(context);
    return;
  }
  
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = userCredential.user;

    runApp(const NavigationBarApp());

    // Handle successful sign-in
  } catch (e) {
    showErrorDialog(context, "Wrong credentials. Please try again.");
  }
}

void _showNoInternetDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your internet connection and try again.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


void showErrorDialog(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}