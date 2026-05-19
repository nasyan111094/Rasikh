// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/profile/data/models/lawyer_profile_model.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

class LawyerProfileModel {
  final String id;
  final String phone;
  final String fullName;
  final String? email;
  final String? city;
  final String? photoUrl;
  final String? nationalId;
  final String? nationalIdDocumentUrl;
  final String? commercialRegistrationDocumentUrl;
  final String? bio;
  final LicenseModel? license;
  final bool isCompany;
  final String? commercialRegistrationNumber;
  final String? qualifications;
  final int? experienceYears;
  final List<SpecializationModel> mainSpecializations;
  final List<SpecializationModel> subSpecializations;
  final List<SpecializationByMainModel> specializationsByMain;
  final bool acceptedTerms;
  final String status;
  final String accountStatus;
  final String activityStatus;
  final bool profileCompleted;
  final bool otpVerified;
  final double? rating;
  final String? createdAt;
  final String? updatedAt;

  const LawyerProfileModel({
    required this.id,
    required this.phone,
    required this.fullName,
    this.email,
    this.city,
    this.photoUrl,
    this.nationalId,
    this.nationalIdDocumentUrl,
    this.commercialRegistrationDocumentUrl,
    this.bio,
    this.license,
    this.isCompany = false,
    this.commercialRegistrationNumber,
    this.qualifications,
    this.experienceYears,
    this.mainSpecializations = const [],
    this.subSpecializations = const [],
    this.specializationsByMain = const [],
    this.acceptedTerms = false,
    this.status = '',
    this.accountStatus = '',
    this.activityStatus = '',
    this.profileCompleted = false,
    this.otpVerified = false,
    this.rating,
    this.createdAt,
    this.updatedAt,
  });

