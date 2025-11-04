import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/features/freelancer/providers/freelancer_provider.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:provider/provider.dart';

class FeaturedItemsDetail extends StatefulWidget {
  final List<Map<String, String>>? featured;
  final int index;
  final dynamic freelanceId;

  const FeaturedItemsDetail({
    super.key,
    this.featured,
    required this.index,
    this.freelanceId,
  });

  @override
  State<FeaturedItemsDetail> createState() => _FeaturedItemsDetailState();
}

class _FeaturedItemsDetailState extends State<FeaturedItemsDetail> {
  FreelancerModel? freelancer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFreelancerDetails();
  }

  Future<void> _loadFreelancerDetails() async {
    final provider = Provider.of<FreelancerProvider>(context, listen: false);

    if (widget.freelanceId != null) {
      await provider.getFreelancerDetails(widget.freelanceId.toString());
      if (!mounted) return;
      setState(() {
        freelancer = provider.freelancerDetails;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FreelancerProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (freelancer == null) {
      return Scaffold(
        appBar: CustomAppBarWidget(
          context: context,
          title:
              getTranslated('Freelance Detail', context) ?? 'Freelancer Detail',
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'No freelancer data found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarWidget(
        context: context,
        title:
            getTranslated('Freelance Detail', context) ?? 'Freelancer Detail',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image ---
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                freelancer?.image ??
                    'https://publiccallonline.com/assets/admin/img/avatars/no-avatar.png',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 12),

            // --- Category & Rating ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    freelancer?.freelancerCategory?.isEmpty ?? true
                        ? 'Unknown'
                        : freelancer!.freelancerCategory!,
                  ),
                  backgroundColor: const Color(0xFFEAE6FA),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text('${freelancer?.avgRating ?? 0.0}'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // --- Name & Member since ---
            Text(
              freelancer?.name ?? 'Unknown Freelancer',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Member since: ${freelancer?.memberSince ?? 'N/A'}',
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 8),

            // --- Price ---
            Text(
              (freelancer?.price == null || freelancer!.price!.isEmpty)
                  ? 'Free'
                  : freelancer!.price!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 16),

            // --- About Section ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F4FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                freelancer?.about?.isEmpty ?? true
                    ? 'No description available'
                    : freelancer!.about!,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),

            const SizedBox(height: 16),

            // --- Available Locations ---
            Text('Available Locations',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${freelancer?.city ?? 'N/A'}, ${freelancer?.country ?? 'N/A'}',
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),

            // --- Reviews ---
            Text('Reviews (${freelancer?.reviews?.length ?? 0})',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (freelancer?.reviews == null || freelancer!.reviews!.isEmpty)
              const Text('No Reviews', style: TextStyle(color: Colors.grey))
            else
              Column(
                children: freelancer!.reviews!.map((review) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F4FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            review.giverImage ??
                                'https://publiccallonline.com/assets/admin/img/avatars/no-avatar.png',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.giverName ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < (review.rating ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                review.comment ?? '',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                review.createdAt ?? '',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // --- Book Now Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: () {
                  RouterHelper.getBookingDateSlotRoute(
                    freelancer?.id.toString() ?? '',
                  );
                  Navigator.of(context).pop();
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text('Booking feature coming soon!'),
                  //   ),
                  // );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
