// features/Lawyer/availability/bloc/lawyer_availability_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/avaiability_status_model.dart';
import '../repo/lawer_availability_rpeo.dart';
import 'avaiabilty_state.dart';



class LawyerAvailabilityCubit extends Cubit<LawyerAvailabilityState> {
  LawyerAvailabilityCubit(this._repo)
      : super(const LawyerAvailabilityInitial());

  final LawyerAvailabilityRepo _repo;

  // ── Cached current status (optimistic) ───────────────────────────────────

  LawyerAvailabilityStatus? currentStatus;

  // ── UPDATE availability ───────────────────────────────────────────────────

  Future<void> updateAvailability(LawyerAvailabilityStatus status) async {
    emit(const UpdateAvailabilityLoading());

    final result = await _repo.updateAvailability(status: status);

    result.fold(
          (error) {
        // Roll back optimistic status on error
        emit(UpdateAvailabilityError(error));
      },
          (response) {
        currentStatus = response.availability ?? status;
        emit(UpdateAvailabilitySuccess(currentStatus!));
      },
    );
  }
}