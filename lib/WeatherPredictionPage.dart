import 'package:flutter/material.dart';
import 'WebApiForWeather.dart';


void main(List<String> args) {
  runApp(WeatherPredictionPage());
}

class WeatherPredictionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WeatherPredictionPageState();
  }
}

class WeatherPredictionPageState extends State<WeatherPredictionPage> {
  Map<String, String> data = {}; // Initialize data map
  TextEditingController _locationController = TextEditingController();
  // @override
  // void initState() {
  //   super.initState();
  //   fetchData(); // Fetch data when the widget initializes
  // }

  // Future<void> fetchData() async {
  //   // Fetch data here, for example:
  //   data = await getMinutelyData("61201");
  //   setState(() {}); // Trigger a rebuild to reflect changes
  // }

  @override
  Widget build(BuildContext context) {
    List<String> keys = data.keys.toList(); // Convert map keys to a list

    return MaterialApp( // Add MaterialApp as the root widget
      home: Directionality(
        textDirection: TextDirection.ltr, // Set text direction to left-to-right
        child: Scaffold(
          appBar: AppBar(
            title: Text('Weather Prediction'),
          ),
          body: SingleChildScrollView(
            child: Column(
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
                          data = await getDayTemp(_locationController.text);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Title ${index + 1}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Time ${"${keys[index]}\n${data[keys[index]]}"}',
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
      ),
    );
  }
}

