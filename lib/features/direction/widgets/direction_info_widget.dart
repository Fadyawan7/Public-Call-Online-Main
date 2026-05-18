// import 'package:flutter/material.dart';
// import 'package:flutter_restaurant/features/direction/domain/models/direction_models.dart';
// import 'package:flutter_restaurant/utill/dimensions.dart';
// import 'package:iconsax/iconsax.dart';

// class DirectionInfoWidget extends StatelessWidget {
//   final PolylineData? polylineData;
//   final bool isLoading;

//   const DirectionInfoWidget({
//     Key? key,
//     required this.polylineData,
//     this.isLoading = false,
//   }) : super(key: key);

//   String _formatDistance(double meters) {
//     if (meters < 1000) {
//       return '${meters.toStringAsFixed(0)} m';
//     }
//     return '${(meters / 1000).toStringAsFixed(2)} km';
//   }

//   String _formatDuration(int minutes) {
//     if (minutes < 60) {
//       return '$minutes min';
//     }
//     final hours = minutes ~/ 60;
//     final mins = minutes % 60;
//     return '${hours}h ${mins}m';
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading || polylineData == null) {
//       return Container(
//         margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//         padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             SizedBox(
//               height: 60,
//               child: Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: Dimensions.paddingSizeSmall),
//             Text(
//               'Initializing direction...',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           ],
//         ),
//       );
//     }

//     return Container(
//       margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//       padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Progress bar
//           ClipRRect(
//             borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//             child: LinearProgressIndicator(
//               value: polylineData!.progressPercentage / 100,
//               minHeight: 6,
//               backgroundColor: Colors.grey[300],
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 Theme.of(context).primaryColor,
//               ),
//             ),
//           ),
//           const SizedBox(height: Dimensions.paddingSizeDefault),

//           // Distance info
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Distance Remaining',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//                   Text(
//                     _formatDistance(polylineData!.remainingDistance),
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           color: Theme.of(context).primaryColor,
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     'ETA',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//                   Text(
//                     _formatDuration(polylineData!.estimatedDurationMinutes),
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           color: Theme.of(context).primaryColor,
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: Dimensions.paddingSizeDefault),

//           // Distance details
//           Container(
//             padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.social_distance,
//                       size: 16,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     const SizedBox(width: Dimensions.paddingSizeSmall),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Total Distance',
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                         Text(
//                           _formatDistance(polylineData!.totalDistance),
//                           style: Theme.of(context)
//                               .textTheme
//                               .bodyMedium
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.directions,
//                       size: 16,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     const SizedBox(width: Dimensions.paddingSizeSmall),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Traveled',
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                         Text(
//                           _formatDistance(polylineData!.traveledDistance),
//                           style: Theme.of(context)
//                               .textTheme
//                               .bodyMedium
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DirectionStatusWidget extends StatelessWidget {
//   final TrackingStatus status;
//   final String? errorMessage;

//   const DirectionStatusWidget({
//     Key? key,
//     required this.status,
//     this.errorMessage,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (status == TrackingStatus.idle) {
//       return const SizedBox.shrink();
//     }

//     Color statusColor;
//     IconData statusIcon;
//     String statusText;

//     switch (status) {
//       case TrackingStatus.active:
//         statusColor = Colors.green;
//         statusIcon = Iconsax.location;
//         statusText = 'Tracking Active';
//         break;
//       case TrackingStatus.paused:
//         statusColor = Colors.orange;
//         statusIcon = Iconsax.pause;
//         statusText = 'Tracking Paused';
//         break;
//       case TrackingStatus.stopped:
//         statusColor = Colors.grey;
//         statusIcon = Iconsax.stop_circle;
//         statusText = 'Tracking Stopped';
//         break;
//       case TrackingStatus.error:
//         statusColor = Colors.red;
//         statusIcon = Iconsax.warning_2;
//         statusText = 'Tracking Error';
//         break;
//       default:
//         statusColor = Colors.grey;
//         statusIcon = Icons.info;
//         statusText = 'Unknown Status';
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(
//         horizontal: Dimensions.paddingSizeDefault,
//         vertical: Dimensions.paddingSizeSmall,
//       ),
//       padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//       decoration: BoxDecoration(
//         color: statusColor.withOpacity(0.1),
//         border: Border.all(color: statusColor.withOpacity(0.3)),
//         borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             statusIcon,
//             color: statusColor,
//             size: 18,
//           ),
//           const SizedBox(width: Dimensions.paddingSizeSmall),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   statusText,
//                   style: TextStyle(
//                     color: statusColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//                 if (errorMessage != null) ...[
//                   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//                   Text(
//                     errorMessage!,
//                     style: TextStyle(
//                       color: statusColor,
//                       fontSize: 12,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DirectionControlsWidget extends StatelessWidget {
//   final VoidCallback onPause;
//   final VoidCallback onResume;
//   final VoidCallback onStop;
//   final TrackingStatus status;
//   final bool isLoading;

//   const DirectionControlsWidget({
//     Key? key,
//     required this.onPause,
//     required this.onResume,
//     required this.onStop,
//     required this.status,
//     this.isLoading = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//       child: Row(
//         children: [
//           // Pause/Resume button
//           if (status == TrackingStatus.active)
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: isLoading ? null : onPause,
//                 icon: const Icon(Iconsax.pause),
//                 label: const Text('Pause'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange,
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.grey,
//                   padding: const EdgeInsets.symmetric(
//                       vertical: Dimensions.paddingSizeSmall),
//                 ),
//               ),
//             ),
//           if (status == TrackingStatus.paused)
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: isLoading ? null : onResume,
//                 icon: const Icon(Iconsax.play),
//                 label: const Text('Resume'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.grey,
//                   padding: const EdgeInsets.symmetric(
//                       vertical: Dimensions.paddingSizeSmall),
//                 ),
//               ),
//             ),
//           if (status == TrackingStatus.active ||
//               status == TrackingStatus.paused)
//             const SizedBox(width: Dimensions.paddingSizeSmall),
//           // Stop button
//           if (status == TrackingStatus.active ||
//               status == TrackingStatus.paused)
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: isLoading ? null : onStop,
//                 icon: const Icon(Iconsax.stop_circle),
//                 label: const Text('Stop'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.grey,
//                   padding: const EdgeInsets.symmetric(
//                       vertical: Dimensions.paddingSizeSmall),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class DirectionFreelancerHeaderWidget extends StatelessWidget {
//   final String freelancerName;
//   final String? freelancerImage;
//   final String category;
//   final double rating;
//   final VoidCallback onBack;

//   const DirectionFreelancerHeaderWidget({
//     Key? key,
//     required this.freelancerName,
//     this.freelancerImage,
//     required this.category,
//     required this.rating,
//     required this.onBack,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Back button
//           GestureDetector(
//             onTap: onBack,
//             child: Container(
//               padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//               ),
//               child: Icon(
//                 Iconsax.arrow_left,
//                 color: Theme.of(context).primaryColor,
//                 size: 20,
//               ),
//             ),
//           ),
//           const SizedBox(width: Dimensions.paddingSizeDefault),

//           // Freelancer info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   freelancerName,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//                 Row(
//                   children: [
//                     Text(
//                       category,
//                       style: Theme.of(context).textTheme.bodySmall,
//                     ),
//                     const SizedBox(width: Dimensions.paddingSizeSmall),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Iconsax.star1,
//                           size: 14,
//                           color: Colors.orange,
//                         ),
//                         const SizedBox(width: 2),
//                         Text(
//                           rating.toStringAsFixed(1),
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
