import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/gradient_button_widget.dart';
import 'package:flutter_restaurant/features/booking/domain/models/booking_model.dart';
import 'package:flutter_restaurant/features/booking/providers/booking_provider.dart';
import 'package:flutter_restaurant/features/booking/widgets/booking_cancel_dialog_widget.dart';
import 'package:flutter_restaurant/features/freelancer_booking/providers/freelancer_booking_provider.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/app_localization.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class FreelancerBookingItemWidget extends StatelessWidget {
  final BookingModel bookingItem;
  final String status;
  final FreelancerBookingProvider freelancerBookingProvider;
  const FreelancerBookingItemWidget(
      {super.key,
      required this.freelancerBookingProvider,
      required this.status,
      required this.bookingItem});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeDefault),
            margin: const EdgeInsets.only(
                left: Dimensions.paddingSizeSmall,
                right: Dimensions.paddingSizeSmall,
                bottom: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              border: Border.all(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Column(children: [
              Row(children: [
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  flex: 3,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${bookingItem.bookingId.toString()}',
                                style: rubikBold.copyWith(
                                    color: Theme.of(context).primaryColor),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  color:
                                      ColorResources.buttonBackgroundColorMap[
                                          '${bookingItem.status}'],
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                ),
                                child: Text(
                                  '${getTranslated('${bookingItem.status}', context)}',
                                  style: rubikSemiBold.copyWith(
                                      color: ColorResources.buttonTextColorMap[
                                          '${bookingItem.status}'],
                                      fontSize: Dimensions.fontSizeSmall),
                                ),
                              ),
                            ]),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${bookingItem.userName}',
                                style: rubikBold.copyWith(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    fontSize: Dimensions.fontSizeDefault),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),

                              // Text(getTranslated('estimate_arrival', context)!, style: rubikSemiBold.copyWith(
                              //   color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall,
                              // )),
                            ]),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${bookingItem.date}',
                                style: rubikBold.copyWith(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.7),
                                    fontSize: Dimensions.fontSizeSmall),
                              ),
                              const SizedBox(width: Dimensions.fontSizeDefault),
                              Text(bookingItem.time!.toCapitalized(),
                                  style: rubikSemiBold.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: Dimensions.fontSizeDefault,
                                  )),
                            ]),
                        Divider(
                          indent: Dimensions.paddingSizeDefault,
                          color: Theme.of(context)
                              .hintColor
                              .withValues(alpha: 0.1),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: Dimensions.paddingSizeLarge * 2,
                                margin: EdgeInsets.zero,
                                child: Consumer<BookingProvider>(
                                  builder: (context, bookingProvider, child) {
                                    return GradientButtonWidget(
                                      onTap: () {
                                        RouterHelper.getBookingDetailsRoute(
                                            bookingItem.id.toString());
                                      },
                                      height: Dimensions.paddingSizeLarge * 2,
                                      borderRadius: 8,
                                      padding: const EdgeInsets.symmetric(
                                          vertical:
                                              Dimensions.paddingSizeSmall),
                                      child: Text(
                                        "View",
                                        style: rubikSemiBold.copyWith(
                                          color: Colors.white,
                                          fontSize: Dimensions.fontSizeLarge,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: Dimensions.fontSizeDefault),
                            if (bookingItem.status == 'pending') ...[
                              Expanded(
                                child: Container(
                                  height: Dimensions.paddingSizeLarge * 2,
                                  margin: EdgeInsets.zero,
                                  child: Consumer<BookingProvider>(
                                    builder: (context, bookingProvider, child) {
                                      return GradientButtonWidget(
                                        gradientColors: const [
                                          Color(0xFFE74C3C),
                                          Color(0xFFC0392B),
                                        ],
                                        height: Dimensions.paddingSizeLarge * 2,
                                        borderRadius: 8,
                                        padding: const EdgeInsets.symmetric(
                                            vertical:
                                                Dimensions.paddingSizeSmall),
                                        onTap: bookingProvider.isLoading
                                            ? null
                                            : () {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) =>
                                                      BookingCancelDialogWidget(
                                                    popUpTxt:
                                                        "are_you_sure_to_reject",
                                                    status: "rejected",
                                                    bookingID: bookingItem.id
                                                        .toString(),
                                                    callback: (String message,
                                                        bool isSuccess,
                                                        String bookingID) {
                                                      if (isSuccess) {
                                                        // Update this
                                                        // provider's local
                                                        // lists directly so
                                                        // the pending tab
                                                        // drops the item
                                                        // immediately,
                                                        // instead of forcing
                                                        // a full dashboard
                                                        // reset.
                                                        freelancerBookingProvider
                                                            .applyBookingStatusUpdate(
                                                          bookingID,
                                                          'rejected',
                                                        );
                                                        showCustomSnackBarHelper(
                                                            message,
                                                            status:
                                                                SnackBarStatus
                                                                    .success);
                                                      } else {
                                                        showCustomSnackBarHelper(
                                                            message,
                                                            status:
                                                                SnackBarStatus
                                                                    .error);
                                                      }
                                                    },
                                                  ),
                                                );
                                              },
                                        child: bookingProvider.isLoading
                                            ? const SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                getTranslated(
                                                    'Reject', context)!,
                                                style: rubikSemiBold.copyWith(
                                                  color: Colors.white,
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                ),
                                              ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            ],
                          ],
                        ),
                      ]),
                ),
              ]),
            ]),
          ),
        ]);
  }
}
