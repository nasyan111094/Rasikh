
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/core/services/app_logger.dart';
import 'package:rasikh/features/User/application/bloc/consulation_application_cubit.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/app_config.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/api/api_handler.dart';
import '../models/consultation_model.dart';
import '../models/bookable_slot_model.dart';


class ConsultationRepo {
  ConsultationRepo();

  final DioAdapterBase _dio = getIt.get<ApiHandler>().dioAdapterBase;

  /// Idempotency keys per consultation so retries / double-taps
  /// reuse the SAME key instead of generating a new one each call
  /// (a new key per call defeats server-side deduplication).
  final Map<String, String> _paymentIdempotencyKeys = {};


  Future<
      Either<
          String,
          ({
            List<SpecializationModel> specializations,
            Map<String, List<SubSpecializationModel>> lawsuitTypes,
          })>> fetchSpecializations({
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
      final lawsuitTypes = <String, List<SubSpecializationModel>>{};
      for (final spec in rawList) {
        final subs = (spec as Map<String, dynamic>)['subSpecializations']
                as List<dynamic>? ??
            [];
        for (final sub in subs) {
          final subJson = sub as Map<String, dynamic>;
          final types = subJson['lawsuitTypes'] as List<dynamic>? ?? [];
          lawsuitTypes[subJson['id'] as String? ?? ''] = types
              .map((t) => t as Map<String, dynamic>)
              .where((t) => t['isActive'] as bool? ?? true)
              .map((t) => SubSpecializationModel(
                    id: (t['_id'] ?? t['id']) as String? ?? '',
                    name: t['name'] as String? ?? '',
                    isActive: true,
                  ))
              .toList();
        }
      }
      return Right(
          (specializations: specializations, lawsuitTypes: lawsuitTypes));
    }
    return Left(result.left);
  }



