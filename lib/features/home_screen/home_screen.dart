import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_button_widget.dart';
import 'package:flutter_restaurant/features/address/providers/location_provider.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/freelancer/providers/freelancer_provider.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/all_categories/view_all_categories.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/all_featured/all_featured.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/all_featured/featured_item_detail.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/relevant_category/relevant_categories.dart';
import 'package:flutter_restaurant/features/home_screen/provider/home_provider.dart';
import 'package:flutter_restaurant/features/notification/screens/notification_screen.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:provider/provider.dart';

// Fixit Style UI Constants
class _FixitTheme {
  static const Color primary = Color(0xFF5C6CFF);
  static const Color background = Color(0xFFF9FAFF);
  static const Color textMain = Color(0xFF232323);
  static const Color textSub = Color(0xFF8A8A8A);
}

class HomeScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;

  const HomeScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.formattedAddress,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      final freelancerProvider =
          Provider.of<FreelancerProvider>(context, listen: false);
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);

      homeProvider.freelanceAllCategory();
      homeProvider.getBanners();
      freelancerProvider.getFreelancerList();
      categoryProvider.getCategoryList();

      if (_isLoggedIn) {
        final passedAddress = widget.formattedAddress?.trim() ?? '';

        if (passedAddress.isNotEmpty) {
          locationProvider.setAddress = passedAddress;
          locationProvider.setPickData();
          return;
        }

        if (locationProvider.address == null ||
            locationProvider.address!.isEmpty) {
          locationProvider.checkPermission(() async {
            if (!mounted) {
              return;
            }

            await locationProvider.getCurrentLocation(
              context,
              true,
              isLoggedIn: _isLoggedIn,
            );
          });
        }
      }
    });

    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FixitTheme.textSub.withValues(alpha: 0.08), // 🔥 HERE

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBarFixed(_isLoggedIn, widget.formattedAddress, context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context)
                        .padding
                        .bottom), // Extra padding for floating button
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _topBannerWithNotification(
                          Provider.of<HomeProvider>(context)),
                      const SizedBox(height: 15),
                      _buildSectionHeader("Top categories", () {
                        final categories = Provider.of<CategoryProvider>(
                                    context,
                                    listen: false)
                                .categoryList ??
                            [];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllCategories(
                              allCategories: categories,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      _buildCategoryGrid(),
                      _buildSectionHeader("Featured", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllFeaturedCategories(),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      _featuredSection(
                        Provider.of<HomeProvider>(context),
                        context,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- UI Components ---

Widget _buildAppBarFixed(
    bool isLoggedIn, String? formattedAddress, BuildContext context) {
  return GestureDetector(
    onTap: () {
      RouterHelper.getDashboardRoute('freelancer',
          action: RouteAction.popAndPush);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
        children: [
          // Location Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: _FixitTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),

          // Address Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "PCO",
                  style: TextStyle(
                    color: _FixitTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Consumer<LocationProvider>(
                  builder: (context, locationProvider, child) {
                    final currentAddress =
                        formattedAddress?.trim().isNotEmpty == true
                            ? formattedAddress!.trim()
                            : locationProvider.address?.trim() ?? '';

                    return Text(
                      isLoggedIn
                          ? (currentAddress.isNotEmpty
                              ? currentAddress
                              : "Select your location")
                          : 'Please Login',
                      style: const TextStyle(
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    );
                  },
                ),
              ],
            ),
          ),

          // Notification Icon - FIXED NAVIGATION
          IconButton(
            onPressed: () {
              debugPrint("----> Navigating to Notification Screen");
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationScreen()),
              );
            },
            icon: const Icon(Icons.notifications_none,
                color: _FixitTheme.textMain),
          ),
        ],
      ),
    ),
  );
}

Widget _topBannerWithNotification(HomeProvider provider) {
  return Consumer<HomeProvider>(
    builder: (context, provider, child) {
      final banners = provider.bannerList;

      if (banners.isEmpty) {
        return const SizedBox(
          height: 240,
          child: Center(child: Text('No banners available')),
        );
      }

      return Stack(
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: PageView.builder(
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return _bannerImage(banners[index]);
              },
            ),
          ),
          // Positioned(
          //   top: 15,
          //   right: 15,
          //   child: Stack(
          //     children: [
          //       const CircleAvatar(
          //         backgroundColor: Colors.white,
          //         radius: 16,
          //         child: Icon(Icons.notifications_none,
          //             size: 18, color: Colors.blueAccent),
          //       ),
          //       Positioned(
          //         top: 0,
          //         right: 0,
          //         child: CircleAvatar(
          //           backgroundColor: Colors.red,
          //           radius: 6,
          //           child: Text('1',
          //               style: TextStyle(fontSize: 7, color: Colors.white)),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      );
    },
  );
}

