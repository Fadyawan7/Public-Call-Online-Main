import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';

import 'package:flutter_restaurant/common/models/response_model.dart';
import 'package:flutter_restaurant/features/booking/domain/models/booking_model.dart';
import 'package:flutter_restaurant/features/freelancer_booking/domain/reposotories/freelancer_booking_repo.dart';

import 'package:flutter_restaurant/helper/api_checker_helper.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreelancerBookingProvider extends ChangeNotifier {
  final FreelancerBookingRepo? freelancerBookingRepo;
  final SharedPreferences? sharedPreferences;
  FreelancerBookingProvider(
      {required this.sharedPreferences, required this.freelancerBookingRepo});

  List<BookingModel> _pendingList = [];
  List<BookingModel> _confirmedList = [];
  List<BookingModel> _historyList = [];
  ResponseModel? _responseModel;
  bool _isLoading = false;
  final Set<String> _statusLoading = <String>{};

  List<BookingModel> get pendingList => _pendingList;
  List<BookingModel> get confirmedList => _confirmedList;
  List<BookingModel> get historyList => _historyList;
  bool isStatusLoading(String status) => _statusLoading.contains(status);
  ResponseModel? get responseModel => _responseModel;

  bool get isLoading => _isLoading;

  Future<void> getBookingList(BuildContext context, String? status) async {
    final String bookingStatus = status ?? 'pending';
    _isLoading = true;
    _statusLoading.add(bookingStatus);
    notifyListeners();

    ApiResponseModel apiResponse =
        await freelancerBookingRepo!.getBookingList(bookingStatus);
    final List<BookingModel> newList = [];

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      apiResponse.response!.data.forEach((booking) {
        BookingModel bookingModel = BookingModel.fromJson(booking);
        newList.add(bookingModel);
      });

      if (bookingStatus == 'pending') {
        _pendingList = newList;
      } else if (bookingStatus == 'confirmed') {
        _confirmedList = newList;
      } else {
        _historyList = newList;
      }
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    _statusLoading.remove(bookingStatus);
    _isLoading = _statusLoading.isNotEmpty;

    notifyListeners();
  }

  void stopLoader() {
    _isLoading = false;
    notifyListeners();
  }

  /// Moves a booking between the local pending/confirmed/history lists
  /// right after a status-changing API call succeeds (accept, reject,
  /// complete, etc.), so the relevant tab updates instantly instead of
  /// waiting for the next full [getBookingList] refetch (e.g. on app
  /// restart).
  void applyBookingStatusUpdate(String bookingID, String? newStatus) {
    BookingModel? bookingModel;
    List<BookingModel>? sourceList;

    for (final list in [_pendingList, _confirmedList, _historyList]) {
      final match = list.where((b) => b.id.toString() == bookingID);
      if (match.isNotEmpty) {
        bookingModel = match.first;
        sourceList = list;
        break;
      }
    }

    if (bookingModel == null) {
      return;
    }

    sourceList?.remove(bookingModel);

    // Pending/confirmed keep their own tab; every other terminal status
    // (rejected, cancelled, completed, history, ...) lands in History.
    final List<BookingModel> targetList;
    if (newStatus == 'pending') {
      targetList = _pendingList;
    } else if (newStatus == 'confirmed') {
      targetList = _confirmedList;
    } else {
      targetList = _historyList;
    }

    final updatedBookingJson = bookingModel.toJson();
    updatedBookingJson['status'] = newStatus;
    final updatedBooking = BookingModel.fromJson(updatedBookingJson);
    targetList.removeWhere((b) => b.id.toString() == bookingID);
    targetList.add(updatedBooking);

    notifyListeners();
  }

  Future<void> setPlaceBooking(String placeBooking) async {
    await sharedPreferences!
        .setString(AppConstants.placeOrderData, placeBooking);
  }

  String? getPlaceBooking() {
    return sharedPreferences!.getString(AppConstants.placeOrderData);
  }

  Future<void> clearPlaceBooking() async {
    await sharedPreferences!.remove(AppConstants.placeOrderData);
  }
}
