class FreelancerCategoryResponse {
  int? freelancerId;
  String? name;
  String? profilePicture;
  int? categoryId;
  String? categoryName;
  String? categoryIcon;
  int? rating;

  FreelancerCategoryResponse({
    this.freelancerId,
    this.name,
    this.profilePicture,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.rating,
  });

  factory FreelancerCategoryResponse.fromJson(Map<String, dynamic> json) {
    return FreelancerCategoryResponse(
      freelancerId: json['freelancer_id'],
      name: json['name'],
      profilePicture: json['profile_picture'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryIcon: json['category_icon'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() => {
        'freelancer_id': freelancerId,
        'name': name,
        'profile_picture': profilePicture,
        'category_id': categoryId,
        'category_name': categoryName,
        'category_icon': categoryIcon,
        'rating': rating,
      };
}
