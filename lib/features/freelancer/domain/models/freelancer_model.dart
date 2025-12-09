class FreelancerModel {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? price;
  String? per_side;
  String? per_hour;

  String? image;
  String? cover_picture;

  String? about;
  String? country;
  String? category_name;

  String? city;
  String? city_id;
  String? member_since;
  String? category;
  double? latitude;
  double? longitude;
  String? current_status;
  String? whatsapp_number;

  int? total_jobs;
  double? average_rating;
  double? rating;

  List<Portfolio>? portfolio;
  List<FreelancerReviews>? reviews;

  int? freelancer_id;
  String? userType;
  String? fcmToken;
  String? temporaryDisabled;
  String? freelancerProfileUpdateRequest;
  String? countryId;
  String? countryEmoji;
  String? phoneCode;
  String? freelancerRequestNote;
  int? category_id;
  String? categoryIcon;
  String? promoted;
  String? coverPicture;

  FreelancerModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.price,
    this.per_side,
    this.per_hour,
    this.image,
    this.cover_picture,
    this.about,
    this.country,
    this.city,
    this.city_id,
    this.member_since,
    this.category,
    this.category_name,
    this.rating,
    this.latitude,
    this.longitude,
    this.current_status,
    this.whatsapp_number,
    this.total_jobs,
    this.average_rating,
    this.portfolio,
    this.reviews,
    this.freelancer_id,
    this.userType,
    this.fcmToken,
    this.temporaryDisabled,
    this.freelancerProfileUpdateRequest,
    this.countryId,
    this.countryEmoji,
    this.phoneCode,
    this.freelancerRequestNote,
    this.category_id,
    this.categoryIcon,
    this.promoted,
    this.coverPicture,
  });

  factory FreelancerModel.fromJson(Map<String, dynamic> json) =>
      FreelancerModel(
        id: json['id'] is int ? json['id'] : int.tryParse("${json['id']}"),
        name: json['name']?.toString(),
        phone: json['phone']?.toString(),
        email: json['email']?.toString(),
        price: json['price']?.toString(),
        per_side: json['per_side']?.toString(),
        per_hour: json['per_hour']?.toString(),
        image: json['profile_picture']?.toString(),
        cover_picture: json['cover_picture']?.toString(),
        about: json['about']?.toString(),
        country: json['country_name']?.toString(),
        city: json['city']?.toString(),
        city_id: json['city_id']?.toString(),
        member_since: json['member_since']?.toString(),
        category: json['category']?.toString(),
        category_name: json['category_name']?.toString(),
        latitude: json['latitude'] is double
            ? json['latitude']
            : double.tryParse("${json['latitude']}"),
        longitude: json['longitude'] is double
            ? json['longitude']
            : double.tryParse("${json['longitude']}"),
        current_status: json['current_status']?.toString(),
        whatsapp_number: json['whatsapp_number']?.toString(),
        total_jobs: json['total_jobs'] is int
            ? json['total_jobs']
            : int.tryParse("${json['total_jobs']}"),
        average_rating: json['average_rating'] is double
            ? json['average_rating']
            : double.tryParse("${json['average_rating']}"),
        rating: json['rating'] is double
            ? json['rating']
            : double.tryParse("${json['rating']}"),
        portfolio: json['portfolio'] != null
            ? List<Portfolio>.from(
                json['portfolio'].map((x) => Portfolio.fromJson(x)))
            : null,
        reviews: json['reviews'] != null
            ? List<FreelancerReviews>.from(
                json['reviews'].map((x) => FreelancerReviews.fromJson(x)))
            : null,
        freelancer_id: json['freelancer_id'] is int
            ? json['freelancer_id']
            : int.tryParse("${json['freelancer_id']}"),
        userType: json['user_type']?.toString(),
        fcmToken: json['fcm_token']?.toString(),
        temporaryDisabled: json['temporary_disabled']?.toString(),
        freelancerProfileUpdateRequest:
            json['freelancer_profile_update_request']?.toString(),
        countryId: json['country_id']?.toString(),
        countryEmoji: json['country_emoji']?.toString(),
        phoneCode: json['phone_code']?.toString(),
        freelancerRequestNote: json['freelancer_request_note']?.toString(),
        category_id: json['category_id'] is int
            ? json['category_id']
            : int.tryParse("${json['category_id']}"),
        categoryIcon: json['category_icon']?.toString(),
        promoted: json['promoted']?.toString(),
        coverPicture: json['cover_picture']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'price': price,
        'per_side': per_side,
        'per_hour': per_hour,
        'profile_picture': image,
        'cover_picture': cover_picture,
        'about': about,
        'country_name': country,
        'category_name': category_name,
        'city': city,
        'city_id': city_id,
        'member_since': member_since,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'current_status': current_status,
        'whatsapp_number': whatsapp_number,
        'total_jobs': total_jobs,
        'rating': average_rating,
        'rating': rating,
        'portfolio': portfolio?.map((x) => x.toJson()).toList(),
        'reviews': reviews?.map((x) => x.toJson()).toList(),
        'freelancer_id': freelancer_id,
        'user_type': userType,
        'fcm_token': fcmToken,
        'temporary_disabled': temporaryDisabled,
        'freelancer_profile_update_request': freelancerProfileUpdateRequest,
        'country_id': countryId,
        'country_emoji': countryEmoji,
        'phone_code': phoneCode,
        'freelancer_request_note': freelancerRequestNote,
        'category_id': category_id,
        'category_icon': categoryIcon,
        'promoted': promoted,
        'cover_picture': coverPicture,
      };
}

class Portfolio {
  int? id;
  String? imageUrl;

  Portfolio({this.id, this.imageUrl});

  factory Portfolio.fromJson(Map<String, dynamic> json) => Portfolio(
        id: json['id'],
        imageUrl: json['image_url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_url': imageUrl,
      };
}

class FreelancerReviews {
  int? id;
  int? rating;
  String? comment;
  String? giverName;
  String? giverImage;
  String? takerName;
  String? takerImage;
  String? createdAt;

  FreelancerReviews({
    this.id,
    this.rating,
    this.comment,
    this.giverName,
    this.giverImage,
    this.takerName,
    this.takerImage,
    this.createdAt,
  });

  factory FreelancerReviews.fromJson(Map<String, dynamic> json) =>
      FreelancerReviews(
        id: json['id'],
        rating: json['rating'],
        comment: json['comment'],
        giverName: json['giver_name'],
        giverImage: json['giver_image'],
        takerName: json['taker_name'],
        takerImage: json['taker_image'],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'rating': rating,
        'comment': comment,
        'giver_name': giverName,
        'giver_image': giverImage,
        'taker_name': takerName,
        'taker_image': takerImage,
        'created_at': createdAt,
      };
}
