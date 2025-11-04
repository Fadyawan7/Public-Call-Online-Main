import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/booking_details_model.dart';
import 'package:flutter_restaurant/common/models/response_model.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/booking/domain/models/booking_model.dart';
import 'package:flutter_restaurant/features/booking/domain/models/place_booking_model.dart';
import 'package:flutter_restaurant/features/booking/domain/reposotories/booking_repo.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/day_date_model.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';
import 'package:flutter_restaurant/helper/get_response_error_message.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BookingProvider extends ChangeNotifier {
  final BookingRepo? bookingRepo;
  final SharedPreferences? sharedPreferences;

  BookingProvider({required this.sharedPreferences, required this.bookingRepo});

  // Separate lists for each booking status
List<BookingModel> _pendingList = [];
List<BookingModel> _confirmedList = [];
List<BookingModel> _historyList = [];


  ResponseModel? _responseModel;
  bool _isLoading = false;

  // Other variables
  List<String> _availableTimes = [];
  List<DayData> _days = [];
  int _selectDateSlot = 0;
  int _selectTimeSlot = -1;
  int _selectAddressIndex = -1;
  int? _selectAddressId;

  String? _date = '';
  String? _timeSlot = '';

  List<XFile>? _images = [];
  List<String> _listImagePath = [];
  BookingDetailsModel? _bookingDetails;

  // ======== GETTERS ========
  bool get isLoading => _isLoading;
    List<XFile>? get images => _images;

