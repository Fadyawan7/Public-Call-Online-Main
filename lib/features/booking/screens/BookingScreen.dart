import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/common/widgets/not_logged_in_widget.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/booking/providers/booking_provider.dart';
import 'package:flutter_restaurant/features/booking/widgets/booking_list_widget.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/freelancer_booking/widgets/freelancer_booking_list_widget.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
  static Future<void> loadData(bool reload, {bool isFcmUpdate = false}) async {
    final ProfileProvider profileProvider =
        Provider.of<ProfileProvider>(Get.context!, listen: false);
    final CategoryProvider categoryProvider =
        Provider.of<CategoryProvider>(Get.context!, listen: false);
    final isLogin =
        Provider.of<AuthProvider>(Get.context!, listen: false).isLoggedIn();
    if (isLogin) {
      categoryProvider.getCategoryList();
      if (isFcmUpdate) {
        Provider.of<AuthProvider>(Get.context!, listen: false).updateToken();
      }
    } else {
      profileProvider.setUserInfoModel = null;
    }
  }
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late bool _isLoggedIn;
  bool isFreelancer = false;

  @override
  void initState() {
    super.initState();

    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    isFreelancer = Provider.of<ProfileProvider>(context, listen: false)
            .userInfoModel
            ?.userType ==
        'freelancer';

    _tabController = TabController(
      length: isFreelancer ? 2 : 1,
      vsync: this,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      setState(() {});
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
      appBar: CustomAppBarWidget(
        titleColor: Colors.white,
        context: context,
        title: 'Booking Screen',
        isBackButtonExist: !ResponsiveHelper.isMobile(),
      ) as PreferredSizeWidget?,
      body: _isLoggedIn
          ? Column(
              children: [
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.webScreenWidth,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              border: Border.all(
                                color: Theme.of(context)
                                    .hintColor
                                    .withValues(alpha: 0.2),
                              ),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraSmall,
                              horizontal: Dimensions.paddingSizeExtraSmall,
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall,
                              horizontal: 50,
                            ),
                            child: TabBar(
                              controller: _tabController,
                              dividerHeight: 0,
                              indicator: const UnderlineTabIndicator(
                                borderSide: BorderSide.none,
                              ),
                              tabs: isFreelancer
                                  ? [
                                      _buildTab(context, 'my_order', 0),
                                      _buildTab(context, 'my_booking', 1),
                                    ]
                                  : [
                                      _buildTab(context, 'my_booking', 0),
                                    ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: isFreelancer
                                  ? [
                                      _MyBookingTabs(),
                                      _MyOrderTabs(),
                                    ]
                                  : [
                                      _MyOrderTabs(),
                                    ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const NotLoggedInWidget(),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index) {
    final bool selected = _tabController.index == index;

    return Tab(
      child: Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).canvasColor,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            getTranslated(label, context)!,
            style: rubikRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: selected
                  ? Theme.of(context).cardColor
                  : Theme.of(context).primaryColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _MyBookingTabs extends StatefulWidget {
  const _MyBookingTabs();

  @override
  State<_MyBookingTabs> createState() => _MyBookingTabsState();
}

class _MyBookingTabsState extends State<_MyBookingTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            border: Border.all(
              color: Theme.of(context).hintColor.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.all(
            3,
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: Dimensions.paddingSizeLarge,
          ),
          child: TabBar(
            controller: _tabController,
            dividerHeight: 0,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide.none,
            ),
            tabs: [
              _innerTab(context, 'pending', 0),
              _innerTab(context, 'Upcoming', 1),
              _innerTab(context, 'history', 2),
            ],
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
          ),
        ),
      ],
    );
  }

  Widget _innerTab(BuildContext context, String label, int index) {
    final bool selected = _tabController.index == index;

    return Tab(
      child: Text(
        getTranslated(label, context)!,
        style: rubikRegular.copyWith(
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withValues(alpha: 0.6),
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _MyOrderTabs extends StatefulWidget {
  const _MyOrderTabs();

  @override
  State<_MyOrderTabs> createState() => _MyOrderTabsState();
}

class _MyOrderTabsState extends State<_MyOrderTabs>
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
        Provider.of<BookingProvider>(context, listen: false)
            .getBookingList(context, 'pending');
      });
    }

    _tabController.addListener(() {
      if (_tabController.indexIsChanging || !_isLoggedIn) return;

      _selectedIndex = _tabController.index;

      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
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
  return Consumer<BookingProvider>(
    builder: (context, order, child) {
      return Column(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                border: Border.all(
                  color: Theme.of(context)
                      .hintColor
                      .withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(
                  Dimensions.radiusDefault,
                ),
              ),
              padding: const EdgeInsets.all(3),
              margin: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: Dimensions.paddingSizeLarge,
              ),
              child: TabBar(
                controller: _tabController,
                dividerHeight: 0,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide.none,
                ),
                tabs: [
                  _buildInnerTab(context, 'pending', 0),
                  _buildInnerTab(context, 'confirmed', 1),
                  _buildInnerTab(context, 'history', 2),
                ],
              ),
            ),
          ),

          Expanded(
            child: SafeArea(
              bottom: true,
              child: TabBarView(
                controller: _tabController,
                children: const [
                  BookingListWidget(status: 'pending'),
                  BookingListWidget(status: 'confirmed'),
                  BookingListWidget(status: 'history'),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
  Widget _buildInnerTab(BuildContext context, String label, int index) {
    final bool selected = _tabController.index == index;

    return Tab(
      child: Text(
        getTranslated(label, context)!,
        style: rubikRegular.copyWith(
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withValues(alpha: 0.6),
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}
