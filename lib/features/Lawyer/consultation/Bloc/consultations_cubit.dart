// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/logic/cubit/consultations_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';

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
  List<ConsultationModel> get consultations => List.unmodifiable(_consultations);
  bool get hasMorePages => _hasMorePages;
  int get currentPage => _currentPage;

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

  // ── Reschedule ────────────────────────────────────────────────────────────
  //
  // Sends POST /api/v1/client/consultations/{id}/reschedule.
  // On success the updated consultation replaces its counterpart in the local
  // list so the card refreshes immediately without a full re-fetch.

  Future<void> rescheduleConsultation({
    required String consultationId,
    required DateTime newStartTime,
  }) async {
    // Guard: only valid for upcoming scheduled consultations.
    _consultations.firstWhere(
          (c) => c.id == consultationId,
      orElse: () => throw StateError('Consultation $consultationId not found'),
    );

    emit(ConsultationRescheduling(
      consultationId: consultationId,
      currentConsultations: _consultations,
      selectedStatus: _selectedStatus,
    ));

    final result = await repo.rescheduleConsultation(
      id: consultationId,
      newStartTime: newStartTime,
    );

    result.fold(
          (error) {
        // Keep the current list intact; surface error to the UI.
        emit(ConsultationRescheduleError(
          message: error,
          currentConsultations: _consultations,
          selectedStatus: _selectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
          (updated) {
        // Optimistic update: replace the old card with the updated one.
        _consultations = _consultations
            .map((c) => c.id == consultationId ? updated : c)
            .toList();

        emit(ConsultationRescheduled(
          updatedConsultation: updated,
          consultations: _consultations,
          selectedStatus: _selectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
    );
  }

  // ── Cancel ────────────────────────────────────────────────────────────────
  //
  // Sends PATCH /api/v1/client/consultations/{id}/cancel.
  // On success the consultation is removed from the local list so the UI
  // updates immediately without a full re-fetch.

  Future<void> cancelConsultation({
    required String consultationId,
  }) async {
    // Guard: ensure the consultation exists locally.
    _consultations.firstWhere(
          (c) => c.id == consultationId,
      orElse: () => throw StateError('Consultation $consultationId not found'),
    );

    emit(ConsultationCancelling(
      consultationId: consultationId,
      currentConsultations: _consultations,
      selectedStatus: _selectedStatus,
    ));

    final result = await repo.cancelConsultation(id: consultationId);

    result.fold(
          (error) {
        // Keep the current list intact; surface error to the UI.
        emit(ConsultationCancelError(
          message: error,
          currentConsultations: _consultations,
          selectedStatus: _selectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
          (_) {
        // Remove the cancelled consultation from the local list.
        _consultations =
            _consultations.where((c) => c.id != consultationId).toList();

        if (_consultations.isEmpty) {
          emit(ConsultationsEmpty(selectedStatus: _selectedStatus));
        } else {
          emit(ConsultationCancelled(
            cancelledId: consultationId,
            consultations: _consultations,
            selectedStatus: _selectedStatus,
            hasMorePages: _hasMorePages,
            currentPage: _currentPage,
          ));
        }
      },
    );
  }

  // ── Rate ──────────────────────────────────────────────────────────────────
  //
  // Sends POST /api/v1/client/ratings.
  // Only valid for completed consultations. [lawyerId] and [clientId] are
  // pulled off the local consultation (already in memory) rather than
  // requiring the caller to pass them in.

  Future<void> rateConsultation({
    required ConsultationModel consultation,
    required int stars,
    String? comment,
  }) async {
    assert(stars >= 1 && stars <= 5, 'stars must be between 1 and 5');
    final String  consultationId = consultation.id ;


    final lawyerId = consultation.lawyer?.id;
    final clientId = consultation.client?.id ?? getIt<CacheHelper>().currentUser?.id;

    if (lawyerId == null || clientId == null) {

      Logger().d(lawyerId) ;
      Logger().d(clientId) ;

      emit(ConsultationRatingError(
        message: 'تعذر إرسال التقييم: بيانات الاستشارة غير مكتملة',
        consultationId: consultationId,
        currentConsultations: _consultations,
        selectedStatus: _selectedStatus,
        hasMorePages: _hasMorePages,
        currentPage: _currentPage,
      ));
      return;
    }

    emit(ConsultationRatingSubmitting(
      consultationId: consultationId,
      currentConsultations: _consultations,
      selectedStatus: _selectedStatus,
    ));

    final result = await repo.rateConsultation(
      consultationId: consultationId,
      lawyerId: lawyerId,
      clientId: clientId,
      stars: stars,
      comment: comment,
    );

    result.fold(
          (error) {
        // Keep the current list intact; surface error to the UI.
        emit(ConsultationRatingError(
          message: error,
          consultationId: consultationId,
          currentConsultations: _consultations,
          selectedStatus: _selectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
          (_) {
        emit(ConsultationRatingSubmitted(
          consultationId: consultationId,
          consultations: _consultations,
          selectedStatus: _selectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
    );
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