// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_restaurant/features/direction/providers/direction_provider.dart';
// import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
// import 'package:flutter_restaurant/utill/dimensions.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';

// class DirectionScreen extends StatefulWidget {
//   final FreelancerModel freelancer;
//   final LatLng currentUserLocation;

//   const DirectionScreen({
//     Key? key,
//     required this.freelancer,
//     required this.currentUserLocation,
//   }) : super(key: key);

//   @override
//   State<DirectionScreen> createState() => _DirectionScreenState();
// }

// class _DirectionScreenState extends State<DirectionScreen>
//     with WidgetsBindingObserver, TickerProviderStateMixin {
//   late GoogleMapController _mapController;
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//   bool _isMapReady = false;
//   bool _isInitializing = true;
//   bool _isFollowingUser = true;
//   bool _showRecenterButton = false;
//   bool _isProgrammaticCameraMove = false;
//   bool _hasFittedRouteInitially = false;
//   bool _has100mNotificationSent = false;
//   LatLng? _trackingStartPosition;
//   bool _isDestinationReached = false;
//   late AnimationController _destinationAnimationController;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _destinationAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _initializeTracking();
//   }

//   @override
//   void dispose() {
//     _destinationAnimationController.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   Future<void> _initializeTracking() async {
//     try {
//       final directionProvider =
//           Provider.of<DirectionProvider>(context, listen: false);

//       _trackingStartPosition = widget.currentUserLocation;

//       final destinationLatLng = LatLng(
//         double.tryParse(widget.freelancer.latitude.toString()) ?? 0,
//         double.tryParse(widget.freelancer.longitude.toString()) ?? 0,
//       );

//       if (destinationLatLng.latitude == 0 && destinationLatLng.longitude == 0) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Invalid freelancer location'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//         return;
//       }

//       final success = await directionProvider.startTracking(
//         widget.currentUserLocation,
//         destinationLatLng,
//         autoStartLocationStream: true,
//       );

//       if (mounted) {
//         setState(() {
//           _isInitializing = false;
//         });

//         if (!success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   directionProvider.errorMessage ?? 'Failed to start tracking'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error initializing tracking: $e');
//       if (mounted) {
//         setState(() {
//           _isInitializing = false;
//         });
//       }
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final directionProvider =
//         Provider.of<DirectionProvider>(context, listen: false);
//     directionProvider.handleAppLifecycle(state);
//   }

//   Future<void> _updateMapUI(DirectionProvider directionProvider) async {
//     if (!_isMapReady) return;

//     try {
//       _markers = _buildMarkers(directionProvider);
//       _polylines = _buildPolylines(directionProvider);

//       // Check if reached destination
//       if (directionProvider.distanceRemaining < 50 && !_isDestinationReached) {
//         setState(() {
//           _isDestinationReached = true;
//           _destinationAnimationController.forward();
//         });
//       }

//       // Auto-notify freelancer at 100m
//       if (!_has100mNotificationSent &&
//           _trackingStartPosition != null &&
//           directionProvider.currentLocation != null) {
//         final distanceMoved = Geolocator.distanceBetween(
//           _trackingStartPosition!.latitude,
//           _trackingStartPosition!.longitude,
//           directionProvider.currentLocation!.latLng.latitude,
//           directionProvider.currentLocation!.latLng.longitude,
//         );

//         if (distanceMoved >= 100) {
//           _has100mNotificationSent = true;
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                     '✓ You are on your way! Freelancer has been notified.'),
//                 duration: const Duration(seconds: 2),
//               ),
//             );
//           }
//         }
//       }

//       // Fit route once, then follow user location
//       if (_markers.isNotEmpty) {
//         if (!_hasFittedRouteInitially && directionProvider.routeData != null) {
//           await _fitRouteBounds();
//           _hasFittedRouteInitially = true;
//         } else if (_isFollowingUser) {
//           await _animateToCurrentUser(directionProvider);
//         }
//       }

//       if (mounted) {
//         setState(() {});
//       }
//     } catch (e) {
//       // Silent error handling
//     }
//   }

//   Set<Marker> _buildMarkers(DirectionProvider directionProvider) {
//     final markers = <Marker>{};

//     markers.add(
//       Marker(
//         markerId: const MarkerId('current_user'),
//         position: directionProvider.currentLocation?.latLng ??
//             widget.currentUserLocation,
//         infoWindow: const InfoWindow(title: 'Your location'),
//         icon: BitmapDescriptor.defaultMarkerWithHue(
//           BitmapDescriptor.hueBlue,
//         ),
//       ),
//     );

//     if (directionProvider.routeData != null) {
//       markers.add(
//         Marker(
//           markerId: const MarkerId('destination'),
//           position: directionProvider.routeData!.endLocation,
//           infoWindow: InfoWindow(
//             title: widget.freelancer.name ?? 'Home',
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueRed,
//           ),
//         ),
//       );
//     }

//     return markers;
//   }

//   Set<Polyline> _buildPolylines(DirectionProvider directionProvider) {
//     final polylines = <Polyline>{};

//     if (directionProvider.polylineData == null) {
//       return polylines;
//     }

