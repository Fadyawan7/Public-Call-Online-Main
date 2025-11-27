class FreelancerModel {
  // -------------------------
  // OLD KEYS (untouched)
  // -------------------------
  int? _id;
  String? _name;
  String? _phone;
  String? _email;
  String? _price;

  String? _image;
  String? _about;
  String? _country;
  String? _city;
  String? _city_id;
  String? _memberSince;
  String? _freelancerCategory;
  double? _latitude;
  double? _longitude;
  String? _status;
  String? _whatsapp;

  int? _totalJob;
  double? _avgRating;
  List<Portfolio>? _portfolio;
  List<FreelancerReviews>? _reviews;

  // -------------------------
  // NEW KEYS FROM API (ONLY ADDITIONS)
  // -------------------------
  int? _freelancerId;
  String? _userType;
  String? _fcmToken;
  String? _temporaryDisabled;
  String? _freelancerProfileUpdateRequest;
  String? _countryId;
  String? _countryEmoji;
  String? _phoneCode;
  String? _freelancerRequestNote;
  int? _categoryId;
  String? _categoryIcon;
  String? _promoted;
  String? _coverPicture;

  // -------------------------
  // CONSTRUCTOR
  // -------------------------
  FreelancerModel({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? price,
    String? country,
    String? city,
    String? city_id,
    String? memberSince,
    String? image,
    String? about,
    String? whatsapp,
    String? freelancerCategory,
    double? latitude,
    double? longitude,
    String? status,
    int? totalJob,
    double? avgRating,
    List<Portfolio>? portfolio,
    List<FreelancerReviews>? reviews,

    // NEW KEYS
    int? freelancerId,
    String? userType,
    String? fcmToken,
    String? temporaryDisabled,
    String? freelancerProfileUpdateRequest,
    String? countryId,
    String? countryEmoji,
    String? phoneCode,
    String? freelancerRequestNote,
    int? categoryId,
    String? categoryIcon,
    String? promoted,
    String? coverPicture,
  }) {
    _id = id;
    _name = name;
    _phone = phone;
    _email = email;
    _price = price;

    _image = image;
    _about = about;
    _whatsapp = whatsapp;
    _freelancerCategory = freelancerCategory;
    _latitude = latitude;
    _longitude = longitude;
    _status = status;
    _totalJob = totalJob;
    _avgRating = avgRating;
    _portfolio = portfolio;
    _reviews = reviews;

    _country = country;
    _city = city;
    _city_id = city_id;
    _memberSince = memberSince;

    // NEW KEYS
    _freelancerId = freelancerId;
    _userType = userType;
    _fcmToken = fcmToken;
    _temporaryDisabled = temporaryDisabled;
    _freelancerProfileUpdateRequest = freelancerProfileUpdateRequest;
    _countryId = countryId;
    _countryEmoji = countryEmoji;
    _phoneCode = phoneCode;
    _freelancerRequestNote = freelancerRequestNote;
    _categoryId = categoryId;
    _categoryIcon = categoryIcon;
    _promoted = promoted;
    _coverPicture = coverPicture;
  }

  // -------------------------
  // GETTERS
  // -------------------------
  int? get id => _id;
  String? get name => _name;
  String? get phone => _phone;
  String? get email => _email;
  String? get price => _price;
  String? get image => _image;
  String? get about => _about;
  String? get country => _country;
  String? get city => _city;
  String? get city_id => _city_id;
  String? get memberSince => _memberSince;
  String? get freelancerCategory => _freelancerCategory;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get status => _status;
  String? get whatsapp => _whatsapp;
  int? get totalJob => _totalJob;
  double? get avgRating => _avgRating;
  List<Portfolio>? get portfolio => _portfolio;
  List<FreelancerReviews>? get reviews => _reviews;

  // NEW KEYS GETTERS
  int? get freelancerId => _freelancerId;
  String? get userType => _userType;
  String? get fcmToken => _fcmToken;
  String? get temporaryDisabled => _temporaryDisabled;
  String? get freelancerProfileUpdateRequest =>
      _freelancerProfileUpdateRequest;
  String? get countryId => _countryId;
  String? get countryEmoji => _countryEmoji;
  String? get phoneCode => _phoneCode;
  String? get freelancerRequestNote => _freelancerRequestNote;
  int? get categoryId => _categoryId;
  String? get categoryIcon => _categoryIcon;
  String? get promoted => _promoted;
  String? get coverPicture => _coverPicture;

  // -------------------------
  // FROM JSON
  // -------------------------
  FreelancerModel.fromJson(Map<String, dynamic> json) {
    // OLD KEYS
    _id = json['id'];
    _name = json['name']?.toString();
    _phone = json['phone']?.toString();
    _email = json['email']?.toString();
    _price = json['price']?.toString();

    _image = json['profile_picture']?.toString();
    _about = json['about']?.toString();
    _country = json['country_name']?.toString();
    _city = json['city_name']?.toString();
    _city_id = json['city_id']?.toString();
    _memberSince = json['member_since']?.toString();
    _whatsapp = json['whatsapp_number']?.toString();
    _freelancerCategory = json['category_name']?.toString();
    _latitude = double.tryParse("${json['latitude']}");
    _longitude = double.tryParse("${json['longitude']}");
    _status = json['freelancer_request_status']?.toString();

    _totalJob = json['total_jobs'];
    _avgRating = double.tryParse("${json['rating']}");

    if (json['portfolio'] != null) {
      _portfolio = [];
      json['portfolio'].forEach((v) {
        _portfolio!.add(Portfolio.fromJson(v));
      });
    }

    if (json['reviews'] != null) {
      _reviews = [];
      json['reviews'].forEach((v) {
        _reviews!.add(FreelancerReviews.fromJson(v));
      });
    }

    // NEW KEYS
    _freelancerId = json['freelancer_id'];
    _userType = json['user_type'];
    _fcmToken = json['fcm_token'];
    _temporaryDisabled = json['temporary_disabled'];
    _freelancerProfileUpdateRequest =
        json['freelancer_profile_update_request'];
    _countryId = json['country_id']?.toString();
    _countryEmoji = json['country_emoji'];
    _phoneCode = json['phone_code']?.toString();
    _freelancerRequestNote = json['freelancer_request_note'];
    _categoryId = json['category_id'];
    _categoryIcon = json['category_icon'];
    _promoted = json['promoted'];
    _coverPicture = json['cover_picture'];
  }

  // -------------------------
  // TO JSON
  // -------------------------
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    // OLD KEYS
    data['id'] = _id;
    data['name'] = _name;
    data['phone'] = _phone;
    data['email'] = _email;
    data['price'] = _price;
    data['about'] = _about;
    data['profile_picture'] = _image;
    data['whatsapp_number'] = _whatsapp;
    data['category_name'] = _freelancerCategory;
    data['latitude'] = _latitude;
    data['longitude'] = _longitude;
    data['freelancer_request_status'] = _status;
    data['total_jobs'] = _totalJob;
    data['rating'] = _avgRating;
    data['country_name'] = _country;
    data['city_name'] = _city;
    data['city_id'] = _city_id;
    data['member_since'] = _memberSince;

    // NEW KEYS
    data['freelancer_id'] = _freelancerId;
    data['user_type'] = _userType;
    data['fcm_token'] = _fcmToken;
    data['temporary_disabled'] = _temporaryDisabled;
    data['freelancer_profile_update_request'] =
        _freelancerProfileUpdateRequest;
    data['country_id'] = _countryId;
    data['country_emoji'] = _countryEmoji;
    data['phone_code'] = _phoneCode;
    data['freelancer_request_note'] = _freelancerRequestNote;
    data['category_id'] = _categoryId;
    data['category_icon'] = _categoryIcon;
    data['promoted'] = _promoted;
    data['cover_picture'] = _coverPicture;

    return data;
  }
}


