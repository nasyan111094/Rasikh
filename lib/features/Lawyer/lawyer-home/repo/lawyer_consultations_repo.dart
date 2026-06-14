// features/Lawyer/lawyer-home/data/lawyer_consultations_repo.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
import '../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../core/utils/api/api_handler.dart';
import '../models/consultation_model.dart';
import '../models/nearest.dart';

class LawyerConsultationsEndpoints {
  static const String availableConsultations =
      'lawyer/consultations/instant/available';

  static String acceptInstant(String id) =>
      'lawyer/consultations/$id/accept-instant';

  static String acceptWritten(String id) =>
      'lawyer/consultations/$id/accept-written';
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Handles all lawyer consultation operations
///
/// API Endpoints:
///   GET  /api/v1/lawyer/consultations/instant/available
///        → Fetches pending instant consultations
///
///   POST /api/v1/lawyer/consultations/{id}/accept-instant
///        → Accepts a pending instant consultation
///        → Transitions consultation from pending → active
///
///   POST /api/v1/lawyer/consultations/{id}/accept-written
///        → Accepts a pending paid written consultation
///        → Assigns lawyer and sets status to active
/// ─────────────────────────────────────────────────────────────────────────────

class LawyerConsultationsRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  /// GET available consultations (instant + written)
  ///
  /// Fetches paginated list of pending instant consultations
  /// that are awaiting lawyer acceptance.
  Future<Either<String, List<Consultation>>> getAvailableConsultations({
    int page = 1,
    int limit = 10,
  }) async {
    final query = {'page': page, 'limit': limit};
    final result = await _adapter.get(
      LawyerConsultationsEndpoints.availableConsultations,
      queryParameters: query,
    );

    return result.fold(
          (error) => Left(_extractError(error)),
          (response) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> consultationsJson = data['data'] ?? [];
        final consultations = consultationsJson
            .map((json) => Consultation.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(consultations);
      },
    );
  }

  /// POST accept instant consultation
  ///
  /// Accepts a pending instant consultation request.
  /// Returns: Updated consultation with status="active"
  ///
  /// Errors:
  /// - 400: Consultation is not instant type or already accepted
  /// - 401: Unauthorized
  /// - 403: LAWYER role required
  /// - 404: Not found
  Future<Either<String, Consultation>> acceptInstantConsultation(
      String id) async {
    final result = await _adapter.post(
      'lawyer/consultations/$id/accept-instant',
      body: {},
    );

    return result.fold(
          (error) => Left(_extractError(error)),
          (response) {
        final data = response.data as Map<String, dynamic>;
        final consultationData =
        data['data']['consultation'] as Map<String, dynamic>;
        return Right(Consultation.fromJson(consultationData));
      },
    );
  }

  /// POST accept written consultation
  ///
  /// Accepts a pending paid written consultation.
  /// Assigns the lawyer and transitions status to active.
  ///
  /// Errors:
  /// - 400: Consultation is not written type or already accepted
  /// - 401: Unauthorized
  /// - 403: LAWYER role required
  /// - 404: Not found
  Future<Either<String, Consultation>> acceptWrittenConsultation(
      String id) async {
    final result = await _adapter.post(
      'lawyer/consultations/$id/accept-written',
      body: {},
    );

    return result.fold(
          (error) => Left(_extractError(error)),
          (response) {
        final data = response.data as Map<String, dynamic>;
        final consultationData =
        data['data']['consultation'] as Map<String, dynamic>;
        return Right(Consultation.fromJson(consultationData));
      },
    );
  }

  String _extractError(dynamic left) {
    try {
      if (left is DioException) {
        final data = left.response?.data;
        if (data is Map) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstField = errors.values.first;
            if (firstField is List && firstField.isNotEmpty) {
              return firstField.first.toString();
            }
          }
          return data['message']?.toString() ??
              data['error']?['details']?.toString() ??
              'حدث خطأ غير متوقع';
        }
      }
      return left.toString();
    } catch (_) {
      return 'حدث خطأ غير متوقع';
    }
  }

  // في الـ endpoints class
  static const String upcomingScheduled =
      'lawyer/consultations/scheduled/upcoming';

// ── GET upcoming scheduled (max 3) ──────────────────────────────────────────
  Future<Either<String, List<ScheduledConsultation>>>
  getUpcomingScheduled() async {
    final result =
    await _adapter.get(upcomingScheduled);

    return result.fold(
          (error) => Left(_extractError(error)),
          (response) {
        final body = response.data as Map<String, dynamic>;
        // shape: { "data": { "data": [...] } }
        final inner = body['data'];
        final List<dynamic> list = (inner is Map ? inner['data'] : inner) ?? [];
        return Right(
          list
              .cast<Map<String, dynamic>>()
              .map(ScheduledConsultation.fromJson)
              .toList(),
        );
      },
    );
  }
}