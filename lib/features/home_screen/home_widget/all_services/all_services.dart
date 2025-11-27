// import 'package:flutter/material.dart';
// import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
// import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
// import 'package:flutter_restaurant/features/home_screen/home_widget/relevant_category/relevant_categories.dart';
// import 'package:flutter_restaurant/localization/language_constrants.dart';
// import 'package:provider/provider.dart';

// class AllServicesCategories extends StatefulWidget {
//   final String? title;
//   const AllServicesCategories({super.key, this.title});

//   @override
//   State<AllServicesCategories> createState() => _AllServicesCategoriesState();
// }

// class _AllServicesCategoriesState extends State<AllServicesCategories> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBarWidget(
//         context: context,
//         title: getTranslated(widget.title, context)!,
//         centerTitle: true,
//       ),
//       body: Consumer<CategoryProvider>(
//         builder: (context, categoryProvider, child) {
//           final categories = categoryProvider.categoryList;

//           if (categories == null || categoryProvider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (categories.isEmpty) {
//             return const Center(child: Text("No categories available"));
//           }

//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//               child: Column(
//                 children: List.generate(categories.length, (index) {
//                   final category = categories[index];

//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ReleventCategories(
//                             categoryId: category.id ?? 0,
//                             title: category.name,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         color: Colors.grey[100],
//                         border: Border.all(
//                             color: Theme.of(context)
//                                 .primaryColor
//                                 .withOpacity(0.2)),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Image
//                           Container(
//                             height: 150,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(16),
//                                 topRight: Radius.circular(16),
//                               ),
//                               image: DecorationImage(
//                                 fit: BoxFit.cover,
//                                 image: NetworkImage(
//                                   category.iconUrl.toString(),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           // Info Section
//                           Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // ⭐ Ratings
//                                 Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: List.generate(
//                                     5,
//                                     (i) => Icon(
//                                       i < (category.totalReviews ?? 0)
//                                           ? Icons.star
//                                           : Icons.star_border,
//                                       size: 16,
//                                       color: Colors.orange,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),

//                                 // 🏷️ Name
//                                 Text(
//                                   category.name.toString(),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),

//                                 const SizedBox(height: 4),

//                                 // 👤 Avatar + Text
//                                 Row(
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 16,
//                                       backgroundImage: NetworkImage(
//                                         category.image.toString(),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         category.name.toString(),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
