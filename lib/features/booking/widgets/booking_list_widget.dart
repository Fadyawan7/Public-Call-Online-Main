import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/no_data_widget.dart';
import 'package:flutter_restaurant/features/booking/domain/models/booking_model.dart';
import 'package:flutter_restaurant/features/booking/providers/booking_provider.dart';
import 'package:flutter_restaurant/features/booking/widgets/booking_item_widget.dart';
import 'package:flutter_restaurant/features/booking/widgets/booking_shimmer_widget.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:provider/provider.dart';

class BookingListWidget extends StatelessWidget {
  final String status;
  const BookingListWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, booking, child) {
        final bool isLoading = booking.isStatusLoading(status);

        List<BookingModel> bookingList = [];
        if (status == 'pending') {
          bookingList = booking.pendingList;
        } else if (status == 'confirmed') {
          bookingList = booking.confirmedList;
        } else {
          bookingList = booking.historyList;
        }

        if (isLoading) {
          return const BookingShimmerWidget();
        }

        Future<void> refresh() =>
            Provider.of<BookingProvider>(context, listen: false)
                .getBookingList(context, status);

        // Pull-to-refresh needs to work even when there's nothing to show
        // yet (e.g. a booking was just placed and this tab was previously
        // empty) - otherwise the only way to see it was to restart the app.
        if (bookingList.isEmpty) {
          return RefreshIndicator(
            onRefresh: refresh,
            backgroundColor: Theme.of(context).primaryColor,
            color: Theme.of(context).cardColor,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: const Center(child: NoDataWidget(isOrder: true)),
                  ),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: refresh,
          backgroundColor: Theme.of(context).primaryColor,
          color: Theme.of(context).cardColor,
          child: ListView.builder(
            padding: EdgeInsets.only(
              top: Dimensions.paddingSizeSmall,
              left: Dimensions.paddingSizeSmall,
              right: Dimensions.paddingSizeSmall,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            itemCount: bookingList.length,
            itemBuilder: (context, index) {
              return Center(
                child: SizedBox(
                  width: Dimensions.webScreenWidth,
                  child: BookingItemWidget(
                    bookingProvider: booking,
                    status: status,
                    bookingItem: bookingList[index],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
