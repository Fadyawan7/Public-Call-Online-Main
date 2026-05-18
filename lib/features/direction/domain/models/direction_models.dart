import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents the current status of direction tracking
enum TrackingStatus {
  idle,
  active,
  paused,
  stopped,
  error,
}

/// Represents polyline data for route visualization
class PolylineData {
  final List<LatLng> points;
  final double totalDistance; // in meters
  final double traveledDistance; // in meters
  final int estimatedDurationMinutes;

  PolylineData({
    required this.points,
    required this.totalDistance,
    required this.traveledDistance,
    required this.estimatedDurationMinutes,
  });

  double get remainingDistance => totalDistance - traveledDistance;

  double get progressPercentage {
    if (totalDistance == 0) return 0;
    return (traveledDistance / totalDistance * 100).clamp(0, 100);
  }

  PolylineData copyWith({
    List<LatLng>? points,
    double? totalDistance,
    double? traveledDistance,
    int? estimatedDurationMinutes,
  }) {
    return PolylineData(
      points: points ?? this.points,
      totalDistance: totalDistance ?? this.totalDistance,
      traveledDistance: traveledDistance ?? this.traveledDistance,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    );
  }
}

/// Represents a location update event with metadata
class DirectionLocationEvent {
  final Position position;
  final double? distanceFromPrevious; // in meters
  final DateTime timestamp;
  final bool isSignificantMove; // true if > 10 meters from last update

  DirectionLocationEvent({
    required this.position,
    this.distanceFromPrevious,
    required this.timestamp,
    required this.isSignificantMove,
  });

  LatLng get latLng => LatLng(position.latitude, position.longitude);
}

/// Represents route information between two locations
class RouteData {
  final LatLng startLocation;
  final LatLng endLocation;
  final List<LatLng> routePoints;
  final double distanceMeters;
  final int durationMinutes;
  final String? encodedPolyline;

  RouteData({
    required this.startLocation,
    required this.endLocation,
    required this.routePoints,
    required this.distanceMeters,
    required this.durationMinutes,
    this.encodedPolyline,
  });

  factory RouteData.fromGoogleDirections(Map<String, dynamic> json) {
    try {
      final route = json['routes'][0];
      final leg = route['legs'][0];

      final distanceMeters = (leg['distance']['value'] as int).toDouble();
      final durationSeconds = leg['duration']['value'] as int;
      final durationMinutes = (durationSeconds / 60).ceil();

      final startLat = leg['start_location']['lat'] as double;
      final startLng = leg['start_location']['lng'] as double;
      final endLat = leg['end_location']['lat'] as double;
      final endLng = leg['end_location']['lng'] as double;

      List<LatLng> routePoints = [];
      final encodedPolyline = route['overview_polyline']['points'] as String;

      // Decode polyline or use provided points
      // For now, we'll use basic parsing - you may want to use a polyline decoder package
      routePoints = _decodePolyline(encodedPolyline);

      return RouteData(
        startLocation: LatLng(startLat, startLng),
        endLocation: LatLng(endLat, endLng),
        routePoints: routePoints,
        distanceMeters: distanceMeters,
        durationMinutes: durationMinutes,
        encodedPolyline: encodedPolyline,
      );
    } catch (e) {
      throw Exception('Failed to parse Google Directions API response: $e');
    }
  }

  /// Simple polyline decoder - basic implementation
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int result = 0;
      int shift = 0;
      int b;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      result = 0;
      shift = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}

/// Represents the complete direction state
class DirectionState {
  final TrackingStatus status;
  final RouteData? routeData;
  final PolylineData? polylineData;
  final DirectionLocationEvent? currentLocation;
  final DirectionLocationEvent? lastSignificantLocation;
  final String? errorMessage;
  final bool isPermissionGranted;
  final bool isLocationServiceEnabled;

  DirectionState({
    required this.status,
    this.routeData,
    this.polylineData,
    this.currentLocation,
    this.lastSignificantLocation,
    this.errorMessage,
    required this.isPermissionGranted,
    required this.isLocationServiceEnabled,
  });

  DirectionState copyWith({
    TrackingStatus? status,
    RouteData? routeData,
    PolylineData? polylineData,
    DirectionLocationEvent? currentLocation,
    DirectionLocationEvent? lastSignificantLocation,
    String? errorMessage,
    bool? isPermissionGranted,
    bool? isLocationServiceEnabled,
  }) {
    return DirectionState(
      status: status ?? this.status,
      routeData: routeData ?? this.routeData,
      polylineData: polylineData ?? this.polylineData,
      currentLocation: currentLocation ?? this.currentLocation,
      lastSignificantLocation:
          lastSignificantLocation ?? this.lastSignificantLocation,
      errorMessage: errorMessage ?? this.errorMessage,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
    );
  }
}
