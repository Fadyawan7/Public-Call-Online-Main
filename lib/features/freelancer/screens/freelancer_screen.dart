import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_dialog_widget.dart';
import 'package:flutter_restaurant/common/widgets/filter_button_widget.dart';
import 'package:flutter_restaurant/features/address/widgets/freelancer_search_dialog_widget.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/features/freelancer/providers/freelancer_provider.dart';
import 'package:flutter_restaurant/features/freelancer/widgets/category_filter.dart';
import 'package:flutter_restaurant/features/freelancer/widgets/freelancer_detail_dialog_widget.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class FreelancerScreen extends StatefulWidget {
  const FreelancerScreen({super.key});

  @override
  State<FreelancerScreen> createState() => _FreelancerScreenState();

  static Future<void> loadData(bool reload, {bool isFcmUpdate = false}) async {}
}

class _FreelancerScreenState extends State<FreelancerScreen>
    with TickerProviderStateMixin {
  LatLng bahrainCountryLatLong = const LatLng(30.81029000, 73.45155000);

  final FreelancerProvider freelancerProvider =
      Provider.of<FreelancerProvider>(Get.context!, listen: false);
  final ProfileProvider profileProvider =
      Provider.of<ProfileProvider>(Get.context!, listen: false);

  final List<String> categories = [
    'Technology',
    'Design',
    'Marketing',
    'Finance',
    'Health'
  ];

  List<Marker> freelancerMarker = [];
  GoogleMapController? googleMapController;
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  BitmapDescriptor availableIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor busyIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor selectedIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    freelancerProvider.getFreelancerList().then((_) async {
      if (!mounted) return;
      await _loadFreelancerMarkers();
    });
    profileProvider.getUserInfo(true);
  }

  @override
  void dispose() {
    googleMapController?.dispose();
    _customInfoWindowController.dispose();
    super.dispose();
  }

  Future<void> _loadFreelancerMarkers() async {
    freelancerMarker.clear();
    final freelancers = freelancerProvider.freelancerList ?? [];

    for (var freelancer in freelancers) {
      final icon = await freelancerProvider.createBorderedMarkerFromUrl(
        freelancer.image.toString(),
        currentStatus: freelancer.current_status?.toString() ?? '',
      );

      final marker = Marker(
        markerId: MarkerId(freelancer.id.toString()),
        icon: icon,
        position: LatLng(
          double.parse(freelancer.latitude.toString()),
          double.parse(freelancer.longitude.toString()),
        ),
        infoWindow: InfoWindow(
          title: freelancer.name,
          snippet: freelancer.category_name,
        ),
        onTap: () async {
          freelancerProvider.setSelectedFreelancer(freelancer: freelancer);
          if (!mounted) return;

          await showModalBottomSheet(
            context: context,
            backgroundColor: Theme.of(context).canvasColor,
            isScrollControlled: true,
            builder: (_) =>
                FreelancerDetailsBottomSheet(freelancer: freelancer),
          );
        },
      );

      freelancerMarker.add(marker);
    }

    if (mounted) setState(() {});
  }

  void _openSearchDialog(
      BuildContext context, GoogleMapController? mapController) {
    showDialog(
      context: context,
      builder: (context) =>
          FreelancerSearchDialogWidget(mapController: mapController),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        isBackButtonExist: false,
        titleColor: Colors.white,
        context: context,
        title: getTranslated('Easy Business\nEvery Business', context),
        actionView: IconButton(
          icon: const Icon(
            Iconsax.add_circle,
            color: Colors.white,
            size: Dimensions.fontSizeDefault * 2,
          ),
          onPressed: () {
            if (profileProvider.isFreelancer!) {
              RouterHelper.getFreelancerPortfolioListRoute();
            } else {
              RouterHelper.getApplyFreelancerRoute();
            }
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: bahrainCountryLatLong,
              zoom: 11,
            ),
            markers: freelancerMarker.toSet(),
            onMapCreated: (controller) {
              googleMapController = controller;
              _customInfoWindowController.googleMapController = controller;
            },
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            myLocationButtonEnabled: false,
            onTap: (_) => _customInfoWindowController.hideInfoWindow?.call(),
            onCameraMove: (_) =>
                _customInfoWindowController.onCameraMove?.call(),
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 100,
            width: 250,
            offset: 16,
          ),
          InkWell(
            onTap: () => _openSearchDialog(context, googleMapController),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge, vertical: 18.0),
              margin: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge, vertical: 23.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    BorderRadius.circular(Dimensions.paddingSizeSmall),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'search worker...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: rubikRegular.copyWith(
                        fontSize: Dimensions.paddingSizeDefault,
                      ),
                    ),
                  ),
                  const Icon(Icons.search, size: 25),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  FilterButton(
                    categories: categories,
                    initiallySelected: ['Tech', 'Design'],
                    onFilterApplied: (selected) {
                      // Handle selected categories
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
