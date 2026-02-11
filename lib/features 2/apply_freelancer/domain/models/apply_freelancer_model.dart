class ApplyFreelancerModel {
  int? category_id;
  String? about;
  String? whatsapp_number;
  String? per_side;
  String? price;
  String? per_hour;

  String? cover_picture;

  ApplyFreelancerModel({
    this.category_id,
    this.about,
    this.whatsapp_number,
    this.price,
    this.per_side,
        this.per_hour,

    this.cover_picture,
  });

  ApplyFreelancerModel.fromJson(Map<String, dynamic> json) {
    category_id = json['category_id'];
    about = json['about'];
    whatsapp_number = json['whatsapp_number'];
    price = json['price'];
    per_side = json['per_side'];
        per_hour = json['per_hour'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category_id'] = category_id;
    data['about'] = about;
    data['whatsapp_number'] = whatsapp_number;
    data['price'] = price;
    data['per_side'] = per_side;
    data['per_hour'] = per_hour;

    return data;
  }
}
