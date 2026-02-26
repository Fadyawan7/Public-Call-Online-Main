
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

  List<BookingModel>? _runningOrderList;
  List<BookingModel>? _historyOrderList;
  ResponseModel? _responseModel;
  bool _isLoading = false;


  List<BookingModel>? get runningOrderList => _runningOrderList;
  ResponseModel? get responseModel => _responseModel;

  bool get isLoading => _isLoading;

  Future<void> getBookingList(BuildContext context,String? status) async {
    _isLoading = true;

    ApiResponseModel apiResponse = await freelancerBookingRepo!.getBookingList(status);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _runningOrderList = [];
      _historyOrderList = [];
      apiResponse.response!.data.forEach((booking) {
        BookingModel bookingModel = BookingModel.fromJson(booking);
        bookingModel = BookingModel.fromJson(booking);
        _runningOrderList!.add(bookingModel);
      });

    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    _isLoading = false;

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