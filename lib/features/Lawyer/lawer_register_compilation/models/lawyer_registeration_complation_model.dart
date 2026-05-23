// ─────────────────────────────────────────────────────────────────────────────
// lawyer_completion/model/lawyer_completion_model.dart
//
// All models exclusive to the lawyer profile-completion flow.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';



// ── Specialization models (GET /api/v1/specializations/active) ────────────────

class SubSpecializationModel {
  final String id;
  final String name;
  final bool   isActive;

  const SubSpecializationModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory SubSpecializationModel.fromJson(Map<String, dynamic> json) {
    return SubSpecializationModel(
      id:       json['id']       as String? ?? '',
      name:     json['name']     as String? ?? '',
      isActive: json['isActive'] as bool?   ?? false,
    );
  }
}

class SpecializationModel {
  final String id;
  final String name;
  final List<SubSpecializationModel> subSpecializations;
  final int  subSpecializationsCount;
  final bool isActive;
  final int  linkedLawyersCount;
  final int  linkedConsultationsCount;

  const SpecializationModel({
    required this.id,
    required this.name,
    required this.subSpecializations,
    required this.subSpecializationsCount,
    required this.isActive,
    required this.linkedLawyersCount,
    required this.linkedConsultationsCount,
  });

  factory SpecializationModel.fromJson(Map<String, dynamic> json) {
    final rawSubs = json['subSpecializations'] as List<dynamic>? ?? [];
    return SpecializationModel(
      id:   json['id']   as String? ?? '',
      name: json['name'] as String? ?? '',
      subSpecializations: rawSubs
          .map((e) => SubSpecializationModel.fromJson(
          e as Map<String, dynamic>))
          .toList(),
      subSpecializationsCount:  json['subSpecializationsCount']  as int?  ?? 0,
      isActive:                 json['isActive']                 as bool? ?? false,
      linkedLawyersCount:       json['linkedLawyersCount']       as int?  ?? 0,
      linkedConsultationsCount: json['linkedConsultationsCount'] as int?  ?? 0,
    );
  }
}

// ── Profile completion response (PUT /lawyers/profile/form) ───────────────────

class LawyerProfileCompletionModel {
  final bool   success;
  final int    statusCode;
  final String message;
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String city;
  final String nationalId;
  final String nationalIdDocumentUrl;
  final String photoUrl;
  final String licenseNumber;
  final String licenseImageUrl;
  final bool   profileCompleted;
  final String status;
  final String accountStatus;

  const LawyerProfileCompletionModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.city,
    required this.nationalId,
    required this.nationalIdDocumentUrl,
    required this.photoUrl,
    required this.licenseNumber,
    required this.licenseImageUrl,
    required this.profileCompleted,
    required this.status,
    required this.accountStatus,
  });

  factory LawyerProfileCompletionModel.fromJson(Map<String, dynamic> json) {
    final data    = json['data']    as Map<String, dynamic>? ?? json;
    final license = data['license'] as Map<String, dynamic>? ?? {};
    return LawyerProfileCompletionModel(
      success:               json['success']    as bool?   ?? false,
      statusCode:            json['statusCode'] as int?    ?? 0,
      message:               json['message']    as String? ?? '',
      id:                    data['id']                    as String? ?? '',
      fullName:              data['fullName']               as String? ?? '',
      phone:                 data['phone']                  as String? ?? '',
      email:                 data['email']                  as String? ?? '',
      city:                  data['city']                   as String? ?? '',
      nationalId:            data['nationalId']             as String? ?? '',
      nationalIdDocumentUrl: data['nationalIdDocumentUrl']  as String? ?? '',
      photoUrl:              data['photoUrl']               as String? ?? '',
      licenseNumber:         license['number']              as String? ?? '',
      licenseImageUrl:       license['imageUrl']            as String? ?? '',
      profileCompleted:      data['profileCompleted']       as bool?   ?? false,
      status:                data['status']                 as String? ?? '',
      accountStatus:         data['accountStatus']          as String? ?? '',
    );
  }
}

// ── Accumulated form data (grows across multi-step screens) ───────────────────

class LawyerRegistrationFormData {
  // Step 1 – Personal Info
  String fullName;
  String email;
  String cityKey;

  // Step 2 – License & Documents
  String nationalId;
  String licenseNumber;
  String licenseExpiryDate;
  String commercialRegistrationNumber;
  bool   isCompany;

