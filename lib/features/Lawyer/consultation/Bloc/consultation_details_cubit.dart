// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/logic/cubit/consultation_details_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';


import '../repo/consultations_repo.dart';

import 'consultations_states.dart';

class ConsultationDetailsCubit extends Cubit<ConsultationDetailsState> {
  ConsultationDetailsCubit({required this.repo})
      : super(ConsultationDetailsInitial());

  final ConsultationsRepo repo;

  // ── Fetch details ──────────────────────────────────────────────────────────

  Future<void> fetchDetails({required String id}) async {
    emit(ConsultationDetailsLoading());

    final result = await repo.getConsultationDetails(id: id);

    result.fold(
      (error) => emit(ConsultationDetailsError(message: error)),
      (consultation) =>
          emit(ConsultationDetailsLoaded(consultation: consultation)),
    );
  }
}
