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
        bool isLoading = booking.isLoading ?? true;

        List<BookingModel> bookingList = [];
        if (status == 'pending') {
          bookingList = booking.pendingList ?? [];
        } else if (status == 'confirmed') {
          bookingList = booking.confirmedList ?? [];
        } else {
          bookingList = booking.historyList ?? [];
        }

        if (isLoading) {
          return const BookingShimmerWidget();
        }

        if (bookingList.isEmpty) {
          return const Center(child: NoDataWidget(isOrder: true));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Provider.of<BookingProvider>(context, listen: false)
                .getBookingList(context, status);
          },
          backgroundColor: Theme.of(context).primaryColor,
          color: Theme.of(context).cardColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: SizedBox(
                width: Dimensions.webScreenWidth,
                child: ListView.builder(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  itemCount: bookingList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return BookingItemWidget(
                      bookingProvider: booking,
                      status: status,
                      bookingItem: bookingList[index],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
