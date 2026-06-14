// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/logic/cubit/consultations_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/consultation_model.dart';
import '../repo/consultations_repo.dart';
import 'consultations_states.dart';

class ConsultationsCubit extends Cubit<ConsultationsState> {
  ConsultationsCubit({required this.repo}) : super(const ConsultationsInitial());

  final ConsultationsRepo repo;

  // ── Internal state ────────────────────────────────────────────────────────

  ConsultationStatus _selectedStatus = ConsultationStatus.none;
  List<ConsultationModel> _consultations = [];
  int _currentPage = 1;
  bool _hasMorePages = false;
  bool _isPaginating = false;

  // ── Public getters ────────────────────────────────────────────────────────

  ConsultationStatus get selectedStatus => _selectedStatus;

  // ── Initial fetch / filter change ─────────────────────────────────────────

  Future<void> fetchConsultations({ConsultationStatus? status}) async {
    if (status != null) _selectedStatus = status;

    _currentPage = 1;
    _consultations = [];

    emit(const ConsultationsLoading());

    final result = await repo.getConsultations(
      page: _currentPage,
      status: _selectedStatus,
    );

    result.fold(
          (error) => emit(
        ConsultationsError(message: error, selectedStatus: _selectedStatus),
      ),
          (model) => _emitLoadedOrEmpty(model.consultations, model.hasMorePages),
    );
  }

  // ── Pull-to-refresh ───────────────────────────────────────────────────────

  Future<void> refreshConsultations() async {
    emit(ConsultationsRefreshing(
      currentConsultations: _consultations,
      selectedStatus: _selectedStatus,
    ));

    _currentPage = 1;

    final result = await repo.getConsultations(
      page: _currentPage,
      status: _selectedStatus,
    );

    result.fold(
          (error) {
        // Restore the previous loaded state so the user doesn't lose their list.
        if (_consultations.isNotEmpty) {
          emit(ConsultationsLoaded(
            consultations: _consultations,
            selectedStatus: _selectedStatus,
            hasMorePages: _hasMorePages,
            currentPage: _currentPage,
          ));
        } else {
          emit(ConsultationsError(
            message: error,
            selectedStatus: _selectedStatus,
          ));
        }
      },
          (model) => _emitLoadedOrEmpty(model.consultations, model.hasMorePages),
    );
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  Future<void> loadMoreConsultations() async {
    if (_isPaginating || !_hasMorePages) return;
    _isPaginating = true;

    emit(ConsultationsPaginating(
      currentConsultations: _consultations,
      selectedStatus: _selectedStatus,
    ));

    _currentPage++;

    final result = await repo.getConsultations(
      page: _currentPage,
      status: _selectedStatus,
    );

    result.fold(
          (error) {
        _currentPage--; // Roll back on failure.
        emit(ConsultationsLoaded(
          consultations: _consultations,
          selectedStatus: _selectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
          (model) {
        _consultations = [..._consultations, ...model.consultations];
        _hasMorePages = model.hasMorePages;
        emit(ConsultationsLoaded(
          consultations: _consultations,
          selectedStatus: _selectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
    );

    _isPaginating = false;
  }

  // ── Apply filter ──────────────────────────────────────────────────────────

  Future<void> applyFilter(ConsultationStatus status) async {
    if (_selectedStatus == status) return;
    await fetchConsultations(status: status);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _emitLoadedOrEmpty(
      List<ConsultationModel> consultations,
      bool hasMorePages,
      ) {
    _consultations = consultations;
    _hasMorePages = hasMorePages;

    if (_consultations.isEmpty) {
      emit(ConsultationsEmpty(selectedStatus: _selectedStatus));
    } else {
      emit(ConsultationsLoaded(
        consultations: _consultations,
        selectedStatus: _selectedStatus,
        hasMorePages: _hasMorePages,
        currentPage: _currentPage,
      ));
    }
  }
}