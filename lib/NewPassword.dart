
import 'dart:async';
import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:larkcoins/firebase_options.dart';
import 'BottomNavigation.dart';
import 'dbHandler.dart';
import 'LoginPage.dart';

// void fireBaseSetUp() async {
//   WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter bindings have been initialized.
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
// }

class SignUpPageApp extends StatelessWidget {
  const SignUpPageApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const SignUpPage(),
    );
  }
}


class ChangeUserName_Password extends StatefulWidget {

  const ChangeUserName_Password({Key? key}) : super(key: key);

  @override
  _ChangeUserName_PasswordeState createState() => _ChangeUserName_PasswordeState();
}

class _ChangeUserName_PasswordeState extends State<ChangeUserName_Password> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
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
          gradient: LinearGradient(
            colors: [Color(0xffcdffd8), Color(0xff94b9ff)],
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
            TextFormField( // Added this block for username input
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
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
                String userName = _usernameController.text;
                signUp(context, email, password, userName);
              },
              child: const Text('Sign Up'),
            ),

            Padding(padding: EdgeInsets.all(10),

              child: ElevatedButton(
                onPressed: () {
                  runApp(LogInPage());
                },
                child: const Text('< Back'),
              ),
            )


          ],
        ),
      ),
    );
  }
}

Future<void> signUp(BuildContext context, String email, String password, String userName) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await dialog(context, "Congratulations!!! Welcome , now lark into the depth of Money ", "Whoop whoop!!");
    newUserCreated(userName);
    //Using async and await to make sure that runApp Does not happen
    Timer(Duration(seconds: 2), () {
      runApp(NavigationBarApp());
    });  } on FirebaseAuthException catch (e) {
    // Handle FirebaseAuth errors
    print('FirebaseAuthException: ${e.message}');
    // Display error message to the user
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${e.message}'),
    ));
  } catch (e) {
    // Handle other errors
    print('Signup error: $e');
    dialog(context, "Signup Error. Please try again. ", "Error");
  }
}



Future<void> dialog(BuildContext context, String message, String title) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}
