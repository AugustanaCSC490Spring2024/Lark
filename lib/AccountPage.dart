import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:larkcoins/NewUserName.dart';
import 'package:larkcoins/dbHandler.dart';
import 'package:larkcoins/topNavigationBar.dart';
import 'LoginPage.dart';
import 'changePassword.dart';
import 'dbHandler.dart';
import 'HomePage.dart';


final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;

final username = getUserName();

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String username = '';



  @override
  void initState() {
    super.initState();
    // Initialize the username here or fetch it from a source
    getUserData();
  }

  Future<void> getUserData() async {
    // Fetch user data including username
    final fetchedUsername = await getUserName();
    setState(() {
      username = fetchedUsername;
    });
  }


  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      runApp(LogInPage());
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
        appBar: CustomAppBar(
          leading: GestureDetector(
            onTap: () {
              // Avoid pushing HomePage again if already on it
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: const TopNavigation(),
          ),
        ),
      //backgroundColor: Color(0xffcdffd8),
    body: Container(

    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [Color(0xffcdffd8), Color(0xff94b9ff)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    ),
    ),

      child: SingleChildScrollView(
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
              child: FutureBuilder<double>(
                future: getUserMoney(), // Fetching user's wallet amount
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Display loading indicator while waiting for data
                    return ElevatedButton(
                      onPressed: () {}, // Disable button during loading
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(screenSize.width, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      ),
                      child: Text('Loading...'),
                    );
                  } else if (snapshot.hasError) {
                    // Display error message if an error occurs
                    return ElevatedButton(
                      onPressed: () {}, // Disable button on error
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(screenSize.width, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      ),
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    // Display the wallet amount once it's fetched
                    return ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Your Wallet'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('The amount of money you have in your wallet is:'),
                                    Text(snapshot.data.toString()), // Display wallet amount
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
                    );
                  }
                },
              ),
            ),




                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                              Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NewUserName()),
                            ).then((newUsername) {
                              if (newUsername != null) {
                                setState(() {
                                  username = newUsername;
                                });
                              }
                            });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(screenSize.width, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.0),


                          ),
                        ),
                          child: const Text('change username'),

            ),
                    ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePassword()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenSize.width, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.0),


                  ),
                ),
                child: const Text('change password'),

              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                  signOut(context);
                  //(LogInPage());
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
    ));
  }
}