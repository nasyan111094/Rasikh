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
    required this.date,
  });
  late final String image;
  late final String id;
  late final String date;

  Advertise.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    id = json['id'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['id'] = id;
    data['date'] = date;
    return data;
  }
}
