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
    return Left(result.left);
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
    return Left(result.left);
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
    return Left(result.left);
  }

  // ── DELETE slot ───────────────────────────────────────────────────────────

  Future<Either<String, bool>> deleteSlot({required String slotId}) async {
    final result = await _adapter.delete(
      _AppointmentsEndpoints.deleteSlot(slotId),
    );

    if (result.isRight) return const Right(true);
    return Left(result.left);
  }


}