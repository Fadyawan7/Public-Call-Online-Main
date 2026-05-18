import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/gradient_card_widget.dart';
import 'package:flutter_restaurant/features/booking/providers/booking_provider.dart';
import 'package:flutter_restaurant/features/booking/widgets/booking_address_widget.dart';
import 'package:flutter_restaurant/features/booking/widgets/booking_attachments_widget.dart';
import 'package:flutter_restaurant/features/booking/widgets/booking_info_widget.dart';
import 'package:flutter_restaurant/features/booking/widgets/freelancer_widget.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class BookingDetailsWidget extends StatefulWidget {
  const BookingDetailsWidget({super.key, this.bookingId});
  final int? bookingId;

  @override
  State<BookingDetailsWidget> createState() => _BookingDetailsWidgetState();
}

class _BookingDetailsWidgetState extends State<BookingDetailsWidget> {
  final TextEditingController _priceController = TextEditingController();
  int? _syncedBookingId;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _syncPriceField(BookingProvider bookingProvider) {
    final bookingDetails = bookingProvider.bookingDetails;

    if (bookingDetails == null) return;

    final currentBookingId = bookingDetails.id;
    final serverPrice = bookingDetails.price ?? '';

    // Only sync once per booking
    if (_syncedBookingId == currentBookingId) {
      return;
    }

    _syncedBookingId = currentBookingId;

    _priceController.text = serverPrice;

    bookingProvider.updatePrice(
      serverPrice.isEmpty ? null : serverPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    final ProfileProvider profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final BookingProvider bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    final bookingStatus = bookingProvider.bookingDetails?.status;
    return Consumer<BookingProvider>(builder: (context, booking, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncPriceField(booking);
        }
      });

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(getTranslated('Booking Info', context)!, style: rubikBold),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                // Update Price field
                if (bookingStatus == 'pending') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(getTranslated('Update Price', context)!,
                          style: rubikBold.copyWith(fontSize: 12)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      SizedBox(
                        width: 120,
                        height: 38,
                        child: TextFormField(
                          controller: _priceController,
                          //focusNode: FocusNode().,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            isDense: true,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault)),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3)),
                          ),

                          onChanged: (val) {
                            booking.updatePrice(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: Dimensions.paddingSizeDefault),
                const GradientCardWidget(
                  padding: EdgeInsets.zero,
                  child: BookingInfoWidget(),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                if (booking.bookingDetails!.deliveryAddress != null) ...[
                  Text(getTranslated('Address Info', context)!,
                      style: rubikBold),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  const GradientCardWidget(
                    padding: EdgeInsets.zero,
                    child: BookingAddressInfoWidget(),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
                if (booking.bookingDetails?.freelancerName != null)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            getTranslated(
                                '${profileProvider.userInfoModel!.userType == "freelancer" ? 'User Detail' : 'Freelancer'} ',
                                context)!,
                            style: rubikBold),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        GradientCardWidget(
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: FreelancerWidget(
                              bookingDetailsModel: booking.bookingDetails!,
                              isFreelancer:
                                  profileProvider.userInfoModel!.userType ==
                                      "freelancer"),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ]),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                if (booking.bookingDetails?.description?.isNotEmpty ??
                    false) ...[
                  Text(getTranslated('Issue Explanation', context)!,
                      style: rubikBold),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  GradientCardWidget(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(booking.bookingDetails?.description ?? '',
                              style: rubikRegular.copyWith(
                                  color: Theme.of(context).hintColor)),
                        ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  if (booking.bookingDetails?.attachments != null &&
                      booking.bookingDetails!.attachments!.isNotEmpty) ...[
                    Text(getTranslated('Attachments', context)!,
                        style: rubikBold),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    GradientCardWidget(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: BookingAttachmentsWidget(
                          bookingProvider: booking,
                          splashProvider: splashProvider),
                    ),
                  ]
                ],
              ]),
        ),
      ]);
    });
  }
}
