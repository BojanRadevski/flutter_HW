// ignore_for_file: missing_required_param

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:demo/.env.dart';
import 'package:demo/models/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsRepository{
  static const String _baseUrl='https://maps.googleapis.com/maps/api/directions/json?';//appito za direkcii
  final Dio? _dio;
  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions> getDirections({
    @required LatLng? origin,
    @required LatLng? destination,

  })async{
    final response = await _dio?.get(
      _baseUrl,
      queryParameters: {
        'origin':'${origin?.latitude},${origin?.longitude}',
        'destination':'${destination?.latitude},${destination?.longitude}',
        'key':googleAPIKey,
      }
    );
    if(response?.statusCode==200){
      return Directions.fromMap(response?.data);
    }
    Directions d=Directions();
    return d;
  }
}
