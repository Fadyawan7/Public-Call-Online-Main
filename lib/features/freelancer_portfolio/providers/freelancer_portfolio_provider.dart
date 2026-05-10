import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/response_model.dart';
import 'package:flutter_restaurant/features/freelancer_portfolio/domain/models/freelancer_portfolio_model.dart';
import 'package:flutter_restaurant/features/freelancer_portfolio/domain/reposotories/freelancer_portfolio_repo.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FreelancerPortfolioProvider extends ChangeNotifier {
  final FreelancerPortfolioRepo? freelancerPortfolioRepo;
  final SharedPreferences? sharedPreferences;
  FreelancerPortfolioProvider(
      {required this.sharedPreferences, required this.freelancerPortfolioRepo});

  ResponseModel? _responseModel;
  bool _isLoading = false;
  List<FreelancerPortfolioModel>? _freelancerPortfolioList;

  ResponseModel? get responseModel => _responseModel;

  bool get isLoading => _isLoading;
  List<FreelancerPortfolioModel>? get freelancerPortfolioList =>
      _freelancerPortfolioList;

  void stopLoader() {
    _isLoading = false;
    notifyListeners();
  }

  Future<ResponseModel> freelancerPortfolioAdd(File? file, String token) async {
    _isLoading = true;
    notifyListeners();
    ResponseModel responseModel;
    http.StreamedResponse response =
        await freelancerPortfolioRepo!.freelancerPortfolioAdd(file, token);
    final String responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      Map map = jsonDecode(responseBody);
      String? message = map["message"];
      responseModel = ResponseModel(true, message);
    } else {
      String errorMessage = '${response.statusCode} ${response.reasonPhrase}';
      try {
        final Map map = jsonDecode(responseBody);
        errorMessage = map['message']?.toString() ?? errorMessage;
      } catch (_) {}
      if (response.statusCode == 403) {
        errorMessage =
            'Portfolio upload is not allowed by server for this account yet.';
      }
      responseModel = ResponseModel(false, errorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<void> getFreelancerPortfolioList() async {
    _isLoading = true;

    ApiResponseModel apiResponse =
        await freelancerPortfolioRepo!.getFreelancerPortfolioList();
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _freelancerPortfolioList = [];
      apiResponse.response!.data.forEach((freelancerPortfolio) {
        FreelancerPortfolioModel freelancerPortfolioModel =
            FreelancerPortfolioModel.fromJson(freelancerPortfolio);
        freelancerPortfolioModel =
            FreelancerPortfolioModel.fromJson(freelancerPortfolio);
        _freelancerPortfolioList!.add(freelancerPortfolioModel);
      });
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    _isLoading = false;

    notifyListeners();
  }

  void deleteFreelancerPortfolio(int portfolioID, Function callback) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse =
        await freelancerPortfolioRepo!.deleteFreelancerPortfolio(
      portfolioID,
    );
    _isLoading = false;

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      FreelancerPortfolioModel? freelancerPortfolioModel;
      for (var freelancerPortfolio in _freelancerPortfolioList ?? []) {
        if (freelancerPortfolio.id == portfolioID) {
          freelancerPortfolioModel = freelancerPortfolio;
        }
      }
      _freelancerPortfolioList?.remove(freelancerPortfolioModel);
      callback(
        apiResponse.response!.data['message'],
        true,
      );
    } else {
      callback(
          ApiCheckerHelper.getError(apiResponse).errors?.first.message, false);
    }
    notifyListeners();
  }
}
