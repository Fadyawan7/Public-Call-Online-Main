import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/error_response_model.dart';
import 'package:flutter_restaurant/localization/app_localization.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:provider/provider.dart';

class ApiCheckerHelper {
  static void checkApi(ApiResponseModel apiResponse,{bool firebaseResponse = false} ) {
    ErrorResponseModel error = getError(apiResponse);
    final Errors firstError = (error.errors != null && error.errors!.isNotEmpty)
        ? error.errors!.first
        : Errors(
            code: '',
            message: apiResponse.error?.toString().trim().isNotEmpty == true
                ? apiResponse.error.toString().trim()
                : 'Something went wrong',
          );

    if ((firstError.code == '401' || firstError.code == 'auth-001') &&
        ModalRoute.of(Get.context!)?.settings.name != RouterHelper.loginScreen) {
      Provider.of<AuthProvider>(Get.context!, listen: false).clearSharedData(Get.context!).then((value) {
        if(Get.context != null && ModalRoute.of(Get.context!)?.settings.name != RouterHelper.loginScreen) {
          RouterHelper.getLoginRoute(action: RouteAction.pushNamedAndRemoveUntil);
        }
      });

    }else {
      final String message = firebaseResponse
          ? (firstError.message?.replaceAll('_', ' ').toCapitalized() ??
              'Something went wrong')
          : (firstError.message ?? 'Something went wrong');
      showCustomSnackBarHelper(message);
    }
  }

  static ErrorResponseModel getError(ApiResponseModel apiResponse){
    ErrorResponseModel error;

    try{
      error = ErrorResponseModel.fromJson(apiResponse);
    }catch(e){
      if(apiResponse.error is String){
        error = ErrorResponseModel(errors: [Errors(code: '', message: apiResponse.error.toString())]);

      }else{
        error = ErrorResponseModel.fromJson(apiResponse.error);
      }
    }
    return error;
  }
}
