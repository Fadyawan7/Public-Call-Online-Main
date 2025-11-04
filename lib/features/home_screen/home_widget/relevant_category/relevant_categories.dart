import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/all_featured/featured_item_detail.dart';
import 'package:flutter_restaurant/features/home_screen/provider/home_provider.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:provider/provider.dart';

class ReleventCategories extends StatefulWidget {
  String? title;
  final int categoryId;
  ReleventCategories({super.key, this.title, required this.categoryId});

  @override
  State<ReleventCategories> createState() => _ReleventCategoriesState();
}

class _ReleventCategoriesState extends State<ReleventCategories> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Fetch freelancers for this category
    Future.microtask(() {
      final provider = Provider.of<HomeProvider>(context, listen: false);
      provider.fetchFreelancersByCategory(widget.categoryId);
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
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.freelancers.isEmpty) {
            return const Center(child: Text("No Data available"));
          }

          return ListView.builder(
            itemCount: provider.freelancers.length,
            itemBuilder: (context, index) {
              final freelancer = provider.freelancers[index];

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                      color: Colors.grey[100],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      freelancer.categoryIcon.toString()))),
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
                              SizedBox(height: 4),
                              Text(
                                freelancer.name.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundImage: NetworkImage(
                                        freelancer.profilePicture.toString()),
                                  ),
                                  SizedBox(width: 8),
                                  Text(freelancer.name.toString()),
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
          );
        },
      ),
    );
  }
}
