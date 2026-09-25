// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/lawyer_Settings/data/models/lawyer_ratings_model.dart
// ─────────────────────────────────────────────────────────────────────────────

// ── Rating Client ─────────────────────────────────────────────────────────────

class RatingClient {
  final String id;
  final String fullName;
  final String phone;
  final String city;
  final String avatar;

  const RatingClient({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.avatar
  });

  factory RatingClient.fromJson(Map<String, dynamic> json) => RatingClient(
    id: json['id']?.toString() ?? '',
    fullName: json['fullName']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
    avatar: json['avatar']?.toString() ?? '',
  );
}

// ── Rating Lawyer ─────────────────────────────────────────────────────────────

class RatingLawyer {
  final String id;
  final String fullName;
  final String city;
  final String licenseNumber;
  final double rating;
  final String photoUrl;

  const RatingLawyer({
    required this.id,
    required this.fullName,
    required this.city,
    required this.licenseNumber,
    required this.rating,
    required this.photoUrl,
  });

  factory RatingLawyer.fromJson(Map<String, dynamic> json) => RatingLawyer(
    id: json['id']?.toString() ?? '',
    fullName: json['fullName']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
    licenseNumber: json['licenseNumber']?.toString() ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    photoUrl: json['photoUrl']?.toString() ?? '',
  );
}

// ── Rating Consultation ───────────────────────────────────────────────────────

class RatingConsultation {
  final String id;
  final String type;
  final String status;

  const RatingConsultation({
    required this.id,
    required this.type,
    required this.status,
  });

  factory RatingConsultation.fromJson(Map<String, dynamic> json) =>
      RatingConsultation(
        id: json['id']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
      );
}

// ── Single Rating Model ───────────────────────────────────────────────────────

class RatingModel {
  final String id;
  final RatingClient client;
  final RatingLawyer lawyer;
  final RatingConsultation consultation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double stars;
  final String comment;
  final String lawyerReply;
  final bool lawyerReplyPublished;
  final String status;
  final String lawyerReportMessage;
  final DateTime? lawyerReportedAt;

  const RatingModel({
    required this.id,
    required this.client,
    required this.lawyer,
    required this.consultation,
    required this.createdAt,
    required this.updatedAt,
    required this.stars,
    required this.comment,
    this.lawyerReply = '',
    this.lawyerReplyPublished = false,
    this.status = 'active',
    this.lawyerReportMessage = '',
    this.lawyerReportedAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) => RatingModel(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    client: RatingClient.fromJson(
      json['client'] as Map<String, dynamic>? ?? {},
    ),
    lawyer: RatingLawyer.fromJson(
      json['lawyer'] as Map<String, dynamic>? ?? {},
    ),
    consultation: RatingConsultation.fromJson(
      json['consultation'] as Map<String, dynamic>? ?? {},
    ),
    createdAt: _parseDate(json['createdAt']),
    updatedAt: _parseDate(json['updatedAt']),
    stars: (json['stars'] as num?)?.toDouble() ?? 0.0,
    comment: json['comment']?.toString() ?? '',
    lawyerReply: json['lawyerReply']?.toString() ?? '',
    lawyerReplyPublished: json['lawyerReplyPublished'] as bool? ?? false,
    status: json['status']?.toString() ?? 'active',
    lawyerReportMessage: json['lawyerReportMessage']?.toString() ?? '',
    lawyerReportedAt: _parseDate(json['lawyerReportedAt']),
  );

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}

// ── Rating Detail Model (for single rating endpoint) ───────────────────────────

class RatingDetailModel {
  final String id;
  final RatingClient client;
  final RatingLawyer lawyer;
  final RatingConsultation consultation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double stars;
  final String comment;
  final String lawyerReply;
  final bool lawyerReplyPublished;
  final String status;
  final String lawyerReportMessage;
  final DateTime? lawyerReportedAt;

  const RatingDetailModel({
    required this.id,
    required this.client,
    required this.lawyer,
    required this.consultation,
    required this.createdAt,
    required this.updatedAt,
    required this.stars,
    required this.comment,
    this.lawyerReply = '',
    this.lawyerReplyPublished = false,
    this.status = 'active',
    this.lawyerReportMessage = '',
    this.lawyerReportedAt,
  });

  factory RatingDetailModel.fromJson(Map<String, dynamic> json) => RatingDetailModel(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    client: RatingClient.fromJson(
      json['client'] as Map<String, dynamic>? ?? {},
    ),
    lawyer: RatingLawyer.fromJson(
      json['lawyer'] as Map<String, dynamic>? ?? {},
    ),
    consultation: RatingConsultation.fromJson(
      json['consultation'] as Map<String, dynamic>? ?? {},
    ),
    createdAt: _parseDate(json['createdAt']),
    updatedAt: _parseDate(json['updatedAt']),
    stars: (json['stars'] as num?)?.toDouble() ?? 0.0,
    comment: json['comment']?.toString() ?? '',
    lawyerReply: json['lawyerReply']?.toString() ?? '',
    lawyerReplyPublished: json['lawyerReplyPublished'] as bool? ?? false,
    status: json['status']?.toString() ?? 'active',
    lawyerReportMessage: json['lawyerReportMessage']?.toString() ?? '',
    lawyerReportedAt: _parseDate(json['lawyerReportedAt']),
  );

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}

// ── Rating Distribution (stars breakdown) ─────────────────────────────────────

class RatingDistributionItem {
  /// 1 → 5
  final int stars;

