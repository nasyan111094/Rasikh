// ─────────────────────────────────────────────────────────────────────────────
// consultation_model.dart
// All models for the Create-Consultation feature.
// Added: EnumValueModel for /api/v1/enums/{type} responses.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:rasikh/config/app_config.dart';

// ── 0. Enum value (from GET /api/v1/enums/{type}) ────────────────────────────

class EnumValueModel {
  final String key;
  final String value;

  const EnumValueModel({required this.key, required this.value});

  factory EnumValueModel.fromJson(Map<String, dynamic> json) => EnumValueModel(
    key: json['key'] as String,
    value: json['value'] as String,
  );
}

// ── 1. Specialization ────────────────────────────────────────────────────────

class SubSpecializationModel {
  final String id;
  final String name;
  final bool isActive;

  const SubSpecializationModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory SubSpecializationModel.fromJson(Map<String, dynamic> json) =>
      SubSpecializationModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? true,
      );
}

class SpecializationModel {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;

  final List<SubSpecializationModel> subSpecializations;
  final int subSpecializationsCount;

  final bool isActive;
  final int linkedLawyersCount;
  final int linkedConsultationsCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SpecializationModel({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.subSpecializations,
    required this.subSpecializationsCount,
    required this.isActive,
    required this.linkedLawyersCount,
    required this.linkedConsultationsCount,
    this.createdAt,
    this.updatedAt,
  });

  factory SpecializationModel.fromJson(Map<String, dynamic> json) =>
      SpecializationModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        iconUrl: json['iconUrl'] != null
            ? AppConfig.baseImgUrl + (json['iconUrl'] as String)
            : null,

        subSpecializations:
        (json['subSpecializations'] as List<dynamic>? ?? [])
            .map(
              (e) => SubSpecializationModel.fromJson(
            e as Map<String, dynamic>,
          ),
        )
            .toList(),

        subSpecializationsCount:
        json['subSpecializationsCount'] as int? ?? 0,

        isActive: json['isActive'] as bool? ?? true,

        linkedLawyersCount:
        json['linkedLawyersCount'] as int? ?? 0,

        linkedConsultationsCount:
        json['linkedConsultationsCount'] as int? ?? 0,

        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,

        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
      );
}

// ── 2. Lawyer (list item) ────────────────────────────────────────────────────

class LawyerSpecializationRef {
  final String id;
  final String? name;

  const LawyerSpecializationRef({required this.id, this.name});

  factory LawyerSpecializationRef.fromJson(Map<String, dynamic> json) =>
      LawyerSpecializationRef(
        id: json['id'] as String,
        name: json['name'] as String?,
      );
}

class LawyerModel {
  final String id;
  final String fullName;
  final String? photoUrl;
  final String? city;
  final int? experienceYears;
  final double rating;
  final List<LawyerSpecializationRef> mainSpecializations;
  final double? consultationFee;
  final bool isCompany;
  final String? bio;

  const LawyerModel({
    required this.id,
    required this.fullName,
    this.photoUrl,
    this.city,
    this.experienceYears,
    required this.rating,
    required this.mainSpecializations,
    this.consultationFee,
    required this.isCompany,
    this.bio,
  });

  factory LawyerModel.fromJson(Map<String, dynamic> json) => LawyerModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    photoUrl: AppConfig.baseImgUrl+json['photoUrl'] as String?,
    city: json['city'] as String?,
    experienceYears: json['experienceYears'] as int?,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    mainSpecializations:
    (json['mainSpecializations'] as List<dynamic>? ?? [])
        .map((e) => LawyerSpecializationRef.fromJson(e as Map<String, dynamic>))
        .toList(),
    consultationFee: (json['consultationFee'] as num?)?.toDouble(),
    isCompany: json['isCompany'] as bool? ?? false,
    bio: json['bio'] as String?,
  );
}

// ── 3a. License ──────────────────────────────────────────────────────────────

class LicenseModel {
  final String? number;
  final String? expiryDate;
  final String? imageUrl;

  const LicenseModel({this.number, this.expiryDate, this.imageUrl});

  factory LicenseModel.fromJson(Map<String, dynamic> json) => LicenseModel(
    number: json['number'] as String?,
    expiryDate: json['expiryDate'] as String?,
    imageUrl: AppConfig.baseImgUrl+json['imageUrl'] as String?,
  );
}

// ── 3. Lawyer Detail ─────────────────────────────────────────────────────────

class LawyerRatingModel {
  final int stars;
  final String? comment;
  final String? lawyerReply;
  final bool lawyerReplyPublished;
  final String createdAt;
  final LawyerRatingClient? client;

