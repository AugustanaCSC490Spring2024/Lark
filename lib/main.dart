import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Album>> fetchAlbums() async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums'));

  if (response.statusCode == 200) {
    // If the server returned a 200 OK response,
    // parse the list of albums using parseAlbums function
    List<Map<String, dynamic>> jsonList = jsonDecode(response.body).cast<Map<String, dynamic>>();
    List<Album> albums = jsonList.map((data) => Album.fromJson(data)).toList();

    return albums;
  } else {
    // If the server did not return a 200 OK response,
    // throw an exception.
    throw Exception('Failed to load albums');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    // Check if the required fields exist in the JSON map
    if (json.containsKey('userId') &&
        json.containsKey('id') &&
        json.containsKey('title')) {
      // Extract values from the JSON map
      int userId = json['userId'] as int;
      int id = json['id'] as int;
      String title = json['title'] as String;

      // Create and return an Album instance
      return Album(
        userId: userId,
        id: id,
        title: title,
      );
    } else {
      // Throw a FormatException if any required field is missing
      throw FormatException('Failed to load album. Missing required fields.');
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Album>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<List<Album>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Handle the case when data is available
                List<Album> albums = snapshot.data!;
                return ListView.builder(
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text("id: ${albums[index].id}\ndata: ${albums[index].title}"),
                    );
                  },
                );

              } else if (snapshot.hasError) {
                // Handle the case when an error occurs
                return Text('${snapshot.error}');
              } else {
                // Handle the case when data is still loading
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
