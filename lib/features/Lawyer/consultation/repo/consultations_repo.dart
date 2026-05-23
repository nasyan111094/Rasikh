// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/data/repos/consultations_repo.dart
//
// Handles all consultation endpoints:
//   GET  /api/v1/consultations        → fetch paginated consultations
//   GET  /api/v1/consultations/{id}   → fetch consultation details
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/consultation_model.dart';

// ── Endpoint constants ────────────────────────────────────────────────────────

class _ConsultationsEndpoints {
  static const String lawyerConsultations = 'lawyer/consultations';

  static String lawyerConsultationDetails(String id) => 'lawyer/consultations/$id';


  static const String clientConsultations = 'client/consultations';

  static String clientConsultationDetails(String id) => 'client/consultations/$id';
}




// ── Repository ────────────────────────────────────────────────────────────────

class ConsultationsRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  // ── GET paginated consultations ────────────────────────────────────────────

  Future<Either<String, ConsultationsModel>> getConsultations({
    int page = 1,
    int limit = 3,
    ConsultationStatus? status,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status != ConsultationStatus.none) {
      queryParameters['status'] = status!.apiValue;
    }

    final result = await _adapter.get(
      getIt<CacheHelper>().cachedVendorType ==VendorType.lawyer?_ConsultationsEndpoints.lawyerConsultations:_ConsultationsEndpoints.clientConsultations,
      queryParameters: queryParameters,
    );

    if (result.isRight) {
      final data = result.right.data;
      return Right(ConsultationsModel.fromJson(data as Map<String, dynamic>));
    }
    return Left(_extractError(result.left));
  }

  // ── GET consultation details ───────────────────────────────────────────────

  Future<Either<String, ConsultationModel>> getConsultationDetails({
    required String id,
  }) async {
    final result = await _adapter.get(
      getIt<CacheHelper>().cachedVendorType ==VendorType.lawyer? _ConsultationsEndpoints.lawyerConsultationDetails(id): _ConsultationsEndpoints.clientConsultationDetails(id),
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

  // ── Error helper ───────────────────────────────────────────────────────────

  String _extractError(dynamic left) {
    try {
      if (left is DioException) {
        final data = left.response?.data;
        if (data is Map) {
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