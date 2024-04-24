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

    var apiUrl = "https://api.tomorrow.io/v4/weather/forecast?location=$zipcode%20US&timesteps=1m&apikey=4VNofUUMjYU4nUaNYbYqS35jkoRHQ6fG";

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
getData(String zipcode, String timeFrame) async{

    var apiUrl = "https://api.tomorrow.io/v4/weather/forecast?location=$zipcode%20US&timesteps=1$timeFrame&apikey=4VNofUUMjYU4nUaNYbYqS35jkoRHQ6fG";
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



getDayTemp(String zipcode) async{

    var apiUrl = "https://api.tomorrow.io/v4/weather/forecast?location=$zipcode%20US&timesteps=1d&apikey=4VNofUUMjYU4nUaNYbYqS35jkoRHQ6fG";
    var response = await getApiJson(apiUrl);
    Map<String, dynamic>  jsonFile = json.decode(response);
    var minutelyData = jsonFile["timelines"]['daily'];
    Map<String,String> dataMap = new Map<String,String>();

    for(var data in minutelyData){

       var time = data["time"].toString();
       var temperature = data["values"]["temperatureAvg"].toString();
       dataMap[time] = temperature;
    }
    return dataMap;

}



void main() async{

  //this is how you get the get daily temp predicted
   Map<String,String> data = await getDayTemp("61201");

   print("This is the size: " + data.length.toString());

}