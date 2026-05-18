// // Helper widget to easily add direction tracking button to freelancer screens

// import 'package:flutter/material.dart';
// import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
// import 'package:flutter_restaurant/helper/router_helper.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:iconsax/iconsax.dart';

// class DirectionTrackingButton extends StatelessWidget {
//   final FreelancerModel freelancer;
//   final VoidCallback? onPressed;
//   final double? userLatitude;
//   final double? userLongitude;

//   const DirectionTrackingButton({
//     Key? key,
//     required this.freelancer,
//     this.onPressed,
//     this.userLatitude,
//     this.userLongitude,
//   }) : super(key: key);

//   Future<void> _startDirectionTracking(BuildContext context) async {
//     try {
//       // Get user's current location if not provided
//       late double userLat;
//       late double userLng;

//       if (userLatitude != null && userLongitude != null) {
//         userLat = userLatitude!;
//         userLng = userLongitude!;
//       } else {
//         final position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         userLat = position.latitude;
//         userLng = position.longitude;
//       }

//       // Navigate to direction screen using router
//       if (!context.mounted) return;

//       final route = RouterHelper.getDirectionRoute(
//         freelancer,
//         userLat,
//         userLng,
//       );

//       Navigator.of(context).pushNamed(route);
//     } catch (e) {
//       if (!context.mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: Could not get location'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: onPressed ?? () => _startDirectionTracking(context),
//       icon: const Icon(Iconsax.location),
//       label: const Text('Start Direction'),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//       ),
//     );
//   }
// }

// /// Example usage in freelancer detail widget:
// ///
// /// DirectionTrackingButton(
// ///   freelancer: freelancerModel,
// ///   userLatitude: currentUserLat,
// ///   userLongitude: currentUserLng,
// /// ),
