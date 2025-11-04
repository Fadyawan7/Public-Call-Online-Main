class CategoryModel {
  int? _id;
  String? _name;
  String? _image;
  double? _avgRating;
  int? _totalReviews;

  CategoryModel({
    int? id,
    String? name,
    String? image,
    double? avgRating,
    int? totalReviews,
  }) {
    _id = id;
    _name = name;
    _image = image;
    _avgRating = avgRating;
    _totalReviews = totalReviews;
  }

  int? get id => _id;
  String? get name => _name;
  String? get image => _image;
  double? get avgRating => _avgRating;
  int? get totalReviews => _totalReviews;

  CategoryModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'] ?? 0;
    _name = json['name'] ?? '';
    _image = json['icon_url'] ?? '';
    _avgRating = (json['avg_rating'] is int)
        ? (json['avg_rating'] as int).toDouble()
        : (json['avg_rating'] ?? 0.0);
    _totalReviews = json['total_reviews'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['icon_url'] = _image;
    data['avg_rating'] = _avgRating;
    data['total_reviews'] = _totalReviews;
    return data;
  }
}
