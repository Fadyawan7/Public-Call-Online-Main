class OnlyCategoryModel {
  int? id;
  String? name;
  String? iconUrl;

  OnlyCategoryModel({
    this.id,
    this.name,
    this.iconUrl,
  });

  factory OnlyCategoryModel.fromJson(Map<String, dynamic> json) {
    return OnlyCategoryModel(
      id: json['id'],
      name: json['name'],
      iconUrl: json['icon_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
    };
  }
}

/// Parse List
List<OnlyCategoryModel> OnlyCategoryModelFromJson(List<dynamic> list) =>
    list.map((e) => OnlyCategoryModel.fromJson(e)).toList();
