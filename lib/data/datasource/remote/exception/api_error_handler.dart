// ignore_for_file: empty_catches

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_restaurant/common/models/error_response_model.dart';
import 'package:flutter_restaurant/common/enums/app_mode_enum.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';

class ApiErrorHandler {
  static dynamic getMessage(error) {
    dynamic errorDescription = "";
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              errorDescription = "Request to API server was cancelled";
              break;

            case DioExceptionType.receiveTimeout:
              errorDescription = "Receive timeout in connection with API server";
              break;

            case DioExceptionType.badResponse:
              try {
                // 🧠 Add type safety before parsing
                var data = error.response?.data;

                if (data is Map<String, dynamic>) {
                  ErrorResponseModel errorResponse = ErrorResponseModel.fromJson(data);

                  if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
                    if (kDebugMode) {
                      print('error----------------== ${errorResponse.errors![0].message} || error: ${error.response!.requestOptions.uri}');
                    }
                    errorDescription = errorResponse.errors![0].message ?? "Unknown error";
                  } else if (data.containsKey('message')) {
                    errorDescription = data['message'];
                  } else {
                    errorDescription = "Failed to load data (invalid error format)";
                  }
                } else if (data is String) {
                  // 🧩 Handle plain string or HTML responses
                  if (kDebugMode) {
                    print('⚠️ Non-JSON error data: $data');
                  }
                  errorDescription = data;
                } else {
                  errorDescription = "Unexpected error response format";
                }
              } catch (e) {
                if (kDebugMode) {
                  print('error is -> ${e.toString()}');
                }
                errorDescription = "Failed to parse server error";
              }
              break;

            case DioExceptionType.sendTimeout:
            case DioExceptionType.connectionTimeout:
              errorDescription = getTranslated('send_timeout_with_server', Get.context!);
              break;

            case DioExceptionType.badCertificate:
              errorDescription = getTranslated('incorrect_certificate', Get.context!);
              break;

            case DioExceptionType.connectionError:
              errorDescription =
                  '${getTranslated('unavailable_to_process_data', Get.context!)} ${AppMode.demo == AppConstants.appMode ? error.response?.requestOptions.path : error.response?.statusCode}';
              break;

            case DioExceptionType.unknown:
              debugPrint(
                  'error----------------== ${error.response?.requestOptions.path} || ${error.response?.statusCode} ${error.response?.data}');
              errorDescription = getTranslated('unavailable_to_process_data', Get.context!);
              break;
          }
        } else {
          errorDescription = "Unexpected error occurred";
        }
      } on FormatException catch (e) {
        errorDescription = e.toString();
      } catch (e) {
        errorDescription = "Unknown exception: $e";
      }
    } else {
      errorDescription = "is not a subtype of exception";
    }
    return errorDescription;
  }
}
