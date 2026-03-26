
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
  FreelancerBookingProvider({ required this.sharedPreferences,required this.freelancerBookingRepo});

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

  Future<void> getBookingList(BuildContext context,String? status) async {
    final String bookingStatus = status ?? 'pending';
    _isLoading = true;
    _statusLoading.add(bookingStatus);
    notifyListeners();

    ApiResponseModel apiResponse = await freelancerBookingRepo!.getBookingList(bookingStatus);
    final List<BookingModel> newList = [];

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
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

  Future<void> setPlaceBooking(String placeBooking)async{
    await sharedPreferences!.setString(AppConstants.placeOrderData, placeBooking);
  }
  String? getPlaceBooking(){
    return sharedPreferences!.getString(AppConstants.placeOrderData);
  }
  Future<void> clearPlaceBooking()async{
    await sharedPreferences!.remove(AppConstants.placeOrderData);
  }
}