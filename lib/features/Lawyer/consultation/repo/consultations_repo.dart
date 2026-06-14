// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/data/repos/consultations_repo.dart
//
// Endpoints:
//   GET /api/v1/lawyer/consultations          → paginated list (lawyer)
//   GET /api/v1/client/consultations          → paginated list (client)
//   GET /api/v1/lawyer/consultations/{id}     → details (lawyer)
//   GET /api/v1/client/consultations/{id}     → details (client)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
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
      final data = result.right.data;
      final json = data is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>? ?? data)
          : data as Map<String, dynamic>;
      return Right(ConsultationModel.fromJson(json));
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