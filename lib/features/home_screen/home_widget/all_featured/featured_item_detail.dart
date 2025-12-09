import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/common/widgets/not_logged_in_widget.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/features/freelancer/providers/freelancer_provider.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/app_localization.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:provider/provider.dart';

class FeaturedItemsDetail extends StatefulWidget {
  final int index;
  final dynamic freelanceId;

  const FeaturedItemsDetail({
    super.key,
    required this.index,
    this.freelanceId,
  });

  @override
  State<FeaturedItemsDetail> createState() => _FeaturedItemsDetailState();
}

class _FeaturedItemsDetailState extends State<FeaturedItemsDetail> {
  FreelancerModel? freelancer;
  bool _isLoading = true;
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _loadFreelancerDetails();
    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
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
      body: _isLoggedIn
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Image ---
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: freelancer?.cover_picture != null &&
                              freelancer!.cover_picture!.trim().isNotEmpty &&
                              freelancer!.cover_picture != "null"
                          ? Image.network(
                              freelancer!.cover_picture!,
                              fit: BoxFit.cover, height: 200,

                              width: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox.shrink();
                              },
                              // errorBuilder: (context, error, stackTrace) =>
                              //     const Icon(Icons.error),
                            )
                          : Image.asset(
                              Images.avatarmen,
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                            )),
                  const SizedBox(height: 12),

                  // --- Category & Rating ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              (freelancer?.category != null &&
                                      freelancer!.category!.trim().isNotEmpty &&
                                      freelancer!.category != "null")
                                  ? freelancer!.category!
                                  : 'Unknown',
                            ),
                            backgroundColor: const Color(0xFFEAE6FA),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text('${freelancer?.average_rating ?? 0.0}'),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          freelancer!.current_status == 'available'
                              ? Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                )
                              : const SizedBox.shrink(),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            freelancer?.current_status?.toCapitalized() ??
                                'Not Available',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // --- Name & Member since ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            freelancer?.name ?? 'Unknown Freelancer',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Member since: ${freelancer?.member_since ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Text(
                        "Price: ${freelancer?.price?.isNotEmpty == true ? double.parse(freelancer!.price!).toInt() : ''}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Per Side: ${freelancer?.per_side?.isNotEmpty == true ? freelancer!.per_side! : '0'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Per Hour: ${freelancer?.per_hour?.isNotEmpty == true ? freelancer!.per_hour! : '0'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- About Section ---
                  Text('Description',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
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
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Available Locations ---
                  Text('Available Locations',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      freelancer?.city ?? 'N/A',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Reviews ---
                  Text('Reviews (${freelancer?.reviews?.length ?? 0})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (freelancer?.reviews == null ||
                      freelancer!.reviews!.isEmpty)
                    const Text('No Reviews',
                        style: TextStyle(color: Colors.grey))
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
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
                  )
                ],
              ),
            )
          : const NotLoggedInWidget(),
    );
  }
}
