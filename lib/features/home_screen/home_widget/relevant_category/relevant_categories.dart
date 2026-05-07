import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_button_widget.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/all_featured/featured_item_detail.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:provider/provider.dart';

class ReleventCategories extends StatefulWidget {
  final String? title;
  final int categoryId;
  const ReleventCategories({super.key, this.title, required this.categoryId});

  @override
  State<ReleventCategories> createState() => _ReleventCategoriesState();
}

class _ReleventCategoriesState extends State<ReleventCategories> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false)
          .freelancerbyCategory(widget.title.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        context: context,
        title: getTranslated(widget.title, context) ?? '',
        centerTitle: true,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.predictionList;
          if (list == null || list.isEmpty) {
            return const Center(child: Text("No Data available"));
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final freelancer = list[index];

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: SizedBox(
                    height: 240,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        /// BACKGROUND IMAGE
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                freelancer.cover_picture?.toString() ?? '',
                              ),
                              onError: (_, __) {},
                            ),
                          ),
                        ),

                        /// CONTENT CARD (OVERLAY)
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
                                        freelancer.coverPicture?.toString() ??
                                            '',
                                      ),
                                      onBackgroundImageError: (_, __) {},
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        freelancer.name?.toString() ?? '',
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
                                      children: List.generate(5, (starIndex) {
                                        num rating = freelancer.rating ?? 0.0;
                                        if (starIndex < rating.floor()) {
                                          return const Icon(Icons.star,
                                              color: Colors.orange, size: 16);
                                        } else if (starIndex < rating) {
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
                                      freelancer.category_name?.toString() ??
                                          '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.black,
                                      ),
                                    ),
                                    CustomButtonWidget(
                                      width: 100,
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
          );
        },
      ),
    );
  }
}
