// sources : https://pub.dev/packages/intl
// https://stackoverflow.com/questions/67719259/how-to-render-full-html-document-with-flutter-html-package
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'WebApiForWeather.dart';

class WeatherForecast {
  final DateTime date; // Change the type to DateTime
  final String temperature;

  WeatherForecast({required this.date, required this.temperature});
}

class WeatherPredictionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WeatherPredictionPageState();
  }
}

class WeatherPredictionPageState extends State<WeatherPredictionPage> {
  List<WeatherForecast> forecasts = [];
  TextEditingController _locationController = TextEditingController(text: '61201');

  @override
  void initState() {
    super.initState();
    _fetchWeatherForecasts();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather Prediction'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Enter location',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        await _fetchWeatherForecasts();
                      },
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: forecasts.length,
                itemBuilder: (context, index) {
                  WeatherForecast forecast = forecasts[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${_formatDate(forecast.date)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Average Temperature: ${forecast.temperature}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _fetchWeatherForecasts() async {
    try {
      Map<String, String> data = await getDayTemp(_locationController.text);
      setState(() {
        forecasts = data.entries
            .map((entry) => WeatherForecast(date: DateTime.parse(entry.key), temperature: entry.value))
            .toList();
      });
    } catch (e) {
      print('Error fetching weather forecasts: $e');
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE MMMM d, yyyy').format(date);
  }
}