//... banner
Widget _bannerImage(String imageUrl) {
  return ClipRRect(
    borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
    child: Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox.shrink();
      },
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
    ),
  );
}

// Widget _buildCouponList() {
//   return SingleChildScrollView(
//     scrollDirection: Axis.horizontal,
//     child: Row(
//       children: [
//         _couponCard("Spend 150 am...", "200\$ OFF", "#A125"),
//         _couponCard("Spend 300 am...", "500\$ OFF", "#A450"),
//       ],
//     ),
//   );
// }

// Widget _couponCard(String title, String discount, String code) {
//   return Container(
//     margin: const EdgeInsets.only(right: 15),
//     width: 240,
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: _FixitTheme.couponBg,
//       borderRadius: BorderRadius.circular(15),
//       border: Border.all(color: _FixitTheme.primary.withOpacity(0.2)),
//     ),
//     child: Row(
//       children: [
//         const Icon(Icons.brightness_7, color: _FixitTheme.primary, size: 30),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//               Text("Use code $code",
//                   style: const TextStyle(
//                       color: _FixitTheme.textSub, fontSize: 12)),
//             ],
//           ),
//         ),
//         Text(discount,
//             style: const TextStyle(
//                 color: _FixitTheme.primary, fontWeight: FontWeight.bold)),
//       ],
//     ),
//   );
// }

Widget _buildCategoryGrid() {
  return Consumer<CategoryProvider>(
    builder: (context, provider, _) {
      final cats = provider.categoryList ?? [];

      return SizedBox(
        height: 200,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: cats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReleventCategories(
                    categoryId: cats[index].id ?? 0,
                    title: cats[index].name,
                  ),
                ),
              ),
              child: SizedBox(
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Image.network(
                        cats[index].iconUrl ?? '',
                        height: 28,
                        width: 28,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cats[index].name ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _featuredSection(HomeProvider provider, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const SizedBox.shrink();
          }

          if (provider.allFreelancers.isEmpty) {
            return const Center(child: Text("No freelancers available"));
          }

          return SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.allFreelancers.length,
              itemBuilder: (context, index) {
                final freelancer = provider.allFreelancers[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeaturedItemsDetail(
                          index: index,
                          freelanceId: freelancer.id,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: 320,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          /// BACKGROUND IMAGE (FULL CARD)
                          Container(
                            height: 240,
                            width: 320,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  freelancer.cover_picture.toString(),
                                ),
                                onError: (_, __) {},
                              ),
                            ),
                          ),

                          /// RED CONTENT CARD (UPPER SECTION)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundImage: NetworkImage(
                                          freelancer.profilePicture.toString(),
                                        ),
                                        onBackgroundImageError: (_, __) {},
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          freelancer.name.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(5, (index) {
                                          // Yahan check karein ke aapka variable 'item' hai ya 'freelancer'
                                          num rating = freelancer.rating ?? 0.0;

                                          if (index < rating.floor()) {
                                            return const Icon(Icons.star,
                                                color: Colors.orange, size: 16);
                                          } else if (index < rating) {
                                            return const Icon(Icons.star_half,
                                                color: Colors.orange, size: 16);
                                          } else {
                                            return const Icon(Icons.star_border,
                                                color: Colors.orange, size: 16);
                                          }
                                        }),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "(${freelancer.rating ?? 0.0})",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        freelancer.categoryName.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                      CustomButtonWidget(
                                        width: 120,
                                        btnTxt: "Book Now",
                                        textStyle: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FeaturedItemsDetail(
                                                index: index,
                                                freelanceId: freelancer.id,
                                              ),
                                            ),
                                          );
                                        },
                                        height: 30,
                                        borderRadius: 16,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      )
    ],
  );
}

Widget _buildSectionHeader(String title, VoidCallback onTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _FixitTheme.textMain)),
      GestureDetector(
          onTap: onTap,
          child: const Text("View all",
              style: TextStyle(
                  color: _FixitTheme.primary, fontWeight: FontWeight.w600))),
    ],
  );
}
