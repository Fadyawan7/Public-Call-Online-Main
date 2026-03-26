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
  State<FreelancerBookingListWidget> createState() => _FreelancerBookingListWidgetState();
}

class _FreelancerBookingListWidgetState extends State<FreelancerBookingListWidget> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<FreelancerBookingProvider>(context, listen: false);
    final status = widget.status ?? 'pending';
    final hasData = (status == 'pending' && provider.pendingList.isNotEmpty) ||
        (status == 'confirmed' && provider.confirmedList.isNotEmpty) ||
        (status == 'history' && provider.historyList.isNotEmpty);
    if (!hasData) {
      provider.getBookingList(context, status);
    }
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

        return !isLoading ? bookingList.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            await Provider.of<FreelancerBookingProvider>(context, listen: false)
                .getBookingList(context, status);
          },
          backgroundColor: Theme.of(context).primaryColor,
          color: Theme.of(context).cardColor,
          child: SingleChildScrollView(
            child: Column(children: [
              Center(
                child: SizedBox(
                  width: Dimensions.webScreenWidth,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
            ]),
          ),
        ) : const Center(child: NoDataWidget(isOrder: true)) : const BookingShimmerWidget();
      },
    );
  }
}
