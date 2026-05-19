// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/lawyer_Settings/data/repos/lawyer_ratings_repo.dart
//
// Handles all lawyer ratings endpoints:
//   GET  /api/v1/lawyer/ratings              → fetch paginated ratings
//   POST /api/v1/lawyer/ratings/{id}/report  → report a rating
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/lawyer_ratings_model.dart';

// ── Endpoint constants ────────────────────────────────────────────────────────

class _RatingsEndpoints {
  static const String ratings = 'lawyer/ratings';

  static String reportRating(String id) => 'lawyer/ratings/$id/report';
}

// ── Repository ────────────────────────────────────────────────────────────────

class LawyerRatingsRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  // ── GET paginated ratings ──────────────────────────────────────────────────

  Future<Either<String, LawyerRatingsModel>> getRatings({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _adapter.get(
      _RatingsEndpoints.ratings,
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    if (result.isRight) {
      final data = result.right.data;
      return Right(LawyerRatingsModel.fromJson(data));
    }
    return Left(_extractError(result.left));
  }

  // ── POST report a rating ───────────────────────────────────────────────────

  Future<Either<String, String>> reportRating({
    required String ratingId,
    required String message,
  }) async {
    final result = await _adapter.post(
      _RatingsEndpoints.reportRating(ratingId),
      body: ReportRatingRequest(message: message).toJson(),
    );

    if (result.isRight) {
      final data = result.right.data;
      final responseMessage =
          data['message']?.toString() ?? 'تم إرسال البلاغ بنجاح';
      return Right(responseMessage);
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
