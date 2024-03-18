import 'package:flutter/material.dart';

class BetsPage extends StatelessWidget {
  const BetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bets'),
        ),
      ),
    );
  }
}
