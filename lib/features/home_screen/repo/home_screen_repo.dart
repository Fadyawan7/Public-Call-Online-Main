import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_restaurant/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';

class HomeScreenRepo {
  final DioClient? dioClient;
  HomeScreenRepo({this.dioClient});



Future<ApiResponseModel> freelanceCategory([int? categoryId]) async {
  try {
    String url = AppConstants.frelanceCategoryUri;

    // ✅ If categoryId is provided, append it
    if (categoryId != null) {
      url = '$url$categoryId';
    }

    final response = await dioClient!.get(url);
    return ApiResponseModel.withSuccess(response);
  } catch (e) {
    return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
  }
}





Future<ApiResponseModel> freelanceAllCategory() async {
  try {
    final response = await dioClient!.get(
      AppConstants.allFreelances,
    );
    return ApiResponseModel.withSuccess(response);
  } catch (e) {
    return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
  }
}





}
