/// Matches GET /api/v1/clients/profile response:
/// {
///   "success": true,
///   "data": {
///     "_id": "...",
///     "phone": "+966...",
///     "fullName": "...",
///     "email": "...",
///     "city": "...",
///     "avatar": "/uploads/client-avatars/...",   ← only on PUT response
///     "isActive": true,
///     "profileCompleted": true,
///     "createdAt": "...",
///     "updatedAt": "..."
///   }
/// }
///
/// PUT response wraps data the same way but uses "id" instead of "_id".

class UserModel {
  final bool success;
  final UserProfileData data;

  UserModel({required this.success, required this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      success: json['success'] as bool? ?? false,
      data: UserProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class UserProfileData {
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? city;
  final String? avatar; // relative path e.g. /uploads/client-avatars/xxx.jpg
  final bool isActive;
  final bool profileCompleted;
  final String? createdAt;
  final String? updatedAt;

  const UserProfileData({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.city,
    this.avatar,
    this.isActive = false,
    this.profileCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    // GET uses "_id", PUT response uses "id"
    final id = (json['_id'] ?? json['id'] ?? '') as String;
    return UserProfileData(
      id: id,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      avatar: json['avatar'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'city': city,
      'avatar': avatar,
      'isActive': isActive,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
  UserProfileData copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? city,
    String? avatar,
    bool? isActive,
    bool? profileCompleted,
  }) {
    return UserProfileData(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
