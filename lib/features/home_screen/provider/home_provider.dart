import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/banners_model.dart';
import 'package:flutter_restaurant/common/models/freelance_category_response.dart';
import 'package:flutter_restaurant/features/address/domain/reposotories/location_repo.dart';
import 'package:flutter_restaurant/features/home_screen/repo/home_screen_repo.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';

class HomeProvider with ChangeNotifier {
  final LocationRepo? locationRepo;
    final HomeScreenRepo? repo;

  HomeProvider({this.locationRepo,this.repo});

  List<String> _bannerList = [];
  List<String> get bannerList => _bannerList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  List<FreelancerCategoryResponse> _freelancers = [];
  List<FreelancerCategoryResponse> get freelancers => _freelancers;

  List<FreelancerCategoryResponse> _allFreelancers = [];
  List<FreelancerCategoryResponse> get allFreelancers => _allFreelancers;


  Future<void> getBanners() async {
    _isLoading = true;
    notifyListeners();

    try {
      ApiResponseModel response = await locationRepo!.getBanners();

      if (response.response?.statusCode == 200 &&
          response.response?.data != null) {
        // ✅ Parse the response into your model
        final bannerResponse = BannerResponse.fromJson(response.response?.data);

        if (bannerResponse.success == true && bannerResponse.data != null) {
          _bannerList = bannerResponse.data!
              .map((banner) => banner.image ?? '')
              .where((img) => img.isNotEmpty)
              .toList();

          debugPrint("✅ Banners loaded: $_bannerList");
        } else {
          debugPrint("⚠️ No banners found or success=false");
        }
      } else {
        ApiCheckerHelper.checkApi(response);
      }
    } catch (e) {
      debugPrint("❌ Error loading banners: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  ///....................  get freelance category//////////////////
  ///
Future<void> fetchFreelancersByCategory(int categoryId) async {
  _isLoading = true;
  notifyListeners();

  try {
    ApiResponseModel response = await repo!.freelanceCategory(categoryId);

    if (response.response?.statusCode == 200 &&
        response.response?.data != null) {
      final data = response.response!.data['data'] as List<dynamic>;
      _freelancers = data
          .map((json) => FreelancerCategoryResponse.fromJson(json))
          .toList();
    } else {
      _freelancers = [];
    }
  } catch (e) {
    _freelancers = [];
    debugPrint("❌ Error in fetchFreelancersByCategory: $e");
  }

  _isLoading = false;
  notifyListeners();
}


Future<void> freelanceAllCategory() async {
  _isLoading = true;
  notifyListeners();

  try {
    ApiResponseModel response = await repo!.freelanceAllCategory();

    if (response.response?.statusCode == 200 &&
        response.response?.data != null) {
      final data = response.response!.data['data'] as List<dynamic>;
      _allFreelancers = data
          .map((json) => FreelancerCategoryResponse.fromJson(json))
          .toList();
    } else {
      _allFreelancers = [];
    }
  } catch (e) {
    _allFreelancers = [];
    debugPrint("❌ Error in fetchFreelancersByCategory: $e");
  }

  _isLoading = false;
  notifyListeners();
}

}
