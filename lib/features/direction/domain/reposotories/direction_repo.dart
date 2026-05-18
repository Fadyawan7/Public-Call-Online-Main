import 'package:flutter_restaurant/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/direction_models.dart';

class DirectionRepository {
  final DioClient dioClient;

  DirectionRepository({required this.dioClient});

  /// Fetch route from Google Directions API
  /// Requires: origin (lat,lng), destination (lat,lng), API key
  Future<RouteData> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final String url = 'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=${AppConstants.googleMapsApiKey}';

      final response = await dioClient.dio!.get(url);

      if (response.statusCode == 200) {
        final routeData = RouteData.fromGoogleDirections(response.data);
        return routeData;
      } else {
        throw Exception('Failed to fetch directions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching directions: $e');
    }
  }

  /// Get distance between two points using Google Distance Matrix API
  /// More accurate than manual calculation
  Future<Map<String, dynamic>> getDistanceMatrix(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/distancematrix/json'
          '?origins=${origin.latitude},${origin.longitude}'
          '&destinations=${destination.latitude},${destination.longitude}'
          '&key=${AppConstants.googleMapsApiKey}';

      final response = await dioClient.dio!.get(url);

      if (response.statusCode == 200) {
        final element = response.data['rows'][0]['elements'][0];
        return {
          'distance': element['distance']['value'], // meters
          'duration': element['duration']['value'], // seconds
          'durationText': element['duration']['text'],
          'distanceText': element['distance']['text'],
        };
      } else {
        throw Exception(
            'Failed to fetch distance matrix: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching distance matrix: $e');
    }
  }
}
