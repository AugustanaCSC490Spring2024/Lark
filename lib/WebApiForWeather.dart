import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

getApiJson(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If the server returned a 200 OK response,
    return response.body;
  
    // print(jsonFile["timelines"]['minutely']);
    // print("This is the response: "+response.toString());
  } else {
    // If the server did not return a 200 OK response,
    // throw an exception.
    throw Exception('Failed to load albums');
  }
}


//Use this method to get a map of time to temp and use that for the frontend

getMinutelyData(String zipcode) async{

    var apiUrl = "https://api.tomorrow.io/v4/weather/forecast?location=$zipcode%20US&timesteps=1m&apikey=RKGfmqYZ1bjR8ILdi3dQWY2FBt4hFqCL";

    var response = await getApiJson(apiUrl);
    Map<String, dynamic>  jsonFile = json.decode(response);
    var minutelyData = jsonFile["timelines"]['minutely'];

    Map<String,String> minutelyDataMap = new Map<String,String>();

    for(var data in minutelyData){

       var time = data["time"].toString();
       var temperature = data["values"]["temperature"].toString();
       minutelyDataMap[time] = temperature;
    }
    return minutelyDataMap;

}

//send h for hourly, m for minutely in timeFrame
//4VNofUUMjYU4nUaNYbYqS35jkoRHQ6fG
getData(String zipcode, String timeFrame) async{

    var apiUrl = "https://api.tomorrow.io/v4/weather/forecast?location=$zipcode%20US&timesteps=1$timeFrame&apikey=RKGfmqYZ1bjR8ILdi3dQWY2FBt4hFqCL";
    var response = await getApiJson(apiUrl);
    Map<String, dynamic>  jsonFile = json.decode(response);
    var minutelyData = jsonFile["timelines"]['minutely'];

    Map<String,String> dataMap = new Map<String,String>();

    for(var data in minutelyData){

       var time = data["time"].toString();
       var temperature = data["values"]["temperature"].toString();
       dataMap[time] = temperature;
    }
    return dataMap;

}


//changed the function so that this can return a list instead of a map

getDayTemp(String zipcode) async{

    var apiUrl = "https://api.tomorrow.io/v4/weather/forecast?location=$zipcode%20US&timesteps=1d&apikey=RKGfmqYZ1bjR8ILdi3dQWY2FBt4hFqCL";
    var response = await getApiJson(apiUrl);
    Map<String, dynamic>  jsonFile = json.decode(response);
    var minutelyData = jsonFile["timelines"]['daily'];
    Map<String,String> dataMap = new Map<String,String>();

    for(var data in minutelyData){

       var time = data["time"].toString();
       var temperature = data["values"]["temperatureAvg"].toString();
       dataMap[time] = temperature;
    }

    var location = jsonFile["location"]["name"];

    var dataList = [];
    dataList.add(dataMap);
    dataList.add(location);
    return dataList;

}


getBackGroundImageUrl(String zipcode) async {

    var apiUrl = "https://api.tomorrow.io/v4/weather/realtime?location=$zipcode&apikey=RKGfmqYZ1bjR8ILdi3dQWY2FBt4hFqCL";
    var response = await getApiJson(apiUrl);
    Map<String, dynamic>  jsonFile = json.decode(response);
    var values = jsonFile['data']['values'];
    var timeNow = DateTime.now();
    var currentHour = timeNow.hour;
    var dayNight = '';
    var night = false;


    if (currentHour >= 18 || currentHour < 5) {
        dayNight = 'night';
        night = true;
      } 

      if (values['snowIntensity'] > 0) {
      return ['snowy.png', 'Snowy', Color.fromRGBO(255, 255, 255, 0.2)]; // White with 80% opacity
    } else if (values['rainIntensity'] > 1) {
      return ['rainy.png', 'Rainy', Color.fromRGBO(95, 95, 95, 0.2)]; // Dark gray with 50% opacity
    } else if (values['cloudCover'] > 25) {
      var url = dayNight + 'cloudy.png';
      var color = night ? Color.fromRGBO(77, 77, 77, 0.25) : Color.fromRGBO(137, 168, 225, 0.498); // Dark blue with 50% opacity or light gray with 50% opacity
      return [url, 'Cloudy', color];
    } else {
      var url = dayNight + 'sunny.png';
      var color = night ? Color.fromRGBO(51, 51, 51, 0.2) : Color.fromRGBO(177, 208, 239, 0.349); // Dark blue with 50% opacity or light gray with 50% opacity
      return [url, 'Clear Sky', color];
    }


}