  Future<Either<String, BookableSlotsResponse>> fetchBookableSlots({
    required String lawyerId,
    required DateTime from,
    required DateTime to,
    int? durationMinutes,
  }) async {
    final queryParams = <String, dynamic>{
      // Send UTC so server filtering matches createConsultation payload.
      'from': from.toUtc().toIso8601String(),
      'to': to.toUtc().toIso8601String(),
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


  Future<Either<String, List<LawyerDetailModel>>> fetchLawyers({
    String? specializationId,
    String? subSpecializationIds,
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
      'availability':  availability,
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
          .map((e) => LawyerDetailModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(lawyers);
    }
    return Left(result.left.toString());
  }


  Future<Either<String, LawyerDetailModel>> fetchLawyerDetails(
      String lawyerId) async {
    final result = await _dio.get('clients/lawyers/$lawyerId');

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(LawyerDetailModel.fromJson(data));
    }
    return Left(result.left.toString());
  }


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



  Future<Either<String, CreatedConsultationModel>> createConsultation(
      CreateConsultationParams params,
      {String? lawsuitTypeId, String? idempotencyKey}) async {

    final fields = <String, dynamic>{
      'pricingId': params.pricingId,
      'lawyerId': params.lawyerId,
      'specializationId': params.specializationId,
      'title': params.title,
      'details': params.details,
      'type': params.type.value,
      'hideClientFromLawyer': params.hideClientFromLawyer.toString(),
    };

    if (lawsuitTypeId != null && lawsuitTypeId.isNotEmpty) {
      fields['lawsuitTypeId'] = lawsuitTypeId;
    }

    if (params.subSpecializationIds.isNotEmpty) {
      fields['subSpecializationIds'] =
      '[${params.subSpecializationIds.map((id) => '"$id"').join(',')}]';
    }

    String formatDate(DateTime? dt) {
      // Device DateTime is local → convert once to UTC for the API.
      // (Previous toLocal().toUtc() round-trip could shift during DST.)
      if (dt == null) return '';
      return dt.toUtc().toIso8601String();
    }

    if (params.startTime != null) {
      AppLogger.info(params.startTime) ;
      fields['startTime'] = formatDate(params.startTime);
      AppLogger.info(formatDate(params.startTime)) ;
    }

    if (params.endTime != null) {
      AppLogger.info(params.endTime) ;
      fields['endTime'] = formatDate(params.endTime);
      AppLogger.info(formatDate(params.endTime)) ;
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

    final formData = FormData();

    fields.forEach((key, value) {
      if (value is MultipartFile) {
        formData.files.add(MapEntry(key, value));
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    final attachmentFiles = params.attachments.take(5).toList();

    for (int i = 0; i < attachmentFiles.length; i++) {
      formData.files.add(MapEntry(
        'attachments',
        await MultipartFile.fromFile(
          attachmentFiles[i].path,
          filename:
          'attachment_$i.${attachmentFiles[i].path.split('.').last}',
        ),
      ));
    }

    final result = await _dio.post(
      'client/consultations',
      body: formData,
      options: idempotencyKey == null
          ? null
          : Options(headers: {'Idempotency-Key': idempotencyKey}),
    );

    if (result.isRight) {

      final data = result.right.data['data'] as Map<String, dynamic>;
      AppLogger.info(data) ;
      return Right(CreatedConsultationModel.fromJson(data));
    }

    return Left(result.left.toString());
  }


  /// Returns a STABLE key per consultationId (creates once, reuses after).
  String _stablePaymentKey(String consultationId) =>
      _paymentIdempotencyKeys.putIfAbsent(
          consultationId, () => const Uuid().v4());

  /// Clears the stored key (call after a terminal paid/failed state
  /// if the backend expects a fresh key for the next payment attempt
  /// on a NEW consultation — keys are per-consultation so this is rarely needed).
  void clearPaymentKey(String consultationId) =>
      _paymentIdempotencyKeys.remove(consultationId);

  Future<Either<String, Map<String, dynamic>>> payWithWallet({
    required String consultationId,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _stablePaymentKey(consultationId);
    
    final result = await _dio.post(
      EndPoints.payWithWallet(consultationId: consultationId),
      options: Options(headers: {
        'Idempotency-Key': key,
      }),
    );

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(data);
    }
    return Left(result.left.toString());
  }


  Future<Either<String, Map<String, dynamic>>> initiatePayment({
    required String consultationId,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _stablePaymentKey(consultationId);
    
    final result = await _dio.post(
      EndPoints.initiatePayment(consultationId: consultationId),
      options: Options(headers: {
        'Idempotency-Key': key,
      }),
    );

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(data);
    }
    return Left(result.left.toString());
  }


  Future<Either<String, Map<String, dynamic>>> checkConsultationStatus({
    required String consultationId,
  }) async {
    final result = await _dio.get('client/consultations/$consultationId');

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(data);
    }
    return Left(result.left.toString());
  }


  Future<Either<String, Map<String, dynamic>>> checkPaymentStatus({
    required String consultationId,
  }) async {
    final result = await _dio.get('client/consultations/$consultationId/payment/status');

    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(data);
    }
    return Left(result.left.toString());
  }

  /// Extracts the external payment URL tolerating backend key variations
  /// (PaymentURL / paymentUrl / paymentLink / url, nested or flat).
  static String? extractPaymentUrl(Map<String, dynamic>? paymentData) {
    if (paymentData == null) return null;
    final candidates = <dynamic>[
      paymentData['payment'] is Map
          ? (paymentData['payment'] as Map)['PaymentURL']
          : null,
      paymentData['payment'] is Map
          ? (paymentData['payment'] as Map)['paymentUrl']
          : null,
      paymentData['payment'] is Map
          ? (paymentData['payment'] as Map)['url']
          : null,
      paymentData['paymentUrl'],
      paymentData['PaymentURL'],
      paymentData['paymentLink'],
      paymentData['url'],
    ];
    for (final c in candidates) {
      if (c is String && c.isNotEmpty) return c;
    }
    return null;
  }

  /// Normalizes invoice/payment status strings across gateway variations.
  static String normalizePaymentStatus(Map<String, dynamic> data) {
    final raw = (data['invoiceStatus'] ??
            data['paymentStatus'] ??
            data['status'] ??
            '')
        .toString()
        .toLowerCase();
    if (raw == 'paid' || raw == 'completed' || raw == 'success') {
      return 'paid';
    }
    if (raw == 'failed' ||
        raw == 'cancelled' ||
        raw == 'canceled' ||
        raw == 'rejected' ||
        raw == 'expired') {
      return 'failed';
    }
    return 'pending';
  }
}