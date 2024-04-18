import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:larkcoins/dbHandler.dart';
import 'LoginPage.dart';
import 'dbHandler.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;

final username = getUserName();

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LogInPage()));
    } catch (e) {
      print('Sign out error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error signing out. Please try again.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      backgroundColor: Color(0xffcdffd8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<String>(
              future: getUserName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else { 
                  return Text(// Here's the change
                    snapshot.data.toString(),
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenSize.width, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),
                child: const Text('Achievements'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Your Wallet'),
                        content: const SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('The amount of money you have in your wallet is:'),
                              Text('100'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
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
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenSize.width, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),
                child: const Text('Wallet'),
              ),
            ),

                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(screenSize.width, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.0),

                          ),
                        ),
                        child: const Text('change username/password'),
                      ),
                    ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                  signOut(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenSize.width, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),
                child: const Text('log out'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('About Us'),
                        content: const SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('This is a betting app'),
                              Text('This app is for entertainment purposes only'),
                              Text('This app is not responsible for any losses'),
                              Text('This app is not responsible for any addiction'),
                              Text('Made by Group Lark'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
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
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenSize.width, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),
                child: const Text('About Us'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
