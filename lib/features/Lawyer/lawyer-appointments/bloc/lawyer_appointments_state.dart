
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:equatable/equatable.dart';

import '../models/availability_slot_model.dart';


abstract class LawyerAppointmentsState extends Equatable {
  const LawyerAppointmentsState();

  @override
  List<Object?> get props => [];
}


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

  SlotDeletedSuccess({String? message})
      : message = message ?? Loc.appointmentDeletedSuccessfully();

  @override
  List<Object?> get props => [message];
}

class SlotMutationError extends LawyerAppointmentsState {
  final String message;

  const SlotMutationError({required this.message});

  @override
  List<Object?> get props => [message];
}