class AdvertismentResponseModel {
  AdvertismentResponseModel({
    required this.data,
    required this.status,
    required this.message,
  });
  late final List<Advertise> data;
  late final bool status;
  late final String message;

  AdvertismentResponseModel.fromJson(Map<String, dynamic> json) {
    data = List.from(json['data']).map((e) => Advertise.fromJson(e)).toList();
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = data.map((e) => e.toJson()).toList();
    map['status'] = status;
    map['message'] = message;
    return map;
  }
}

class Advertise {
  Advertise({
    required this.image,
    required this.id,
    required this.title,
    required this.bannerType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  late final String image;
  late final String id;
  late final String title;
  late final String bannerType;
  late final bool isActive;
  late final String createdAt;
  late final String updatedAt;

  Advertise.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    id = json['_id'] ?? '';
    title = json['title'] ?? '';
    bannerType = json['bannerType'] ?? '';
    isActive = json['isActive'] ?? false;
    createdAt = json['createdAt'] ?? '';
    updatedAt = json['updatedAt'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['_id'] = id;
    data['title'] = title;
    data['bannerType'] = bannerType;
    data['isActive'] = isActive;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
