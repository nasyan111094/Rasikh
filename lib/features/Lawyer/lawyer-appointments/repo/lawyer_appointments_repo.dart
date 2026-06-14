// features/Lawyer/lawyer-appointments/data/repos/lawyer_appointments_repo.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/availability_slot_model.dart';

// ── Endpoint constants ────────────────────────────────────────────────────────

class _AppointmentsEndpoints {
  /// POST /api/v1/lawyers/availability/slots
  static const String createSlot = 'lawyers/availability/slots';

  /// PUT /api/v1/lawyers/availability/slots/{id}
  static String updateSlot(String id) => 'lawyers/availability/slots/$id';

  /// DELETE /api/v1/lawyers/availability/slots/{id}
  static String deleteSlot(String id) => 'lawyers/availability/slots/$id';

  /// GET /api/v1/lawyers/availability/week?weekStart=YYYY-MM-DD
  static const String weeklyAvailability = 'lawyers/availability/week';
}

// ── Repository ────────────────────────────────────────────────────────────────

class LawyerAppointmentsRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  // ── GET weekly availability ───────────────────────────────────────────────

  Future<Either<String, WeeklyAvailabilityModel>> getWeeklyAvailability({
    String? weekStart,
  }) async {
    final queryParams = <String, dynamic>{
      if (weekStart != null) 'weekStart': weekStart,
    };

    final result = await _adapter.get(
      _AppointmentsEndpoints.weeklyAvailability,
      queryParameters: queryParams,
    );

    if (result.isRight) {
      final data = result.right.data;
      return Right(
        WeeklyAvailabilityModel.fromJson(data as Map<String, dynamic>),
      );
    }
    return Left(_extractError(result.left));
  }

  // ── POST create slot ──────────────────────────────────────────────────────

  Future<Either<String, SlotMutationResponse>> createSlot({
    required SlotRequestModel request,
  }) async {
    final result = await _adapter.post(
      _AppointmentsEndpoints.createSlot,
      body: request.toJson(),
    );

    if (result.isRight) {
      final data = result.right.data;
      return Right(
        SlotMutationResponse.fromJson(data as Map<String, dynamic>),
      );
    }
    return Left(_extractError(result.left));
  }

  // ── PUT update slot ───────────────────────────────────────────────────────

  Future<Either<String, SlotMutationResponse>> updateSlot({
    required String slotId,
    required SlotRequestModel request,
  }) async {
    final result = await _adapter.put(
      _AppointmentsEndpoints.updateSlot(slotId),
      body: request.toJson(),
    );

    if (result.isRight) {
      final data = result.right.data;
      return Right(
        SlotMutationResponse.fromJson(data as Map<String, dynamic>),
      );
    }
    return Left(_extractError(result.left));
  }

  // ── DELETE slot ───────────────────────────────────────────────────────────

  Future<Either<String, bool>> deleteSlot({required String slotId}) async {
    final result = await _adapter.delete(
      _AppointmentsEndpoints.deleteSlot(slotId),
    );

    if (result.isRight) return const Right(true);
    return Left(_extractError(result.left));
  }

  // ── Error extraction ──────────────────────────────────────────────────────
  //
  // Priority order:
  //   1. Validation field errors   → errors.<field>[0]
  //   2. Top-level message         → message
  //   3. Error details             → error.details
  //   4. HTTP status text fallback → DioException.message
  //   5. Generic Arabic fallback

  String _extractError(dynamic left) {
    try {
      if (left is DioException) {
        final responseData = left.response?.data;

        if (responseData is Map<String, dynamic>) {
          // 1. Validation errors object
          final errors = responseData['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstField = errors.values.first;
            if (firstField is List && firstField.isNotEmpty) {
              return firstField.first.toString();
            }
          }

          // 2. Top-level message (covers 404 "المورد غير موجود", etc.)
          final message = responseData['message'];
          if (message is String && message.isNotEmpty) {
            return message;
          }

          // 3. error.details
          final error = responseData['error'];
          if (error is Map) {
            final details = error['details'];
            if (details is String && details.isNotEmpty) return details;
          }
        }

        // 4. DioException itself (timeout, no connection, etc.)
        if (left.type == DioExceptionType.connectionTimeout ||
            left.type == DioExceptionType.receiveTimeout ||
            left.type == DioExceptionType.sendTimeout) {
          return 'انتهت مهلة الاتصال، يرجى المحاولة مجدداً';
        }
        if (left.type == DioExceptionType.connectionError) {
          return 'تعذّر الاتصال بالخادم، تحقق من اتصالك بالإنترنت';
        }
      }

      return left?.toString() ?? 'حدث خطأ غير متوقع';
    } catch (_) {
      return 'حدث خطأ غير متوقع';
    }
  }
}