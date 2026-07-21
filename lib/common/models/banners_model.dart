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
  final int? status;
  final int? isInternal;
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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      image: json['image']?.toString(),
      url: json['url']?.toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ''),
      isInternal: json['is_internal'] is int
          ? json['is_internal']
          : int.tryParse(json['is_internal']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
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
