import 'package:flutter/material.dart';
import 'package:larkcoins/HomePage.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:dice_icons/dice_icons.dart';
import 'AccountPage.dart';
import 'HomePage.dart';
import 'BetsPage.dart';
import 'WeatherPredictionPage.dart';

 void main() => runApp(const NavigationBarApp());

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({Key? key}) : super(key: key);

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  final List<Widget> _pages = [

    HomePage(),
    BetsPage(),
    WeatherPredictionPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: _pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        backgroundColor: Colors.blue[200],
        indicatorColor: Colors.blue[100],
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(DiceIcons.dice6),
            label: 'Bets',
          ),
          NavigationDestination(
            icon: Icon(WeatherIcons.day_cloudy),
            label: 'Predictions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: "Account",
          ),
        ],
      ),
    );
  }
}
