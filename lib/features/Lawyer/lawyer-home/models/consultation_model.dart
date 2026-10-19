// consultation_accept_response_model.dart

class ConsultationAcceptResponse {
  final bool success;
  final int statusCode;
  final String message;
  final ConsultationData data;
  final Meta meta;

  ConsultationAcceptResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory ConsultationAcceptResponse.fromJson(Map<String, dynamic> json) {
    return ConsultationAcceptResponse(
      success: json['success'] == true,
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      data: ConsultationData.fromJson(json['data'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
      'data': data.toJson(),
      'meta': meta.toJson(),
    };
  }
}

// ---------------- DATA WRAPPER ----------------

class ConsultationData {
  final Consultation consultation;

  ConsultationData({
    required this.consultation,
  });

  factory ConsultationData.fromJson(Map<String, dynamic> json) {
    return ConsultationData(
      consultation: Consultation.fromJson(json['consultation'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consultation': consultation.toJson(),
    };
  }
}

// ---------------- MAIN CONSULTATION ----------------

class Consultation {
  final String id;
  final Client client;
  final Lawyer lawyer;
  final Pricing pricing;
  final int priceAmountHalala;
  final String currency;
  final int durationMin;
  final Specialization specialization;
  final List<String> subSpecializationIds;
  final String title;
  final String details;
  final String type;
  final List<String> attachments;
  final bool hideClientFromLawyer;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String consultationNumber;
  final DateTime? instantLawyerAcceptedAt;

  Consultation({
    required this.id,
    required this.client,
    required this.lawyer,
    required this.pricing,
    required this.priceAmountHalala,
    required this.currency,
    required this.durationMin,
    required this.specialization,
    required this.subSpecializationIds,
    required this.title,
    required this.details,
    required this.type,
    required this.attachments,
    required this.hideClientFromLawyer,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.consultationNumber,
    required this.instantLawyerAcceptedAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',

      client: Client.fromJson(json['client'] ?? {}),
      lawyer: Lawyer.fromJson(json['lawyer'] ?? {}),
      pricing: Pricing.fromJson(json['pricing'] ?? {}),

      priceAmountHalala: (json['priceAmountHalala'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? '',
      durationMin: (json['durationMin'] as num?)?.toInt() ?? 0,

      specialization:
      Specialization.fromJson(json['specialization'] ?? {}),

      subSpecializationIds:
      (json['subSpecializationIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],

      title: json['title']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],

      hideClientFromLawyer: json['hideClientFromLawyer'] == true,
      status: json['status']?.toString() ?? '',

      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),

      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),

      consultationNumber: json['consultationNumber']?.toString() ?? '',

      instantLawyerAcceptedAt:
      json['instantLawyerAcceptedAt'] != null
          ? DateTime.tryParse(json['instantLawyerAcceptedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'client': client.toJson(),
      'lawyer': lawyer.toJson(),
      'pricing': pricing.toJson(),
      'priceAmountHalala': priceAmountHalala,
      'currency': currency,
      'durationMin': durationMin,
      'specialization': specialization.toJson(),
      'subSpecializationIds': subSpecializationIds,
      'title': title,
      'details': details,
      'type': type,
      'attachments': attachments,
      'hideClientFromLawyer': hideClientFromLawyer,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'consultationNumber': consultationNumber,
      'instantLawyerAcceptedAt':
      instantLawyerAcceptedAt?.toIso8601String(),
    };
  }
}

// ---------------- CLIENT ----------------

class Client {
  final String id;
  final String phone;
  final String city;
  final String fullName;
  final String avatar;

  Client({
    required this.id,
    required this.phone,
    required this.city,
    required this.fullName,
    required this.avatar,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['_id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phone': phone,
      'city': city,
      'fullName': fullName,
      'avatar': avatar,
    };
  }
}

// ---------------- LAWYER ----------------

class Lawyer {
  final String id;
  final String phone;
  final int rating;
  final String fullName;

  Lawyer({
    required this.id,
    required this.phone,
    required this.rating,
    required this.fullName,
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    return Lawyer(
      id: json['_id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      fullName: json['fullName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phone': phone,
      'rating': rating,
      'fullName': fullName,
    };
  }
}

// ---------------- PRICING ----------------

class Pricing {
  final String id;
  final String consultationType;
  final int duration;
  final int basePrice;
  final String currency;

  Pricing({
    required this.id,
    required this.consultationType,
    required this.duration,
    required this.basePrice,
    required this.currency,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      id: json['_id']?.toString() ?? '',
      consultationType: json['consultationType']?.toString() ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      basePrice: (json['basePrice'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'consultationType': consultationType,
      'duration': duration,
      'basePrice': basePrice,
      'currency': currency,
    };
  }
}

// ---------------- SPECIALIZATION ----------------

class Specialization {
  final String id;
  final String name;

  Specialization({
    required this.id,
    required this.name,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

// ---------------- META ----------------

class Meta {
  final String timestamp;
  final String path;

  Meta({
    required this.timestamp,
    required this.path,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      timestamp: json['timestamp']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'path': path,
    };
  }
}