//     final polylineData = directionProvider.polylineData!;

//     // Full route polyline (light gray background)
//     polylines.add(
//       Polyline(
//         polylineId: const PolylineId('full_route'),
//         points: polylineData.points,
//         color: Colors.blue,
//         width: 8,
//         geodesic: true,
//       ),
//     );

//     // Traveled route polyline (Google Maps blue)
//     if (polylineData.traveledDistance > 0 && polylineData.points.isNotEmpty) {
//       final traveledPoints = _calculateTraveledPoints(
//         polylineData.points,
//         polylineData.traveledDistance,
//         polylineData.totalDistance,
//       );

//       if (traveledPoints.isNotEmpty) {
//         polylines.add(
//           Polyline(
//             polylineId: const PolylineId('traveled_route'),
//             points: traveledPoints,
//             color: Colors.blueAccent,
//             width: 8,
//             geodesic: true,
//             zIndex: 1,
//           ),
//         );
//       }
//     }

//     return polylines;
//   }

//   List<LatLng> _calculateTraveledPoints(
//     List<LatLng> routePoints,
//     double traveledDistance,
//     double totalDistance,
//   ) {
//     if (routePoints.isEmpty || traveledDistance <= 0) {
//       return [];
//     }

//     final progressRatio = (traveledDistance / totalDistance).clamp(0, 1);
//     final pointCount = (routePoints.length * progressRatio).toInt();
//     return routePoints.sublist(0, pointCount.clamp(1, routePoints.length));
//   }

//   Future<void> _fitRouteBounds() async {
//     if (!_isMapReady || _markers.isEmpty) return;

//     try {
//       final bounds = _getMarkerBounds(_markers);
//       _isProgrammaticCameraMove = true;
//       await _mapController.animateCamera(
//         CameraUpdate.newLatLngBounds(bounds, 120),
//       );
//     } catch (e) {
//       debugPrint('Error fitting route bounds: $e');
//     } finally {
//       _isProgrammaticCameraMove = false;
//     }
//   }

//   Future<void> _animateToCurrentUser(
//       DirectionProvider directionProvider) async {
//     final currentTarget =
//         directionProvider.currentLocation?.latLng ?? widget.currentUserLocation;

//     try {
//       _isProgrammaticCameraMove = true;
//       await _mapController.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: currentTarget,
//             zoom: 17,
//             tilt: 45,
//             bearing: 0,
//           ),
//         ),
//       );
//     } catch (e) {
//       debugPrint('Error animating to current user: $e');
//     } finally {
//       _isProgrammaticCameraMove = false;
//     }
//   }

//   void _onUserCameraMove(CameraPosition position, DirectionProvider provider) {
//     if (_isProgrammaticCameraMove) return;

//     final currentTarget =
//         provider.currentLocation?.latLng ?? widget.currentUserLocation;
//     final distanceFromUser = Geolocator.distanceBetween(
//       position.target.latitude,
//       position.target.longitude,
//       currentTarget.latitude,
//       currentTarget.longitude,
//     );

//     if (distanceFromUser > 40 && _isFollowingUser) {
//       setState(() {
//         _isFollowingUser = false;
//         _showRecenterButton = true;
//       });
//     }
//   }

//   Future<void> _recenterMap(DirectionProvider directionProvider) async {
//     if (!mounted) return;
//     setState(() {
//       _isFollowingUser = true;
//       _showRecenterButton = false;
//     });
//     await _animateToCurrentUser(directionProvider);
//   }

//   LatLngBounds _getMarkerBounds(Set<Marker> markers) {
//     var leastNorth = 90.0;
//     var leastSouth = -90.0;
//     var leastEast = 180.0;
//     var leastWest = -180.0;

//     for (final marker in markers) {
//       leastNorth = min(marker.position.latitude, leastNorth);
//       leastSouth = max(marker.position.latitude, leastSouth);
//       leastEast = min(marker.position.longitude, leastEast);
//       leastWest = max(marker.position.longitude, leastWest);
//     }

//     return LatLngBounds(
//       southwest: LatLng(leastNorth, leastEast),
//       northeast: LatLng(leastSouth, leastWest),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Consumer<DirectionProvider>(
//         builder: (context, directionProvider, child) {
//           if (_isMapReady && !_isInitializing) {
//             _updateMapUI(directionProvider);
//           }

//           return SafeArea(
//             child: Stack(
//               children: [
//                 // Google Maps with smooth updates
//                 GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: widget.currentUserLocation,
//                     zoom: 15,
//                   ),
//                   onCameraMove: (position) {
//                     _onUserCameraMove(position, directionProvider);
//                   },
//                   onMapCreated: (controller) {
//                     _mapController = controller;
//                     setState(() {
//                       _isMapReady = true;
//                     });
//                     if (!_isInitializing) {
//                       _updateMapUI(directionProvider);
//                     }
//                   },
//                   markers: _markers,
//                   polylines: _polylines,
//                   myLocationEnabled: false,
//                   zoomControlsEnabled: false,
//                   compassEnabled: true,
//                   mapToolbarEnabled: false,
//                   buildingsEnabled: true,
//                 ),