List<BookingModel> get pendingList => _pendingList;
List<BookingModel> get confirmedList => _confirmedList;
List<BookingModel> get historyList => _historyList;

  BookingDetailsModel? get bookingDetails => _bookingDetails;
  List<String> get availableTimes => _availableTimes;
  List<DayData> get days => _days;
  
  List<String> get listImagePath => _listImagePath;
  int get selectDateSlot => _selectDateSlot;
  int get selectTimeSlot => _selectTimeSlot;
  int get selectAddressIndex => _selectAddressIndex;
  int? get selectAddressId => _selectAddressId;
  String? get date => _date;
  String? get timeSlot => _timeSlot;
  int get totalPickedImage => _listImagePath.length;

  // ======== METHODS ========

  void checkAvailableTimes(String selectedDate) {
    final now = DateTime.now();
    try {
      final inputDate = DateFormat('y-MM-dd').parse(selectedDate);
      if (inputDate.isBefore(now)) {
        if (now.hour < 12) {
          _availableTimes = ["evening", "afternoon"];
        } else {
          _availableTimes = ["afternoon"];
        }
      } else {
        _availableTimes = ["morning", "evening", "afternoon"];
      }
    } catch (e) {
      print("Invalid date format: $e");
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void checkAvailableDates() {
    final today = DateTime.now();
    _days.clear();
    for (int i = 0; i < 7; i++) {
      final desiredDate = today.add(Duration(days: i));
      final formattedDate = DateFormat('EEE', 'en_US').format(desiredDate);
      final day = desiredDate.day;

      _days.add(DayData(
        index: i,
        date: desiredDate,
        formattedDate: formattedDate,
        day: day,
      ));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void updateTimeSlot(int index, String? timeSlot) {
    _selectTimeSlot = index;
    if (timeSlot != null) _timeSlot = timeSlot;
    Future.microtask(() => notifyListeners());
  }

  void updateDateSlot(int index, String? date) {
    resetSlots();
    _selectDateSlot = index;
    if (date != null) _date = date;
    Future.microtask(() => notifyListeners());
  }

  void updateSelectedAddress(int index, int addressId) {
    _selectAddressIndex = index;
    _selectAddressId = addressId;
    Future.microtask(() => notifyListeners());
  }

  void resetSlots() {
    _selectDateSlot = 0;
    _selectTimeSlot = -1;
    Future.microtask(() => notifyListeners());
  }

  Future<void> pickImage() async {
    _images = await ImagePicker().pickMultiImage(limit: 8);
    if (_images != null) {
      for (XFile file in _images!) {
        _listImagePath.add(file.path);
      }
    }
    Future.microtask(() => notifyListeners());
  }

  void removeImage(int index, bool fromColor) {
    _listImagePath.removeAt(index);
    notifyListeners();
  }

  Future<ResponseModel> placeBooking(
    PlaceBookingBody placeBookingBody,
    List<String> imageList,
    Function callback,
    String token, {
    bool isUpdate = true,
  }) async {
    _isLoading = true;
    notifyListeners();
    ResponseModel responseModel;

    http.StreamedResponse response =
        await bookingRepo!.placeBooking(placeBookingBody, imageList, token);
    Map map = jsonDecode(await response.stream.bytesToString());

    if (response.statusCode == 200) {
      _listImagePath = [];
      String? message = map["message"];
      responseModel = ResponseModel(true, message);
      callback(true, 'Booking booked Successfully !');
    } else {
      String errorMessage = getErrorMessage(map);
      responseModel = ResponseModel(false, errorMessage);
      callback(false, errorMessage);
    }

    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

Future<void> getBookingList(BuildContext context, String? status) async {
  _isLoading = true;
  notifyListeners();

  print("⏳ API call started for: $status");

  ApiResponseModel apiResponse = await bookingRepo!.getBookingList(status);

  List<BookingModel> newList = [];

  if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
    final responseData = apiResponse.response!.data;

    if (responseData is List) {
      // 🔥 Directly parse the list
      for (var booking in responseData) {
        newList.add(BookingModel.fromJson(booking));
      }
    } else {
      print("❌ Unexpected response format: $responseData");
    }

    print("✅ Received ${newList.length} records for $status");

    // Assign to correct list
    if (status == 'pending') {
      _pendingList = newList;
    } else if (status == 'confirmed') {
      _confirmedList = newList;
    } else if (status == 'history') {
      _historyList = newList;
    }

  } else {
    print("❌ API error: ${apiResponse.error}");
  }

  // Delay rebuild until data assigned
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _isLoading = false;
    notifyListeners();
  });

  print("🏁 UI updated for $status with count: ${newList.length}");
}

  void stopLoader() {
    _isLoading = false;
    notifyListeners();
  }

  Future<ResponseModel?> getBookingDetails(String bookingID,
      {bool isApiCheck = true}) async {
    _bookingDetails = null;
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    ApiResponseModel apiResponse = await bookingRepo!.getBookingDetails(bookingID);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      try {
        _bookingDetails = BookingDetailsModel.fromJson(apiResponse.response!.data);
        _responseModel = ResponseModel(true, apiResponse.response!.data.toString());
      } catch (e) {
        print("Error parsing JSON: $e");
        _bookingDetails = BookingDetailsModel(id: -1);
        _responseModel = ResponseModel(false, "Error parsing booking details.");
      }
    } else {
      _bookingDetails = BookingDetailsModel(id: -1);
      if (isApiCheck) ApiCheckerHelper.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
    return _responseModel;
  }

  void updateBookingStatus(String bookingID, String? status, Function callback) async {
    _isLoading = true;
    notifyListeners();

    ApiResponseModel apiResponse =
        await bookingRepo!.updateBookingStatus(bookingID, status);
    _isLoading = false;

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      BookingModel? bookingModel;
      List<BookingModel>? targetList;

      if (status == 'pending') targetList = _pendingList;
      if (status == 'confirmed') targetList = _confirmedList;
      if (status == 'history') targetList = _historyList;

      for (var booking in targetList ?? []) {
        if (booking.id.toString() == bookingID) {
          bookingModel = booking;
        }
      }

      targetList?.remove(bookingModel);
      String? message = 'Booking $bookingID $status Successfully !';
      callback(message, true, bookingID);
    } else {
      callback(ApiCheckerHelper.getError(apiResponse).errors?.first.message, false, '-1');
    }

    notifyListeners();
  }

  // ======== Local Cache Methods ========
  Future<void> setPlaceBooking(String placeBooking) async {
    await sharedPreferences!.setString(AppConstants.placeOrderData, placeBooking);
  }

  String? getPlaceBooking() {
    return sharedPreferences!.getString(AppConstants.placeOrderData);
  }

  Future<void> clearPlaceBooking() async {
    await sharedPreferences!.remove(AppConstants.placeOrderData);
  }
}
