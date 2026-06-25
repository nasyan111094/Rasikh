// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/data/repos/consultations_repo.dart
//
// Endpoints:
//   GET   /api/v1/lawyer/consultations          → paginated list (lawyer)
//   GET   /api/v1/client/consultations          → paginated list (client)
//   GET   /api/v1/lawyer/consultations/{id}     → details (lawyer)
//   GET   /api/v1/client/consultations/{id}     → details (client)
//   POST  /api/v1/client/consultations/{id}/reschedule → reschedule (client)
//   PATCH /api/v1/client/consultations/{id}/cancel     → cancel (client)
//   POST  /api/v1/client/ratings                       → rate (client)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/consultation_model.dart';

// ── Endpoint Resolver ─────────────────────────────────────────────────────────

class _Endpoints {
  _Endpoints._();

  static bool get _isLawyer =>
      getIt<CacheHelper>().cachedVendorType == VendorType.lawyer;

  static String get list =>
      _isLawyer ? 'lawyer/consultations' : 'client/consultations';

  static String details(String id) =>
      _isLawyer ? 'lawyer/consultations/$id' : 'client/consultations/$id';

  /// Reschedule is a client-only action.
  static String reschedule(String id) =>
      'client/consultations/$id/reschedule';

  /// Cancel is a client-only action.
  static String cancel(String id) =>
      'client/consultations/$id/cancel';

  /// Ratings are a client-only action, and unlike the other endpoints this
  /// one is NOT nested under /consultations/{id} — it's its own resource.
  static String rate = 'client/ratings';
}

// ── Repository ────────────────────────────────────────────────────────────────

class ConsultationsRepo {
  ConsultationsRepo() : _adapter = getIt<ApiHandler>().dioAdapterBase;

  final DioAdapterBase _adapter;

  // ── Fetch paginated consultations ─────────────────────────────────────────

  Future<Either<String, ConsultationsModel>> getConsultations({
    int page = 1,
    int limit = 3,
    ConsultationStatus? status,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null && status != ConsultationStatus.none)
        'status': status.apiValue,
    };

    final result = await _adapter.get(
      _Endpoints.list,
      queryParameters: query,
    );

    if (result.isRight) {



      return Right(
        ConsultationsModel.fromJson(result.right.data as Map<String, dynamic>),
      );
    }
    return Left(_extractError(result.left));
  }

  // ── Fetch consultation details ─────────────────────────────────────────────

  Future<Either<String, ConsultationModel>> getConsultationDetails({
    required String id,
  }) async {
    final result = await _adapter.get(_Endpoints.details(id));

    if (result.isRight) {
      Logger().i(result.right.data);
      final data = result.right.data;
      final json = data is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>? ?? data)
          : data as Map<String, dynamic>;
      return Right(ConsultationModel.fromJson(json));
    }
    return Left(_extractError(result.left));
  }

  // ── Reschedule consultation ───────────────────────────────────────────────
  //
  // Only valid for scheduled + upcoming consultations owned by the client.
  // [newStartTime] must be a future UTC datetime that fits the lawyer's
  // availability grid; the server releases the old slot automatically.

  Future<Either<String, ConsultationModel>> rescheduleConsultation({
    required String id,
    required DateTime newStartTime,
  }) async {
    final result = await _adapter.post(
      _Endpoints.reschedule(id),
      body: {
        'newStartTime': newStartTime.toUtc().toIso8601String(),
      },
    );

    if (result.isRight) {
      final data = result.right.data;
      final json = data is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>? ?? data)
          : data as Map<String, dynamic>;
      return Right(ConsultationModel.fromJson(json));
    }
    return Left(_extractError(result.left));
  }

  // ── Cancel consultation ───────────────────────────────────────────────────
  //
  // Sends PATCH /api/v1/client/consultations/{id}/cancel.
  // No request body is required. Returns a success boolean or an error string.

  Future<Either<String, bool>> cancelConsultation({
    required String id,
  }) async {
    final result = await _adapter.patch(
      _Endpoints.cancel(id),
    );

    if (result.isRight) {
      return const Right(true);
    }
    return Left(_extractError(result.left));
  }

  // ── Rate consultation ─────────────────────────────────────────────────────
  //
  // Sends POST /api/v1/client/ratings.
  // One rating per consultation; the consultation must be completed and
  // owned by the client. [lawyerId] and [clientId] are required by the API
  // alongside the consultation id — pull them straight off the
  // [ConsultationModel] the card already has in memory (no extra fetch).

  Future<Either<String, bool>> rateConsultation({
    required String consultationId,
    required String lawyerId,
    required String clientId,
    required int stars,
    String? comment,
  }) async {
    final result = await _adapter.post(
      _Endpoints.rate,
      body: {
        'consultationId': consultationId,
        'lawyerId': lawyerId,
        'clientId': clientId,
        'stars': stars,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );

    if (result.isRight) {
      return const Right(true);
    }
    return Left(_extractError(result.left));
  }

  // ── Error helper ──────────────────────────────────────────────────────────

  String _extractError(dynamic error) {
    try {
      if (error is DioException) {
        final data = error.response?.data;
        if (data is Map) {
          return data['message']?.toString() ??
              data['error']?['details']?.toString() ??
              'حدث خطأ غير متوقع';
        }
      }
      return error.toString();
    } catch (_) {
      return 'حدث خطأ غير متوقع';
    }
  }
}