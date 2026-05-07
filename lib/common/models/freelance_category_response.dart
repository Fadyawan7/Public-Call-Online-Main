class FreelancerCategoryResponse {
  int? id;

  int? freelancerId;

  String? name;
  String? profilePicture;
  int? categoryId;
  String? categoryName;
  String? categoryIcon;
  int? rating;
  String? cover_picture;
  int? price;

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String)
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    return null;
  }

  FreelancerCategoryResponse({
    this.id,
    this.freelancerId,
    this.name,
    this.profilePicture,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.rating,
    this.cover_picture,
    this.price,
  });

  factory FreelancerCategoryResponse.fromJson(Map<String, dynamic> json) {
    return FreelancerCategoryResponse(
      freelancerId: _asInt(json['freelancer_id']),
      id: _asInt(json['id']),
      name: json['name'],
      profilePicture: json['profile_picture'],
      categoryId: _asInt(json['category_id']),
      categoryName: json['category_name'],
      categoryIcon: json['category_icon'],
      rating: _asInt(json['rating']),
      cover_picture: json['cover_picture'],
      price: _asInt(json['price']),
    );
  }

  Map<String, dynamic> toJson() => {
        'freelancer_id': freelancerId,
        'id': id,
        'name': name,
        'profile_picture': profilePicture,
        'category_id': categoryId,
        'category_name': categoryName,
        'category_icon': categoryIcon,
        'rating': rating,
        'cover_picture': cover_picture,
        'price': price,
      };
}