class Portfolio {
  int? _id;
  String? _imageUrl;
  Portfolio({
    int? id,
    String? imageUrl,
  }) {
    _id = id;
    _imageUrl = imageUrl;
  }

  int? get id => _id;
  String? get imageUrl => _imageUrl;

  Portfolio.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['image_url'] = _imageUrl;
    return data;
  }
}

class FreelancerReviews {
  int? _id;
  int? _rating;
  String? _comment;
  String? _giverName;
  String? _giverImage;
  String? _takerName;
  String? _takerImage;
  String? _createdAt;

  FreelancerReviews({
    int? id,
    int? rating,
    String? comment,
    String? giverName,
    String? giverImage,
    String? takerName,
    String? takerImage,
    String? createdAt,
  }) {
    _id = id;
    _rating = rating;
    _comment = comment;
    _giverName = giverName;
    _giverImage = giverImage;
    _takerName = takerName;
    _takerImage = takerImage;
    _createdAt = createdAt;
  }

  int? get id => _id;
  int? get rating => _rating;
  String? get comment => _comment;
  String? get giverName => _giverName;
  String? get giverImage => _giverImage;
  String? get takerName => _takerName;
  String? get takerImage => _takerImage;

  String? get createdAt => _createdAt;

  FreelancerReviews.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _rating = json['rating'];
    _comment = json['comment'];
    _giverName = json['giver_name'];
    _giverImage = json['giver_image'];
    _takerName = json['taker_name'];
    _takerImage = json['taker_image'];
    _createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['rating'] = _rating;
    data['comment'] = _comment;
    data['giver_name'] = _giverName;
    data['giver_image'] = _giverImage;
    data['taker_name'] = _takerName;
    data['taker_image'] = _takerImage;
    data['created_at'] = _createdAt;
    return data;
  }
}
