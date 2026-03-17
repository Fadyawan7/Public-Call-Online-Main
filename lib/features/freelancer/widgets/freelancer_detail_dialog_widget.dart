import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_outlined_button_widget.dart';
import 'package:flutter_restaurant/common/widgets/list_tile_widget.dart';
import 'package:flutter_restaurant/common/widgets/rate_review_widget.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/chat/providers/chat_provider.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/features/freelancer/widgets/freelancer_basic_widget.dart';
import 'package:flutter_restaurant/features/freelancer/widgets/freelancer_portfolio_widget.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

class FreelancerDetailsBottomSheet extends StatefulWidget {
  final FreelancerModel freelancer;

  const FreelancerDetailsBottomSheet({
    super.key,
    required this.freelancer,
  });

  @override
  State<FreelancerDetailsBottomSheet> createState() =>
      _FreelancerDetailsBottomSheetState();
}

class _FreelancerDetailsBottomSheetState
    extends State<FreelancerDetailsBottomSheet> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1;
  late bool _isLoggedIn;
  double? _distanceKm;
  int? _etaMinutes;
  bool _isDistanceLoading = false;

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
              content: Text('Location permission is required for directions')),
        );
      }
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 12),
    );
  }

  Future<void> _loadDistanceInfo({bool showFeedback = false}) async {
    final double? destinationLat = widget.freelancer.latitude;
    final double? destinationLng = widget.freelancer.longitude;

    if (destinationLat == null || destinationLng == null) {
      return;
    }

    if (mounted) {
      setState(() => _isDistanceLoading = true);
    }

    try {
      final Position? position =
          await _getCurrentPosition(showFeedback: showFeedback);
      if (position == null) {
        return;
      }

      final distanceInMeter = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        destinationLat,
        destinationLng,
      );

      final double distanceKm = distanceInMeter / 1000;
      final int etaMinutes = ((distanceKm / 35) * 60).ceil();

      if (mounted) {
        setState(() {
          _distanceKm = distanceKm;
          _etaMinutes = etaMinutes;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isDistanceLoading = false);
      }
    }
  }

  Future<void> _handleDirectionTap() async {
    final double? destinationLat = widget.freelancer.latitude;
    final double? destinationLng = widget.freelancer.longitude;

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

    final distanceInMeter = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      destinationLat,
      destinationLng,
    );

    final double distanceKm = distanceInMeter / 1000;
    final int etaMinutes = ((distanceKm / 35) * 60).ceil();

    if (mounted) {
      setState(() {
        _distanceKm = distanceKm;
        _etaMinutes = etaMinutes;
      });
    }

    if (!mounted) {
      return;
    }

    await Navigator.maybeOf(context)?.maybePop();

    final Uri directionUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=$destinationLat,$destinationLng&travelmode=driving',
    );

    if (await canLaunchUrl(directionUri)) {
      await launchUrl(directionUri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open directions')),
      );
    }
  }

  @override
  void initState() {
    _tabController =
        TabController(length: 2, initialIndex: _selectedIndex, vsync: this);
    _tabController.addListener(() {
      _selectedIndex = _tabController.index;
      if (mounted) {
        setState(() {});
      }
    });
    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDistanceInfo();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Freelancer Basic Widget
                FreelancerBasicInfo(freelancer: widget.freelancer),
                SizedBox(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeDefault,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_isLoggedIn)
                            CustomOutlinedButton(
                              label: "Book Now",
                              icon: Iconsax.add,
                              onPressed: () {
                                RouterHelper.getBookingDateSlotRoute(
                                  widget.freelancer.id.toString(),
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          if (_isLoggedIn)
                            const SizedBox(
                                width: Dimensions.paddingSizeDefault),
                          CustomOutlinedButton(
                            label: "Direction",
                            icon: Icons.directions,
                            onPressed: () async {
                              await _handleDirectionTap();
                            },
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          CustomOutlinedButton(
                            label: "Call",
                            icon: Icons.phone,
                            onPressed: () async {
                              await _launchCall(
                                context,
                                widget.freelancer.phone,
                              );
                              // RouterHelper.getBookingDateSlotRoute(
                              //   widget.freelancer.id.toString(),
                              // );
                            },
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          if (_isLoggedIn)
                            Consumer<ChatProvider>(
                              builder: (context, chatProvider, child) {
                                return CustomOutlinedButton(
                                  label: "Chat",
                                  icon: Icons.chat,
                                  onPressed: () async {
                                    await chatProvider.startNewChat(
                                        widget.freelancer.id ?? 0);
                                    RouterHelper.getConversationScreen(
                                        chat: chatProvider.newChat);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                          if (_isLoggedIn)
                            const SizedBox(
                                width: Dimensions.paddingSizeDefault),
                          CustomOutlinedButton(
                            label: "Whatsapp",
                            icon: Icons.phone_android_outlined,
                            onPressed: () => _launchWhatsApp(
                                context, widget.freelancer.whatsapp_number),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  child: _isDistanceLoading
                      ? Row(
                          children: [
                            SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Calculating distance...',
                              style: rubikRegular.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ],
                        )
                      : (_distanceKm != null && _etaMinutes != null)
                          ? Row(
                              children: [
                                Icon(Icons.near_me_outlined,
                                    size: 16,
                                    color: Theme.of(context).primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  'Distance: ${_distanceKm!.toStringAsFixed(1)} km',
                                  style: rubikMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'ETA: ~$_etaMinutes min',
                                  style: rubikRegular.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                ),
                //Freelancer Portfolio Widget
                if (widget.freelancer.portfolio?.isNotEmpty ?? false)
                  FreelancerPortfolioWidget(freelancer: widget.freelancer),

                TabBar(
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.zero,
                  dividerHeight: 0.1,
                  dividerColor: Theme.of(context).dividerColor.withOpacity(0.6),
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2.0,
                    ),
                  ),
                  controller: _tabController,
                  tabs: const <Widget>[
                    Tab(text: 'Reviews'),
                    Tab(text: 'About'),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        child: widget.freelancer.reviews?.isNotEmpty ?? false
                            ? Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(
                                      height: Dimensions.paddingSizeSmall),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeDefault,
                                      vertical: Dimensions.paddingSizeSmall,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rate & review',
                                          style: rubikBold.copyWith(
                                            fontSize:
                                                Dimensions.paddingSizeDefault,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => RouterHelper
                                              .getRateReviewListRoute(
                                            widget.freelancer.id.toString(),
                                          ),
                                          style: TextButton.styleFrom(
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            padding: EdgeInsets.zero,
                                            foregroundColor: Colors.transparent,
                                          ),
                                          child: Text(
                                            getTranslated(
                                                    'view_all', context) ??
                                                'View All',
                                            style: rubikMedium.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    key: PageStorageKey(widget.freelancer.id),
                                    shrinkWrap: true,
                                    itemCount:
                                        widget.freelancer.reviews?.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return RateReviewWidget(
                                        rating: widget
                                            .freelancer.reviews?[index].rating,
                                        comment: widget
                                            .freelancer.reviews?[index].comment,
                                        userImage: widget.freelancer
                                            .reviews?[index].giverImage,
                                        userName: widget.freelancer
                                            .reviews?[index].giverName,
                                        reviewDate: widget.freelancer
                                            .reviews?[index].createdAt,
                                      );
                                    },
                                  ),
                                ],
                              )
                            : Center(
                                child: Text('No Reviews'),
                              ),
                      ),
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              child: ReadMoreText(
                                '${widget.freelancer.about}',
                                trimMode: TrimMode.Line,
                                trimLines: 4,
                                trimLength: 200,
                                moreStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                                lessStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: Dimensions.fontSizeLarge,
                                  fontWeight: FontWeight.w500,
                                ),
                                trimCollapsedText: '...Show more',
                                trimExpandedText: ' show less',
                              ),
                            ),
                            Divider(
                              indent: Dimensions.paddingSizeDefault,
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.1),
                            ),
                            ListTileWidget(
                              iconData: Icons.email_outlined,
                              mainTxt: 'email',
                              subTxt: '${widget.freelancer.email}',
                            ),
                            Divider(
                              indent: Dimensions.paddingSizeDefault,
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.1),
                            ),
                            ListTileWidget(
                              assetImage: Images.whatsapps,
                              mainTxt: 'contact',
                              subTxt: '${widget.freelancer.phone}',
                            ),
                            Divider(
                              indent: Dimensions.paddingSizeDefault,
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.1),
                            ),
                            ListTileWidget(
                              iconData: Iconsax.global,
                              mainTxt: 'location',
                              subTxt: '${widget.freelancer.country}',
                            ),
                            Divider(
                              indent: Dimensions.paddingSizeDefault,
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.1),
                            ),
                            // ListTileWidget(
                            //   iconData: Iconsax.calendar,
                            //   mainTxt: 'Member Since',
                            //   subTxt: '${widget.freelancer.member_since}',
                            // ),
                            // Divider(
                            //   indent: Dimensions.paddingSizeDefault,
                            //   color:
                            //       Theme.of(context).hintColor.withOpacity(0.1),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchWhatsApp(
    BuildContext context, String? whatsappNumber) async {
  // Dismiss the current sheet/dialog only when a back stack exists.
  await Navigator.maybeOf(context)?.maybePop();

  // Phone number with country code (remove all non-digit characters)
  final whatsappUrl = Uri.parse(Platform.isAndroid
          ? "https://wa.me/$whatsappNumber" // Android URL format
          : "https://api.whatsapp.com/send?phone=$whatsappNumber" // iOS URL format
      );

  try {
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error launching WhatsApp: ${e.toString()}')),
    );
  }
}

Future<void> _launchCall(
  BuildContext context,
  String? phoneNumber,
) async {
  // Dismiss the current sheet/dialog only when a back stack exists.
  await Navigator.maybeOf(context)?.maybePop();

  final Uri callUri = Uri.parse("tel:$phoneNumber");

  try {
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open dialer')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error opening dialer: ${e.toString()}')),
    );
  }
}
