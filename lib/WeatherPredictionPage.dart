import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:larkcoins/Test.dart';
import 'WebApiForWeather.dart';
import 'WeatherPredictionPageHandler.dart';


class WeatherForecast {
  final DateTime date;
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
  TextEditingController _locationController = TextEditingController();
  

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
                        showSearchedDataInformation(context, _locationController.text);
                       // await _fetchWeatherForecasts();
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




showSearchedDataInformation(BuildContext context, String zipcode) async {

  if (_locationController.text != null) {
    var dataInfo = await getDayTemp(_locationController.text);
    Map<String, String> temperatureInformation = dataInfo[0];
    var location = dataInfo[1];
    DateTime dt = DateTime.now();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var screenSize = MediaQuery.of(context).size;
        return Dialog(
          child: Container(
            width: screenSize.width,
            height: screenSize.height * 0.9,
            // Container properties and child widgets
            child: Column(
              children: [
                Text(
                  location + "\n" + dt.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: temperatureInformation.length,
                    itemBuilder: (BuildContext context, int i) {
                      var key = temperatureInformation.keys.elementAt(i);
                      var value = temperatureInformation[key];
                      return ListTile(
                        title: Text('$key: $value'),
                      );
                    },
                  ),
                ),
                 ElevatedButton(
                  onPressed: t ,
                  child: Text("Add To Watch List"),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

t(){}

Future<void> _fetchWeatherForecasts() async {
    try {
      var dataList = await getDayTemp(_locationController.text);
      Map<String, String> data = dataList[0];
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
