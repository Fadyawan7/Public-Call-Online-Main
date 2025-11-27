import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';

import 'package:flutter_restaurant/common/models/response_model.dart';
import 'package:flutter_restaurant/features/apply_freelancer/domain/models/apply_freelancer_model.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/features/freelancer/domain/reposotories/freelancer_repo.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreelancerProvider extends ChangeNotifier {
  final FreelancerRepo? freelancerRepo;
  final SharedPreferences? sharedPreferences;
  FreelancerProvider(
      {required this.sharedPreferences, required this.freelancerRepo});

  List<FreelancerModel>? _freelancerList;
  ResponseModel? _responseModel;
  bool _isLoading = false;
  int _selectedCategoryID = -1;
  DateTime? now = DateTime.now();
  int? get selectedCategoryID => _selectedCategoryID;
  FreelancerModel? _freelancerDetails;
  List<FreelancerModel> _predictionList = [];

  FreelancerModel? _selectedFreelancer;

  ApplyFreelancerModel? _applyFreelancerModel;
  FreelancerModel? get freelancerDetails => _freelancerDetails;

  ApplyFreelancerModel? get applyFreelancerModel => _applyFreelancerModel;

  FreelancerModel? get selectedFreelancer => _selectedFreelancer;

  List<FreelancerModel>? get freelancerList => _freelancerList;
  ResponseModel? get responseModel => _responseModel;
  bool get isLoading => _isLoading;

  void setSelectedFreelancer({FreelancerModel? freelancer}) {
    _selectedFreelancer = freelancer ?? null;
    notifyListeners();
  }

  Future<void> getFreelancerList({int? categoryId}) async {
    try {
      final ApiResponseModel apiResponse =
          await freelancerRepo!.getFreelancerList(categoryId: categoryId);
      final responseData = apiResponse.response!.data;

      if (responseData["status"] == true) {
        _freelancerList = (responseData["data"] as List)
            .map((freelancer) => FreelancerModel.fromJson(freelancer))
            .toList();
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
    } catch (e) {
      // Handle any potential errors
      debugPrint('Error fetching freelancer list: $e');
      // You might want to set an error state here
    } finally {
      notifyListeners();
    }
  }

  void setCategoryID(
      {int? categoryID, bool isUpdate = true, bool isReload = false}) {
    if (isReload) {
      _selectedCategoryID = -1;
    } else {
      _selectedCategoryID = categoryID!;
    }
    if (isUpdate) {
      notifyListeners();
    }
  }

  void resetCategoryID() {
    _selectedCategoryID = -1;
    notifyListeners();
  }

  void updateFreelancerList(List<FreelancerModel> list) {
    _freelancerList = list;
    notifyListeners();
  }

  Future<List<FreelancerModel>> searchFreelancer(
    BuildContext context,
    String text,
  ) async {
    _predictionList = [];

    if (text.isNotEmpty) {
      ApiResponseModel apiResponse =
          await freelancerRepo!.searchFreelancer(text);

      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        final List<dynamic> freelancers =
            apiResponse.response!.data['data'] ?? [];

        _predictionList = freelancers
            .map((freelancerJson) => FreelancerModel.fromJson(freelancerJson))
            .toList();
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
    }

    return _predictionList;
  }

  Future<void> applyFreelancer(
      ApplyFreelancerModel applyFreelancerModelRequest, Function callback,
      {bool isUpdate = true}) async {
    _isLoading = true;
    if (isUpdate) {
      notifyListeners();
    }

    ApiResponseModel apiResponse =
        await freelancerRepo!.applyFreelancer(applyFreelancerModelRequest);
    print('=====RESPONSE====${apiResponse.response}');

    _isLoading = false;
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      String? message = apiResponse.response!.data['message'];
      callback(true, message);
    } else {
      callback(
          false, ApiCheckerHelper.getError(apiResponse).errors![0].message);
    }

    notifyListeners();
  }

  void stopLoader() {
    _isLoading = false;
    notifyListeners();
  }

  Future<ResponseModel?> getFreelancerDetails(String freelancerID,
      {bool isApiCheck = true}) async {
    _freelancerDetails = null;
    _isLoading = true;
    ApiResponseModel apiResponse;

    apiResponse = await freelancerRepo!.getFreelancerDetails(freelancerID);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      try {
        // Add a try-catch block for JSON parsing errors
        _freelancerDetails =
            FreelancerModel.fromJson(apiResponse.response!.data);
        _responseModel =
            ResponseModel(true, apiResponse.response!.data.toString());
        print("Heloooooooooooo: ${apiResponse.response!.data.toString()}");
      } catch (e) {
        print("Error parsing JSON: $e");
        _freelancerDetails =
            FreelancerModel(id: -1); // Or handle the error differently
        _responseModel = ResponseModel(false, "Error parsing booking details.");
      }
    } else {
      _freelancerDetails = FreelancerModel(id: -1);
      if (isApiCheck) {
        ApiCheckerHelper.checkApi(apiResponse);
      }
    }

    _isLoading = false;
    notifyListeners();
    return _responseModel;
  }

  double getDistanceBetween(LatLng startLatLng, LatLng endLatLng) {
    return Geolocator.distanceBetween(
      startLatLng.latitude,
      startLatLng.longitude,
      endLatLng.latitude,
      endLatLng.longitude,
    );
  }

  Future<BitmapDescriptor> createMarkerFromNetworkImage(String imageUrl) async {
    // 1. Load image from network
    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;

    // 2. Decode image with target width
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 70, // <-- width in pixels
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // 3. Create a circular canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint();
    final size = 70.0; // width & height
    final rect = Rect.fromLTWH(0, 0, size, size);
    final radius = size / 2;

    // Draw circular clip
    canvas.clipPath(Path()..addOval(rect));

    // Draw image into circular canvas
    paint.isAntiAlias = true;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      rect,
      paint,
    );

    // 4. Convert canvas to bytes
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bitmap = byteData!.buffer.asUint8List();

    // 5. Create BitmapDescriptor
    return BitmapDescriptor.fromBytes(bitmap);
  }
}
