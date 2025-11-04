import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/enums/data_source_enum.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/product_model.dart';
import 'package:flutter_restaurant/common/providers/data_sync_provider.dart';
import 'package:flutter_restaurant/data/datasource/local/cache_response.dart';
import 'package:flutter_restaurant/features/category/domain/category_model.dart';
import 'package:flutter_restaurant/features/category/domain/reposotories/category_repo.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';

class CategoryProvider extends DataSyncProvider {
  final CategoryRepo? categoryRepo;

  CategoryProvider({required this.categoryRepo});

  List<CategoryModel>? _categoryList;
    List<CategoryModel>? _servicesList;

  List<CategoryModel>? _subCategoryList;
  ProductModel? _categoryProductModel;
  bool _pageFirstIndex = true;
  bool _pageLastIndex = false;
  bool _isLoading = false;
  String? _selectedSubCategoryId;

  List<CategoryModel>? get categoryList => _categoryList;
    List<CategoryModel>? get servicesList => _servicesList;

  List<CategoryModel>? get subCategoryList => _subCategoryList;
  ProductModel? get categoryProductModel => _categoryProductModel;
  bool get pageFirstIndex => _pageFirstIndex;
  bool get pageLastIndex => _pageLastIndex;
  bool get isLoading => _isLoading;
  String? get selectedSubCategoryId => _selectedSubCategoryId;

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
              _categoryList!.add(CategoryModel.fromJson(category));
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
    if (_servicesList == null) {
      _isLoading = true;

      fetchAndSyncData(
        fetchFromLocal: () => categoryRepo!
            .getCategoryList<CacheResponseData>(source: DataSourceEnum.local),
        fetchFromClient: () =>
            categoryRepo!.getCategoryList(source: DataSourceEnum.client),
        onResponse: (data, _) {
          _servicesList = [];

          // 🧠 Safely handle different data formats (Map or List)
          dynamic extractedData = data;
          if (data is Map && data.containsKey('data')) {
            extractedData = data['data'];
          }

          if (extractedData is List) {
            for (var category in extractedData) {
              _servicesList!.add(CategoryModel.fromJson(category));
            }
          } else {
            debugPrint(
                '⚠️ Unexpected data format for category list: ${data.runtimeType}');
          }

          // ✅ Set default subcategory if available
          if (_servicesList!.isNotEmpty) {
            _selectedSubCategoryId = '${_servicesList?.first.id}';
          }

          _isLoading = false;
          notifyListeners();
        },
      );
    }
  }




}
