import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_button_widget.dart';
import 'package:flutter_restaurant/features/booking/providers/booking_provider.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class BookingAddressInfoWidget extends StatelessWidget {
  const BookingAddressInfoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Center(child: Consumer<BookingProvider>(
          builder: (context, bookingProvider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.house,
                        size: Dimensions.fontSizeExtraLarge),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          bookingProvider
                                  .bookingDetails!.deliveryAddress!.address ??
                              'N/A',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: Dimensions.paddingSizeDefault,
                  color: Theme.of(context).hintColor.withOpacity(0.1),
                ),
                if ((bookingProvider.bookingDetails?.status == 'completed' ||
                        bookingProvider.bookingDetails?.status ==
                            'confirmed') &&
                    (Provider.of<ProfileProvider>(context, listen: false)
                            .isFreelancer ??
                        false)) ...[
                  Center(
                    child: Container(
                      width: width > 700 ? 700 : width / 2,
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: CustomButtonWidget(
                        height: Dimensions.paddingSizeLarge * 2,
                        iconData: Icons.directions,
                        btnTxt: 'Get Direction',
                        onTap: () async {
                          final latitude = double.tryParse(
                                bookingProvider.bookingDetails?.deliveryAddress
                                        ?.latitude ??
                                    '',
                              ) ??
                              0;
                          final longitude = double.tryParse(
                                bookingProvider.bookingDetails?.deliveryAddress
                                        ?.longitude ??
                                    '',
                              ) ??
                              0;

                          if (latitude == 0 && longitude == 0) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid destination location'),
                                ),
                              );
                            }
                            return;
                          }

                          try {
                            final currentPosition =
                                await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                            );

                            final destinationFreelancer = FreelancerModel(
                              name: bookingProvider.bookingDetails?.userName ??
                                  'Destination',
                              category_name: 'Booking Address',
                              latitude: latitude,
                              longitude: longitude,
                              rating: 0,
                            );

                            RouterHelper.getDirectionRoute(
                              destinationFreelancer,
                              currentPosition.latitude,
                              currentPosition.longitude,
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to open direction: $e'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ]
              ],
            );
          },
        )));
  }
}
