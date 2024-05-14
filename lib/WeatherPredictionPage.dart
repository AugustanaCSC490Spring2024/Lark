import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  List<String> urlList = [];
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

              FutureBuilder<void> (

                future: loadUrls(),
                builder: (context, snapshot){
               if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator while data is being fetched
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                return   ListView.builder(
                shrinkWrap: true,
                itemCount: forecasts.length,
                itemBuilder: (context, index) {
                  String forecast = forecasts[index];
                  print("Printing index: ");
                  print(index);

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
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10), // Set border radius to match the card's shape
                        image: DecorationImage(
                          image: AssetImage(urlList[index]), // Your background image
                          fit: BoxFit.cover, // Adjust the fit as needed
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              forecast.toString(),
                              style: TextStyle(
                                color: Colors.white,
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
                    ),
                  ),

                  );
                },
              );

              }

              }

              ),
            
            ],
          ),
        ),
      ),
    );
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

Future<void> loadUrls() async {

  try{
        for(var data in forecasts){
        var forcastList = data.split(',');
        print(forcastList);
        var bgInfo = await getBackGroundImageUrl(forcastList[0]);
        print(bgInfo);
        var url = "assets/PredictionPageImages/" + bgInfo[0];
        urlList.add(url);
      }

      print("Sucessfully loaded the URLS");
      print("All URLS ");
      print(urlList.length);
      print(urlList.toString());

  }catch(e){

    
  }

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

showSearchedDataInformation(
    
    BuildContext context, String zipcode, bool viewonly) async {
    if (zipcode != null) {
      var dataInfo = await getDayTemp(zipcode);
      Map<String, String> temperatureInformation = dataInfo[0];
      var location = dataInfo[1];
      DateTime dt = DateTime.now();
      var locationTitleArr = location.split(",");
      var locationTitle = locationTitleArr[0] + ", " + locationTitleArr[1];
      var tempTitle = temperatureInformation.values.first;
      var skySituation = await getBackGroundImageUrl(zipcode);
      var url = "assets/PredictionPageImages/"+ skySituation[0];
      Color weatherColor = skySituation[2];


showDialog(
  context: context,
  builder: (BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(url), // Your background image
            fit: BoxFit.cover,
          ),
        ),
        width: screenSize.width,
        height: screenSize.height * 0.6,
        // Container properties and child widgets
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Text(
                locationTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white, // Set text color to white
                ),
              ),
            ),
            Container(
              child: Text(
                tempTitle + " C",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: Colors.white, // Set text color to white
                ),
              ),
            ),
            Text(
              skySituation[1],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: Colors.white, // Set text color to white
              ),
            ),
            Text(
              "Weather Forecast For 6 days",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white, // Set text color to white
              ),
            ),
            Expanded(
              child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: weatherColor,
              ),
              child: ListView.builder(
                itemCount: temperatureInformation.length,
                itemBuilder: (BuildContext context, int i) {
                  var key = temperatureInformation.keys.elementAt(i);
                  var value = temperatureInformation[key];
                  return ListTile(
                    title: Text(
                      '$key: $value' + " C",
                      style: TextStyle(
                        color: Colors.white, // Set text color to white
                        fontSize: 25,
                      ),
                    ),
                  );
                },
              ),
            )
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10, top: 10,),
              child: ElevatedButton(
                onPressed: () {
                  if (viewonly) {
                    Navigator.of(context).pop();
                  } else {
                    watchListUpdate(_locationController.text, location);
                  }
                },
                child: viewonly
                    ? Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black), // Set text color to black for cancel button
                      )
                    : Text("Add To WatchList"),
              ),
            ),
          ],
        ),
      ),
    );
  },
);
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



 