  /// Number of ratings with this star value.
  final int count;

  /// Percentage of the total (0 → 100).
  final double percentage;

  const RatingDistributionItem({
    required this.stars,
    required this.count,
    required this.percentage,
  });

  factory RatingDistributionItem.fromJson(Map<String, dynamic> json) =>
      RatingDistributionItem(
        stars: (json['stars'] as num?)?.toInt() ?? 0,
        count: (json['count'] as num?)?.toInt() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      );

  /// 0.0 → 1.0, safe to pass directly to `FractionallySizedBox.widthFactor`.
  double get fraction => (percentage / 100).clamp(0.0, 1.0);
}

// ── Ratings Meta ──────────────────────────────────────────────────────────────

class RatingsMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final double averageRating;

  /// Always 5 entries, ordered from 5 stars down to 1 star.
  final List<RatingDistributionItem> distribution;

  const RatingsMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.averageRating,
    this.distribution = const [],
  });

  factory RatingsMeta.fromJson(Map<String, dynamic> json) => RatingsMeta(
    total: (json['total'] as num?)?.toInt() ?? 0,
    page: (json['page'] as num?)?.toInt() ?? 1,
    limit: (json['limit'] as num?)?.toInt() ?? 10,
    totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    distribution: _parseDistribution(json['distribution']),
  );

  /// Normalises the API list into exactly 5 items ordered 5 → 1,
  /// filling any missing star value with zeros.
  static List<RatingDistributionItem> _parseDistribution(dynamic value) {
    final parsed = <int, RatingDistributionItem>{};

    if (value is List) {
      for (final e in value) {
        if (e is Map<String, dynamic>) {
          final item = RatingDistributionItem.fromJson(e);
          if (item.stars >= 1 && item.stars <= 5) {
            parsed[item.stars] = item;
          }
        }
      }
    }

    return List.generate(
      5,
          (i) {
        final stars = 5 - i;
        return parsed[stars] ??
            RatingDistributionItem(stars: stars, count: 0, percentage: 0);
      },
    );
  }

  /// True when the API actually sent usable distribution data.
  bool get hasDistribution => distribution.any((e) => e.count > 0);

  /// Builds a 5 → 1 distribution locally from a list of ratings.
  /// Used only as a fallback when the API omits `distribution`.
  static List<RatingDistributionItem> distributionFromRatings(
      List<RatingModel> ratings,
      ) {
    final counts = <int, int>{for (var s = 1; s <= 5; s++) s: 0};

    for (final r in ratings) {
      final s = r.stars.round().clamp(1, 5);
      counts[s] = (counts[s] ?? 0) + 1;
    }

    final total = ratings.length;

    return List.generate(5, (i) {
      final stars = 5 - i;
      final count = counts[stars] ?? 0;
      return RatingDistributionItem(
        stars: stars,
        count: count,
        percentage: total == 0 ? 0 : (count / total) * 100,
      );
    });
  }

  /// Lookup helper — never returns null.
  RatingDistributionItem distributionFor(int stars) =>
      distribution.firstWhere(
            (e) => e.stars == stars,
        orElse: () =>
            RatingDistributionItem(stars: stars, count: 0, percentage: 0),
      );
}

// ── Paginated Ratings Response ────────────────────────────────────────────────

class LawyerRatingsModel {
  final List<RatingModel> ratings;
  final RatingsMeta meta;

  const LawyerRatingsModel({
    required this.ratings,
    required this.meta,
  });

  factory LawyerRatingsModel.fromJson(Map<String, dynamic> json) =>
      LawyerRatingsModel(
        ratings: (json['data'] as List<dynamic>? ?? [])
            .map((e) => RatingModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: RatingsMeta.fromJson(
          json['meta'] as Map<String, dynamic>? ?? {},
        ),
      );

  /// Distribution from the API, or computed from the loaded ratings
  /// when the API didn't send one.
  List<RatingDistributionItem> get effectiveDistribution =>
      meta.hasDistribution || ratings.isEmpty
          ? meta.distribution
          : RatingsMeta.distributionFromRatings(ratings);

  /// Average from the API, or computed from the loaded ratings as a fallback.
  double get effectiveAverage {
    if (meta.averageRating > 0 || ratings.isEmpty) return meta.averageRating;
    final sum = ratings.fold<double>(0, (a, r) => a + r.stars);
    return sum / ratings.length;
  }

  /// Total from the API, falling back to the number of loaded ratings.
  int get effectiveTotal => meta.total > 0 ? meta.total : ratings.length;
}

// ── Report Rating Request ─────────────────────────────────────────────────────

class ReportRatingRequest {
  final String message;

  const ReportRatingRequest({required this.message});

  Map<String, dynamic> toJson() => {'message': message};
}

// ── Reply to Rating Request ────────────────────────────────────────────────────

class ReplyRatingRequest {
  final String reply;

  const ReplyRatingRequest({required this.reply});

  Map<String, dynamic> toJson() => {'reply': reply};
}