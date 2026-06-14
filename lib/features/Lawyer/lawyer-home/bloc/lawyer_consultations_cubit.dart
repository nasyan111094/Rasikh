// features/Lawyer/lawyer-home/bloc/lawyer_consultations_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/consultation_model.dart';
import '../models/nearest.dart';
import '../repo/lawyer_consultations_repo.dart';
import 'lawyer_consultations_state.dart';

class LawyerConsultationsCubit extends Cubit<LawyerConsultationsState> {
  final LawyerConsultationsRepo _repo;
  LawyerConsultationsCubit(this._repo) : super(LawyerConsultationsInitial());

  List<Consultation> _consultations = [];

  String? acceptedConsultationId;

  Future<void> fetchConsultations() async {
    emit(LawyerConsultationsLoading());
    final result = await _repo.getAvailableConsultations();
    result.fold(
          (error) => emit(LawyerConsultationsError(error)),
          (consultations) {
        _consultations = consultations;
        emit(LawyerConsultationsLoaded(consultations));
      },
    );
  }

  Future<void> acceptConsultation(Consultation consultation) async {
    final isWritten = consultation.type == 'written';

    // Emit the correct loading state based on type
    if (isWritten) {
      emit(AcceptWrittenConsultationLoading(consultation.id));
    } else {
      emit(AcceptConsultationLoading(consultation.id));
    }

    // Call the matching repo method
    final result = isWritten
        ? await _repo.acceptWrittenConsultation(consultation.id)
        : await _repo.acceptInstantConsultation(consultation.id);

    result.fold(
          (error) => isWritten
          ? emit(AcceptWrittenConsultationError(error))
          : emit(AcceptConsultationError(error)),
          (accepted) {
        // Remove accepted consultation from local list
        _consultations.removeWhere((c) => c.id == consultation.id);
        emit(LawyerConsultationsLoaded(List.from(_consultations)));

        acceptedConsultationId = consultation.id;

        // Emit the correct success state based on type
        if (isWritten) {
          emit(AcceptWrittenConsultationSuccess(accepted));
        } else {
          emit(AcceptConsultationSuccess(accepted));
        }
      },
    );
  }

  List<ScheduledConsultation> _upcomingAppointments = [];

  Future<void> fetchUpcomingScheduled() async {
    emit(UpcomingScheduledLoading());
    final result = await _repo.getUpcomingScheduled();
    result.fold(
          (error) => emit(UpcomingScheduledError(error)),
          (list) {
        _upcomingAppointments = list;
        emit(UpcomingScheduledLoaded(list));
      },
    );
  }
}