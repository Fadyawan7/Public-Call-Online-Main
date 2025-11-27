import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/category_model_response.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/features/category/domain/category_model.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/relevant_category/relevant_categories.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/images.dart';

class AllCategories extends StatefulWidget {
  final List<OnlyCategoryModel> allCategories;

  const AllCategories({super.key, required this.allCategories});

  @override
  State<AllCategories> createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories> {
  late List<OnlyCategoryModel> categories;

  @override
  void initState() {
    super.initState();
    categories = widget.allCategories; // assign the passed list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        context: context,
        title: getTranslated('All Categories', context)!,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 20),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 4.0,
            childAspectRatio: 1.0,
            mainAxisExtent: 120,
          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          category.iconUrl ?? '',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          //   color: Colors.white,
                          errorBuilder: (context, _, __) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
