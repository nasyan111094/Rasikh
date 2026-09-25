// features/Lawyer/lawyer-appointments/presentation/bloc/lawyer_appointments_state.dart

import 'package:equatable/equatable.dart';

import '../models/availability_slot_model.dart';

// ── Base State ───────────────────────────────────────────────────────────────

abstract class LawyerAppointmentsState extends Equatable {
  const LawyerAppointmentsState();

  @override
  List<Object?> get props => [];
}

// ── Fetch States ─────────────────────────────────────────────────────────────

class LawyerAppointmentsInitial extends LawyerAppointmentsState {
  const LawyerAppointmentsInitial();
}

class LawyerAppointmentsLoading extends LawyerAppointmentsState {
  const LawyerAppointmentsLoading();
}

class LawyerAppointmentsLoaded extends LawyerAppointmentsState {
  final WeeklyAvailabilityModel weeklyData;

  const LawyerAppointmentsLoaded({required this.weeklyData});

  @override
  List<Object?> get props => [weeklyData];
}

class LawyerAppointmentsError extends LawyerAppointmentsState {
  final String message;

  const LawyerAppointmentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ── Mutation States ─────────────────────────────────────────────────────────

class SlotMutationLoading extends LawyerAppointmentsState {
  const SlotMutationLoading();
}

class SlotCreatedSuccess extends LawyerAppointmentsState {
  final String message;

  const SlotCreatedSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class SlotUpdatedSuccess extends LawyerAppointmentsState {
  final String message;

  const SlotUpdatedSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class SlotDeletedSuccess extends LawyerAppointmentsState {
  final String message;

  const SlotDeletedSuccess({this.message = 'تم حذف الموعد بنجاح'});

  @override
  List<Object?> get props => [message];
}

class SlotMutationError extends LawyerAppointmentsState {
  final String message;

  const SlotMutationError({required this.message});

  @override
  List<Object?> get props => [message];
}