import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/enums/data_source_enum.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/category_model_response.dart';
import 'package:flutter_restaurant/common/models/product_model.dart';
import 'package:flutter_restaurant/common/providers/data_sync_provider.dart';
import 'package:flutter_restaurant/data/datasource/local/cache_response.dart';
import 'package:flutter_restaurant/features/category/domain/category_model.dart';
import 'package:flutter_restaurant/features/category/domain/reposotories/category_repo.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';

class CategoryProvider extends DataSyncProvider {
  final CategoryRepo? categoryRepo;

  CategoryProvider({required this.categoryRepo});

  List<OnlyCategoryModel>? _categoryList;
  List<FreelancerModel> _predictionList = [];

  List<CategoryModel>? _servicesList;

  List<CategoryModel>? _subCategoryList;
  ProductModel? _categoryProductModel;
  bool _pageFirstIndex = true;
  bool _pageLastIndex = false;
  bool _isLoading = false;
  String? _selectedSubCategoryId;

  List<OnlyCategoryModel>? get categoryList => _categoryList;
  List<FreelancerModel>? get predictionList => _predictionList;
  List<CategoryModel>? get servicesList => _servicesList;

  List<CategoryModel>? get subCategoryList => _subCategoryList;
  ProductModel? get categoryProductModel => _categoryProductModel;
  bool get pageFirstIndex => _pageFirstIndex;
  bool get pageLastIndex => _pageLastIndex;
  bool get isLoading => _isLoading;
  String? get selectedSubCategoryId => _selectedSubCategoryId;

  Future<List<FreelancerModel>> freelancerbyCategory(
    String text,
  ) async {
    _predictionList = [];
    notifyListeners();

    if (text.isNotEmpty) {
      ApiResponseModel apiResponse =
          await categoryRepo!.freelancerbyCategory(text);

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
    _isLoading = false;
    notifyListeners();
    return _predictionList;
  }

  Future<void> getCategoryList() async {
    if (_categoryList == null) {
      _isLoading = true;

      fetchAndSyncData(
        fetchFromLocal: () => categoryRepo!
            .getCategoryList<CacheResponseData>(source: DataSourceEnum.local),
        fetchFromClient: () =>
            categoryRepo!.getCategoryList(source: DataSourceEnum.client),
        onResponse: (data, _) {
          _categoryList = [];

          // 🧠 Safely handle different data formats (Map or List)
          dynamic extractedData = data;
          if (data is Map && data.containsKey('data')) {
            extractedData = data['data'];
          }

          if (extractedData is List) {
            for (var category in extractedData) {
              _categoryList!.add(OnlyCategoryModel.fromJson(category));
            }
          } else {
            debugPrint(
                '⚠️ Unexpected data format for category list: ${data.runtimeType}');
          }

          // ✅ Set default subcategory if available
          if (_categoryList!.isNotEmpty) {
            _selectedSubCategoryId = '${_categoryList?.first.id}';
          }

          _isLoading = false;
          notifyListeners();
        },
      );
    }
  }

  Future<void> getServicesList() async {
    try {
      _isLoading = true;
      notifyListeners();

      // 🚀 Always fetch fresh data since API is public
      final response =
          await categoryRepo!.getCategoryList(source: DataSourceEnum.client);

      dynamic extractedData = response.response.data;

      if (extractedData is Map && extractedData.containsKey('data')) {
        extractedData = extractedData['data'];
      }

      _servicesList = [];

      if (extractedData is List) {
        for (var category in extractedData) {
          _servicesList!.add(CategoryModel.fromJson(category));
        }
      } else {
        debugPrint("⚠ Unexpected data type: ${extractedData.runtimeType}");
      }

      // Set default selected category
      if (_servicesList!.isNotEmpty) {
        _selectedSubCategoryId = '${_servicesList!.first.id}';
      }
    } catch (e) {
      debugPrint("❌ Error loading categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
