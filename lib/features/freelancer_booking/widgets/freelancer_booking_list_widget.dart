import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/no_data_widget.dart';
import 'package:flutter_restaurant/features/booking/domain/models/booking_model.dart';
import 'package:flutter_restaurant/features/booking/widgets/booking_shimmer_widget.dart';
import 'package:flutter_restaurant/features/freelancer_booking/providers/freelancer_booking_provider.dart';
import 'package:flutter_restaurant/features/freelancer_booking/widgets/freelancer_booking_item_widget.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:provider/provider.dart';

class FreelancerBookingListWidget extends StatefulWidget {
  final String? status;
  const FreelancerBookingListWidget({super.key, required this.status});

  @override
  State<FreelancerBookingListWidget> createState() =>
      _FreelancerBookingListWidgetState();
}

class _FreelancerBookingListWidgetState
    extends State<FreelancerBookingListWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<FreelancerBookingProvider>(context, listen: false);

      final status = widget.status ?? 'pending';

      final hasData =
          (status == 'pending' && provider.pendingList.isNotEmpty) ||
              (status == 'confirmed' && provider.confirmedList.isNotEmpty) ||
              (status == 'history' && provider.historyList.isNotEmpty);

      if (!hasData) {
        provider.getBookingList(context, status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FreelancerBookingProvider>(
      builder: (context, freelancerBooking, index) {
        final status = widget.status ?? 'pending';
        final bool isLoading = freelancerBooking.isStatusLoading(status);
        List<BookingModel> bookingList = [];
        if (status == 'pending') {
          bookingList = freelancerBooking.pendingList;
        } else if (status == 'confirmed') {
          bookingList = freelancerBooking.confirmedList;
        } else {
          bookingList = freelancerBooking.historyList;
        }

        if (isLoading) {
          return const BookingShimmerWidget();
        }

        Future<void> refresh() =>
            Provider.of<FreelancerBookingProvider>(context, listen: false)
                .getBookingList(context, status);

        // Pull-to-refresh needs to work even when there's nothing to show
        // yet (e.g. a new booking just came in and this tab was previously
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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 5,
              ),
              child: Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: Dimensions.webScreenWidth,
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        itemCount: bookingList.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return FreelancerBookingItemWidget(
                            freelancerBookingProvider: freelancerBooking,
                            status: status,
                            bookingItem: bookingList[index],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
