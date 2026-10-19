
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/availability_slot_model.dart';
import '../repo/lawyer_appointments_repo.dart';
import 'lawyer_appointments_state.dart';

class LawyerAppointmentsCubit extends Cubit<LawyerAppointmentsState> {
  LawyerAppointmentsCubit(this._repo)
      : super(const LawyerAppointmentsInitial());

  final LawyerAppointmentsRepo _repo;

  WeeklyAvailabilityModel? _cachedWeeklyData;
  String? _lastWeekStart;

  WeeklyAvailabilityModel? get cachedWeeklyData => _cachedWeeklyData;


  Future<void> fetchWeeklyAvailability({String? weekStart}) async {
    emit(const LawyerAppointmentsLoading());
    _lastWeekStart = weekStart;

    final result = await _repo.getWeeklyAvailability(weekStart: weekStart);

    result.fold(
          (error) => emit(LawyerAppointmentsError(message: error)),
          (data) {
        _cachedWeeklyData = data;
        emit(LawyerAppointmentsLoaded(weeklyData: data));
      },
    );
  }


  Future<void> createSlot({required SlotRequestModel request}) async {
    emit(const SlotMutationLoading());

    final result = await _repo.createSlot(request: request);

    result.fold(
          (error) => emit(SlotMutationError(message: error)),
          (response) async {
        emit(SlotCreatedSuccess(message: response.message));
        await _refreshWeekly();
      },
    );
  }


  Future<void> updateSlot({
    required String slotId,
    required SlotRequestModel request,
  }) async {
    emit(const SlotMutationLoading());

    final result = await _repo.updateSlot(slotId: slotId, request: request);

    result.fold(
          (error) => emit(SlotMutationError(message: error)),
          (response) async {
        emit(SlotUpdatedSuccess(message: response.message));
        await _refreshWeekly();
      },
    );
  }


  Future<void> deleteSlot({required String slotId}) async {
    emit(const SlotMutationLoading());

    final result = await _repo.deleteSlot(slotId: slotId);

    result.fold(
          (error) => emit(SlotMutationError(message: error)),
          (_) async {
        emit(SlotDeletedSuccess());
        await _refreshWeekly();
      },
    );
  }


  Future<void> _refreshWeekly() async {
    final result = await _repo.getWeeklyAvailability(weekStart: _lastWeekStart);

    result.fold(
          (error) => emit(LawyerAppointmentsError(message: error)),
          (data) {
        _cachedWeeklyData = data;
        emit(LawyerAppointmentsLoaded(weeklyData: data));
      },
    );
  }
}