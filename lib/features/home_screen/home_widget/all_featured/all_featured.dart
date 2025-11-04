import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/all_featured/featured_item_detail.dart';
import 'package:flutter_restaurant/features/home_screen/provider/home_provider.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
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
        title: getTranslated(widget.title, context)!,
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🔍 Search bar
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextField(
              //         decoration: InputDecoration(
              //           hintText: "Search for ${widget.title}",
              //           prefixIcon: const Icon(Icons.search),
              //           filled: true,
              //           fillColor: Colors.grey[200],
              //           contentPadding:
              //               const EdgeInsets.symmetric(horizontal: 16),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(16),
              //             borderSide: BorderSide.none,
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 10),
              //     Container(
              //       decoration: BoxDecoration(
              //         color: Theme.of(context).primaryColor,
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       padding: const EdgeInsets.all(12),
              //       child: const Icon(Icons.tune, color: Colors.white),
              //     ),
              //   ],
              // ),

              const SizedBox(height: 16),

              // 🧑‍🎨 Flexible freelancer list
              ...List.generate(provider.allFreelancers.length, (index) {
                final freelancer = provider.allFreelancers[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeaturedItemsDetail(
                          index: index,
                          freelanceId: freelancer.freelancerId,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[100],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🖼️ Image
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

                          // 📄 Details
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
              }),
            ],
          );
        },
      ),
    );
  }
}
