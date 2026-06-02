// features/Lawyer/lawyer-home/data/lawyer_consultations_repo.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:logger/logger.dart';
import '../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../core/utils/api/api_handler.dart';
import '../models/consultation_model.dart';

class LawyerConsultationsEndpoints {
  static const String availableConsultations = 'lawyer/consultations/instant/available';
  static String acceptInstant(String id) => 'lawyer/consultations/$id/accept-instant';
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
///        → Response includes updated consultation with new status
/// ─────────────────────────────────────────────────────────────────────────────

class LawyerConsultationsRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  /// GET available consultations (instant + written)
  ///
  /// Fetches paginated list of pending instant consultations
  /// that are awaiting lawyer acceptance.
  ///
  /// Response contains:
  /// - consultation list with id, title, details, type, client info
  /// - pagination metadata (page, limit, total, totalPages)
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
  ///
  /// Flow:
  /// 1. Client creates instant consultation (status: pending)
  /// 2. Lawyer calls this endpoint with consultation ID
  /// 3. Status changes to active
  /// 4. Real-time connection established
  /// 5. Both parties can join the video call
  ///
  /// Returns: Updated consultation with status="active"
  ///
  /// Errors:
  /// - 400: Consultation is not instant type or already accepted
  /// - 401: Unauthorized - Invalid or missing JWT token
  /// - 403: Forbidden - LAWYER role required
  /// - 404: Consultation not found
  Future<Either<String, Consultation>> acceptInstantConsultation(String id) async {

    Logger().i(id) ;
    Logger().i(id) ;
    Logger().i(id) ;
    Logger().i(id) ;
    Logger().i(id) ;
    Logger().i(id) ;
    Logger().i(id) ;
    Logger().i(id) ;
    Logger().i(id) ;
    Logger().i(id) ;
    Logger().i(id) ;
    Logger().i(id) ;


    final result = await _adapter.post(
      "lawyer/consultations/$id/accept-instant",
      body: {}, // empty body per API spec
    );

    return result.fold(
          (error) => Left(_extractError(error)),
          (response) {
        final data = response.data as Map<String, dynamic>;
        final consultationData = data['data']['consultation'] as Map<String, dynamic>;
        final acceptedConsultation = Consultation.fromJson(consultationData);
        return Right(acceptedConsultation);
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
}