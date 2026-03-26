import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/features/freelancer/providers/freelancer_provider.dart';
import 'package:flutter_restaurant/features/freelancer/widgets/freelancer_detail_dialog_widget.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    freelancerProvider.getFreelancerList().then((_) async {
      if (!mounted) return;
      _syncCategoriesFromFreelancers();
      await _loadFreelancerMarkers();
    });
    profileProvider.getUserInfo(true);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
              const SnackBar(
                  content: Text('Unable to load freelancer details')),
            );
            return;
          }

          freelancerProvider.setSelectedFreelancer(
              freelancer: selectedFreelancer);

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
              ),
            ),
          );
        },
      );

      freelancerMarker.add(marker);
    }

    if (mounted) setState(() {});
  }

  void _syncCategoriesFromFreelancers() {
    final freelancers = freelancerProvider.freelancerList ?? [];
    final uniqueNames = <String>{};

    for (final freelancer in freelancers) {
      final categoryName = freelancer.category_name?.trim() ?? '';
      final freelancerName = freelancer.name?.trim() ?? '';
      if (categoryName.isNotEmpty) {
        uniqueNames.add(categoryName);
        _searchVocabulary.add(categoryName);
      }
      if (freelancerName.isNotEmpty) {
        _searchVocabulary.add(freelancerName);
      }
    }

    final mergedNames = <String>{...categories, ...uniqueNames};
    final updatedCategories = mergedNames.toList()..sort();

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

  Future<void> _applySearchResultsOnMap() async {
    if (!mounted) return;
    _syncCategoriesFromFreelancers();
    await _loadFreelancerMarkers();
    await _focusOnFreelancers();
  }

  Future<void> _performSearch(String rawQuery) async {
    final query = rawQuery.trim();
    if (_isSearching) {
      return;
    }

    setState(() {
      _isSearching = true;
    });

    if (query.isEmpty) {
      await freelancerProvider.getFreelancerList();
    } else {
      final results = await freelancerProvider.searchFreelancer(context, query);
      freelancerProvider.updateFreelancerList(results);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _querySuggestions = [];
      _searchController.text = query;
      _searchController.selection =
          TextSelection.fromPosition(TextPosition(offset: query.length));
    });

    await _applySearchResultsOnMap();

    if (mounted) {
      setState(() {
        _isSearching = false;
      });
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

    final suggestions = _searchVocabulary
        .where((item) => item.toLowerCase().contains(query))
        .take(6)
        .toList();

    setState(() {
      _querySuggestions = suggestions;
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

  Future<void> _focusOnFreelancers() async {
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

    final first = freelancers.first;
    final latitude = double.tryParse(first.latitude.toString());
    final longitude = double.tryParse(first.longitude.toString());

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

  @override
  Widget build(BuildContext context) {
    final int freelancerCount = freelancerProvider.freelancerList?.length ?? 0;

    return Scaffold(
      body: Stack(
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
            markers: freelancerMarker.toSet(),
            onMapCreated: (controller) {
              googleMapController = controller;
              _customInfoWindowController.googleMapController = controller;
            },
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            buildingsEnabled: true,
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                children: [
                  Material(
                    elevation: 4,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusExtraLarge),
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),
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
                          hintText: 'Search workers, categories, location',
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
                                  onPressed: () =>
                                      _performSearch(_searchController.text),
                                  icon: const Icon(Icons.search),
                                  color: Theme.of(context).primaryColor,
                                ),
                              if (_searchController.text.trim().isNotEmpty)
                                IconButton(
                                  onPressed: () async {
                                    _searchController.clear();
                                    _buildSuggestions('');
                                    await _performSearch('');
                                  },
                                  icon: const Icon(Icons.clear),
                                  color: Theme.of(context).primaryColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_querySuggestions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Material(
                        elevation: 4,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusLarge),
                        color: Theme.of(context).cardColor,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                      itemBuilder: (context, index) {
                        final label =
                            index == 0 ? 'All' : categories[index - 1];
                        final isSelected = selectedFilterChip == label;
                        return ChoiceChip(
                          label: Text(
                            label,
                            style: rubikMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: isSelected
                                  ? Theme.of(context).cardColor
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => _onFilterChipSelected(label),
                          selectedColor: Theme.of(context).primaryColor,
                          backgroundColor: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusLarge),
                          ),
                        );
                      },
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
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  color: Theme.of(context).cardColor,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    onTap: _focusOnFreelancers,
                    child: const Padding(
                      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Icon(Icons.my_location),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15)),
                        onTap: () => _zoomMapBy(1),
                        child: const Padding(
                          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
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
                          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Icon(Icons.remove),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            bottom: Dimensions.paddingSizeLarge,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Icon(
                        Icons.people_alt_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$freelancerCount workers nearby',
                            style: rubikSemiBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap marker to view worker profile',
                            style: rubikRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
