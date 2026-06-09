import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_button_widget.dart';
import 'package:flutter_restaurant/common/widgets/gradient_button_widget.dart';
import 'package:flutter_restaurant/features/booking/providers/booking_provider.dart';
import 'package:flutter_restaurant/features/booking/widgets/booking_cancel_dialog_widget.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
  });

  double? _parseAmount(String? value) {
    if (value == null) return null;
    return double.tryParse(value.replaceAll(',', '').trim());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(builder: (context, bookingProvider, _) {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final userType = profileProvider.userInfoModel!.userType;
      final currentUserId = profileProvider.userInfoModel?.id;
      final bookingDetails = bookingProvider.bookingDetails;
      final bookingStatus = bookingDetails?.status;
      final bookingUserId = bookingDetails?.userId;
      final bookingFreelancerId = bookingDetails?.freelancerId;
      final width = MediaQuery.of(context).size.width;

      // Determine if current user created the booking
      final isBookingCreator = currentUserId == bookingUserId;
      // Determine if current user is the freelancer for this booking
      final isBookingFreelancer =
          currentUserId == bookingFreelancerId && userType == "freelancer";

      Widget buildActionButton({
        required String text,
        required Color backgroundColor,
        required Color textColor,
        required VoidCallback onPressed,
      }) {
        return Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: GradientButtonWidget(
                onTap: onPressed,
                height: 50,
                borderRadius: 10,
                gradientColors: [
                  backgroundColor,
                  Theme.of(context).primaryColor,
                ],
                child: Text(
                  getTranslated(text, context)!,
                  style: rubikBold.copyWith(
                    color: textColor,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return Column(
        children: [
          if (isBookingCreator && bookingStatus == 'pending') ...[
            Center(
              child: Container(
                color: Theme.of(context).cardColor,
                width: width > 700 ? 700 : width,
                child: Row(
                  children: [
                    Builder(builder: (context) {
                      final currentPrice = _parseAmount(bookingProvider.price);
                      final originalPrice =
                          _parseAmount(bookingProvider.bookingDetails?.price);
                      final bool priceChanged = originalPrice == null
                          ? (bookingProvider.price != null &&
                              bookingProvider.price!.trim().isNotEmpty)
                          : currentPrice != null &&
                              currentPrice != originalPrice;
                      if (priceChanged) {
                        return buildActionButton(
                          text: 'Update Booking',
                          backgroundColor: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).cardColor,
                          onPressed: () {
                            bookingProvider.updateBookingPrice(
                                bookingProvider.bookingDetails!.id.toString(),
                                bookingProvider.price, (String message,
                                    bool isSuccess, String bookingID) {
                              if (isSuccess) {
                                showCustomSnackBarHelper(message,
                                    status: SnackBarStatus.success);
                                // Refresh details already performed in provider
                              } else {
                                showCustomSnackBarHelper(message,
                                    status: SnackBarStatus.error);
                              }
                            });
                          },
                        );
                      }

                      return buildActionButton(
                        text: 'Cancel Booking',
                        backgroundColor:
                            Theme.of(context).hintColor.withOpacity(0.2),
                        textColor: ColorResources.homePageSectionTitleColor,
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => BookingCancelDialogWidget(
                              popUpTxt: "are_you_sure_to_cancel",
                              status: "cancelled",
                              bookingID:
                                  bookingProvider.bookingDetails!.id.toString(),
                              callback: (String message, bool isSuccess,
                                  String bookingID) {
                                if (isSuccess) {
                                  showCustomSnackBarHelper(message,
                                      status: SnackBarStatus.success);
                                  RouterHelper.getMainRoute(
                                      action:
                                          RouteAction.pushNamedAndRemoveUntil);
                                } else {
                                  showCustomSnackBarHelper(message,
                                      status: SnackBarStatus.error);
                                }
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
          if (isBookingFreelancer && bookingStatus == 'pending') ...[
            Center(
              child: Container(
                color: Theme.of(context).cardColor,
                width: width > 700 ? 700 : width,
                child: Row(
                  children: [
                    buildActionButton(
                      text: 'Confirm Booking',
                      backgroundColor: Theme.of(context).primaryColor,
                      textColor: Theme.of(context).cardColor,
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => BookingCancelDialogWidget(
                            popUpTxt: "are_you_sure_to_confirm",
                            status: "confirmed",
                            bookingID:
                                bookingProvider.bookingDetails!.id.toString(),
                            callback: (String message, bool isSuccess,
                                String bookingID) async {
                              if (isSuccess) {
                                showCustomSnackBarHelper(message,
                                    status: SnackBarStatus.success);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } else {
                                showCustomSnackBarHelper(message,
                                    status: SnackBarStatus.error);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (isBookingCreator &&
              bookingStatus == 'completed' &&
              bookingProvider.bookingDetails!.userReview == false) ...[
            Center(
              child: Container(
                width: width > 700 ? 700 : width,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CustomButtonWidget(
                  btnTxt: getTranslated('review', context),
                  onTap: () {
                    String? takerId = userType == "freelancer"
                        ? bookingProvider.bookingDetails!.userId.toString()
                        : bookingProvider.bookingDetails!.freelancerId
                            .toString();
                    RouterHelper.getSubmitRateReviewRoute(
                        bookingId: bookingProvider.bookingDetails!.id,
                        takerId: takerId);
                  },
                ),
              ),
            ),
          ],
          if (bookingStatus == "confirmed" && isBookingFreelancer) ...[
            Center(
              child: Container(
                color: Theme.of(context).cardColor,
                width: width > 700 ? 700 : width,
                child: Row(
                  children: [
                    buildActionButton(
                      text: 'Complete Booking',
                      backgroundColor: Theme.of(context).primaryColor,
                      textColor: Theme.of(context).cardColor,
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => BookingCancelDialogWidget(
                            popUpTxt: "are_you_sure_to_complete",
                            status: "completed",
                            bookingID:
                                bookingProvider.bookingDetails!.id.toString(),
                            callback: (String message, bool isSuccess,
                                String bookingID) {
                              if (isSuccess) {
                                bookingProvider
                                    .getBookingDetails(bookingID)
                                    .then((_) {
                                  showCustomSnackBarHelper(message,
                                      status: SnackBarStatus.success);
                                });
                              } else {
                                showCustomSnackBarHelper(message,
                                    status: SnackBarStatus.error);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}
