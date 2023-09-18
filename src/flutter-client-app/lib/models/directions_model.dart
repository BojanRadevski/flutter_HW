
import 'package:flutter/foundation.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class Directions{
  LatLngBounds? bounds; // centrira kamera
  List<PointLatLng>? polylinePoins; // lista od tocki za crtanje na direkciite
  String? totalDistance; 
  String? totalDuration;

  Directions({
    @required this.bounds,
    @required this.polylinePoins,
    @required this.totalDistance,
    @required this.totalDuration
  });

  factory Directions.fromMap(Map<String,dynamic>map){
    if ((map['routes'] as List).isEmpty) return Directions(bounds: null, polylinePoins: null, totalDistance: null, totalDuration: null);
     
     final data = Map<String, dynamic>.from(map['routes'][0]);

     final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    String distance = '';
    String duration = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    return Directions(
      bounds: bounds,
      polylinePoins:
          PolylinePoints().decodePolyline(data['overview_polyline']['points']),
      totalDistance: distance,
      totalDuration: duration,
    );
  }

}
  