  factory LawyerProfileModel.fromJson(Map<String, dynamic> json) {
    return LawyerProfileModel(
      id: json['_id'] ?? '',
      phone: json['phone'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'],
      city: json['city'],
      photoUrl: json['photoUrl'],
      nationalId: json['nationalId'],
      nationalIdDocumentUrl: json['nationalIdDocumentUrl'],
      commercialRegistrationDocumentUrl:
      json['commercialRegistrationDocumentUrl'],
      bio: json['bio'],
      license: json['license'] != null
          ? LicenseModel.fromJson(json['license'])
          : null,
      isCompany: json['isCompany'] ?? false,
      commercialRegistrationNumber: json['commercialRegistrationNumber'],
      qualifications: json['qualifications'],
      experienceYears: json['experienceYears'],
      mainSpecializations: (json['mainSpecializations'] as List<dynamic>?)
          ?.map((e) => SpecializationModel.fromJson(e))
          .toList() ??
          [],
      subSpecializations: (json['subSpecializations'] as List<dynamic>?)
          ?.map((e) => SpecializationModel.fromJson(e))
          .toList() ??
          [],
      specializationsByMain:
      (json['specializationsByMain'] as List<dynamic>?)
          ?.map((e) => SpecializationByMainModel.fromJson(e))
          .toList() ??
          [],
      acceptedTerms: json['acceptedTerms'] ?? false,
      status: json['status'] ?? '',
      accountStatus: json['accountStatus'] ?? '',
      activityStatus: json['activityStatus'] ?? '',
      profileCompleted: json['profileCompleted'] ?? false,
      otpVerified: json['otpVerified'] ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'phone': phone,
    'fullName': fullName,
    if (email != null) 'email': email,
    if (city != null) 'city': city,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (nationalId != null) 'nationalId': nationalId,
    if (bio != null) 'bio': bio,
    if (experienceYears != null) 'experienceYears': experienceYears,
    'isCompany': isCompany,
    'accountStatus': accountStatus,
    'createdAt': createdAt,
  };

  LawyerProfileModel copyWith({
    String? fullName,
    String? email,
    String? city,
    String? photoUrl,
    String? bio,
    int? experienceYears,
    LicenseModel? license,
    String? nationalId,
    String? commercialRegistrationNumber,
  }) {
    return LawyerProfileModel(
      id: id,
      phone: phone,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      city: city ?? this.city,
      photoUrl: photoUrl ?? this.photoUrl,
      nationalIdDocumentUrl: nationalIdDocumentUrl,
      commercialRegistrationDocumentUrl: commercialRegistrationDocumentUrl,
      bio: bio ?? this.bio,
      license: license ?? this.license,
      isCompany: isCompany,
      commercialRegistrationNumber:
      commercialRegistrationNumber ?? this.commercialRegistrationNumber,
      qualifications: qualifications,
      experienceYears: experienceYears ?? this.experienceYears,
      mainSpecializations: mainSpecializations,
      subSpecializations: subSpecializations,
      specializationsByMain: specializationsByMain,
      acceptedTerms: acceptedTerms,
      status: status,
      accountStatus: accountStatus,
      activityStatus: activityStatus,
      profileCompleted: profileCompleted,
      otpVerified: otpVerified,
      rating: rating,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nationalId: nationalId ?? this.nationalId,
    );
  }
}

// ── License ───────────────────────────────────────────────────────────────────

class LicenseModel {
  final String? number;
  final String? imageUrl;
  final String? expiryDate;
  final String? status;

  const LicenseModel({
    this.number,
    this.imageUrl,
    this.expiryDate,
    this.status,
  });

  factory LicenseModel.fromJson(Map<String, dynamic> json) => LicenseModel(
    number: json['number'],
    imageUrl: json['imageUrl'],
    expiryDate: json['expiryDate'],
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    if (number != null) 'number': number,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (expiryDate != null) 'expiryDate': expiryDate,
    if (status != null) 'status': status,
  };
}

// ── Specialization ────────────────────────────────────────────────────────────

class SpecializationModel {
  final String id;
  final String name;
  final String? status;

  const SpecializationModel({
    required this.id,
    required this.name,
    this.status,
  });

  factory SpecializationModel.fromJson(Map<String, dynamic> json) =>
      SpecializationModel(
        id: json['id'] ?? json['_id'] ?? '',
        name: json['name'] ?? '',
        status: json['status'],
      );
}

// ── SpecializationByMain ─────────────────────────────────────────────────────

class SpecializationByMainModel {
  final String id;
  final String name;
  final String? status;
  final List<SpecializationModel> selectedSubSpecializations;

  const SpecializationByMainModel({
    required this.id,
    required this.name,
    this.status,
    this.selectedSubSpecializations = const [],
  });

  factory SpecializationByMainModel.fromJson(Map<String, dynamic> json) =>
      SpecializationByMainModel(
        id: json['id'] ?? json['_id'] ?? '',
        name: json['name'] ?? '',
        status: json['status'],
        selectedSubSpecializations:
        (json['selectedSubSpecializations'] as List<dynamic>?)
            ?.map((e) => SpecializationModel.fromJson(e))
            .toList() ??
            [],
      );
}

// ── Update Profile Request ────────────────────────────────────────────────────

class UpdateProfileRequest {
  final String? fullName;
  final String? email;
  final String? city;
  final String? bio;
  final int? experienceYears;

  const UpdateProfileRequest({
    this.fullName,
    this.email,
    this.city,
    this.bio,
    this.experienceYears,
  });

  Map<String, String> toFormFields() {
    final map = <String, String>{};
    if (fullName != null && fullName!.isNotEmpty) map['fullName'] = fullName!;
    if (email != null && email!.isNotEmpty) map['email'] = email!;
    if (city != null && city!.isNotEmpty) map['city'] = city!;
    if (bio != null && bio!.isNotEmpty) map['bio'] = bio!;
    if (experienceYears != null) {
      map['experienceYears'] = experienceYears.toString();
    }
    return map;
  }
}

// ── Update Licence Request ────────────────────────────────────────────────────

class UpdateLicenceRequest {
  final String nationalId;
  final String licenseNumber;
  final String? commercialRegistrationNumber;
  final String? expiryDate;

  const UpdateLicenceRequest({
    required this.nationalId,
    required this.licenseNumber,
    this.commercialRegistrationNumber,
    this.expiryDate,
  });

  Map<String, String> toFormFields() {
    final licenseJson = <String, dynamic>{
      'number': licenseNumber,
    };
    if (expiryDate != null && expiryDate!.isNotEmpty) {
      licenseJson['expiryDate'] = expiryDate!;
    }

    final map = <String, String>{
      'nationalId': nationalId,
      'license': jsonEncode(licenseJson),
    };
    if (commercialRegistrationNumber != null &&
        commercialRegistrationNumber!.isNotEmpty) {
      map['commercialRegistrationNumber'] = commercialRegistrationNumber!;
    }
    return map;
  }
}

// ── Change Phone Models ───────────────────────────────────────────────────────

class ChangePhoneRequestModel {
  final String phone;
  const ChangePhoneRequestModel({required this.phone});
  Map<String, dynamic> toJson() => {'phone': '+966$phone'};
}

class ChangePhoneVerifyModel {
  final String phone;
  final String code;
  const ChangePhoneVerifyModel({required this.phone, required this.code});
  Map<String, dynamic> toJson() => {'phone': '+966$phone', 'code': code};
}

class ChangePhoneResponseModel {
  final String message;
  final String? newPhoneNumber;

  const ChangePhoneResponseModel({
    required this.message,
    this.newPhoneNumber,
  });

  factory ChangePhoneResponseModel.fromJson(Map<String, dynamic> json) =>
      ChangePhoneResponseModel(
        message: json['message'] ?? '',
        newPhoneNumber: json['newPhoneNumber'],
      );
}

// ── Account Deletion Models ───────────────────────────────────────────────────

/// Request body for POST /account/deletion/request
class DeleteAccountRequestBody {
  const DeleteAccountRequestBody({required this.otp});

  final String otp;

  Map<String, dynamic> toJson() => {
    'confirm': true,
    'otp': otp,
  };
}

/// Response model for a successful deletion schedule.
/// Maps the `data` object returned by the server:
/// { "graceDays": 14, "deletionRequestedAt": "...", "deletionEffectiveAt": "..." }
class DeleteAccountResponseModel {
  final String message;
  final int graceDays;
  final String deletionRequestedAt;
  final String deletionEffectiveAt;

  const DeleteAccountResponseModel({
    required this.message,
    required this.graceDays,
    required this.deletionRequestedAt,
    required this.deletionEffectiveAt,
  });

  factory DeleteAccountResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return DeleteAccountResponseModel(
      message: json['message']?.toString() ?? '',
      graceDays: (data['graceDays'] as num?)?.toInt() ?? 14,
      deletionRequestedAt: data['deletionRequestedAt']?.toString() ?? '',
      deletionEffectiveAt: data['deletionEffectiveAt']?.toString() ?? '',
    );
  }
}