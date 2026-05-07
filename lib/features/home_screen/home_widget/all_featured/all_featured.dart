import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_button_widget.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/all_featured/featured_item_detail.dart';
import 'package:flutter_restaurant/features/home_screen/provider/home_provider.dart';
import 'package:provider/provider.dart';

class AllFeaturedCategories extends StatefulWidget {
  final String? title;
  const AllFeaturedCategories({super.key, this.title});

  @override
  State<AllFeaturedCategories> createState() => _AllFeaturedCategoriesState();
}

class _AllFeaturedCategoriesState extends State<AllFeaturedCategories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        context: context,
        title: 'All Categories',
        centerTitle: true,
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.allFreelancers.isEmpty) {
            return const Center(child: Text("No freelancers available"));
          }

          return Column(
            children: [
              const SizedBox(height: 16),

              // Wrap the list section in Expanded so it occupies
              // the remaining space and becomes scrollable.
              Expanded(
                child: _featuredSectionDetail(provider, context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _featuredSectionDetail(HomeProvider provider, BuildContext context) {
    // Use the provider passed as an argument rather than nesting another Consumer
    // unless you specifically need it for scoped updates.
    return ListView.builder(
      physics: const BouncingScrollPhysics(), // Added for better scroll feel
      padding: const EdgeInsets.only(bottom: 20), // Extra space at bottom
      scrollDirection: Axis.vertical,
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
            // Added vertical padding so cards don't stick together
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              height: 240,
              // Removed width: 320 to allow it to be responsive to screen width
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  /// BACKGROUND IMAGE (FULL CARD)
                  Container(
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

                  /// CONTENT CARD
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
                            const BorderRadius.all(Radius.circular(16)),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                width: 100, // Slightly reduced to fit better
                                btnTxt: "Book Now",
                                textStyle: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
    );
  }
}
