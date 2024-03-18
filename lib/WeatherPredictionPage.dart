import 'package:flutter/material.dart';

class WeatherPredictionPage extends StatelessWidget {
  const WeatherPredictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather Predictions'),
        ),
      ),
    );
  }
}
