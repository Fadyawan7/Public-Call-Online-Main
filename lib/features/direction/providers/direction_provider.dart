import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_restaurant/features/direction/domain/models/direction_models.dart';
import 'package:flutter_restaurant/features/direction/domain/reposotories/direction_repo.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionProvider with ChangeNotifier {
  final DirectionRepository directionRepo;
  VoidCallback? _onDestinationReached;

  // State
  DirectionState _state = DirectionState(
    status: TrackingStatus.idle,
    isPermissionGranted: false,
    isLocationServiceEnabled: false,
  );

  // Streams and subscriptions
  StreamSubscription<Position>? _locationStreamSubscription;
  Timer? _locationCheckTimer;

  // Live re-routing (keeps the polyline + distance glued to the user, like
  // turn-by-turn nav apps do)
  LatLng? _destinationLocation;
  bool _isRefreshingRoute = false;
  DateTime? _lastRouteRefreshAt;
  static const Duration _minRouteRefreshInterval = Duration(seconds: 4);

  // Tracking configuration
  static const int _locationUpdateThresholdMeters = 10;
  static const Duration _locationCheckInterval = Duration(seconds: 10);
  static const LocationAccuracy _desiredAccuracy = LocationAccuracy.high;

  DirectionProvider({required this.directionRepo}) {
    _initializeLocationPermissions();
  }

  // Getters
  DirectionState get state => _state;
  TrackingStatus get trackingStatus => _state.status;
  RouteData? get routeData => _state.routeData;
  PolylineData? get polylineData => _state.polylineData;
  DirectionLocationEvent? get currentLocation => _state.currentLocation;
  double get distanceRemaining => _state.polylineData?.remainingDistance ?? 0;
  double get progressPercentage => _state.polylineData?.progressPercentage ?? 0;
  int get etaMinutes => _state.polylineData?.estimatedDurationMinutes ?? 0;
  bool get isTracking => _state.status == TrackingStatus.active;
  String? get errorMessage => _state.errorMessage;

  /// Initialize location permissions and service status
  Future<void> _initializeLocationPermissions() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateState(
          state.copyWith(
            isLocationServiceEnabled: false,
            errorMessage: 'Location service is disabled',
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final isGranted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      _updateState(
        state.copyWith(
          isPermissionGranted: isGranted,
          isLocationServiceEnabled: true,
        ),
      );
    } catch (e) {
      debugPrint('Error initializing location permissions: $e');
      _updateState(
        state.copyWith(
          errorMessage: 'Failed to initialize location permissions',
        ),
      );
    }
  }

  /// Start direction tracking between current user and freelancer
  Future<bool> startTracking(
    LatLng currentLocation,
    LatLng destinationLocation, {
    bool autoStartLocationStream = true,
    VoidCallback? onDestinationReached,
  }) async {
    try {
      _onDestinationReached = onDestinationReached;
      _destinationLocation = destinationLocation;
      _lastRouteRefreshAt = DateTime.now();

      // Check permissions first
      if (!_state.isPermissionGranted) {
        await _initializeLocationPermissions();
        if (!_state.isPermissionGranted) {
          _updateState(
            state.copyWith(
              status: TrackingStatus.error,
              errorMessage: 'Location permission not granted',
            ),
          );
          return false;
        }
      }

      if (!_state.isLocationServiceEnabled) {
        _updateState(
          state.copyWith(
            status: TrackingStatus.error,
            errorMessage: 'Location service is disabled',
          ),
        );
        return false;
      }

      _updateState(
        state.copyWith(
          status: TrackingStatus.active,
          errorMessage: null,
        ),
      );

      // Fetch route from API
      try {
        final routeData = await directionRepo.getDirections(
          currentLocation,
          destinationLocation,
        );

        final polylineData = PolylineData(
          points: routeData.routePoints,
          totalDistance: routeData.distanceMeters.toDouble(),
          traveledDistance: 0,
          estimatedDurationMinutes: routeData.durationMinutes,
        );

        _updateState(
          state.copyWith(
            routeData: routeData,
            polylineData: polylineData,
          ),
        );
      } catch (e) {
        debugPrint('Error fetching route: $e');
        // Continue with tracking even if API fails
        final polylineData = PolylineData(
          points: [currentLocation, destinationLocation],
          totalDistance:
              _calculateDistance(currentLocation, destinationLocation),
          traveledDistance: 0,
          estimatedDurationMinutes: 0,
        );

        _updateState(
          state.copyWith(
            polylineData: polylineData,
            errorMessage: 'Could not fetch optimal route, using direct path',
          ),
        );
      }

      // Start location stream if requested
      if (autoStartLocationStream) {
        await _startLocationStream();
      }

      return true;
    } catch (e) {
      debugPrint('Error starting tracking: $e');
      _updateState(
        state.copyWith(
          status: TrackingStatus.error,
          errorMessage: 'Failed to start tracking: $e',
        ),
      );
      return false;
    }
  }

  /// Start listening to real-time location updates
  Future<void> _startLocationStream() async {
    try {
      // Cancel existing subscription if any
      await _locationStreamSubscription?.cancel();

      _locationStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: _desiredAccuracy,
          distanceFilter: _locationUpdateThresholdMeters,
          timeLimit: const Duration(seconds: 30),
        ),
      ).listen(
        _onLocationUpdate,
        onError: _onLocationError,
        cancelOnError: false,
      );

      // Fallback timer to check location even if stream events don't fire
      _locationCheckTimer = Timer.periodic(_locationCheckInterval, (_) async {
        try {
          final lastUpdate =
              _state.currentLocation?.timestamp ?? DateTime(1970);
          final timeSinceLastUpdate = DateTime.now().difference(lastUpdate);

          if (timeSinceLastUpdate.inSeconds > 30) {
            final currentPos = await Geolocator.getCurrentPosition(
              desiredAccuracy: _desiredAccuracy,
            );
            _onLocationUpdate(currentPos);
          }
        } catch (e) {
          debugPrint('Error in location check timer: $e');
        }
      });
    } catch (e) {
      debugPrint('Error starting location stream: $e');
      _updateState(
        state.copyWith(
          status: TrackingStatus.error,
          errorMessage: 'Failed to start location tracking: $e',
        ),
      );
    }
  }

  /// Handle location update event
  void _onLocationUpdate(Position position) {
    try {
      final newLatLng = LatLng(position.latitude, position.longitude);
      final now = DateTime.now();

      // Calculate distance from last significant location
      double? distanceFromLast;
      bool isSignificantMove = true;

      if (_state.lastSignificantLocation != null) {
        final lastPos = _state.lastSignificantLocation!.position;
        distanceFromLast = Geolocator.distanceBetween(
          lastPos.latitude,
          lastPos.longitude,
          position.latitude,
          position.longitude,
        );
        isSignificantMove = distanceFromLast >= _locationUpdateThresholdMeters;
      }

      final locationEvent = DirectionLocationEvent(
        position: position,
        distanceFromPrevious: distanceFromLast,
        timestamp: now,
        isSignificantMove: isSignificantMove,
      );

      // Update current location
      _updateState(state.copyWith(currentLocation: locationEvent));

      // Update last significant location if threshold met
      if (isSignificantMove) {
        _updateState(
          state.copyWith(lastSignificantLocation: locationEvent),
        );

        // Keep the polyline + distance glued to the live position, like
        // turn-by-turn navigation apps do.
        _refreshRouteFromCurrentLocation(newLatLng);
      }

      // Check if reached destination
      _checkIfReachedDestination(newLatLng);
    } catch (e) {
      debugPrint('Error in _onLocationUpdate: $e');
      _updateState(
        state.copyWith(
          errorMessage: 'Error processing location update: $e',
        ),
      );
    }
  }

  /// Re-fetches the route from the user's current position to the
  /// destination so the polyline and remaining distance stay accurate as
  /// the user moves (mirrors how Google Maps redraws the route live).
  Future<void> _refreshRouteFromCurrentLocation(LatLng currentPosition) async {
    if (_destinationLocation == null || _isRefreshingRoute) {
      return;
    }

    final now = DateTime.now();
    if (_lastRouteRefreshAt != null &&
        now.difference(_lastRouteRefreshAt!) < _minRouteRefreshInterval) {
      // Too soon since the last API refresh - fall back to a lightweight
      // local estimate so the UI still feels responsive in between.
      if (_state.polylineData != null && _state.routeData != null) {
        _updateTraveledDistance(currentPosition);
      }
      return;
    }

    _isRefreshingRoute = true;
    _lastRouteRefreshAt = now;

    try {
      final routeData = await directionRepo.getDirections(
        currentPosition,
        _destinationLocation!,
      );

      final polylineData = PolylineData(
        points: routeData.routePoints,
        totalDistance: routeData.distanceMeters.toDouble(),
        traveledDistance: 0,
        estimatedDurationMinutes: routeData.durationMinutes,
      );

      _updateState(
        state.copyWith(
          routeData: routeData,
          polylineData: polylineData,
        ),
      );
    } catch (e) {
      debugPrint('Error refreshing live route: $e');
      // Fall back to the old distance-along-route estimate so the UI
      // doesn't just freeze if the API call fails.
      if (_state.polylineData != null && _state.routeData != null) {
        _updateTraveledDistance(currentPosition);
      }
    } finally {
      _isRefreshingRoute = false;
    }
  }

  /// Handle location stream error
  void _onLocationError(Object error) {
    // Silent error handling - don't show technical errors to user
    // unless it's a critical permission issue
    if (error.toString().contains('Permission')) {
      _updateState(
        state.copyWith(
          status: TrackingStatus.error,
          errorMessage: 'Location permission required',
        ),
      );
    }
  }

  /// Update traveled distance on polyline
  void _updateTraveledDistance(LatLng currentPosition) {
    if (_state.polylineData == null || _state.routeData == null) return;

    try {
      double traveledDistance = 0;

      // Calculate cumulative distance along the route
      for (int i = 0; i < _state.routeData!.routePoints.length - 1; i++) {
        final point1 = _state.routeData!.routePoints[i];
        final point2 = _state.routeData!.routePoints[i + 1];

        final segmentDistance = Geolocator.distanceBetween(
          point1.latitude,
          point1.longitude,
          point2.latitude,
          point2.longitude,
        );

        traveledDistance += segmentDistance;

        // Check if current position is closer to this segment
        final distToPoint2 = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          point2.latitude,
          point2.longitude,
        );

        if (distToPoint2 < 50) {
          // Within 50 meters of this point
          break;
        }
      }

      // Clamp traveled distance between 0 and total
      traveledDistance = traveledDistance.clamp(
        0,
        _state.polylineData!.totalDistance,
      );

      final updatedPolyline = _state.polylineData!.copyWith(
        traveledDistance: traveledDistance,
      );

      _updateState(state.copyWith(polylineData: updatedPolyline));
    } catch (e) {
      debugPrint('Error updating traveled distance: $e');
    }
  }

  /// Check if user has reached destination
  void _checkIfReachedDestination(LatLng currentPosition) {
    if (_state.routeData == null) return;

    final distanceToDestination = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      _state.routeData!.endLocation.latitude,
      _state.routeData!.endLocation.longitude,
    );

    // Consider reached if within 50 meters
    if (distanceToDestination < 50) {
      _onDestinationReached?.call();
      _onDestinationReached = null;
      _stopTracking(silent: true);
    }
  }

  /// Calculate straight-line distance between two points (in meters)
  double _calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Pause tracking
  void pauseTracking() {
    if (_state.status == TrackingStatus.active) {
      _locationStreamSubscription?.pause();
      _locationCheckTimer?.cancel();
      _updateState(state.copyWith(status: TrackingStatus.paused));
    }
  }

  /// Resume tracking
  Future<void> resumeTracking() async {
    if (_state.status == TrackingStatus.paused) {
      _locationStreamSubscription?.resume();
      _locationCheckTimer = Timer.periodic(_locationCheckInterval, (_) async {
        try {
          final currentPos = await Geolocator.getCurrentPosition(
            desiredAccuracy: _desiredAccuracy,
          );
          _onLocationUpdate(currentPos);
        } catch (e) {
          debugPrint('Error in resumed location check: $e');
        }
      });
      _updateState(state.copyWith(status: TrackingStatus.active));
    }
  }

  /// Stop tracking completely
  void _stopTracking({bool silent = false}) {
    _locationStreamSubscription?.cancel();
    _locationCheckTimer?.cancel();
    _locationStreamSubscription = null;
    _locationCheckTimer = null;
    _destinationLocation = null;
    _isRefreshingRoute = false;
    _lastRouteRefreshAt = null;

    _updateState(
      state.copyWith(
        status: TrackingStatus.stopped,
        errorMessage: silent ? null : 'Tracking stopped',
      ),
    );
  }

  /// Stop tracking and clean up
  void stopTracking() {
    _stopTracking(silent: false);
  }

  /// Reset tracking state
  void resetTracking() {
    _stopTracking(silent: true);
    _onDestinationReached = null;
    _state = DirectionState(
      status: TrackingStatus.idle,
      isPermissionGranted: _state.isPermissionGranted,
      isLocationServiceEnabled: _state.isLocationServiceEnabled,
    );
    notifyListeners();
  }

  /// Update internal state
  void _updateState(DirectionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Handle app lifecycle changes
  void handleAppLifecycle(AppLifecycleState appState) {
    switch (appState) {
      case AppLifecycleState.resumed:
        if (_state.status == TrackingStatus.paused) {
          resumeTracking();
        }
        break;
      case AppLifecycleState.paused:
        // Keep tracking in background if possible
        // Note: On Android, you may need to use a foreground service
        break;
      case AppLifecycleState.detached:
        _stopTracking(silent: true);
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _stopTracking(silent: true);
    super.dispose();
  }
}
