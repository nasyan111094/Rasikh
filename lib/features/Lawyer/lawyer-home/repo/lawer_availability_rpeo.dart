// features/Lawyer/availability/data/repos/lawyer_availability_repo.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/avaiability_status_model.dart';


// ── Endpoint constants ────────────────────────────────────────────────────────

class _LawyerAvailabilityEndpoints {
  /// PUT /api/v1/lawyers/availability
  static const String updateAvailability = 'lawyers/availability';
}

// ── Repository ────────────────────────────────────────────────────────────────

class LawyerAvailabilityRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  // ── PUT availability status ───────────────────────────────────────────────

  Future<Either<String, UpdateAvailabilityResponse>> updateAvailability({
    required LawyerAvailabilityStatus status,
  }) async {
    final body = UpdateAvailabilityRequest(availability: status).toJson();

    final result = await _adapter.put(
      _LawyerAvailabilityEndpoints.updateAvailability,
      body: body,
    );

    if (result.isRight) {
      final data = result.right.data;
      return Right(
          UpdateAvailabilityResponse.fromJson(data as Map<String, dynamic>));
    }
    return Left(_extractError(result.left));
  }

  // ── Error helper ──────────────────────────────────────────────────────────

  String _extractError(dynamic left) {
    try {
      if (left is DioException) {
        final data = left.response?.data;
        if (data is Map) {
          // Handle field-level validation errors (e.g. availability: [...])
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