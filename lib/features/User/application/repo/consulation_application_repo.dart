// ─────────────────────────────────────────────────────────────────────────────
// consultation_repo.dart
// Single repository that handles all API calls for the consultation feature.
// Updated endpoints:
//   • GET  /api/v1/specializations/active          (was /api/v1/specializations)
//   • GET  /api/v1/enums/{type}                    (NEW – consultation-types & cities)
//   • GET  /api/v1/clients/lawyers
//   • GET  /api/v1/clients/lawyers/{id}
//   • GET  /api/v1/clients/lawyers/recommended
//   • GET  /api/v1/client/pricing
//   • POST /api/v1/client/consultations
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../config/app_config.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/api/api_handler.dart';
import '../models/consultation_model.dart';
import '../models/bookable_slot_model.dart';


class ConsultationRepo {
  ConsultationRepo();

  final DioAdapterBase _dio = getIt.get<ApiHandler>().dioAdapterBase;

  // ── 1. GET /api/v1/specializations/active ────────────────────────────────
  // Public endpoint – returns only active specializations with active subs.
  // Sorted by name; supports optional search.

  Future<Either<String, List<SpecializationModel>>> fetchSpecializations({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final result = await _dio.get(
      'specializations/active',
      queryParameters: queryParams,
    );

    if (result.isRight) {
      final rawList = result.right.data['data'] as List<dynamic>? ?? [];
      final specializations = rawList
          .map((e) => SpecializationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(specializations);
    }
    return Left(result.left.toString());
  }


  // ── 8. GET /api/v1/lawyers/{lawyerId}/availability/slots ──────────────────
  // Returns discrete bookable slots filtered by duration
  // from and to are ISO datetime strings in Asia/Riyadh timezone
  // durationMin filters for slots that have ceil(durationMin/15) consecutive periods

  Future<Either<String, BookableSlotsResponse>> fetchBookableSlots({
    required String lawyerId,
    required DateTime from,
    required DateTime to,
    int? durationMinutes,
  }) async {
    final queryParams = <String, dynamic>{
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      if (durationMinutes != null) 'durationMin': durationMinutes,
    };

    final result = await _dio.get(
      'lawyers/$lawyerId/availability/slots',
      queryParameters: queryParams,
    );

    if (result.isRight) {
      final data = result.right.data as Map<String, dynamic>;
      return Right(BookableSlotsResponse.fromJson(data));
    }
    return Left(result.left.toString());
  }
  // ── 2. GET /api/v1/enums/{type} ──────────────────────────────────────────
  // Fetches key-value enum pairs for a given type.
  // Used for: 'consultation-types', 'cities', and any future enum.

  Future<Either<String, List<EnumValueModel>>> fetchEnum(String type) async {
    final result = await _dio.get('enums/$type');

    if (result.isRight) {
      final rawList = result.right.data['data'] as List<dynamic>? ?? [];
      final values = rawList
          .map((e) => EnumValueModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(values);
    }
    return Left(result.left.toString());
  }

  // ── 3. GET /api/v1/clients/lawyers ────────────────────────────────────────

  Future<Either<String, List<LawyerModel>>> fetchLawyers({
    String? specializationId,
    String? subSpecializationIds, // comma-separated
    String? city,
    int? minExperience,
    double? maxPrice,
    bool availability = true,
    double? minRating,
    String? search,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, dynamic>{
      'availability': availability,
      'page': page,
      'limit': limit,
      if (specializationId != null) 'specialization': specializationId,
      if (subSpecializationIds != null)
        'subSpecializationIds': subSpecializationIds,
      if (city != null) 'city': city,
      if (minExperience != null) 'minExperience': minExperience,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (minRating != null) 'minRating': minRating,
      if (search != null && search.isNotEmpty) 'search': search,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };

    final result = await _dio.get(
      'clients/lawyers',
      queryParameters: queryParams,
    );

    if (result.isRight) {
      final rawList = result.right.data['data'] as List<dynamic>? ?? [];
      final lawyers = rawList
          .map((e) => LawyerModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(lawyers);
    }
    return Left(result.left.toString());
  }

  // ── 4. GET /api/v1/clients/lawyers/{id} ───────────────────────────────────

  Future<Either<String, LawyerDetailModel>> fetchLawyerDetails(
      String lawyerId) async {
    final result = await _dio.get('clients/lawyers/$lawyerId');

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(LawyerDetailModel.fromJson(data));
    }
    return Left(result.left.toString());
  }

  // ── 5. GET /api/v1/clients/lawyers/recommended ────────────────────────────
  // subSpecializationIds: backend accepts repeated params, comma-separated,
  // or JSON array string. We send as repeated query params (most compatible).

  Future<Either<String, LawyerDetailModel>> fetchRecommendedLawyer({
    required String specializationId,
    List<String>? subSpecializationIds,
  }) async {
    final queryParams = <String, dynamic>{
      'specializationId': specializationId,
      if (subSpecializationIds != null && subSpecializationIds.isNotEmpty)
        'subSpecializationIds': subSpecializationIds,
    };

    final result = await _dio.get(
      'clients/lawyers/recommended',
      queryParameters: queryParams,
    );

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(LawyerDetailModel.fromJson(data));
    }
    return Left(result.left.toString());
  }

  // ── 6. GET /api/v1/client/pricing ─────────────────────────────────────────
  // Only active pricing plans are returned.
  // consultation_type filter: 'instant' | 'written' | 'scheduled'

  Future<Either<String, List<PricingModel>>> fetchPricing({
    int page = 1,
    int limit = 20,
    String? consultationType,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (consultationType != null) 'consultation_type': consultationType,
    };

    final result = await _dio.get(
      'client/pricing',
      queryParameters: queryParams,
    );

    if (result.isRight) {
      final rawList = result.right.data['data'] as List<dynamic>? ?? [];
      final pricing = rawList
          .map((e) => PricingModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(pricing);
    }
    return Left(result.left.toString());
  }

  // ── 7. POST /api/v1/client/consultations ──────────────────────────────────
  // multipart/form-data. lawyerId is always required.

// ── 7. POST /api/v1/client/consultations ──────────────────────────────────

  Future<Either<String, CreatedConsultationModel>> createConsultation(
      CreateConsultationParams params) async {

    final fields = <String, dynamic>{
      'pricingId': params.pricingId,
      'lawyerId': params.lawyerId,
      'specializationId': params.specializationId,
      'title': params.title,
      'details': params.details,
      'type': params.type.value,
      'hideClientFromLawyer': params.hideClientFromLawyer.toString(),
    };

    if (params.subSpecializationIds.isNotEmpty) {
      fields['subSpecializationIds'] =
      '[${params.subSpecializationIds.map((id) => '"$id"').join(',')}]';
    }

    if (params.startTime != null) {
      fields['startTime'] = params.startTime!.toUtc().toIso8601String();
    }
    if (params.endTime != null) {
      fields['endTime'] = params.endTime!.toUtc().toIso8601String();
    }

    if (params.voiceNote != null) {
      fields['voiceNote'] = await MultipartFile.fromFile(
        params.voiceNote!.path,
        filename: 'voice_note.mp3',
      );
      if (params.voiceNoteDurationSeconds != null) {
        fields['voiceNoteDurationSeconds'] =
            params.voiceNoteDurationSeconds.toString();
      }
    }

    // ✅ الصح: بناء FormData يدوياً بـ MultipartFile list تحت نفس الـ key
    final formData = FormData();

    // أضف الـ fields العادية
    fields.forEach((key, value) {
      if (value is MultipartFile) {
        formData.files.add(MapEntry(key, value));
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    // أضف الـ attachments كلها تحت نفس الـ key
    final attachmentFiles = params.attachments.take(5).toList();
    for (int i = 0; i < attachmentFiles.length; i++) {
      formData.files.add(MapEntry(
        'attachments',
        await MultipartFile.fromFile(
          attachmentFiles[i].path,
          filename: 'attachment_$i.${attachmentFiles[i].path.split('.').last}',
        ),
      ));
    }

    final result = await _dio.post(
      'client/consultations',
      body: formData,
    );

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(CreatedConsultationModel.fromJson(data));
    }
    return Left(result.left.toString());
  }
}