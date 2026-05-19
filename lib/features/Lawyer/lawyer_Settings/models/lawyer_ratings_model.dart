// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/lawyer_Settings/data/models/lawyer_ratings_model.dart
// ─────────────────────────────────────────────────────────────────────────────

// ── Rating Client ─────────────────────────────────────────────────────────────

class RatingClient {
  final String id;
  final String fullName;
  final String phone;
  final String city;

  const RatingClient({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.city,
  });

  factory RatingClient.fromJson(Map<String, dynamic> json) => RatingClient(
        id: json['id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
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
  final RatingConsultation consultation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double stars;
  final String comment;

  const RatingModel({
    required this.id,
    required this.client,
    required this.consultation,
    required this.createdAt,
    required this.updatedAt,
    required this.stars,
    required this.comment,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) => RatingModel(
        id: json['id']?.toString() ?? '',
        client: RatingClient.fromJson(
          json['client'] as Map<String, dynamic>? ?? {},
        ),
        consultation: RatingConsultation.fromJson(
          json['consultation'] as Map<String, dynamic>? ?? {},
        ),
        createdAt: _parseDate(json['createdAt']),
        updatedAt: _parseDate(json['updatedAt']),
        stars: (json['stars'] as num?)?.toDouble() ?? 0.0,
        comment: json['comment']?.toString() ?? '',
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

// ── Ratings Meta ──────────────────────────────────────────────────────────────

class RatingsMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final double averageRating;

  const RatingsMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.averageRating,
  });

  factory RatingsMeta.fromJson(Map<String, dynamic> json) => RatingsMeta(
        total: (json['total'] as num?)?.toInt() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 1,
        limit: (json['limit'] as num?)?.toInt() ?? 10,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
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
}

// ── Report Rating Request ─────────────────────────────────────────────────────

class ReportRatingRequest {
  final String message;

  const ReportRatingRequest({required this.message});

  Map<String, dynamic> toJson() => {'message': message};
}
