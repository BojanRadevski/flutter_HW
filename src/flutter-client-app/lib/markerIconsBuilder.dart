import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'locationsBuilder.dart';

class MarkerIconsBuilder extends StatelessWidget {
  const MarkerIconsBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, BitmapDescriptor>>(
        future: initMarkers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HttpScreen(markerIcons: snapshot.data);
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
Future<Map<String, BitmapDescriptor>> initMarkers() async {
  Map<String, BitmapDescriptor> markerIcons = <String, BitmapDescriptor>{};
  final Uint8List markerIcon = await getBytesFromAsset('assets/cave_.png', 100);
  markerIcons["CAVE"] = BitmapDescriptor.fromBytes(markerIcon);
  final Uint8List markerIcon2 =
      await getBytesFromAsset('assets/lake_.png', 100);
  markerIcons["LAKE"] = BitmapDescriptor.fromBytes(markerIcon2);
  final Uint8List markerIcon3 =
      await getBytesFromAsset('assets/lodge_.png', 100);
  markerIcons["LODGE"] = BitmapDescriptor.fromBytes(markerIcon3);
  final Uint8List markerIcon4 =
      await getBytesFromAsset('assets/mountain_.png', 100);
  markerIcons["PEAK"] = BitmapDescriptor.fromBytes(markerIcon4);
  final Uint8List markerIcon5 =
      await getBytesFromAsset('assets/river_.png', 100);
  markerIcons["SPRING"] = BitmapDescriptor.fromBytes(markerIcon5);
  final Uint8List markerIcon6 =
      await getBytesFromAsset('assets/waterfall_.png', 100);
  markerIcons["WATERFALL"] = BitmapDescriptor.fromBytes(markerIcon6);
  return markerIcons;
}
Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}