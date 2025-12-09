import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_restaurant/data/datasource/remote/dio/logging_interceptor.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final String baseUrl;
  final LoggingInterceptor loggingInterceptor;
  final SharedPreferences sharedPreferences;

  Dio? dio;
  String? token;

  DioClient(this.baseUrl,
      Dio? dioC, {
        required this.loggingInterceptor,
        required this.sharedPreferences,
      }) {
    token = sharedPreferences.getString(AppConstants.token);
    dio = dioC ?? Dio();

    updateHeader(dioC: dioC, getToken: token);


  }

  Future<void> updateHeader({String? getToken, Dio? dioC})async {
    dio
      ?..options.baseUrl = baseUrl
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..httpClientAdapter
      ..options.headers = {

        // 'Content-Type': 'application/json; charset=UTF-8',
        'X-localization': sharedPreferences.getString(AppConstants.languageCode)
            ?? AppConstants.languages[0].languageCode,
        'Authorization': 'Bearer $getToken',

      };
    dio?.interceptors.add(loggingInterceptor);
  }



  Future<Response> get(String uri, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      debugPrint('apiCall ==> url=> $uri \nparams---> $queryParameters\nheader=> ${dio!.options.headers}');

      var response = await dio!.get(
        uri,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      debugPrint('apiCalll ==${response.data}');

      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }
Future<Response> getWithoutToken(String uri, {
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
  ProgressCallback? onReceiveProgress,
}) async {
  try {
    // Clone dio headers
    Map<String, String> headers = Map.from(dio!.options.headers);

    // Remove Authorization header
    headers.remove('Authorization');

    debugPrint('apiCall (without token) ==> url=> $uri \nparams---> $queryParameters\nheader=> $headers');

    var response = await dio!.get(
      uri,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      options: Options(headers: headers),
    );

    debugPrint('apiCalll ==${response.data}');
    return response;
  } catch (e) {
    rethrow;
  }
}

  Future<Response> post(String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,  Options? options,
  }) async {
    try {
      debugPrint('apiCall ==> url=> $uri \nparams---> $queryParameters\nheader=> ${dio!.options.headers} \nbody---> $data');

      var response = await dio!.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    debugPrint('apiCall ==> url=> $uri \nparams---> $queryParameters\nheader=> ${dio!.options.headers}');

    try {
      var response = await dio!.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    debugPrint('apiCall ==> url=> $uri \nparams---> $queryParameters\nheader=> ${dio!.options.headers}');

    try {
      var response = await dio!.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }


  Future<Response> postMultipart(String uri, {
    Map<String, dynamic>? data,
    List<XFile?>? files,
    String? fileKey,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    debugPrint('apiCall ==> url=> $uri \nparams---> $queryParameters\nheader=> ${dio!.options.headers}');

    try{
      List<MultipartFile> fileList = [];

      if(files != null) {
        for(int i = 0; i < files.length; i++) {
          fileList.add(MultipartFile.fromBytes(
            await files[i]!.readAsBytes(),
            filename: files[i]!.name,
          ));
        }
      }

      if(fileList.isNotEmpty) {
        data?.addAll({
          '${fileKey ?? 'image'}[]' : fileList,
        });
      }

      print('-------data---- $fileList');

    }catch(e) {
      rethrow;
    }




    try {
      var response = await dio!.post(
        uri,
        data: FormData.fromMap(data ?? {}),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

Future<Response> postMultipartImages(String uri, {
  Map<String, dynamic>? data,
  List<XFile?>? files,
  String? fileKey,
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
  ProgressCallback? onSendProgress,
  ProgressCallback? onReceiveProgress,
}) async {

  // 🔥 Override header JUST for this request
  Options newOptions = Options(
    headers: {
      ...dio!.options.headers,
      'Content-Type': 'multipart/form-data',
    },
  );

  try {
    List<MultipartFile> fileList = [];

    if (files != null) {
      for (var f in files) {
        if (f != null) {
          fileList.add(MultipartFile.fromBytes(
            await f.readAsBytes(),
            filename: f.name,
          ));
        }
      }
    }

    if (fileList.isNotEmpty) {
      data?.addAll({ fileKey ?? "image": fileList.first });
    }

    final response = await dio!.post(
      uri,
      data: FormData.fromMap(data ?? {}),
      options: newOptions, // 👈 ONLY MULTIPART uses this
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return response;

  } catch (e) {
    rethrow;
  }
}



}
