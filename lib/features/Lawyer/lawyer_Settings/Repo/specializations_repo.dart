// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/specializations/data/repos/specializations_repo.dart
//
// Handles:
//   GET /api/v1/specializations/active   → fetch active catalog (public)
//
// Dependencies are resolved via getIt — no constructor args needed.
// Register once in get_it_service.dart:
//   getIt.registerLazySingleton(() => SpecializationsRepo());
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/specialization_catalog_model.dart';

class _SpecializationsEndpoints {
  static const String active = 'specializations/active';
}

class SpecializationsRepo {
  // Resolved lazily the same way LawyerProfileRepo does it.
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  // ── GET active specializations ─────────────────────────────────────────────

  Future<Either<String, SpecializationCatalogResponse>> getActiveSpecializations({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final result = await _adapter.get(
      _SpecializationsEndpoints.active,
      queryParameters: queryParams,
    );

    if (result.isRight) {
      final data = result.right.data;
      return Right(SpecializationCatalogResponse.fromJson(data));
    }
    return Left(_extractError(result.left));
  }

  // ── Error helper ──────────────────────────────────────────────────────────

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