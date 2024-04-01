import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart'; // Assuming LoginPage.dart is in the same directory

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key); // Make key parameter nullable

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LogInPage()));
    } catch (e) {
      print('Sign out error: $e');
      // Show SnackBar using ScaffoldMessenger
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error signing out. Please try again.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accounts'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color for the whole page
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'User Account',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: Text('Achievements'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: Text('Wallet'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: Text('Change Username/Password'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  print('Logging out');
                  signOut(context);
                },
                child: Text('Log Out'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: Text('About Us'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ScaffoldMessenger(
      child: AccountPage(),
    ),
  ));
}
