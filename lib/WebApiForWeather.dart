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






void main() async{

  //this is how you get the getMinutelyDataFromAPI
   Map<String,String> data = await getMinutelyData("61201");
  print("This is the size: " + data.length.toString());
}