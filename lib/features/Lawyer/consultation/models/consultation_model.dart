// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/data/models/consultation_model.dart
// ─────────────────────────────────────────────────────────────────────────────

// ── Status Enum ───────────────────────────────────────────────────────────────

enum ConsultationStatus {
  none,
  active,
  upcoming,
  completed,
  cancelled,
  disputes,
}

extension ConsultationStatusX on ConsultationStatus {
  String get label {
    switch (this) {
      case ConsultationStatus.none:
        return 'الكل';
      case ConsultationStatus.active:
        return 'نشطة';
      case ConsultationStatus.upcoming:
        return 'قادمة';
      case ConsultationStatus.completed:
        return 'مكتملة';
      case ConsultationStatus.cancelled:
        return 'ملغاة';
      case ConsultationStatus.disputes:
        return 'نزاعات';
    }
  }

  String get apiValue {
    switch (this) {
      case ConsultationStatus.none:
        return '';
      case ConsultationStatus.active:
        return 'active';
      case ConsultationStatus.upcoming:
        return 'upcoming';
      case ConsultationStatus.completed:
        return 'completed';
      case ConsultationStatus.cancelled:
        return 'cancelled';
      case ConsultationStatus.disputes:
        return 'disputes';
    }
  }

  static ConsultationStatus fromString(String value) {
    switch (value) {
      case 'active':
        return ConsultationStatus.active;
      case 'upcoming':
        return ConsultationStatus.upcoming;
      case 'pending':
        return ConsultationStatus.none;
      case 'completed':
        return ConsultationStatus.completed;
      case 'cancelled':
        return ConsultationStatus.cancelled;
      case 'disputes':
        return ConsultationStatus.disputes;
      default:
        return ConsultationStatus.none;
    }
  }
}

// ── Client ───────────────────────────────────────────────────────────────────

class ConsultationClient {
  final String id;
  final String fullName;
  final String? phone;
  final String? city;
  final String? avatar;

  const ConsultationClient({
    required this.id,
    required this.fullName,
    this.phone,
    this.city,
    this.avatar,
  });

  factory ConsultationClient.fromJson(Map<String, dynamic> json) {
    return ConsultationClient(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString(),
      city: json['city']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'city': city,
    'avatar': avatar,
  };
}

// ── Lawyer ───────────────────────────────────────────────────────────────────

class ConsultationLawyer {
  final String id;
  final String fullName;
  final double? rating;
  final String? city;
  final String? photoUrl;

  const ConsultationLawyer({
    required this.id,
    required this.fullName,
    this.rating,
    this.city,
    this.photoUrl,
  });

  factory ConsultationLawyer.fromJson(Map<String, dynamic> json) {
    return ConsultationLawyer(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      city: json['city']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'rating': rating,
    'city': city,
    'photoUrl': photoUrl,
  };
}

// ── Specialization ───────────────────────────────────────────────────────────

class ConsultationSpecialization {
  final String id;
  final String name;

  const ConsultationSpecialization({
    required this.id,
    required this.name,
  });

