import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/common/widgets/not_logged_in_widget.dart';
import 'package:flutter_restaurant/features/address/providers/location_provider.dart';
import 'package:flutter_restaurant/features/address/screens/select_location_screen.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/freelancer/providers/freelancer_provider.dart';
import 'package:flutter_restaurant/features/freelancer/screens/freelancer_screen.dart';
import 'package:flutter_restaurant/features/freelancer/widgets/freelancer_detail_dialog_widget.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/all_featured/all_featured.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/all_categories/view_all_categories.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/all_featured/featured_item_detail.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/all_services/all_services.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/relevant_category/relevant_categories.dart';
import 'package:flutter_restaurant/features/home_screen/provider/home_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

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
  final FreelancerProvider freelancerProvider =
      Provider.of<FreelancerProvider>(Get.context!, listen: false);
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<HomeProvider>(context, listen: false);
      provider.freelanceAllCategory();
    });
    freelancerProvider.getFreelancerList();

    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);

      if (_isLoggedIn) {
        // Load banners or other user-specific data
        await homeProvider.getBanners();
      }

      if (locationProvider.address == null ||
          locationProvider.address!.isEmpty) {
        // ignore: use_build_context_synchronously
        await locationProvider.getCurrentLocation(context, true);

        LatLng currentLatLng = LatLng(
          locationProvider.position.latitude,
          locationProvider.position.longitude,
        );

        String address =
            await locationProvider.getAddressFromGeocode(currentLatLng);
        locationProvider.setAddress = address;
        locationProvider.setPickData();

        if (kDebugMode) {
          print("✅ Current Address (from device): $address");
        }
      } else {
        if (kDebugMode) {
          print(
              "✅ Using previously selected address: ${locationProvider.address}");
        }
      }
    });
    _loadData();
  }

  void _loadData() async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    categoryProvider.getServicesList();
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        titleColor: Colors.white,
        context: context,
        title: getTranslated('Home Screen', context),
        isBackButtonExist: !ResponsiveHelper.isMobile(),
      ) as PreferredSizeWidget?,
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              _isLoggedIn
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            _searchAndFilterBar(context),
                            const SizedBox(height: 15),
                            _topBannerWithNotification(),
                            const SizedBox(height: 20),
                            _categorySection(context),
                            const SizedBox(height: 20),
                            _featuredSection(),
                            const SizedBox(height: 25),
                            _servicesSection(),
                          ],
                        ),
                      ),
                    )
                  : const NotLoggedInWidget(),

              // 🔹 Overall loading indicator
              if (provider.isLoading)
                Container(
                  color: Colors.black38,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // 🔹 TOP IMAGE CAROUSEL + Notification
  Widget _topBannerWithNotification() {
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

  // 🔹 SEARCH AND FILTER BAR
  Widget _searchAndFilterBar(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SelectLocationScreen()),
        );

        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.black54),
            const SizedBox(width: 10),
            Expanded(
              child: Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  final formattedAddress = locationProvider.address ?? '';
                  return Text(
                    formattedAddress.isNotEmpty
                        ? formattedAddress
                        : "Select your location",
                    style: const TextStyle(
                      fontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
            // const Icon(Icons.location_searching_sharp, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  // 🔹 CATEGORY SECTION
  Widget _categorySection(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categoryList;

        if (categories == null || categoryProvider.isLoading) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Categories",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllCategories(
                                allCategories: categories,
                              )),
                    );
                  },
                  child: Text("View All",
                      style: TextStyle(fontSize: 15, color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // 🔹 Category list from backend
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  bool isSelected = index == selectedIndex;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedIndex = index);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReleventCategories(
                                  categoryId: category.id ?? 0,
                                  title: category.name,
                                )),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[200],
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                category.image ?? '',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                color: isSelected ? Colors.white : Colors.black,
                                errorBuilder: (context, _, __) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // 🔹 FEATURED SECTION
  Widget _featuredSection() {
    List<Map<String, String>> featured = [
      {
        "image": Images.bannerhome1,
        "title": "Pipe Bursting Repair",
        "author": "Felix Harris",
        "price": "Free",
        "tag": "PLUMBING REPAIRS"
      },
      {
        "image": Images.bannerhome2,
        "title": "Custom Fabric Cleaning",
        "author": "Felix Harris",
        "price": "\$20.00",
        "tag": "CLEANING"
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Featured",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllFeaturedCategories(
                        title: 'Featured',
                      ),
                    ));
              },
              child: Text("View All",
                  style: TextStyle(fontSize: 15, color: Colors.grey)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Consumer<HomeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const SizedBox.shrink();
            }

            if (provider.allFreelancers.isEmpty) {
              return const Center(child: Text("No freelancers available"));
            }

            return SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.allFreelancers.length,
                itemBuilder: (context, index) {
                  final freelancer = provider.allFreelancers[index];
                  // final freelancers = freelancerProvider.freelancerList ?? [];
                  // final freelancernext = freelancers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FeaturedItemsDetail(
                                  index: index,
                                  freelanceId: freelancer.freelancerId,
                                )),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[100],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    freelancer.categoryIcon.toString(),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < (freelancer.rating ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    freelancer.name.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundImage: NetworkImage(
                                          freelancer.profilePicture.toString(),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          freelancer.name.toString(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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

  // 🔹 SERVICES SECTION
  Widget _servicesSection() {
    List<Map<String, String>> services = [
      {
        "image": Images.bannerhome1,
        "title": "AC Filter Cleaning",
        "price": "\$15.00",
        "tag": "CLEANING"
      },
      {
        "image": Images.bannerhome2,
        "title": "Full Sanitization",
        "price": "\$43.00",
        "tag": "SANITIZATION"
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Services",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllServicesCategories(
                        title: 'Services',
                      ),
                    ));
              },
              child: Text("View All",
                  style: TextStyle(fontSize: 15, color: Colors.grey)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            final categories = categoryProvider.categoryList;

            if (categories == null || categoryProvider.isLoading) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReleventCategories(
                                  categoryId: category.id ?? 0,
                                  title: category.name,
                                )),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[100],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    category.image.toString(),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      5, // Always show 5 stars
                                      (i) => Icon(
                                        i < (category.totalReviews ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category.name.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(
                                          category.image.toString(),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          category.name.toString(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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

        // SizedBox(
        //   height: 250,
        //   child: ListView.builder(
        //     scrollDirection: Axis.horizontal,
        //     itemCount: services.length,
        //     itemBuilder: (context, index) {
        //       var item = services[index];
        //       return GestureDetector(
        //         onTap: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => FeaturedItemsDetail(
        //                 featured: services,
        //                 index: index,
        //               ),
        //             ),
        //           );
        //         },
        //         child: Container(
        //           width: 180,
        //           margin: const EdgeInsets.only(left: 0, right: 5),
        //           decoration: BoxDecoration(
        //             color: Colors.white,
        //             borderRadius: BorderRadius.circular(15),
        //             border: Border.all(
        //               color: Colors.black12,
        //             ),
        //             boxShadow: [
        //               BoxShadow(color: Colors.black12, blurRadius: 5)
        //             ],
        //           ),
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Stack(
        //                 children: [
        //                   ClipRRect(
        //                     borderRadius: const BorderRadius.only(
        //                         topLeft: Radius.circular(15),
        //                         topRight: Radius.circular(15)),
        //                     child: Image.asset(
        //                       item["image"]!,
        //                       height: 140,
        //                       width: double.infinity,
        //                       fit: BoxFit.cover,
        //                     ),
        //                   ),
        //                   Positioned(
        //                     top: 10,
        //                     left: 10,
        //                     child: Container(
        //                       padding: const EdgeInsets.symmetric(
        //                           horizontal: 8, vertical: 4),
        //                       decoration: BoxDecoration(
        //                         color: Colors.white.withOpacity(0.8),
        //                         borderRadius: BorderRadius.circular(15),
        //                       ),
        //                       child: Text(item["tag"]!,
        //                           style: const TextStyle(
        //                               fontSize: 12,
        //                               fontWeight: FontWeight.bold)),
        //                     ),
        //                   ),
        //                   Positioned(
        //                     bottom: 10,
        //                     right: 10,
        //                     child: Container(
        //                       padding: const EdgeInsets.symmetric(
        //                           horizontal: 10, vertical: 5),
        //                       decoration: BoxDecoration(
        //                         color: Colors.deepPurpleAccent,
        //                         borderRadius: BorderRadius.circular(20),
        //                       ),
        //                       child: Text(item["price"]!,
        //                           style: const TextStyle(
        //                               fontSize: 13, color: Colors.white)),
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //               Padding(
        //                 padding: const EdgeInsets.all(10),
        //                 child: Column(
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: [
        //                     const Row(
        //                       children: [
        //                         Icon(Icons.star_border, size: 16),
        //                         Icon(Icons.star_border, size: 16),
        //                         Icon(Icons.star_border, size: 16),
        //                         Icon(Icons.star_border, size: 16),
        //                         Icon(Icons.star_border, size: 16),
        //                       ],
        //                     ),
        //                     const SizedBox(height: 5),
        //                     Text(item["title"]!,
        //                         style: const TextStyle(
        //                             fontSize: 15, fontWeight: FontWeight.w600)),
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }

  // 🔹 SHOP SECTION
  Widget _shopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Shop",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("View All",
                  style: TextStyle(fontSize: 15, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE6FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storefront,
                          color: Color(0xFF6759FF), size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Trustworthy Tradesmen",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 15, color: Colors.grey),
                              SizedBox(width: 4),
                              Text("Los Angeles, California, United States",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 15, color: Colors.grey),
                              SizedBox(width: 4),
                              Text("3:30 PM - 3:30 AM",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.grey.shade300, height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Services List",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("View All",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: const [
                    _ServiceTag(text: "Authentic Mexican Chef"),
                    _ServiceTag(text: "Indoor Lighting Installation"),
                    _ServiceTag(text: "Transmission Repair"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 PURPLE BOX SECTION (Post New Job Request)
  Widget _postNewJobBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: const Color(0xFF6759FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            "Didn't find your service? Don't worry, You can post your requirements.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add, color: Color(0xFF6759FF)),
                SizedBox(width: 6),
                Text(
                  "Post New Job Request",
                  style: TextStyle(
                    color: Color(0xFF6759FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔸 REUSABLE TAG WIDGET
class _ServiceTag extends StatelessWidget {
  final String text;
  const _ServiceTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE6FB),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6759FF),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
