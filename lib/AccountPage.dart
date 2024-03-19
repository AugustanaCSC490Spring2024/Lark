import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Accounts'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,// Background color for the whole page
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'User Account',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
                Padding(padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Respond to button press
                  },
                  child: const Text('Acheivements'),

              ),
                ),
              Padding(padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Respond to button press
                  },
                  child: const Text('Wallet'),

                ),
              ),
              Padding(padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Respond to button press
                  },
                  child: const Text('change username/password'),

                ),
              ),
              Padding(padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Respond to button press
                  },
                  child: const Text('log out'),

                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Respond to button press
                  },
                  child: const Text('About Us'),
                ),
              )
            ]
          )
        ),
      ),
    );
  }
}


void main(){

  runApp(AccountPage());

}
