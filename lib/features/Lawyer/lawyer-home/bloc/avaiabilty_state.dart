// features/Lawyer/availability/bloc/lawyer_availability_state.dart

import 'package:equatable/equatable.dart';

import '../models/avaiability_status_model.dart';

abstract class LawyerAvailabilityState extends Equatable {
  const LawyerAvailabilityState();

  @override
  List<Object?> get props => [];
}

// ── Initial ───────────────────────────────────────────────────────────────────

class LawyerAvailabilityInitial extends LawyerAvailabilityState {
  const LawyerAvailabilityInitial();
}

// ── Update states ─────────────────────────────────────────────────────────────

class UpdateAvailabilityLoading extends LawyerAvailabilityState {
  const UpdateAvailabilityLoading();
}

class UpdateAvailabilitySuccess extends LawyerAvailabilityState {
  final LawyerAvailabilityStatus currentStatus;

  const UpdateAvailabilitySuccess(this.currentStatus);

  @override
  List<Object?> get props => [currentStatus];
}

class UpdateAvailabilityError extends LawyerAvailabilityState {
  final String message;

  const UpdateAvailabilityError(this.message);

  @override
  List<Object?> get props => [message];
}