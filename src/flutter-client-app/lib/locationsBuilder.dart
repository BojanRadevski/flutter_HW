
import 'dart:convert';
import 'package:demo/models/location.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'mapScreenBuilder.dart';
class HttpScreen extends StatelessWidget {
  const HttpScreen({Key? key, this.markerIcons}) : super(key: key);
  // ignore: prefer_typing_uninitialized_variables
  final markerIcons;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Location>>(
        future: getLocations(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MapScreen(locs: snapshot.data!, markerIcons: markerIcons);
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

Future<List<Location>> getLocations() async {
  const url = "http://10.0.0.2:8080/home";
  var response = await http.get(Uri.parse(url));
  var data = json.decode(utf8.decode(response.bodyBytes));
  if (response.statusCode == 200) {
    final jsonLocations = data;
    final locations = List.from(jsonLocations);
    List<Location> locs = locations.map((e) => Location.fromJson(e)).toList();
    return locs;
  }
  throw Exception("error");
}