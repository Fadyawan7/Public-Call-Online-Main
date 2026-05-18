import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/booking_details_model.dart';
import 'package:flutter_restaurant/common/models/response_model.dart';
import 'package:flutter_restaurant/features/booking/domain/models/booking_model.dart';
import 'package:flutter_restaurant/features/booking/domain/models/place_booking_model.dart';
import 'package:flutter_restaurant/features/booking/domain/reposotories/booking_repo.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/day_date_model.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';
import 'package:flutter_restaurant/helper/get_response_error_message.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/image_utils.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final Set<String> _statusLoading = <String>{};

  // Other variables
  List<String> _availableTimes = [];
  final List<DayData> _days = [];
  int _selectDateSlot = 0;
  int _selectTimeSlot = -1;
  int _selectAddressIndex = -1;
  int? _selectAddressId;

  String? _date = '';
  String? _timeSlot = '';
  String? _price = '';

  final List<XFile> _images = [];
  List<String> _listImagePath = [];
  BookingDetailsModel? _bookingDetails;

  // ======== GETTERS ========
  bool get isLoading => _isLoading;
  bool isStatusLoading(String status) => _statusLoading.contains(status);
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
  String? get price => _price;
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

  void updatePrice(String? price) {
    _price = price;
    notifyListeners();
  }

  void resetSlots() {
    _selectDateSlot = 0;
    _selectTimeSlot = -1;
    Future.microtask(() => notifyListeners());
  }

  // Future<void> pickImage() async {
  //   _images = await ImagePicker().pickMultiImage(limit: 8);
  //   if (_images != null) {
  //     for (XFile file in _images!) {
  //       _listImagePath.add(file.path);
  //     }
  //   }
  //   Future.microtask(() => notifyListeners());
  // }
  Future<File?> _cropAndCompressBookingImage(
    XFile image, {
    required Color cropperColor,
  }) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 45,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Booking Image',
          toolbarColor: cropperColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
          cropStyle: CropStyle.rectangle,
          aspectRatioPresets: const [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Booking Image',
          aspectRatioLockEnabled: false,
          aspectRatioPickerButtonHidden: false,
          resetAspectRatioEnabled: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    if (croppedFile == null) {
      return null;
    }

    return ImageUtils.compressFile(File(croppedFile.path));
  }

  Future<void> pickImage(bool fromCamera, {BuildContext? context}) async {
    if (_listImagePath.length >= 2) return;

    final Color cropperColor =
        context != null ? Theme.of(context).primaryColor : Colors.black;
    final ImagePicker picker = ImagePicker();

    if (fromCamera) {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 35,
        maxHeight: 1000,
        maxWidth: 1000,
      );
      if (image != null && _listImagePath.length < 2) {
        final File? processed = await _cropAndCompressBookingImage(image,
            cropperColor: cropperColor);
        if (processed != null) {
          _listImagePath.add(processed.path);
        }
      }
    } else {
      final List<XFile> images = await picker.pickMultiImage(limit: 2);
      for (XFile file in images) {
        if (_listImagePath.length < 2) {
          final File? processed = await _cropAndCompressBookingImage(file,
              cropperColor: cropperColor);
          if (processed != null) {
            _listImagePath.add(processed.path);
          }
        }
      }
    }

    /// 🔥 You forgot this line
    notifyListeners();
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
    final String bookingStatus = status ?? 'pending';
    _statusLoading.add(bookingStatus);
    notifyListeners();

    print("⏳ API call started for: $bookingStatus");

    ApiResponseModel apiResponse =
        await bookingRepo!.getBookingList(bookingStatus);

    List<BookingModel> newList = [];

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
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
      if (bookingStatus == 'pending') {
        _pendingList = newList;
      } else if (bookingStatus == 'confirmed') {
        _confirmedList = newList;
      } else if (bookingStatus == 'history') {
        _historyList = newList;
      }
    } else {
      print("❌ API error: ${apiResponse.error}");
    }

    _statusLoading.remove(bookingStatus);
    notifyListeners();

    print("🏁 UI updated for $bookingStatus with count: ${newList.length}");
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

    ApiResponseModel apiResponse =
        await bookingRepo!.getBookingDetails(bookingID);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      try {
        _bookingDetails =
            BookingDetailsModel.fromJson(apiResponse.response!.data);
        _responseModel =
            ResponseModel(true, apiResponse.response!.data.toString());
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

  void updateBookingStatus(
      String bookingID, String? status, Function callback) async {
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
      callback(ApiCheckerHelper.getError(apiResponse).errors?.first.message,
          false, '-1');
    }

    notifyListeners();
  }

  void updateBookingPrice(
    String bookingID,
    String? price,
    Function callback,
  ) async {
    _isLoading = true;
    notifyListeners();

    ApiResponseModel apiResponse = await bookingRepo!.updateBooking(
      bookingID,
      price: price,
    );

    final statusCode = apiResponse.response?.statusCode;

    if (statusCode == 200 || statusCode == 201) {
      await getBookingDetails(bookingID);

      // force latest updated price locally
      bookingDetails?.price = price;

      _price = price;

      callback(
        'Booking updated successfully',
        true,
        bookingID,
      );
    } else {
      callback(
        'Failed to update booking',
        false,
        '-1',
      );
    }

    _isLoading = false;

    notifyListeners();
  }

  // ======== Local Cache Methods ========
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
