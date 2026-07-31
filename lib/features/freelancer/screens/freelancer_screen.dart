import 'dart:ui' as ui;

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_restaurant/features/direction/domain/models/direction_models.dart';
import 'package:flutter_restaurant/features/direction/providers/direction_provider.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/features/freelancer/providers/freelancer_provider.dart';
import 'package:flutter_restaurant/features/freelancer/widgets/freelancer_detail_dialog_widget.dart';
import 'package:flutter_restaurant/features/home_screen/provider/home_provider.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class FreelancerScreen extends StatefulWidget {
  final FreelancerModel? autoTrackFreelancer;

  const FreelancerScreen({super.key, this.autoTrackFreelancer});

  @override
  State<FreelancerScreen> createState() => _FreelancerScreenState();

  static Future<void> loadData(bool reload, {bool isFcmUpdate = false}) async {}
}

class _FreelancerScreenState extends State<FreelancerScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  LatLng bahrainCountryLatLong = const LatLng(30.81029000, 73.45155000);

  final FreelancerProvider freelancerProvider =
      Provider.of<FreelancerProvider>(Get.context!, listen: false);
  final HomeProvider homeProvider =
      Provider.of<HomeProvider>(Get.context!, listen: false);
  final ProfileProvider profileProvider =
      Provider.of<ProfileProvider>(Get.context!, listen: false);

  List<String> categories = [];

  List<Marker> freelancerMarker = [];
  GoogleMapController? googleMapController;
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  final TextEditingController _searchController = TextEditingController();
  String selectedFilterChip = 'All';
  final Set<String> _searchVocabulary = <String>{};
  List<String> _querySuggestions = <String>[];
  bool _isSearching = false;
  FreelancerModel? _activeDirectionFreelancer;
  LatLng? _trackingStartLocation;
  bool _trackingBoundsFitted = false;
  bool _arrivalDialogVisible = false;
  bool _directionCompleted = false;
  BitmapDescriptor? _currentLocationMarkerIcon;
  bool _isFreelancerDetailsSheetOpen = false;
  LatLng? _currentUserLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _initializeFreelancerData();
      profileProvider.getUserInfo(true);
    });
  }

  Future<void> _initializeFreelancerData() async {
    await Future.wait([
      freelancerProvider.getFreelancerList(),
      homeProvider.freelanceAllCategory(),
    ]);

    if (!mounted) return;

    _syncCategoriesFromFreelancers();
    await _loadFreelancerMarkers();

    // Don't block marker rendering on the location permission/GPS fetch.
    _loadCurrentUserLocation();

    if (!mounted) return;
    if (widget.autoTrackFreelancer != null) {
      await _autoStartDirectionTracking(widget.autoTrackFreelancer!);
    }
  }

  /// Fetches the user's current location and drops a marker for it on the
  /// map. Runs every time the freelancer screen is (re)initialized.
  Future<void> _loadCurrentUserLocation() async {
    final Position? position = await _getCurrentPosition(showFeedback: false);
    if (position == null || !mounted) {
      return;
    }

    final LatLng userLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentUserLocation = userLatLng;
    });

    // Only auto-recenter the camera if we're not already focused on an
    // active direction-tracking route.
    if (googleMapController != null && _activeDirectionFreelancer == null) {
      await googleMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 14),
      );
    }
  }

  /// Called when we navigate into this screen already knowing which
  /// freelancer to track (e.g. tapping "Direction" from the chat screen).
  /// Fetches the latest freelancer details and starts tracking directly,
  /// without reopening the details bottomsheet.
  Future<void> _autoStartDirectionTracking(FreelancerModel freelancer) async {
    await freelancerProvider.getFreelancerDetails(
      freelancer.id.toString(),
      isApiCheck: false,
    );

    if (!mounted) return;
    final selectedFreelancer = freelancerProvider.freelancerDetails;

    if (selectedFreelancer == null ||
        selectedFreelancer.id == null ||
        selectedFreelancer.id == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load freelancer details')),
      );
      return;
    }

    freelancerProvider.setSelectedFreelancer(freelancer: selectedFreelancer);

    if (!mounted) return;
    await _startDirectionTracking(selectedFreelancer);
  }

  Future<void> _openFreelancerDetailsSheet(FreelancerModel freelancer) async {
    if (_isFreelancerDetailsSheetOpen) {
      return;
    }

    if (!mounted) return;

    await freelancerProvider.getFreelancerDetails(
      freelancer.id.toString(),
      isApiCheck: false,
    );

    if (!mounted) return;
    final selectedFreelancer = freelancerProvider.freelancerDetails;

    if (selectedFreelancer == null ||
        selectedFreelancer.id == null ||
        selectedFreelancer.id == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load freelancer details')),
      );
      return;
    }

    freelancerProvider.setSelectedFreelancer(freelancer: selectedFreelancer);

    setState(() {
      _isFreelancerDetailsSheetOpen = true;
    });

    try {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).canvasColor,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => FractionallySizedBox(
          heightFactor: 0.85,
          child: FreelancerDetailsBottomSheet(
            freelancer: selectedFreelancer,
            onDirectionTap: () => _startDirectionTracking(selectedFreelancer),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFreelancerDetailsSheetOpen = false;
        });
      } else {
        _isFreelancerDetailsSheetOpen = false;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    googleMapController?.dispose();
    _customInfoWindowController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocationMarkerIcon() async {
    if (_currentLocationMarkerIcon != null) {
      return;
    }

    _currentLocationMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(32, 32)),
      Images.currentLocationMarker,
    );
  }

  Future<void> _loadFreelancerMarkers() async {
    freelancerMarker.clear();
    final freelancers = freelancerProvider.freelancerList ?? [];

    // Create markers with default icons instantly
    for (var freelancer in freelancers) {
      final isAvailable =
          freelancer.current_status?.toString().toLowerCase() == 'available';
      final marker = Marker(
        markerId: MarkerId(freelancer.id.toString()),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isAvailable ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        position: LatLng(
          double.parse(freelancer.latitude.toString()),
          double.parse(freelancer.longitude.toString()),
        ),
        infoWindow: InfoWindow(
          title: freelancer.name,
          snippet: freelancer.category_name,
        ),
        onTap: () async {
          await _openFreelancerDetailsSheet(freelancer);
        },
      );

      freelancerMarker.add(marker);
    }

    if (mounted) setState(() {});

    // Load custom bordered icons in parallel in background
    _loadCustomMarkerIconsInBackground(freelancers);
  }

  Future<void> _loadCustomMarkerIconsInBackground(
      List<FreelancerModel> freelancers) async {
    try {
      // Load all icons in parallel
      final iconFutures = freelancers.map((freelancer) {
        return freelancerProvider
            .createBorderedMarkerFromUrl(
              freelancer.image.toString(),
              currentStatus: freelancer.current_status?.toString() ?? '',
            )
            .then((icon) => MapEntry(freelancer.id.toString(), icon));
      }).toList();

      final iconResults = await Future.wait(iconFutures);
      if (!mounted) return;

      // Update markers with custom icons
      final iconMap = Map<String, BitmapDescriptor>.fromEntries(iconResults);
      final updatedMarkers = <Marker>[];

      for (var marker in freelancerMarker) {
        final customIcon = iconMap[marker.markerId.value];
        if (customIcon != null) {
          updatedMarkers.add(
            marker.copyWith(iconParam: customIcon),
          );
        } else {
          updatedMarkers.add(marker);
        }
      }

      if (mounted) {
        setState(() {
          freelancerMarker = updatedMarkers;
        });
      }
    } catch (e) {
      debugPrint('Error loading custom marker icons: $e');
    }
  }

  void _syncCategoriesFromFreelancers() {
    final categoryNames = <String>{};
    final freelancerNames = <String>{};

    for (final item in homeProvider.allFreelancers) {
      final categoryName = item.categoryName?.trim() ?? '';
      final freelancerName = item.name?.trim() ?? '';

      if (categoryName.isNotEmpty) {
        categoryNames.add(categoryName);
      }
      if (freelancerName.isNotEmpty) {
        freelancerNames.add(freelancerName);
      }
    }

    for (final freelancer in freelancerProvider.freelancerList ?? []) {
      final categoryName = freelancer.category_name?.trim() ?? '';
      final freelancerName = freelancer.name?.trim() ?? '';

      if (categoryName.isNotEmpty) {
        categoryNames.add(categoryName);
      }
      if (freelancerName.isNotEmpty) {
        freelancerNames.add(freelancerName);
      }
    }

    _searchVocabulary.clear();
    _searchVocabulary.addAll(categoryNames);
    _searchVocabulary.addAll(freelancerNames);

    final updatedCategories = categoryNames.toList()..sort();

    if (updatedCategories.join('|') != categories.join('|')) {
      categories = updatedCategories;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _onFilterChipSelected(String label) async {
    setState(() {
      selectedFilterChip = label;
    });

    if (label == 'All') {
      await freelancerProvider.getFreelancerList();
    } else {
      await freelancerProvider.getFreelancerList(categoryName: label);
    }

    if (!mounted) {
      return;
    }

    _syncCategoriesFromFreelancers();
    await _loadFreelancerMarkers();
  }

  Future<void> _applySearchResultsOnMap({String? query}) async {
    if (!mounted) return;
    _syncCategoriesFromFreelancers();
    await _loadFreelancerMarkers();
    await _focusOnFreelancers(query: query);
  }

  Future<void> _performSearch(String rawQuery) async {
    final query = rawQuery.trim();
    if (_isSearching) {
      return;
    }

    // Immediately update UI - hide loading instantly
    setState(() {
      _isSearching = true;
      _querySuggestions = [];
      _searchController.text = query;
      _searchController.selection =
          TextSelection.fromPosition(TextPosition(offset: query.length));
    });

    // Hide loading immediately
    if (mounted) {
      setState(() {
        _isSearching = false;
      });
    }

    // Run heavy operations in background without blocking UI
    try {
      if (query.isEmpty) {
        await freelancerProvider.getFreelancerList();
      } else {
        final results =
            await freelancerProvider.searchFreelancer(context, query);
        freelancerProvider.updateFreelancerList(results);
      }

      if (!mounted) return;
      await _applySearchResultsOnMap(query: query);
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  void _buildSuggestions(String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) {
      if (_querySuggestions.isNotEmpty) {
        setState(() {
          _querySuggestions = <String>[];
        });
      }
      return;
    }

    // Show all matching suggestions, prioritize exact category matches first
    final categoryMatches = <String>{};
    final freelancerMatches = <String>{};

    for (final item in _searchVocabulary) {
      final itemLower = item.toLowerCase();
      if (itemLower.contains(query)) {
        // Check if it's a category name
        if (categories.contains(item)) {
          categoryMatches.add(item);
        } else {
          freelancerMatches.add(item);
        }
      }
    }

    // Combine: categories first, then freelancers
    final allSuggestions = [...categoryMatches, ...freelancerMatches].toList();

    setState(() {
      _querySuggestions = allSuggestions;
    });
  }

  Future<void> _zoomMapBy(double delta) async {
    if (googleMapController == null) {
      return;
    }

    final currentZoom = await googleMapController!.getZoomLevel();
    await googleMapController!
        .animateCamera(CameraUpdate.zoomTo(currentZoom + delta));
  }

  FreelancerModel? _bestMatchedFreelancer(String? query) {
    final freelancers = freelancerProvider.freelancerList;
    if (freelancers == null || freelancers.isEmpty) {
      return null;
    }

    final trimmedQuery = query?.trim().toLowerCase() ?? '';
    if (trimmedQuery.isEmpty) {
      return freelancers.first;
    }

    final exactMatch = freelancers.where((freelancer) {
      final name = freelancer.name?.trim().toLowerCase() ?? '';
      return name == trimmedQuery;
    }).toList();
    if (exactMatch.isNotEmpty) {
      return exactMatch.first;
    }

    final containsMatch = freelancers.where((freelancer) {
      final name = freelancer.name?.trim().toLowerCase() ?? '';
      final category = freelancer.category_name?.trim().toLowerCase() ?? '';
      return name.contains(trimmedQuery) || category.contains(trimmedQuery);
    }).toList();
    if (containsMatch.isNotEmpty) {
      return containsMatch.first;
    }

    return freelancers.first;
  }

  Future<void> _focusOnFreelancers({String? query}) async {
    if (googleMapController == null) {
      return;
    }

    final freelancers = freelancerProvider.freelancerList;
    if (freelancers == null || freelancers.isEmpty) {
      await googleMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(bahrainCountryLatLong, 11),
      );
      return;
    }

    final targetFreelancer = _bestMatchedFreelancer(query) ?? freelancers.first;
    final latitude = double.tryParse(targetFreelancer.latitude.toString());
    final longitude = double.tryParse(targetFreelancer.longitude.toString());

    if (latitude == null || longitude == null) {
      await googleMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(bahrainCountryLatLong, 11),
      );
      return;
    }

    await googleMapController!.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 13),
    );
  }

  Future<Position?> _getCurrentPosition({bool showFeedback = true}) async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      if (mounted && showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location service')),
        );
      }
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted && showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required for directions'),
          ),
        );
      }
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 12),
    );
  }

  Future<void> _clearDirectionTracking({bool resetProvider = true}) async {
    if (resetProvider) {
      Provider.of<DirectionProvider>(context, listen: false).resetTracking();
    }

    if (!mounted) return;
    setState(() {
      _activeDirectionFreelancer = null;
      _trackingStartLocation = null;
      _trackingBoundsFitted = false;
      _arrivalDialogVisible = false;
      _directionCompleted = false;
    });

    await _loadFreelancerMarkers();
  }

  Future<void> _startDirectionTracking(FreelancerModel freelancer) async {
    final double? destinationLat = freelancer.latitude;
    final double? destinationLng = freelancer.longitude;

    if (destinationLat == null || destinationLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Freelancer location is not available')),
      );
      return;
    }

    final Position? position = await _getCurrentPosition(showFeedback: true);
    if (position == null) {
      return;
    }

    final directionProvider =
        Provider.of<DirectionProvider>(context, listen: false);
    directionProvider.resetTracking();

    if (!mounted) return;
    setState(() {
      _activeDirectionFreelancer = freelancer;
      _trackingStartLocation = LatLng(position.latitude, position.longitude);
      _trackingBoundsFitted = false;
      _arrivalDialogVisible = false;
      _directionCompleted = false;
    });

    final success = await directionProvider.startTracking(
      LatLng(position.latitude, position.longitude),
      LatLng(destinationLat, destinationLng),
      autoStartLocationStream: true,
      onDestinationReached: () => _handleDestinationReached(freelancer),
    );

    if (!mounted) return;
    if (!success) {
      await _clearDirectionTracking(resetProvider: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(directionProvider.errorMessage ??
              'Failed to start direction tracking'),
        ),
      );
      return;
    }

    if (googleMapController != null) {
      await _fitTrackingRouteBounds();
    }
  }

  Future<void> _handleDestinationReached(FreelancerModel freelancer) async {
    if (!mounted || _arrivalDialogVisible) {
      return;
    }

    setState(() {
      _directionCompleted = true;
      _arrivalDialogVisible = true;
    });

    await _showArrivalLocalNotification(freelancer);

    if (!mounted) return;
    await _showArrivalDialog(freelancer);
  }

  Future<void> _showArrivalLocalNotification(FreelancerModel freelancer) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      2001,
      '${freelancer.name ?? 'Freelancer'} arrived',
      'You have reached the destination.',
      notificationDetails,
    );
  }

  Future<void> _showArrivalDialog(FreelancerModel freelancer) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF111827)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00A884).withValues(alpha: 0.95),
                        const Color(0xFF4ADE80).withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'You have arrived',
                  textAlign: TextAlign.center,
                  style: rubikSemiBold.copyWith(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${freelancer.name ?? 'Freelancer'} is at the destination.',
                  textAlign: TextAlign.center,
                  style: rubikRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A884),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Nice'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Marker for the user's current location, shown when direction tracking
  /// isn't active (tracking already shows a live-updating current location
  /// marker via [_buildTrackingMarkers]).
  Set<Marker> _buildCurrentUserLocationMarker() {
    if (_activeDirectionFreelancer != null || _currentUserLocation == null) {
      return {};
    }

    return {
      Marker(
        markerId: const MarkerId('current_user_location'),
        position: _currentUserLocation!,
        infoWindow: const InfoWindow(title: 'Your location'),
        icon: _currentLocationMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.5),
        flat: true,
      ),
    };
  }

  Set<Marker> _buildTrackingMarkers(DirectionProvider directionProvider) {
    final markers = <Marker>{};

    if (_activeDirectionFreelancer == null) {
      return markers;
    }

    final destination = LatLng(
      _activeDirectionFreelancer!.latitude ?? 0,
      _activeDirectionFreelancer!.longitude ?? 0,
    );

    final currentLocation =
        directionProvider.currentLocation?.latLng ?? _trackingStartLocation;
    final currentHeading =
        directionProvider.currentLocation?.position.heading ?? 0;

    markers.add(
      Marker(
        markerId: const MarkerId('direction_destination'),
        position: destination,
        infoWindow: InfoWindow(
          title: _activeDirectionFreelancer!.name ?? 'Freelancer',
          snippet: _directionCompleted ? 'Arrived' : 'Destination',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _directionCompleted
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
      ),
    );

    if (currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('direction_current'),
          position: currentLocation,
          infoWindow: const InfoWindow(title: 'Live location'),
          icon: _currentLocationMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          flat: true,
          anchor: const Offset(0.5, 0.5),
          rotation: currentHeading,
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildTrackingPolylines(DirectionProvider directionProvider) {
    final polylines = <Polyline>{};

    if (_activeDirectionFreelancer == null ||
        directionProvider.polylineData == null) {
      return polylines;
    }

    final polylineData = directionProvider.polylineData!;
    final routeColor =
        _directionCompleted ? const Color(0xFF4ADE80) : const Color(0xFF00A884);

    polylines.add(
      Polyline(
        polylineId: const PolylineId('route_backdrop'),
        points: polylineData.points,
        color: Colors.black.withValues(alpha: 0.12),
        width: 12,
        geodesic: true,
      ),
    );

    polylines.add(
      Polyline(
        polylineId: const PolylineId('route_main'),
        points: polylineData.points,
        color: routeColor,
        width: 7,
        geodesic: true,
        zIndex: 1,
      ),
    );

    if (polylineData.traveledDistance > 0 && polylineData.points.isNotEmpty) {
      final traveledPoints = _calculateTraveledPoints(
        polylineData.points,
        polylineData.traveledDistance,
        polylineData.totalDistance,
      );

      if (traveledPoints.isNotEmpty) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route_traveled'),
            points: traveledPoints,
            color: Colors.white.withValues(alpha: 0.88),
            width: 5,
            geodesic: true,
            zIndex: 2,
          ),
        );
      }
    }

    return polylines;
  }

  List<LatLng> _calculateTraveledPoints(
    List<LatLng> routePoints,
    double traveledDistance,
    double totalDistance,
  ) {
    if (routePoints.isEmpty || traveledDistance <= 0 || totalDistance <= 0) {
      return [];
    }

    final progressRatio = (traveledDistance / totalDistance).clamp(0, 1);
    final pointCount = (routePoints.length * progressRatio).toInt();
    return routePoints.sublist(0, pointCount.clamp(1, routePoints.length));
  }

  Future<void> _fitTrackingRouteBounds() async {
    if (googleMapController == null ||
        _trackingStartLocation == null ||
        _activeDirectionFreelancer == null) {
      return;
    }

    final destination = LatLng(
      _activeDirectionFreelancer!.latitude ?? 0,
      _activeDirectionFreelancer!.longitude ?? 0,
    );

    try {
      final southWest = LatLng(
        _trackingStartLocation!.latitude < destination.latitude
            ? _trackingStartLocation!.latitude
            : destination.latitude,
        _trackingStartLocation!.longitude < destination.longitude
            ? _trackingStartLocation!.longitude
            : destination.longitude,
      );
      final northEast = LatLng(
        _trackingStartLocation!.latitude > destination.latitude
            ? _trackingStartLocation!.latitude
            : destination.latitude,
        _trackingStartLocation!.longitude > destination.longitude
            ? _trackingStartLocation!.longitude
            : destination.longitude,
      );

      await googleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: southWest, northeast: northEast),
          120,
        ),
      );

      if (mounted) {
        setState(() {
          _trackingBoundsFitted = true;
        });
      }
    } catch (_) {
      // ignore fit errors for very short routes
    }
  }

  Widget _buildTrackingSummaryCard(DirectionProvider directionProvider) {
    final freelancer = _activeDirectionFreelancer;
    if (freelancer == null) {
      return const SizedBox.shrink();
    }

    final polylineData = directionProvider.polylineData;
    final remainingKm = directionProvider.distanceRemaining / 1000;
    final eta = directionProvider.etaMinutes;
    final progress = directionProvider.progressPercentage / 100;

    final statusLabel = _directionCompleted
        ? 'Arrived'
        : directionProvider.trackingStatus == TrackingStatus.active
            ? 'Live tracking'
            : 'Tracking paused';

    return Positioned(
      left: Dimensions.paddingSizeDefault,
      right: Dimensions.paddingSizeDefault,
      bottom: MediaQuery.paddingOf(context).bottom - 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0F172A).withValues(alpha: 0.9),
                  const Color(0xFF111827).withValues(alpha: 0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            freelancer.name ?? 'Freelancer',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: rubikSemiBold.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            freelancer.category_name ?? 'Live route preview',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: rubikRegular.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A884).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFF00A884).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        statusLabel,
                        style: rubikMedium.copyWith(
                          color: const Color(0xFF7CFFCB),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _clearDirectionTracking,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (polylineData != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.09),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00E6A8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _trackingStatTile(
                          title: 'Remaining',
                          value: '${remainingKm.toStringAsFixed(1)} km',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _trackingStatTile(
                          title: 'ETA',
                          value: eta > 0 ? '$eta min' : '--',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _trackingStatTile(
                          title: 'Route',
                          value: '${(progress * 100).toStringAsFixed(0)}%',
                        ),
                      ),
                    ],
                  ),
                ] else
                  Text(
                    'Preparing route...',
                    style: rubikRegular.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _trackingStatTile({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: rubikRegular.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: rubikSemiBold.copyWith(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Consumer<DirectionProvider>(
        builder: (context, directionProvider, child) {
          if (_currentLocationMarkerIcon == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadCurrentLocationMarkerIcon();
            });
          }

          final combinedMarkers = <Marker>{
            ...freelancerMarker,
            ..._buildTrackingMarkers(directionProvider),
            ..._buildCurrentUserLocationMarker(),
          };
          final polylines = _buildTrackingPolylines(directionProvider);

          if (_activeDirectionFreelancer != null &&
              !_trackingBoundsFitted &&
              googleMapController != null &&
              directionProvider.polylineData != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_trackingBoundsFitted) {
                _fitTrackingRouteBounds();
              }
            });
          }

          return Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: bahrainCountryLatLong,
                  zoom: 11,
                ),
                padding: const EdgeInsets.only(
                  top: 170,
                  right: Dimensions.paddingSizeOverLarge,
                  bottom: 170,
                ),
                markers: combinedMarkers,
                polylines: polylines,
                onMapCreated: (controller) {
                  googleMapController = controller;
                  _customInfoWindowController.googleMapController = controller;
                  if (_activeDirectionFreelancer != null &&
                      directionProvider.polylineData != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && !_trackingBoundsFitted) {
                        _fitTrackingRouteBounds();
                      }
                    });
                  } else if (_currentUserLocation != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _activeDirectionFreelancer == null) {
                        googleMapController!.animateCamera(
                          CameraUpdate.newLatLngZoom(_currentUserLocation!, 14),
                        );
                      }
                    });
                  }
                },
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                buildingsEnabled: true,
                onTap: (_) =>
                    _customInfoWindowController.hideInfoWindow?.call(),
                onCameraMove: (_) =>
                    _customInfoWindowController.onCameraMove?.call(),
              ),
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.12),
                      ],
                    ),
                  ),
                ),
              ),
              CustomInfoWindow(
                controller: _customInfoWindowController,
                height: 100,
                width: 250,
                offset: 16,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(
                                Dimensions.radiusExtraLarge),
                            color: Theme.of(context).cardColor,
                            child: TextField(
                              controller: _searchController,
                              textAlign: TextAlign.start,
                              textAlignVertical: TextAlignVertical.center,
                              textInputAction: TextInputAction.search,
                              onSubmitted: _performSearch,
                              onChanged: (value) {
                                _buildSuggestions(value);
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                hintText:
                                    'Search workers, categories, location',
                                hintStyle: rubikRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).hintColor,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                  vertical: Dimensions.paddingSizeSmall,
                                ),
                                border: InputBorder.none,
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_isSearching)
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      )
                                    else
                                      IconButton(
                                        onPressed: () => _performSearch(
                                            _searchController.text),
                                        icon: const Icon(Icons.search),
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    if (_searchController.text
                                        .trim()
                                        .isNotEmpty)
                                      IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          _buildSuggestions('');
                                          _performSearch('');
                                        },
                                        icon: const Icon(Icons.clear),
                                        color: Theme.of(context).primaryColor,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length + 1,
                              separatorBuilder: (_, __) => const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              itemBuilder: (context, index) {
                                final label =
                                    index == 0 ? 'All' : categories[index - 1];
                                final isSelected = selectedFilterChip == label;
                                return ChoiceChip(
                                  label: Text(
                                    label,
                                    style: rubikMedium.copyWith(
                                      fontSize: 11,
                                      color: isSelected
                                          ? Theme.of(context).cardColor
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (_) =>
                                      _onFilterChipSelected(label),
                                  selectedColor: Theme.of(context).primaryColor,
                                  backgroundColor: Theme.of(context).cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusLarge,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_querySuggestions.isNotEmpty)
                        Positioned(
                          top: 48,
                          left: 0,
                          right: 0,
                          child: Material(
                            elevation: 8,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusLarge),
                            color: Theme.of(context).cardColor,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 240,
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: _querySuggestions.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                ),
                                itemBuilder: (context, index) {
                                  final suggestion = _querySuggestions[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      suggestion,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () async {
                                      _searchController.text = suggestion;
                                      _searchController.selection =
                                          TextSelection.fromPosition(
                                        TextPosition(offset: suggestion.length),
                                      );
                                      await _performSearch(suggestion);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: Dimensions.paddingSizeDefault,
                bottom: 190,
                child: Column(
                  children: [
                    Material(
                      elevation: 3,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusLarge),
                      color: Theme.of(context).cardColor,
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusLarge),
                        onTap:
                            // _focusOnFreelancers,
                            _loadCurrentUserLocation,
                        child: const Padding(
                          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Icon(Icons.my_location),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Material(
                      elevation: 3,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusLarge),
                      color: Theme.of(context).cardColor,
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15)),
                            onTap: () => _zoomMapBy(1),
                            child: const Padding(
                              padding:
                                  EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Icon(Icons.add),
                            ),
                          ),
                          Container(
                            height: 1,
                            width: 40,
                            color: Theme.of(context).dividerColor,
                          ),
                          InkWell(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(15)),
                            onTap: () => _zoomMapBy(-1),
                            child: const Padding(
                              padding:
                                  EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Icon(Icons.remove),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_activeDirectionFreelancer != null)
                _buildTrackingSummaryCard(directionProvider),
            ],
          );
        },
      ),
    );
  }
}
