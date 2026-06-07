// features/Lawyer/lawyer-home/bloc/lawyer_consultations_state.dart

import 'package:equatable/equatable.dart';
import '../models/consultation_model.dart';

abstract class LawyerConsultationsState extends Equatable {
  const LawyerConsultationsState();
  @override
  List<Object?> get props => [];
}

class LawyerConsultationsInitial extends LawyerConsultationsState {}

class LawyerConsultationsLoading extends LawyerConsultationsState {}

class LawyerConsultationsLoaded extends LawyerConsultationsState {
  final List<Consultation> consultations;
  const LawyerConsultationsLoaded(this.consultations);
  @override
  List<Object?> get props => [consultations];
}

class LawyerConsultationsError extends LawyerConsultationsState {
  final String message;
  const LawyerConsultationsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Accept Instant ───────────────────────────────────────────────────────────

class AcceptConsultationLoading extends LawyerConsultationsState {
  final String consultationId;
  const AcceptConsultationLoading(this.consultationId);
  @override
  List<Object?> get props => [consultationId];
}

class AcceptConsultationSuccess extends LawyerConsultationsState {
  final Consultation acceptedConsultation;
  const AcceptConsultationSuccess(this.acceptedConsultation);
  @override
  List<Object?> get props => [acceptedConsultation];
}

class AcceptConsultationError extends LawyerConsultationsState {
  final String message;
  const AcceptConsultationError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Accept Written ───────────────────────────────────────────────────────────

class AcceptWrittenConsultationLoading extends LawyerConsultationsState {
  final String consultationId;
  const AcceptWrittenConsultationLoading(this.consultationId);
  @override
  List<Object?> get props => [consultationId];
}

class AcceptWrittenConsultationSuccess extends LawyerConsultationsState {
  final Consultation acceptedConsultation;
  const AcceptWrittenConsultationSuccess(this.acceptedConsultation);
  @override
  List<Object?> get props => [acceptedConsultation];
}

class AcceptWrittenConsultationError extends LawyerConsultationsState {
  final String message;
  const AcceptWrittenConsultationError(this.message);
  @override
  List<Object?> get props => [message];
}