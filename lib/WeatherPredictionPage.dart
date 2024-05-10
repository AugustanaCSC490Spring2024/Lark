import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:larkcoins/Test.dart';
import 'WebApiForWeather.dart';
import 'dbHandler.dart';


class WeatherForecast {
  final DateTime date;
  final String temperature;
  final String location;

  WeatherForecast({required this.date, required this.temperature, required this.location});

}

class WeatherPredictionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WeatherPredictionPageState();
  }
}

class WeatherPredictionPageState extends State<WeatherPredictionPage> {

  List<String> forecasts = [];
  TextEditingController _locationController = TextEditingController();
  
  Map<String, String> watchlist = {}; 
  @override
  initState()  {
    super.initState();
    watchlistForcastDispaly();

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
                        await showSearchedDataInformation(context, _locationController.text, false);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: forecasts.length,
                itemBuilder: (context, index) {
                  String forecast = forecasts[index];

                  return GestureDetector(
                  onTap: () async {
                          var zipcode;
                          watchlist.forEach((key, value) {
                            if (value == forecast) {
                              zipcode = key;
                            }
                          }); 
                           await showSearchedDataInformation (context, zipcode,true);
                          },
                
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            forecast.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ElevatedButton(
                            onPressed: () async {
                              await deleteWatchlist(forecast);
                              setState(() {});
                            },
                            child: Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  )
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

deleteWatchlist(String zipcode) async{
    print("Deleting");
    print(zipcode);
    watchlist.removeWhere((key, value) => value == zipcode);
    addWatchlist(watchlist);
    forecasts.remove(zipcode);

}

watchListUpdate(String zipcode, String location) async {
    if(watchlist[zipcode] == null){
      watchlist[zipcode] = location;
    }else{
      print("Nothing to update");
    }
      addWatchlist(watchlist);
      await watchlistForcastDispaly();
      Navigator.of(context).pop(); 
}

showSearchedDataInformation(BuildContext context, String zipcode, bool viewonly) async {
  if (zipcode != null) {
    var dataInfo = await getDayTemp(zipcode);
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
                      onPressed: () {
                        if (viewonly) {
                                Navigator.of(context).pop(); 
                        }else{
                          watchListUpdate(_locationController.text, location);

                        }
                      },
                      child: viewonly
                      ? Text("Cancle")
                      : Text("Add To WatchList")

                    )

              ],
            ),
          ),
        );
      },
    );
  }
}




Future<void> watchlistForcastDispaly() async {
    await loadWatchlist();
    try {
      var location = watchlist.values.toList();
      forecasts = location;
      print("Sucessfully loaded the location");
      print("All locations");
      print( forecasts.length);
    } catch (e) {
      print('Error fetching weather forecasts: $e');
    }
  }


  Future<void> loadWatchlist() async {
    Map<String, String> loadedWatchlist = await getWatchlist();
    if (loadedWatchlist != null) {
      setState(() {
        watchlist = loadedWatchlist;
      });
      print("Sucessfully loaded watchlist");
      print("Loaded watchlist size");
      print(watchlist.length);
    }else{
      print("Wathcing list is null");
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE MMMM d, yyyy').format(date);
  }

}



 