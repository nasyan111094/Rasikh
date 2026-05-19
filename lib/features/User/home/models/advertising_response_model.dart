class AdvertismentResponseModel {
  AdvertismentResponseModel({
    required this.data,
    required this.status,
    required this.message,
  });
  late final Data data;
  late final bool status;
  late final String message;

  AdvertismentResponseModel.fromJson(Map<String, dynamic> json) {
    data = Data.fromJson(json['data']);
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = data.toJson();
    map['status'] = status;
    map['message'] = message;
    return map;
  }
}

class Data {
  Data({
    required this.listData,
    required this.paginationData,
  });
  late final List<Advertise> listData;
  late final PaginationData paginationData;

  Data.fromJson(Map<String, dynamic> json) {

    print(json['listData']);
    listData =
        List.from(json['listData']).map((e) => Advertise.fromJson(e)).toList();
    paginationData = PaginationData.fromJson(json['paginationData']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['listData'] = listData.map((e) => e.toJson()).toList();
    data['paginationData'] = paginationData.toJson();
    return data;
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

class PaginationData {
  PaginationData({
    required this.totalCount,
    required this.pageSize,
    required this.currentPage,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
  });
  late final int totalCount;
  late final int pageSize;
  late final int currentPage;
  late final int totalPages;
  late final bool hasPrevious;
  late final bool hasNext;

  PaginationData.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    pageSize = json['pageSize'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
    hasPrevious = json['hasPrevious'];
    hasNext = json['hasNext'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['totalCount'] = totalCount;
    data['pageSize'] = pageSize;
    data['currentPage'] = currentPage;
    data['totalPages'] = totalPages;
    data['hasPrevious'] = hasPrevious;
    data['hasNext'] = hasNext;
    return data;
  }
}
