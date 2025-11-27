class FreelancerMarkersModel {
  bool status;
  String message;
  List<Datum> data;

  FreelancerMarkersModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FreelancerMarkersModel.fromJson(Map<String, dynamic> json) {
    return FreelancerMarkersModel(
      status: json['status'],
      message: json['message'],
      data: List<Datum>.from(json['data'].map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }
}

class Datum {
  int freelancerId;
  int id;
  String name;
  String phone;
  String email;
  String userType;
  String fcmToken;
  String profilePicture;
  dynamic temporaryDisabled;
  String freelancerProfileUpdateRequest;
  String countryId;
  String countryName;
  String countryEmoji;
  String phoneCode;
  String freelancerRequestStatus;
  dynamic freelancerRequestNote;
  String about;
  String whatsappNumber;
  int categoryId;
  String categoryName;
  String categoryIcon;
  String cityId;
  String cityName;
  String latitude;
  String longitude;
  int rating;
  String promoted;
  dynamic price;
  String coverPicture;

  Datum({
    required this.freelancerId,
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.userType,
    required this.fcmToken,
    required this.profilePicture,
    required this.temporaryDisabled,
    required this.freelancerProfileUpdateRequest,
    required this.countryId,
    required this.countryName,
    required this.countryEmoji,
    required this.phoneCode,
    required this.freelancerRequestStatus,
    required this.freelancerRequestNote,
    required this.about,
    required this.whatsappNumber,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.cityId,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.promoted,
    required this.price,
    required this.coverPicture,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      freelancerId: json['freelancer_id'],
      id: json['id'],
      name: json['name'],
      phone: json['phone'] ?? "",
      email: json['email'] ?? "",
      userType: json['user_type'] ?? "",
      fcmToken: json['fcm_token'] ?? "",
      profilePicture: json['profile_picture'] ?? "",
      temporaryDisabled: json['temporary_disabled'],
      freelancerProfileUpdateRequest: json['freelancer_profile_update_request'] ?? "",
      countryId: json['country_id'].toString(),
      countryName: json['country_name'] ?? "",
      countryEmoji: json['country_emoji'] ?? "",
      phoneCode: json['phone_code'] ?? "",
      freelancerRequestStatus: json['freelancer_request_status'] ?? "",
      freelancerRequestNote: json['freelancer_request_note'],
      about: json['about'] ?? "",
      whatsappNumber: json['whatsapp_number'] ?? "",
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryIcon: json['category_icon'],
      cityId: json['city_id'].toString(),
      cityName: json['city_name'] ?? "",
      latitude: json['latitude'],
      longitude: json['longitude'],
      rating: json['rating'],
      promoted: json['promoted'],
      price: json['price'],
      coverPicture: json['cover_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "freelancer_id": freelancerId,
      "id": id,
      "name": name,
      "phone": phone,
      "email": email,
      "user_type": userType,
      "fcm_token": fcmToken,
      "profile_picture": profilePicture,
      "temporary_disabled": temporaryDisabled,
      "freelancer_profile_update_request": freelancerProfileUpdateRequest,
      "country_id": countryId,
      "country_name": countryName,
      "country_emoji": countryEmoji,
      "phone_code": phoneCode,
      "freelancer_request_status": freelancerRequestStatus,
      "freelancer_request_note": freelancerRequestNote,
      "about": about,
      "whatsapp_number": whatsappNumber,
      "category_id": categoryId,
      "category_name": categoryName,
      "category_icon": categoryIcon,
      "city_id": cityId,
      "city_name": cityName,
      "latitude": latitude,
      "longitude": longitude,
      "rating": rating,
      "promoted": promoted,
      "price": price,
      "cover_picture": coverPicture,
    };
  }
}
