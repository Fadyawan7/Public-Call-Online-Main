class ApplyFreelancerModel {
  List<int>? category_id;
  String? about;
  String? whatsapp_number;
  String? per_side;
  String? price;
  String? per_hour;
  String? other_category;

  String? cover_picture;

  ApplyFreelancerModel({
    this.category_id,
    this.about,
    this.whatsapp_number,
    this.price,
    this.per_side,
    this.per_hour,
    this.other_category,
    this.cover_picture,
  });

  ApplyFreelancerModel.fromJson(Map<String, dynamic> json) {
    // backend now sends category_id as a list of ints
    final dynamic cat = json['category_id'];
    if (cat is List) {
      try {
        category_id = cat.map<int>((e) => int.parse(e.toString())).toList();
      } catch (_) {
        category_id = [];
      }
    } else if (cat is int) {
      category_id = [cat];
    } else {
      category_id = null;
    }
    about = json['about'];
    whatsapp_number = json['whatsapp_number'];
    price = json['price'];
    per_side = json['per_side'];
    per_hour = json['per_hour'];
    other_category = json['other_category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['about'] = about;
    data['whatsapp_number'] = whatsapp_number;
    data['price'] = price;
    data['per_side'] = per_side;
    data['per_hour'] = per_hour;
    if (category_id != null && category_id!.isNotEmpty) {
      data['category_id'] = category_id;
    }
    if (other_category != null && other_category!.trim().isNotEmpty) {
      data['other_category'] = other_category;
    }

    return data;
  }
}
