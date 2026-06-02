// features/Lawyer/lawyer-home/bloc/lawyer_consultations_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../models/consultation_model.dart';
import '../repo/lawyer_consultations_repo.dart';
import 'lawyer_consultations_state.dart';

class LawyerConsultationsCubit extends Cubit<LawyerConsultationsState> {
  final LawyerConsultationsRepo _repo;
  LawyerConsultationsCubit(this._repo) : super( LawyerConsultationsInitial());

  List<Consultation> _consultations = [];

  String ? acceptedConsultationId;

  Future<void> fetchConsultations() async {
    emit( LawyerConsultationsLoading());
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


    emit(AcceptConsultationLoading(consultation.id));
    final result = await _repo.acceptInstantConsultation(consultation.id);
    result.fold(
          (error) => emit(AcceptConsultationError(error)),
          (accepted) {
        // Remove accepted consultation from local list
        _consultations.removeWhere((c) => c.id == consultation.id);
        emit(LawyerConsultationsLoaded(_consultations));
        acceptedConsultationId = consultation.id;
        emit(AcceptConsultationSuccess(accepted));
      },
    );
  }
}