//                 // Header with freelancer info and rating
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: Dimensions.paddingSizeDefault,
//                       vertical: 12,
//                     ),
//                     child: Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () => Navigator.pop(context),
//                           child: const Icon(
//                             Icons.arrow_back,
//                             size: 24,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(width: Dimensions.paddingSizeDefault),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 widget.freelancer.name ?? 'Freelancer',
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               if (widget.freelancer.category_name != null)
//                                 Text(
//                                   widget.freelancer.category_name ?? '',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                             ],
//                           ),
//                         ),
//                         // Rating badge (top right)
//                         if (widget.freelancer.rating != null)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFFFC107).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(6),
//                               border: Border.all(
//                                 color: const Color(0xFFFFC107).withOpacity(0.3),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Icon(
//                                   Icons.star,
//                                   size: 16,
//                                   color: Color(0xFFFFC107),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   '${widget.freelancer.rating}',
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFFFFC107),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Recenter button (bottom-left, Google Maps style)
//                 if (_showRecenterButton && !_isInitializing)
//                   Positioned(
//                     left: Dimensions.paddingSizeDefault,
//                     bottom: 180,
//                     child: Material(
//                       elevation: 6,
//                       borderRadius: BorderRadius.circular(8),
//                       color: Colors.white,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(8),
//                         onTap: () => _recenterMap(directionProvider),
//                         child: const Padding(
//                           padding: EdgeInsets.all(12),
//                           child: Icon(
//                             Icons.my_location,
//                             size: 24,
//                             color: Color(0xFF2196F3),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                 // Call and Chat buttons (smooth slide animation when destination reached)
//                 if (_isDestinationReached && !_isInitializing)
//                   SlideTransition(
//                     position: Tween<Offset>(
//                       begin: const Offset(2, 0),
//                       end: Offset.zero,
//                     ).animate(CurvedAnimation(
//                       parent: _destinationAnimationController,
//                       curve: Curves.easeOutCubic,
//                     )),
//                     child: Positioned(
//                       top: 90,
//                       right: Dimensions.paddingSizeDefault,
//                       child: Column(
//                         children: [
//                           // Call button
//                           Material(
//                             elevation: 8,
//                             borderRadius: BorderRadius.circular(12),
//                             color: Colors.green,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(12),
//                               onTap: () {
//                                 if (widget.freelancer.phone != null) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(
//                                           'کال: ${widget.freelancer.phone}'),
//                                       duration: const Duration(seconds: 1),
//                                     ),
//                                   );
//                                 }
//                               },
//                               child: const Padding(
//                                 padding: EdgeInsets.all(14),
//                                 child: Icon(
//                                   Icons.call,
//                                   size: 26,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: Dimensions.paddingSizeDefault),
//                           // Chat button
//                           Material(
//                             elevation: 8,
//                             borderRadius: BorderRadius.circular(12),
//                             color: Colors.blue.shade500,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(12),
//                               onTap: () {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('چیٹ کھول رہے ہیں...'),
//                                     duration: Duration(seconds: 1),
//                                   ),
//                                 );
//                               },
//                               child: const Padding(
//                                 padding: EdgeInsets.all(14),
//                                 child: Icon(
//                                   Icons.chat_bubble_outline,
//                                   size: 26,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                 // Bottom sheet - Static, always visible
//                 // Positioned(
//                 //   bottom: 0,
//                 //   left: 0,
//                 //   right: 0,
//                 //   child: Container(
//                 //     decoration: BoxDecoration(
//                 //       color: Colors.white,
//                 //       borderRadius: const BorderRadius.only(
//                 //         topLeft: Radius.circular(20),
//                 //         topRight: Radius.circular(20),
//                 //       ),
//                 //       boxShadow: [
//                 //         BoxShadow(
//                 //           color: Colors.black.withOpacity(0.12),
//                 //           blurRadius: 12,
//                 //           offset: const Offset(0, -3),
//                 //         ),
//                 //       ],
//                 //     ),
//                 //     child: SingleChildScrollView(
//                 //       child: Column(
//                 //         mainAxisSize: MainAxisSize.min,
//                 //         children: [
//                 //           Padding(
//                 //             padding: const EdgeInsets.only(
//                 //               top: Dimensions.paddingSizeSmall,
//                 //             ),
//                 //             child: Container(
//                 //               height: 4,
//                 //               width: 40,
//                 //               decoration: BoxDecoration(
//                 //                 color: Colors.grey[300],
//                 //                 borderRadius: BorderRadius.circular(2),
//                 //               ),
//                 //             ),
//                 //           ),
//                 //           DirectionStatusWidget(
//                 //             status: directionProvider.trackingStatus,
//                 //             errorMessage: directionProvider.errorMessage,
//                 //           ),
//                 //           DirectionInfoWidget(
//                 //             polylineData: directionProvider.polylineData,
//                 //             isLoading: _isInitializing,
//                 //           ),
//                 //         ],
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),

//                 // Loading overlay
//                 if (_isInitializing)
//                   Container(
//                     color: Colors.black.withOpacity(0.3),
//                     child: const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
