class UserProfileModel {
  UserProfileModel({
    required this.message,
    required this.status,
    required this.data,
  });
  late final String message;
  late final bool status;
  late final UserProfileData data;

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    data = UserProfileData.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    data['data'] = data.values.map((user) => user.toJson()).toList();
    ;
    return data;
  }
}

class UserProfileData {
  UserProfileData({
    required this.id,
    required this.fullName,
    required this.email,
    required this.nationalId,
    required this.gender,
    required this.genderName,
    required this.image,
    required this.phoneNumber,
  });
  late final int id;
  late final String? fullName;
  late final String? email;
  late final String? nationalId;
  late final int? gender;
  late final String? genderName;
  late final String? image;
  late final String? phoneNumber;

  UserProfileData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 1;
    phoneNumber = json['phoneNumber'] ?? "";
    fullName = json['fullName'] ?? "";
    email = json['email'] ?? "";
    nationalId = json['nationalId'] ?? "1111111111";
    gender = json['gender'] ?? 0;
    genderName = json['genderName'] ?? "";
    image = json['image'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['phoneNumber'] = phoneNumber;
    data['email'] = email;
    data['nationalId'] = nationalId;
    data['gender'] = gender;
    data['genderName'] = genderName;
    data['image'] = image;
    return data;
  }
}
