class BannerResponse {
  final bool? success;
  final String? message;
  final List<BannerData>? data;
  final int? status;

  BannerResponse({
    this.success,
    this.message,
    this.data,
    this.status,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<BannerData>.from(
              json['data'].map((x) => BannerData.fromJson(x)))
          : [],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((x) => x.toJson()).toList(),
      'status': status,
    };
  }
}

class BannerData {
  final int? id;
  final String? image;
  final String? url;
  final String? status;
  final String? isInternal;
  final String? createdAt;
  final String? updatedAt;

  BannerData({
    this.id,
    this.image,
    this.url,
    this.status,
    this.isInternal,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      id: json['id'],
      image: json['image'],
      url: json['url'],
      status: json['status'],
      isInternal: json['is_internal'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'url': url,
      'status': status,
      'is_internal': isInternal,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
