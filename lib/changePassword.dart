

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/src/auth_credential.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:larkcoins/LoginPage.dart';

import 'AccountPage.dart';

bool checkPasswords(String p1, String p2){
  return p1 == p2;
}

Future<bool> checkCredentials( String userPassword) async {
  User? user = auth.currentUser;
  String email = user!.email!;
  try {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: userPassword);
    await user?.reauthenticateWithCredential(credential);
    return true;
  } catch (e) {
    return false;
  }
}

void changePassword(String newPassword) async{
  await user?.updatePassword(newPassword);
}

class changePasswordApp extends StatelessWidget {
  const changePasswordApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const ChangePassword(),
    );
  }
}


class ChangePassword extends StatefulWidget {

  const ChangePassword({Key? key}) : super(key: key);

  @override
  _changePassword createState() => _changePassword();
}
class _changePassword extends State<ChangePassword> {
  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();




  @override
  void dispose() {
    oldPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
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
            TextFormField(
              controller: oldPassword,
              decoration: const InputDecoration(
                labelText: 'Old Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: newPassword,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: confirmPassword,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                if (checkPasswords(newPassword.text, confirmPassword.text)) {
                  if (await checkCredentials(oldPassword.text)) {
                    changePassword(newPassword.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password changed successfully'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Incorrect old password'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Passwords do not match'),
                    ),
                  );
                }

              },
              child: const Text('change passwoed'),
            ),

            Padding(padding: EdgeInsets.all(10),

                child:
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the previous screen
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