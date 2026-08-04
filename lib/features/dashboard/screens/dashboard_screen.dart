import 'package:floating_bottom_bar/animated_bottom_navigation_bar.dart'
    hide Images;
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_pop_scope_widget.dart';
import 'package:flutter_restaurant/features/address/providers/location_provider.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/booking/screens/BookingScreen.dart';
import 'package:flutter_restaurant/features/chat/screens/chat_screen.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/features/freelancer/screens/freelancer_screen.dart';
import 'package:flutter_restaurant/features/home_screen/home_screen.dart';
import 'package:flutter_restaurant/features/menu/screens/menu_screen.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/utill/images.dart' show Images;
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final FreelancerModel? autoTrackFreelancer;
  const DashboardScreen(
      {super.key, required this.pageIndex, this.autoTrackFreelancer});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  PageController? _pageController;
  int _pageIndex = 0; // Set initial page index to 1
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.pageIndex;

    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if (splashProvider.policyModel == null) {
      splashProvider.getPolicyPage();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BookingScreen.loadData(false);
    });

    locationProvider.checkPermission(
      () => locationProvider
          .getCurrentLocation(context, false, isLoggedIn: _isLoggedIn)
          .then((currentAddress) {
        locationProvider.onChangeCurrentAddress(currentAddress);
      }),
      canBeIgnoreDialog: true,
    );

    _pageController = PageController(initialPage: _pageIndex);

    _screens = [
      const HomeScreen(),
      const BookingScreen(),
      FreelancerScreen(autoTrackFreelancer: widget.autoTrackFreelancer),
      const ChatScreen(),
      MenuScreen(onTap: (int pageIndex) {
        _setPage(pageIndex);
      }),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      profileProvider.getUserInfo(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
        isExit: _pageIndex == 0,
        onPopInvoked: () async {
          if (_pageIndex != 0) {
            _setPage(0);
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          extendBody: true,
          // floatingActionButton: !ResponsiveHelper.isDesktop(context) && _pageIndex == 0
          //     ? Container(margin: const EdgeInsets.only(bottom: 80), child: const ThirdPartyChatWidget()) : null,
          floatingActionButton: const SizedBox(height: 50, width: 50),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: PageView.builder(
            controller: _pageController,
            itemCount: _screens.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _screens[index];
            },
          ),
          bottomNavigationBar: _FloatingDashboardBottomBar(
            currentIndex: _pageIndex,
            onTap: _setPage,
          ),
        ));
  }

  void _setPage(int pageIndex) {
    if (!mounted) return;
    _pageController?.jumpToPage(pageIndex);
    setState(() {
      _pageIndex = pageIndex;
    });
  }
}

class _FloatingDashboardBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingDashboardBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const Color _accentColor = Color(0xFF5C6CFF);
  static const Color _inactiveColor = Color(0xFF8B96A5);

  @override
  Widget build(BuildContext context) {
    final bool isCenterSelected = currentIndex == 2;
    return Container(
      decoration: BoxDecoration(
        //  color: _barColor,
        borderRadius: BorderRadius.circular(20),

        // 👇 Yeh floating effect dega (gray bg ki jagah)
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.08),
        //     blurRadius: 20,
        //     spreadRadius: 2,
        //     offset: const Offset(0, 6),
        //   ),
        // ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBottomNavigationBar(
          key: ValueKey<int>(currentIndex),
          //  barColor: Colors.transparent, // IMPORTANT
          controller: FloatingBottomBarController(
            initialIndex: _bottomBarIndex,
          ),
          bottomBar: [
            _item(Images.home, 0, currentIndex),
            _item(Images.bookingicon, 1, currentIndex),
            _item(Images.chaticons, 3, currentIndex),
            _item(Images.profileicon, 4, currentIndex),
          ],
          bottomBarCenterModel: BottomBarCenterModel(
            centerBackgroundColor:
                isCenterSelected ? _accentColor : _inactiveColor,
            centerIcon: FloatingCenterButton(
              child: GestureDetector(
                onTap: () => onTap(2),
                child: SizedBox.expand(
                  child: Center(
                    child: Image.asset(
                      Images.bookLocation,
                      width: 30,
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            centerIconChild: [
              FloatingCenterButtonChild(
                onTap: () => onTap(2),
                child: Image.asset(
                  Images.bookLocation,
                  width: 28,
                  height: 28,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomBarItem _item(String image, int index, int currentIndex) {
    final bool isSelected = currentIndex == index;
    return BottomBarItem(
      icon: Image.asset(
        image,
        width: 28,
        height: 28,
        color: _inactiveColor,
      ),
      iconSelected: Image.asset(
        image,
        width: 28,
        height: 28,
        color: isSelected ? _accentColor : _inactiveColor,
      ),
      title: '',
      titleStyle: const TextStyle(fontSize: 0, height: 0),
      dotColor: isSelected ? _accentColor : Colors.transparent,
      onTap: (_) => onTap(index),
    );
  }

  int get _bottomBarIndex {
    switch (currentIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return 0;
    }
  }
}