  factory ConsultationSpecialization.fromJson(
      Map<String, dynamic> json,
      ) {
    return ConsultationSpecialization(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

// ── Pricing ──────────────────────────────────────────────────────────────────

class ConsultationPricing {
  final String? id;
  final String? consultationType;
  final int? duration;
  final num? basePrice;
  final String? currency;
  final Map<String, dynamic> raw;

  const ConsultationPricing({
    this.id,
    this.consultationType,
    this.duration,
    this.basePrice,
    this.currency,
    required this.raw,
  });

  factory ConsultationPricing.fromJson(
      Map<String, dynamic> json,
      ) {
    return ConsultationPricing(
      id: json['_id']?.toString(),
      consultationType: json['consultationType']?.toString(),
      duration: json['duration'] as int?,
      basePrice: json['basePrice'] as num?,
      currency: json['currency']?.toString(),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw;
}

// ── Attachment ───────────────────────────────────────────────────────────────

class ConsultationAttachment {
  final String url;

  const ConsultationAttachment({
    required this.url,
  });

  factory ConsultationAttachment.fromJson(dynamic raw) {
    if (raw is String) {
      return ConsultationAttachment(url: raw);
    }

    if (raw is Map<String, dynamic>) {
      return ConsultationAttachment(
        url: raw['url']?.toString() ??
            raw['path']?.toString() ??
            raw['id']?.toString() ??
            '',
      );
    }

    return const ConsultationAttachment(url: '');
  }

  Map<String, dynamic> toJson() => {
    'url': url,
  };
}

// ── Dispute ──────────────────────────────────────────────────────────────────

class ConsultationDispute {
  final String id;
  final String? disputeNumber;
  final String? consultationId;
  final String? clientId;
  final String? lawyerId;
  final String? reason;
  final String? description;
  final List<ConsultationAttachment> attachments;

  /// e.g. "Open"
  final String? status;

  /// e.g. "None"
  final String? decision;

  final num? amount;
  final bool amountHeld;

  final List<String> history;
  final List<dynamic> transactions;

  final String? createdAt;
  final String? updatedAt;

  const ConsultationDispute({
    required this.id,
    this.disputeNumber,
    this.consultationId,
    this.clientId,
    this.lawyerId,
    this.reason,
    this.description,
    this.attachments = const [],
    this.status,
    this.decision,
    this.amount,
    this.amountHeld = false,
    this.history = const [],
    this.transactions = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ConsultationDispute.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'];

    final attachments = rawAttachments is List
        ? rawAttachments.map(ConsultationAttachment.fromJson).toList()
        : <ConsultationAttachment>[];

    final rawHistory = json['history'];

    final history = rawHistory is List
        ? rawHistory.map((e) => e.toString()).toList()
        : <String>[];

    return ConsultationDispute(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      disputeNumber: json['disputeNumber']?.toString(),
      consultationId: json['consultation']?.toString(),
      clientId: json['client']?.toString(),
      lawyerId: json['lawyer']?.toString(),
      reason: json['reason']?.toString(),
      description: json['description']?.toString(),
      attachments: attachments,
      status: json['status']?.toString(),
      decision: json['decision']?.toString(),
      amount: json['amount'] as num?,
      amountHeld: json['amountHeld'] as bool? ?? false,
      history: history,
      transactions:
      (json['transactions'] is List) ? json['transactions'] as List : const [],
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'disputeNumber': disputeNumber,
    'consultation': consultationId,
    'client': clientId,
    'lawyer': lawyerId,
    'reason': reason,
    'description': description,
    'attachments': attachments.map((e) => e.toJson()).toList(),
    'status': status,
    'decision': decision,
    'amount': amount,
    'amountHeld': amountHeld,
    'history': history,
    'transactions': transactions,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// ── Consultation ─────────────────────────────────────────────────────────────

class ConsultationModel {
  final String id;
  final String consultationNumber;

  final String title;
  final String? details;

  final String? voiceNoteUrl;
  final int? voiceNoteDurationSeconds;

  final List<ConsultationAttachment> attachments;

  /// instant | scheduled | written
  final String type;

  final ConsultationStatus status;

  final int? durationMin;
  final int? priceAmountHalala;
  final String? currency;

  final String? summary;

  final bool hideClientFromLawyer;

  final ConsultationClient? client;
  final ConsultationLawyer? lawyer;

  final ConsultationSpecialization? specialization;

  final List<ConsultationSpecialization> subSpecializations;

  final String? instantSessionStartedAt;
  final String? instantSessionEndsAt;

  final String? startTime;
  final String? endTime;

  final String? scheduledAttendanceStatus;

  final ConsultationPricing? pricing;

  final ConsultationDispute? dispute;

  final String? createdAt;
  final String? updatedAt;

  const ConsultationModel({
    required this.id,
    required this.consultationNumber,
    required this.title,
    this.details,
    this.voiceNoteUrl,
    this.voiceNoteDurationSeconds,
    this.attachments = const [],
    required this.type,
    required this.status,
    this.durationMin,
    this.priceAmountHalala,
    this.currency,
    this.summary,
    this.hideClientFromLawyer = false,
    this.client,
    this.lawyer,
    this.specialization,
    this.subSpecializations = const [],
    this.instantSessionStartedAt,
    this.instantSessionEndsAt,
    this.startTime,
    this.endTime,
    this.scheduledAttendanceStatus,
    this.pricing,
    this.dispute,
    this.createdAt,
    this.updatedAt,
  });

  // ── Computed Properties ───────────────────────────────────────────────────

  double? get priceInSar =>
      priceAmountHalala != null ? priceAmountHalala! / 100 : null;

  bool get isInstant => type == 'instant';

  bool get isScheduled => type == 'scheduled';

  bool get isWritten => type == 'written';

  bool get isCompleted => status == ConsultationStatus.completed;

  bool get isCancelled => status == ConsultationStatus.cancelled;

  bool get isActive => status == ConsultationStatus.active;

  bool get isUpcoming => status == ConsultationStatus.upcoming;

  bool get isDisputed => status == ConsultationStatus.disputes;

  DateTime? get effectiveStartDateTime {
    final raw = startTime ?? instantSessionStartedAt;

    if (raw == null) return null;

    try {
      return DateTime.parse(raw)  ;
    } catch (_) {
      return null;
    }
  }

  DateTime? get effectiveEndDateTime {
    final raw = endTime ?? instantSessionEndsAt;

    if (raw == null) return null;

    try {
      return DateTime.parse(raw)  ;
    } catch (_) {
      return null;
    }
  }

  Duration? get timeUntilStart {
    final dt = effectiveStartDateTime;

    if (dt == null) return null;

    final diff =
        dt.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;

    return diff <= 0
        ? Duration.zero
        : Duration(milliseconds: diff);
  }

  bool get isUpcomingAndNotStarted =>
      isUpcoming &&
          (timeUntilStart?.inMilliseconds ?? 0) > 0;

  // ── Serialization ─────────────────────────────────────────────────────────

  factory ConsultationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawAttachments = json['attachments'];

    final attachments = rawAttachments is List
        ? rawAttachments
        .map(ConsultationAttachment.fromJson)
        .toList()
        : <ConsultationAttachment>[];

    final specJson = json['specialization'];

    final specialization = specJson is Map<String, dynamic>
        ? ConsultationSpecialization.fromJson(specJson)
        : null;

    final subSpecJson = json['subSpecializations'];

    final subSpecs = subSpecJson is List
        ? subSpecJson
        .whereType<Map<String, dynamic>>()
        .map(ConsultationSpecialization.fromJson)
        .toList()
        : <ConsultationSpecialization>[];

    final clientJson = json['client'];

    final client = clientJson is Map<String, dynamic>
        ? ConsultationClient.fromJson(clientJson)
        : null;

    final lawyerJson = json['lawyer'];

    final lawyer = lawyerJson is Map<String, dynamic>
        ? ConsultationLawyer.fromJson(lawyerJson)
        : null;

    final pricingJson = json['pricing'];

    final pricing = pricingJson is Map<String, dynamic>
        ? ConsultationPricing.fromJson(pricingJson)
        : null;

    final disputeJson = json['dispute'];

    final dispute = disputeJson is Map<String, dynamic>
        ? ConsultationDispute.fromJson(disputeJson)
        : null;

    return ConsultationModel(
      id: json['id']?.toString() ?? '',
      consultationNumber:
      json['consultationNumber']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      details: json['details']?.toString(),
      voiceNoteUrl: json['voiceNoteUrl']?.toString(),
      voiceNoteDurationSeconds:
      json['voiceNoteDurationSeconds'] as int?,
      attachments: attachments,
      type: json['type']?.toString() ?? 'instant',
      status: ConsultationStatusX.fromString(
        json['status']?.toString() ?? '',
      ),
      durationMin: json['durationMin'] as int?,
      priceAmountHalala: json['priceAmountHalala'] as int?,
      currency: json['currency']?.toString(),
      summary: json['summary']?.toString(),
      hideClientFromLawyer:
      json['hideClientFromLawyer'] as bool? ?? false,
      client: client,
      lawyer: lawyer,
      specialization: specialization,
      subSpecializations: subSpecs,
      instantSessionStartedAt:
      json['instantSessionStartedAt']?.toString(),
      instantSessionEndsAt:
      json['instantSessionEndsAt']?.toString(),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      scheduledAttendanceStatus:
      json['scheduledAttendanceStatus']?.toString(),
      pricing: pricing,
      dispute: dispute,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'consultationNumber': consultationNumber,
    'title': title,
    'details': details,
    'voiceNoteUrl': voiceNoteUrl,
    'voiceNoteDurationSeconds':
    voiceNoteDurationSeconds,
    'attachments':
    attachments.map((e) => e.toJson()).toList(),
    'type': type,
    'status': status.apiValue,
    'durationMin': durationMin,
    'priceAmountHalala': priceAmountHalala,
    'currency': currency,
    'summary': summary,
    'hideClientFromLawyer': hideClientFromLawyer,
    'client': client?.toJson(),
    'lawyer': lawyer?.toJson(),
    'specialization': specialization?.toJson(),
    'subSpecializations':
    subSpecializations.map((e) => e.toJson()).toList(),
    'instantSessionStartedAt':
    instantSessionStartedAt,
    'instantSessionEndsAt':
    instantSessionEndsAt,
    'startTime': startTime,
    'endTime': endTime,
    'scheduledAttendanceStatus':
    scheduledAttendanceStatus,
    'pricing': pricing?.toJson(),
    'dispute': dispute?.toJson(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// ── Paginated Response ───────────────────────────────────────────────────────

class ConsultationsModel {
  final List<ConsultationModel> consultations;
  final int currentPage;
  final int totalPages;
  final int total;
  final int limit;

  const ConsultationsModel({
    required this.consultations,
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.limit,
  });

  bool get hasMorePages => currentPage < totalPages;

  factory ConsultationsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final data = json['data'];
    final meta = json['meta'] ?? {};

    final rawList = data is List ? data : [];

    return ConsultationsModel(
      consultations: rawList
          .whereType<Map<String, dynamic>>()
          .map(ConsultationModel.fromJson)
          .toList(),
      currentPage: meta['page'] as int? ?? 1,
      totalPages: meta['totalPages'] as int? ?? 1,
      total: meta['total'] as int? ?? rawList.length,
      limit: meta['limit'] as int? ?? 10,
    );
  }
}

// ── Details Response ─────────────────────────────────────────────────────────

class ConsultationDetailsResponse {
  final bool success;
  final int statusCode;
  final String message;
  final ConsultationModel consultation;

  const ConsultationDetailsResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.consultation,
  });

  factory ConsultationDetailsResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return ConsultationDetailsResponse(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message']?.toString() ?? '',
      consultation: ConsultationModel.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}