  const LawyerRatingModel({
    required this.stars,
    this.comment,
    this.lawyerReply,
    required this.lawyerReplyPublished,
    required this.createdAt,
    this.client,
  });

  factory LawyerRatingModel.fromJson(Map<String, dynamic> json) =>
      LawyerRatingModel(
        stars: json['stars'] as int? ?? 0,
        comment: json['comment'] as String?,
        lawyerReply: json['lawyerReply'] as String?,
        lawyerReplyPublished: json['lawyerReplyPublished'] as bool? ?? false,
        createdAt: json['createdAt'] as String? ?? '',
        client: json['client'] != null
            ? LawyerRatingClient.fromJson(json['client'] as Map<String, dynamic>)
            : null,
      );
}

class LawyerRatingClient {
  final String id;
  final String fullName;
  final String? avatar;

  const LawyerRatingClient({
    required this.id,
    required this.fullName,
    this.avatar,
  });

  factory LawyerRatingClient.fromJson(Map<String, dynamic> json) =>
      LawyerRatingClient(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        avatar: AppConfig.baseImgUrl+json['avatar'] as String?,
      );
}

class LawyerDetailModel extends LawyerModel {
  final String? email;
  final String? qualifications;
  final List<LawyerSpecializationRef> subSpecializations;
  final List<LawyerRatingModel> ratings;
  final String? accountStatus;
  final String? activityStatus;
  final String? createdAt;
  final LicenseModel? license;

  const LawyerDetailModel({
    required super.id,
    required super.fullName,
    super.photoUrl,
    super.city,
    super.experienceYears,
    required super.rating,
    required super.mainSpecializations,
    super.consultationFee,
    required super.isCompany,
    super.bio,
    this.email,
    this.qualifications,
    required this.subSpecializations,
    required this.ratings,
    this.accountStatus,
    this.activityStatus,
    this.createdAt,
    this.license,
  });

  factory LawyerDetailModel.fromJson(Map<String, dynamic> json) =>
      LawyerDetailModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        photoUrl: AppConfig.baseImgUrl+json['photoUrl'] as String?,
        city: json['city'] as String?,
        experienceYears: json['experienceYears'] as int?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        mainSpecializations:
        (json['mainSpecializations'] as List<dynamic>? ?? [])
            .map((e) => LawyerSpecializationRef.fromJson(e as Map<String, dynamic>))
            .toList(),
        consultationFee: (json['consultationFee'] as num?)?.toDouble(),
        isCompany: json['isCompany'] as bool? ?? false,
        bio: json['bio'] as String?,
        email: json['email'] as String?,
        qualifications: json['qualifications'] as String?,
        subSpecializations:
        (json['subSpecializations'] as List<dynamic>? ?? [])
            .map((e) => LawyerSpecializationRef.fromJson(e as Map<String, dynamic>))
            .toList(),
        ratings: (json['ratings'] as List<dynamic>? ?? [])
            .map((e) => LawyerRatingModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        accountStatus: json['accountStatus'] as String?,
        activityStatus: json['activityStatus'] as String?,
        createdAt: json['createdAt'] as String?,
        license: json['license'] != null
            ? LicenseModel.fromJson(json['license'] as Map<String, dynamic>)
            : null,
      );
}

// ── 4. Pricing ───────────────────────────────────────────────────────────────

class PricingModel {
  final String id;
  final String consultationType; // instant | written | scheduled
  final int? duration;           // minutes; null for written
  final double basePrice;
  final String currency;

  const PricingModel({
    required this.id,
    required this.consultationType,
    this.duration,
    required this.basePrice,
    required this.currency,
  });

  factory PricingModel.fromJson(Map<String, dynamic> json) => PricingModel(
    id: json['id'] as String,
    consultationType: json['consultationType'] as String,
    duration: json['duration'] as int?,
    basePrice: (json['basePrice'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'SAR',
  );

  /// Human-readable label e.g. "15 دقيقة"
  String get durationLabel => duration != null ? '$duration دقيقة' : '—';

  /// Human-readable price e.g. "150 ريال"
  String get priceLabel => '${basePrice.toStringAsFixed(0)} ريال';
}


// ── 5. Consultation type enum ────────────────────────────────────────────────

enum ConsultationType { instant, written, scheduled }

extension ConsultationTypeX on ConsultationType {
  String get value {
    switch (this) {
      case ConsultationType.instant:
        return 'instant';
      case ConsultationType.written:
        return 'written';
      case ConsultationType.scheduled:
        return 'scheduled';
    }
  }

  String get arabicLabel {
    switch (this) {
      case ConsultationType.instant:
        return 'استشارة فورية';
      case ConsultationType.written:
        return 'استشارة كتابية';
      case ConsultationType.scheduled:
        return 'استشارة مجدولة';
    }
  }

  /// Parse from API enum value string (e.g. 'instant' or 'INSTANT')
  static ConsultationType fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'written':
        return ConsultationType.written;
      case 'scheduled':
        return ConsultationType.scheduled;
      default:
        return ConsultationType.instant;
    }
  }
}

