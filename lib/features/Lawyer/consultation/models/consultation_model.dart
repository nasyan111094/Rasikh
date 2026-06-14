// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/data/models/consultation_model.dart
// ─────────────────────────────────────────────────────────────────────────────

// ── Status Enum ───────────────────────────────────────────────────────────────

enum ConsultationStatus { none, active, upcoming, completed, cancelled, disputes }

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

// ── Client Model ──────────────────────────────────────────────────────────────

class ConsultationClient {
  final String id;
  final String fullName;
  final String? phone;
  final String? city;

  const ConsultationClient({
    required this.id,
    required this.fullName,
    this.phone,
    this.city,
  });

  factory ConsultationClient.fromJson(Map<String, dynamic> json) =>
      ConsultationClient(
        id: json['id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        phone: json['phone']?.toString(),
        city: json['city']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'city': city,
  };
}

// ── Specialization Model ──────────────────────────────────────────────────────

class ConsultationSpecialization {
  final String id;
  final String name;

  const ConsultationSpecialization({required this.id, required this.name});

  factory ConsultationSpecialization.fromJson(Map<String, dynamic> json) =>
      ConsultationSpecialization(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

// ── Pricing Model ─────────────────────────────────────────────────────────────

class ConsultationPricing {
  final String? id;
  final Map<String, dynamic> raw;

  const ConsultationPricing({this.id, required this.raw});

  factory ConsultationPricing.fromJson(Map<String, dynamic> json) =>
      ConsultationPricing(id: json['_id']?.toString(), raw: json);
}

// ── Attachment ────────────────────────────────────────────────────────────────

class ConsultationAttachment {
  final String url;

  const ConsultationAttachment({required this.url});

  factory ConsultationAttachment.fromJson(dynamic raw) {
    if (raw is String) return ConsultationAttachment(url: raw);
    if (raw is Map<String, dynamic>) {
      return ConsultationAttachment(
        url: raw['url']?.toString() ?? raw['id']?.toString() ?? '',
      );
    }
    return const ConsultationAttachment(url: '');
  }
}

// ── Main Consultation Model ───────────────────────────────────────────────────

class ConsultationModel {
  final String id;
  final String consultationNumber;
  final String title;
  final String? details;
  final String? voiceNoteUrl;
  final int? voiceNoteDurationSeconds;
  final List<ConsultationAttachment> attachments;
  final String type; // 'instant' | 'scheduled' | 'written'
  final ConsultationStatus status;
  final int? durationMin;
  final int? priceAmountHalala;
  final String? currency;
  final String? summary;
  final bool hideClientFromLawyer;
  final ConsultationClient? client;
  final ConsultationSpecialization? specialization;
  final List<ConsultationSpecialization> subSpecializations;
  final String? instantSessionStartedAt;
  final String? instantSessionEndsAt;
  final String? startTime;
  final String? endTime;
  final ConsultationPricing? pricing;

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
    this.specialization,
    this.subSpecializations = const [],
    this.instantSessionStartedAt,
    this.instantSessionEndsAt,
    this.startTime,
    this.endTime,
    this.pricing,
  });

  // ── Computed Properties ───────────────────────────────────────────────────

  /// Price in SAR (halala ÷ 100).
  double? get priceInSar =>
      priceAmountHalala != null ? priceAmountHalala! / 100 : null;

  /// Effective start time: prefers [startTime] (scheduled), falls back to
  /// [instantSessionStartedAt]. Always parsed as UTC so the clock values
  /// from the API are preserved without any timezone shift.
  DateTime? get effectiveStartDateTime {
    final raw = startTime ?? instantSessionStartedAt;
    if (raw == null) return null;
    try {
      return DateTime.parse(raw).toUtc();
    } catch (_) {
      return null;
    }
  }

  /// Remaining time until the session starts. Returns [Duration.zero] once
  /// the session has started, and `null` when no start time is available.
  Duration? get timeUntilStart {
    final dt = effectiveStartDateTime;
    if (dt == null) return null;
    final diffMs =
        dt.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
    return diffMs <= 0 ? Duration.zero : Duration(milliseconds: diffMs);
  }

  bool get isActive => status == ConsultationStatus.active;

  bool get isUpcoming => status == ConsultationStatus.upcoming;

  /// True when this is an upcoming consultation whose session hasn't started.
  bool get isUpcomingAndNotStarted =>
      isUpcoming && (timeUntilStart?.inMilliseconds ?? 0) > 0;

  // ── Serialization ─────────────────────────────────────────────────────────

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'];
    final attachments = rawAttachments is List
        ? rawAttachments.map(ConsultationAttachment.fromJson).toList()
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

    final pricingJson = json['pricing'];
    final pricing = pricingJson is Map<String, dynamic>
        ? ConsultationPricing.fromJson(pricingJson)
        : null;

    return ConsultationModel(
      id: json['id']?.toString() ?? '',
      consultationNumber: json['consultationNumber']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      details: json['details']?.toString(),
      voiceNoteUrl: json['voiceNoteUrl']?.toString(),
      voiceNoteDurationSeconds: json['voiceNoteDurationSeconds'] as int?,
      attachments: attachments,
      type: json['type']?.toString() ?? 'instant',
      status: ConsultationStatusX.fromString(
        json['status']?.toString() ?? '',
      ),
      durationMin: json['durationMin'] as int?,
      priceAmountHalala: json['priceAmountHalala'] as int?,
      currency: json['currency']?.toString(),
      summary: json['summary']?.toString(),
      hideClientFromLawyer: json['hideClientFromLawyer'] as bool? ?? false,
      client: client,
      specialization: specialization,
      subSpecializations: subSpecs,
      instantSessionStartedAt: json['instantSessionStartedAt']?.toString(),
      instantSessionEndsAt: json['instantSessionEndsAt']?.toString(),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      pricing: pricing,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'consultationNumber': consultationNumber,
    'title': title,
    'details': details,
    'voiceNoteUrl': voiceNoteUrl,
    'voiceNoteDurationSeconds': voiceNoteDurationSeconds,
    'attachments': attachments.map((a) => a.url).toList(),
    'type': type,
    'status': status.apiValue,
    'durationMin': durationMin,
    'priceAmountHalala': priceAmountHalala,
    'currency': currency,
    'summary': summary,
    'hideClientFromLawyer': hideClientFromLawyer,
    'client': client?.toJson(),
    'specialization': specialization?.toJson(),
    'subSpecializations': subSpecializations.map((s) => s.toJson()).toList(),
    'instantSessionStartedAt': instantSessionStartedAt,
    'instantSessionEndsAt': instantSessionEndsAt,
    'startTime': startTime,
    'endTime': endTime,
  };
}

// ── Paginated Response Model ──────────────────────────────────────────────────

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

  factory ConsultationsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] ?? json['pagination'] ?? {};
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