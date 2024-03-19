import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

fetchAlbums() async {
  final response = await http.get(Uri.parse('https://api.tomorrow.io/v4/map/tile/1/0/1/temperature/now.png?apikey=4VNofUUMjYU4nUaNYbYqS35jkoRHQ6fG'));

  if (response.statusCode == 200) {
    // If the server returned a 200 OK response,
    // parse the list of albums using parseAlbums function
    print(response.toString());
  } else {
    // If the server did not return a 200 OK response,
    // throw an exception.
    throw Exception('Failed to load albums');
  }
}

void main(){
  fetchAlbums();
}