  File? photo;
  File? nationalIdDocument;
  File? licenseImage;
  File? commercialRegistrationDocument;

  // Step 3 – Qualifications
  String qualifications;
  int    experienceYears;

  // Step 4 – Specializations
  List<String> mainSpecializationIds;
  List<String> subSpecializationIds;

  bool acceptedTerms;

  LawyerRegistrationFormData({
    this.fullName                        = '',
    this.email                           = '',
    this.cityKey                         = '',
    this.nationalId                      = '',
    this.licenseNumber                   = '',
    this.licenseExpiryDate               = '2030-12-31T23:59:59.999Z',
    this.commercialRegistrationNumber    = '',
    this.isCompany                       = false,
    this.photo,
    this.nationalIdDocument,
    this.licenseImage,
    this.commercialRegistrationDocument,
    this.qualifications                  = '',
    this.experienceYears                 = 0,
    this.mainSpecializationIds           = const [],
    this.subSpecializationIds            = const [],
    this.acceptedTerms                   = false,
  });

  bool get isPersonalInfoComplete =>
      fullName.isNotEmpty && email.isNotEmpty && cityKey.isNotEmpty;

  bool get isLicenseComplete =>
      nationalId.isNotEmpty &&
          licenseNumber.isNotEmpty &&
          nationalIdDocument != null &&
          licenseImage != null &&
          (!isCompany || commercialRegistrationDocument != null);

  bool get isQualificationsComplete =>
      qualifications.isNotEmpty && experienceYears > 0;

  bool get isSpecializationsComplete => mainSpecializationIds.isNotEmpty;

  bool get isReadyToSubmit =>
      isPersonalInfoComplete &&
          isLicenseComplete &&
          isQualificationsComplete &&
          isSpecializationsComplete &&
          acceptedTerms;

  Map<String, dynamic> toFormFields() {
    return {
      'fullName':   fullName,
      'email':      email,
      'city':       cityKey,
      'nationalId': nationalId,
      'license':
      '{"number":"$licenseNumber","expiryDate":"$licenseExpiryDate"}',
      'isCompany': isCompany.toString(),
      if (isCompany && commercialRegistrationNumber.isNotEmpty)
        'commercialRegistrationNumber': commercialRegistrationNumber,
      'qualifications':    qualifications,
      'experienceYears':   experienceYears.toString(),
      'mainSpecializations': mainSpecializationIds,
      'subSpecializations':  subSpecializationIds,
      'acceptedTerms':     acceptedTerms.toString(),
    };
  }

  LawyerRegistrationFormData copyWith({
    String?       fullName,
    String?       email,
    String?       cityKey,
    String?       nationalId,
    String?       licenseNumber,
    String?       licenseExpiryDate,
    String?       commercialRegistrationNumber,
    bool?         isCompany,
    File?         photo,
    File?         nationalIdDocument,
    File?         licenseImage,
    File?         commercialRegistrationDocument,
    String?       qualifications,
    int?          experienceYears,
    List<String>? mainSpecializationIds,
    List<String>? subSpecializationIds,
    bool?         acceptedTerms,
  }) {
    return LawyerRegistrationFormData(
      fullName:                       fullName                       ?? this.fullName,
      email:                          email                          ?? this.email,
      cityKey:                        cityKey                        ?? this.cityKey,
      nationalId:                     nationalId                     ?? this.nationalId,
      licenseNumber:                  licenseNumber                  ?? this.licenseNumber,
      licenseExpiryDate:              licenseExpiryDate              ?? this.licenseExpiryDate,
      commercialRegistrationNumber:   commercialRegistrationNumber   ?? this.commercialRegistrationNumber,
      isCompany:                      isCompany                      ?? this.isCompany,
      photo:                          photo                          ?? this.photo,
      nationalIdDocument:             nationalIdDocument             ?? this.nationalIdDocument,
      licenseImage:                   licenseImage                   ?? this.licenseImage,
      commercialRegistrationDocument: commercialRegistrationDocument ?? this.commercialRegistrationDocument,
      qualifications:                 qualifications                 ?? this.qualifications,
      experienceYears:                experienceYears                ?? this.experienceYears,
      mainSpecializationIds:          mainSpecializationIds          ?? this.mainSpecializationIds,
      subSpecializationIds:           subSpecializationIds           ?? this.subSpecializationIds,
      acceptedTerms:                  acceptedTerms                  ?? this.acceptedTerms,
    );
  }
}