// ── 6. Create-Consultation params ────────────────────────────────────────────

class CreateConsultationParams {
  final String pricingId;
  final String lawyerId;
  final String specializationId;
  final List<String> subSpecializationIds;
  final String title;
  final String details;
  final ConsultationType type;
  final bool hideClientFromLawyer;

  // Scheduled only
  final DateTime? startTime;
  final DateTime? endTime;

  // Optional media
  final List<File> attachments;
  final File? voiceNote;
  final int? voiceNoteDurationSeconds;

  const CreateConsultationParams({
    required this.pricingId,
    required this.lawyerId,
    required this.specializationId,
    required this.subSpecializationIds,
    required this.title,
    required this.details,
    required this.type,
    this.hideClientFromLawyer = false,
    this.startTime,
    this.endTime,
    this.attachments = const [],
    this.voiceNote,
    this.voiceNoteDurationSeconds,
  });

  CreateConsultationParams copyWith({
    String? pricingId,
    String? lawyerId,
    String? specializationId,
    List<String>? subSpecializationIds,
    String? title,
    String? details,
    ConsultationType? type,
    bool? hideClientFromLawyer,
    DateTime? startTime,
    DateTime? endTime,
    List<File>? attachments,
    File? voiceNote,
    int? voiceNoteDurationSeconds,
  }) =>
      CreateConsultationParams(
        pricingId: pricingId ?? this.pricingId,
        lawyerId: lawyerId ?? this.lawyerId,
        specializationId: specializationId ?? this.specializationId,
        subSpecializationIds: subSpecializationIds ?? this.subSpecializationIds,
        title: title ?? this.title,
        details: details ?? this.details,
        type: type ?? this.type,
        hideClientFromLawyer: hideClientFromLawyer ?? this.hideClientFromLawyer,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        attachments: attachments ?? this.attachments,
        voiceNote: voiceNote ?? this.voiceNote,
        voiceNoteDurationSeconds:
        voiceNoteDurationSeconds ?? this.voiceNoteDurationSeconds,
      );
}

// ── 7. Created Consultation response ─────────────────────────────────────────

class CreatedConsultationModel {
  final String id;
  final String consultationNumber;
  final String title;
  final String details;
  final String? voiceNoteUrl;
  final int? voiceNoteDurationSeconds;
  final List<String> attachments;
  final String type;
  final String? startTime;
  final String? endTime;
  final String status;
  final int? durationMin;
  final int? priceAmountHalala;
  final String currency;
  final bool hideClientFromLawyer;
  final String createdAt;

  const CreatedConsultationModel({
    required this.id,
    required this.consultationNumber,
    required this.title,
    required this.details,
    this.voiceNoteUrl,
    this.voiceNoteDurationSeconds,
    required this.attachments,
    required this.type,
    this.startTime,
    this.endTime,
    required this.status,
    this.durationMin,
    this.priceAmountHalala,
    required this.currency,
    required this.hideClientFromLawyer,
    required this.createdAt,
  });

  factory CreatedConsultationModel.fromJson(Map<String, dynamic> json) =>
      CreatedConsultationModel(
        id: json['id'] as String,
        consultationNumber: json['consultationNumber'] as String,
        title: json['title'] as String,
        details: json['details'] as String,
        voiceNoteUrl: json['voiceNoteUrl'] as String?,
        voiceNoteDurationSeconds: json['voiceNoteDurationSeconds'] as int?,
        attachments: (json['attachments'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        type: json['type'] as String,
        startTime: json['startTime'] as String?,
        endTime: json['endTime'] as String?,
        status: json['status'] as String,
        durationMin: json['durationMin'] as int?,
        priceAmountHalala: json['priceAmountHalala'] as int?,
        currency: json['currency'] as String? ?? 'SAR',
        hideClientFromLawyer: json['hideClientFromLawyer'] as bool? ?? false,
        createdAt: json['createdAt'] as String? ?? '',
      );

  /// Price in SAR (halala ÷ 100)
  double get priceInSAR => (priceAmountHalala ?? 0) / 100.0;
}