// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/specializations/data/models/specialization_catalog_model.dart
//
// Models for GET /api/v1/specializations/active
// ─────────────────────────────────────────────────────────────────────────────

class SubSpecializationCatalogModel {
  final String id;
  final String name;
  final bool isActive;

  const SubSpecializationCatalogModel({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  factory SubSpecializationCatalogModel.fromJson(Map<String, dynamic> json) =>
      SubSpecializationCatalogModel(
        id: json['id'] ?? json['_id'] ?? '',
        name: json['name'] ?? '',
        isActive: json['isActive'] ?? true,
      );
}

class SpecializationCatalogModel {
  final String id;
  final String name;
  final List<SubSpecializationCatalogModel> subSpecializations;
  final int subSpecializationsCount;
  final bool isActive;
  final int linkedLawyersCount;
  final int linkedConsultationsCount;
  final String? createdAt;
  final String? updatedAt;

  const SpecializationCatalogModel({
    required this.id,
    required this.name,
    this.subSpecializations = const [],
    this.subSpecializationsCount = 0,
    this.isActive = true,
    this.linkedLawyersCount = 0,
    this.linkedConsultationsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory SpecializationCatalogModel.fromJson(Map<String, dynamic> json) =>
      SpecializationCatalogModel(
        id: json['id'] ?? json['_id'] ?? '',
        name: json['name'] ?? '',
        subSpecializations: (json['subSpecializations'] as List<dynamic>?)
            ?.map((e) => SubSpecializationCatalogModel.fromJson(e))
            .toList() ??
            [],
        subSpecializationsCount:
        (json['subSpecializationsCount'] as num?)?.toInt() ?? 0,
        isActive: json['isActive'] ?? true,
        linkedLawyersCount:
        (json['linkedLawyersCount'] as num?)?.toInt() ?? 0,
        linkedConsultationsCount:
        (json['linkedConsultationsCount'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );
}

class SpecializationCatalogMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const SpecializationCatalogMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory SpecializationCatalogMeta.fromJson(Map<String, dynamic> json) =>
      SpecializationCatalogMeta(
        total: (json['total'] as num?)?.toInt() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 1,
        limit: (json['limit'] as num?)?.toInt() ?? 50,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      );
}

class SpecializationCatalogResponse {
  final List<SpecializationCatalogModel> data;
  final SpecializationCatalogMeta meta;

  const SpecializationCatalogResponse({
    required this.data,
    required this.meta,
  });

  factory SpecializationCatalogResponse.fromJson(Map<String, dynamic> json) =>
      SpecializationCatalogResponse(
        data: (json['data'] as List<dynamic>?)
            ?.map((e) => SpecializationCatalogModel.fromJson(e))
            .toList() ??
            [],
        meta: SpecializationCatalogMeta.fromJson(
            json['meta'] as Map<String, dynamic>? ?? {}),
      );
}