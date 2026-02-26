import 'package:flutter_restaurant/data/datasource/remote/dio/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreelancerRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  FreelancerRepo({required this.dioClient, required this.sharedPreferences});


}