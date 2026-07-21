import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/freelancer_booking/providers/freelancer_booking_provider.dart';
import 'package:flutter_restaurant/features/freelancer_booking/widgets/freelancer_booking_list_widget.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class FreelancerBookingScreen extends StatefulWidget {
  const FreelancerBookingScreen({super.key});

  @override
  State<FreelancerBookingScreen> createState() =>
      _FreelancerBookingScreenState();
}

class _FreelancerBookingScreenState extends State<FreelancerBookingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late bool _isLoggedIn;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(length: 3, initialIndex: _selectedIndex, vsync: this);

    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    if (_isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<FreelancerBookingProvider>(context, listen: false)
            .getBookingList(context, 'pending');
      });
    }

    _tabController.addListener(() {
      if (_tabController.indexIsChanging || !_isLoggedIn) return;

      _selectedIndex = _tabController.index;

      final bookingProvider =
          Provider.of<FreelancerBookingProvider>(context, listen: false);

      final String status = ['pending', 'confirmed', 'history'][_selectedIndex];

      final bool hasData = (status == 'pending' &&
              bookingProvider.pendingList.isNotEmpty) ||
          (status == 'confirmed' && bookingProvider.confirmedList.isNotEmpty) ||
          (status == 'history' && bookingProvider.historyList.isNotEmpty);

      if (!hasData) {
        bookingProvider.getBookingList(context, status);
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (CustomAppBarWidget(
        titleColor: Colors.white,
        context: context,
        title: getTranslated('Booking Requests', context),
      )) as PreferredSizeWidget?,
      body: Consumer<FreelancerBookingProvider>(
        builder: (context, freelancerBooking, child) {
          return Column(children: [
            Expanded(
                child: Center(
                    child: SizedBox(
                        width: Dimensions.webScreenWidth,
                        child: Column(children: [
                          Center(
                            child: Container(
                              //width: 320,
                              decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                border: Border.all(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                              ),
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall),
                              margin: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeDefault,
                                  horizontal: Dimensions.paddingSizeLarge),
                              child: TabBar(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeExtraSmall,
                                ),
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                ),
                                controller: _tabController,
                                dividerHeight: 0,
                                indicator: const UnderlineTabIndicator(
                                    borderSide: BorderSide.none),
                                tabs: [
                                  Tab(
                                    iconMargin: EdgeInsets.zero,
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(minHeight: 28),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      margin: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusSmall),
                                        color: _selectedIndex == 0
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).canvasColor,
                                        boxShadow: _selectedIndex == 0
                                            ? [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.12),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 1),
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          getTranslated('pending', context)!,
                                          style: rubikRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                            color: _selectedIndex == 0
                                                ? Theme.of(context).cardColor
                                                : Theme.of(context)
                                                    .primaryColor,
                                            fontWeight: _selectedIndex == 0
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    iconMargin: EdgeInsets.zero,
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(minHeight: 28),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      margin: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusSmall),
                                        color: _selectedIndex == 1
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).canvasColor,
                                        boxShadow: _selectedIndex == 1
                                            ? [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.12),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 1),
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          getTranslated('Upcoming', context)!,
                                          style: rubikRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                            color: _selectedIndex == 1
                                                ? Theme.of(context).cardColor
                                                : Theme.of(context)
                                                    .primaryColor,
                                            fontWeight: _selectedIndex == 1
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    iconMargin: EdgeInsets.zero,
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(minHeight: 28),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      margin: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusSmall),
                                        color: _selectedIndex == 2
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).canvasColor,
                                        boxShadow: _selectedIndex == 2
                                            ? [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.12),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 1),
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          getTranslated('history', context)!,
                                          style: rubikRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                            color: _selectedIndex == 2
                                                ? Theme.of(context).cardColor
                                                : Theme.of(context)
                                                    .primaryColor,
                                            fontWeight: _selectedIndex == 2
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              child: TabBarView(
                            controller: _tabController,
                            children: const [
                              FreelancerBookingListWidget(status: 'pending'),
                              FreelancerBookingListWidget(status: 'confirmed'),
                              FreelancerBookingListWidget(status: 'history'),
                            ],
                          )),
                        ])))),
          ]);
        },
      ),
    );
  }
}
