import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/category_model_response.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/features/home_screen/home_widget/relevant_category/relevant_categories.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';

class AllCategories extends StatelessWidget {
  final List<OnlyCategoryModel> allCategories;

  const AllCategories({super.key, required this.allCategories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBarWidget(
        context: context,
        title: getTranslated('All Categories', context)!,
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allCategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 20,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          final category = allCategories[index];

          List<Color> borderColors = [
            Colors.yellow.shade100, // Electrician
            Colors.blue.shade100, // Plumber
            Colors.orange.shade100, // Mason
            Colors.lime.shade100, // Carpenter
            Colors.blue.shade100, // Painter
            Colors.orange.shade100, // Welder
            Colors.grey.shade100, // Mechanic
            Colors.green.shade100, // Gardener
            Colors.green.shade100, // Cleaner
            Colors.purple.shade100, // IT Technician
            Colors.grey.shade100, // hell7 (setting)
            Colors.lime.shade100, // Carpenter
            Colors.cyan.shade100, // yasssssasss (setting)
          ];

          Color borderColor = borderColors[index % borderColors.length];

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReleventCategories(
                      categoryId: category.id ?? 0, title: category.name)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Image.network(
                    category.iconUrl ?? '',
                    height: 40,
                    width: 40,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.category,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category.name ?? '',
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
          );
        },
      ),
    );
  }
}
