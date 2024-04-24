import 'dart:async';
import 'dart:html';
import 'dbHandler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:larkcoins/firebase_options.dart';
import 'AccountPage.dart';
import 'BottomNavigation.dart';
import 'dbHandler.dart';
import 'LoginPage.dart';


class NewUserNameApp extends StatelessWidget {
  const NewUserNameApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NewUserName(),
    );
  }
}


class NewUserName extends StatefulWidget {

  const NewUserName({Key? key}) : super(key: key);

  @override
  _NewUserName createState() => _NewUserName();
}
class _NewUserName extends State<NewUserName> {
  final TextEditingController _newUserName = TextEditingController();
  late Future<String> _usernameFuture;

  @override
  void initState() {
    super.initState();
    _usernameFuture = getUserName();
    // Set opacity to 1 gradually after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        // _logoOpacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _newUserName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New User Name'),
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
            FutureBuilder<String>(
              future: getUserName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While waiting for the username to be fetched, display a loading indicator
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // If an error occurs while fetching the username, display an error message
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Once the username is fetched, display it
                  return Text(
                    'Username: ${snapshot.data}',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _newUserName,
              decoration: const InputDecoration(
                labelText: '_newUserName',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                  changeUserName(_newUserName.text);
                  setState(() {
                  _usernameFuture = getUserName(); // Update the future to fetch the new username
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Username changed successfully'),
                  ),
                );

            },
              child: const Text('change user name'),
            ),

            Padding(padding: EdgeInsets.all(10),

              child:
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _newUserName.text); // Navigate back to the previous screen
                },
                child: const Text('< Back'),
            )
            ),


          ],
        ),
      ),
    );
  }
}