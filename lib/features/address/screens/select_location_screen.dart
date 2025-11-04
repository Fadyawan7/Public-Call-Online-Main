import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/common/widgets/custom_button_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../widgets/permission_dialog_widget.dart';

class SelectLocationScreen extends StatefulWidget {
  final GoogleMapController? googleMapController;
  const SelectLocationScreen({super.key, this.googleMapController});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  GoogleMapController? _controller;
  final TextEditingController _locationController = TextEditingController();
  late LatLng _initialPosition;
  LatLng? _markerPosition;
  CameraPosition? _cameraPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    // Set initial position
    _initialPosition = (locationProvider.pickedAddressLatitude != null &&
            locationProvider.pickedAddressLongitude != null)
        ? LatLng(
            double.parse(locationProvider.pickedAddressLatitude!),
            double.parse(locationProvider.pickedAddressLongitude!),
          )
        : LatLng(locationProvider.position.latitude,
            locationProvider.position.longitude);

    _markerPosition = _initialPosition;
    _cameraPosition = CameraPosition(target: _initialPosition, zoom: 16);
    _addMarker(_markerPosition!);
  }

  void _addMarker(LatLng position) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('draggableMarker'),
        position: position,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _markerPosition = newPosition;
          });
          Provider.of<LocationProvider>(context, listen: false).updatePosition(
            CameraPosition(target: newPosition, zoom: 16),
            false,
            null,
            context,
            false,
          );
        },
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
  }

  void _checkPermission(Function callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PermissionDialogWidget(),
      );
    } else {
      callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final locationProvider = Provider.of<LocationProvider>(context);

    if (locationProvider.address != null) {
      _locationController.text = locationProvider.address!;
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(getTranslated('select_delivery_address', context)!),
      ),
      body: SingleChildScrollView(
        physics: ResponsiveHelper.isDesktop(context)
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: SizedBox(
          width: Dimensions.webScreenWidth,
          height: height * 0.9,
          child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _cameraPosition!,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                compassEnabled: false,
                indoorViewEnabled: true,
                mapToolbarEnabled: true,
                markers: _markers,
                onMapCreated: (controller) {
                  _controller = controller;
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _controller!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _markerPosition ?? _initialPosition,
                          zoom: 16,
                        ),
                      ),
                    );
                  });
                },
                onCameraMove: (position) {
                  _cameraPosition = position;
                  _markerPosition = position.target;
                },
                onCameraIdle: () {
                  locationProvider.updatePosition(
                      _cameraPosition, false, null, context, false);
                },
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => _checkPermission(() {
                        locationProvider.getCurrentLocation(context, true,
                            mapController: _controller);
                      }),
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(
                            right: Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeSmall),
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: Theme.of(context).primaryColor,
                          size: 35,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Center(
                        child: SizedBox(
                          width:
                              ResponsiveHelper.isDesktop(context) ? 450 : 1170,
                          child: Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeLarge),
                            child: CustomButtonWidget(
                              btnTxt: "Select Location",
                              onTap: () async {
                                final selectedPosition = _markerPosition!;
                                print(
                                    "selectedPosition.......$selectedPosition");

                                final formattedAddress = await locationProvider
                                    .getAddressFromGeocode(
                                  LatLng(selectedPosition.latitude,
                                      selectedPosition.longitude),
                                );

                                print(
                                    "formattedAddress.......$formattedAddress");

                                // ✅ Set latitude & longitude
                                locationProvider.setPickedAddressLatLon(
                                  selectedPosition.latitude.toString(),
                                  selectedPosition.longitude.toString(),
                                );

                                // ✅ Update address properly (and trigger UI refresh)
                                locationProvider.setAddress = formattedAddress;

                                // ✅ Notify other pick data
                                locationProvider.setPickData();

                                print("Address set successfully ✅");

                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (locationProvider.loading)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
