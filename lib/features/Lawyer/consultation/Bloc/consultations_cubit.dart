// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/logic/cubit/consultations_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';


import '../models/consultation_model.dart';
import '../repo/consultations_repo.dart';

import 'consultations_states.dart';

class ConsultationsCubit extends Cubit<ConsultationsState> {
  ConsultationsCubit({required this.repo}) : super(ConsultationsInitial());

  final ConsultationsRepo repo;

  // ── Internal state ─────────────────────────────────────────────────────────

  ConsultationStatus _selectedStatus = ConsultationStatus.none;
  List<ConsultationModel> _consultations = [];
  int _currentPage = 1;
  bool _hasMorePages = false;
  bool _isPaginating = false;

  // ── Getters ────────────────────────────────────────────────────────────────

  ConsultationStatus get selectedStatus => _selectedStatus;

  // ── Fetch (initial or after filter change) ─────────────────────────────────

  Future<void> fetchConsultations({ConsultationStatus? status}) async {
    // Update filter if provided
    if (status != null) _selectedStatus = status;

    // Reset pagination
    _currentPage = 1;
    _consultations = [];

    emit(ConsultationsLoading());

    final result = await repo.getConsultations(
      page: _currentPage,
      status: _selectedStatus,
    );

    result.fold(
          (error) => emit(
        ConsultationsError(
          message: error,
          selectedStatus: _selectedStatus,
        ),
      ),
          (model) {
        _consultations = model.consultations;
        _hasMorePages = model.hasMorePages;

        if (_consultations.isEmpty) {
          emit(ConsultationsEmpty(selectedStatus: _selectedStatus));
        } else {
          emit(
            ConsultationsLoaded(
              consultations: _consultations,
              selectedStatus: _selectedStatus,
              hasMorePages: _hasMorePages,
              currentPage: _currentPage,
            ),
          );
        }
      },
    );
  }

  // ── Pull-to-refresh ────────────────────────────────────────────────────────

  Future<void> refreshConsultations() async {
    // Show refreshing state (keeps old data visible under the refresh indicator)
    emit(
      ConsultationsRefreshing(
        currentConsultations: _consultations,
        selectedStatus: _selectedStatus,
      ),
    );

    _currentPage = 1;

    final result = await repo.getConsultations(
      page: _currentPage,
      status: _selectedStatus,
    );

    result.fold(
          (error) {
        // On refresh error, restore previous loaded state if we have data
        if (_consultations.isNotEmpty) {
          emit(
            ConsultationsLoaded(
              consultations: _consultations,
              selectedStatus: _selectedStatus,
              hasMorePages: _hasMorePages,
              currentPage: _currentPage,
            ),
          );
        } else {
          emit(
            ConsultationsError(
              message: error,
              selectedStatus: _selectedStatus,
            ),
          );
        }
      },
          (model) {
        _consultations = model.consultations;
        _hasMorePages = model.hasMorePages;

        if (_consultations.isEmpty) {
          emit(ConsultationsEmpty(selectedStatus: _selectedStatus));
        } else {
          emit(
            ConsultationsLoaded(
              consultations: _consultations,
              selectedStatus: _selectedStatus,
              hasMorePages: _hasMorePages,
              currentPage: _currentPage,
            ),
          );
        }
      },
    );
  }

  // ── Pagination (load next page) ────────────────────────────────────────────

  Future<void> loadMoreConsultations() async {
    if (_isPaginating || !_hasMorePages) return;
    _isPaginating = true;

    emit(
      ConsultationsPaginating(
        currentConsultations: _consultations,
        selectedStatus: _selectedStatus,
      ),
    );

    _currentPage++;

    final result = await repo.getConsultations(
      page: _currentPage,
      status: _selectedStatus,
    );

    result.fold(
          (error) {
        // Revert page on error
        _currentPage--;
        emit(
          ConsultationsLoaded(
            consultations: _consultations,
            selectedStatus: _selectedStatus,
            hasMorePages: _hasMorePages,
            currentPage: _currentPage,
          ),
        );
      },
          (model) {
        _consultations = [..._consultations, ...model.consultations];
        _hasMorePages = model.hasMorePages;

        emit(
          ConsultationsLoaded(
            consultations: _consultations,
            selectedStatus: _selectedStatus,
            hasMorePages: _hasMorePages,
            currentPage: _currentPage,
          ),
        );
      },
    );

    _isPaginating = false;
  }

  // ── Apply filter from bottom sheet ─────────────────────────────────────────

  Future<void> applyFilter(ConsultationStatus status) async {
    if (_selectedStatus == status) return;
    await fetchConsultations(status: status);
  }
}