import 'package:flutter_restaurant/common/enums/data_source_enum.dart';
import 'package:flutter_restaurant/common/reposotories/data_sync_repo.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';

class CategoryRepo extends DataSyncRepo{
  CategoryRepo({required super.dioClient, required super.sharedPreferences});

  Future<ApiResponseModel<T>> getCategoryList<T>({required DataSourceEnum source}) async {

    return await fetchData<T>(AppConstants.categoryUri, source);
  }

//  Future<ApiResponseModel<T>> getServicesList<T>({required DataSourceEnum source}) async {

//     return await fetchData<T>(AppConstants.servicesCategories, source);
//   }



  Future<ApiResponseModel> freelancerbyCategory(String text, ) async {
    try {
      final response = await dioClient!.getWithoutToken('${AppConstants.frelanceCategoryUri}?categoryName=$text');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}