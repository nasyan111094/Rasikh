
import 'package:rasikh/config/localization/loc_keys.dart';
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


  ConsultationStatus currentSelectedStatus = ConsultationStatus.none;
  List<ConsultationModel> _consultations = [];
  int _currentPage = 1;
  bool _hasMorePages = false;
  bool _isPaginating = false;
  // Guards against stale paginate responses racing with applyFilter.
  int _fetchToken = 0;


  ConsultationStatus get selectedStatus => currentSelectedStatus;
  List<ConsultationModel> get consultations => List.unmodifiable(_consultations);
  bool get hasMorePages => _hasMorePages;
  int get currentPage => _currentPage;


  Future<void> fetchConsultations({ConsultationStatus? status}) async {
    if (status != null) currentSelectedStatus = status;

    _currentPage = 1;
    _consultations = [];
    final token = ++_fetchToken;

    emit(const ConsultationsLoading());

    final result = await repo.getConsultations(
      page: _currentPage,
      status: currentSelectedStatus,
    );
    if (token != _fetchToken) return; // stale response ignored

    result.fold(
          (error) => emit(
        ConsultationsError(message: error, selectedStatus: currentSelectedStatus),
      ),
          (model) => _emitLoadedOrEmpty(model.consultations, model.hasMorePages),
    );
  }


  Future<void> refreshConsultations() async {
    emit(ConsultationsRefreshing(
      currentConsultations: _consultations,
      selectedStatus: currentSelectedStatus,
    ));

    _currentPage = 1;

    final result = await repo.getConsultations(
      page: _currentPage,
      status: currentSelectedStatus,
    );

    result.fold(
          (error) {
        if (_consultations.isNotEmpty) {
          emit(ConsultationsLoaded(
            consultations: _consultations,
            selectedStatus: currentSelectedStatus,
            hasMorePages: _hasMorePages,
            currentPage: _currentPage,
          ));
        } else {
          emit(ConsultationsError(
            message: error,
            selectedStatus: currentSelectedStatus,
          ));
        }
      },
          (model) => _emitLoadedOrEmpty(model.consultations, model.hasMorePages),
    );
  }


  Future<void> loadMoreConsultations() async {
    if (_isPaginating || !_hasMorePages) return;
    _isPaginating = true;

    emit(ConsultationsPaginating(
      currentConsultations: _consultations,
      selectedStatus: currentSelectedStatus,
    ));

    _currentPage++;

    final result = await repo.getConsultations(
      page: _currentPage,
      status: currentSelectedStatus,
    );
    final token = _fetchToken;

    result.fold(
          (error) {
        _currentPage--;
        emit(ConsultationsLoaded(
          consultations: _consultations,
          selectedStatus: currentSelectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
          (model) {
        if (token != _fetchToken) return; // stale paginate ignored
        _consultations = [..._consultations, ...model.consultations];
        _hasMorePages = model.hasMorePages;
        emit(ConsultationsLoaded(
          consultations: _consultations,
          selectedStatus: currentSelectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
    );

    _isPaginating = false;
  }


  Future<void> applyFilter(ConsultationStatus status) async {
    if (currentSelectedStatus == status) return;
    await fetchConsultations(status: status);
  }


  Future<void> rescheduleConsultation({
    required String consultationId,
    required DateTime newStartTime,
  }) async {
    // Past-date guard (client clock / stale slot).
    if (newStartTime.isBefore(DateTime.now())) {
      emit(ConsultationRescheduleError(
        message: Loc.consultationTimeEnded(),
        currentConsultations: _consultations,
        selectedStatus: currentSelectedStatus,
        hasMorePages: _hasMorePages,
        currentPage: _currentPage,
      ));
      return;
    }

    // Safe lookup: item may live on another page/filter — don't crash.
    final exists = _consultations.any((c) => c.id == consultationId);
    if (!exists) {
      emit(ConsultationRescheduleError(
        message: Loc.unexpectedError(),
        currentConsultations: _consultations,
        selectedStatus: currentSelectedStatus,
        hasMorePages: _hasMorePages,
        currentPage: _currentPage,
      ));
      return;
    }

    emit(ConsultationRescheduling(
      consultationId: consultationId,
      currentConsultations: _consultations,
      selectedStatus: currentSelectedStatus,
    ));

    final result = await repo.rescheduleConsultation(
      id: consultationId,
      newStartTime: newStartTime,
    );

    result.fold(
          (error) {
        emit(ConsultationRescheduleError(
          message: error,
          currentConsultations: _consultations,
          selectedStatus: currentSelectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
          (updated) {
        _consultations = _consultations
            .map((c) => c.id == consultationId ? updated : c)
            .toList();

        emit(ConsultationRescheduled(
          updatedConsultation: updated,
          consultations: _consultations,
          selectedStatus: currentSelectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
    );
  }


  Future<void> cancelConsultation({
    required String consultationId,
  }) async {
    // Safe lookup instead of throwing when the item isn't in the
    // currently loaded page/filter.
    final exists = _consultations.any((c) => c.id == consultationId);
    if (!exists) {
      emit(ConsultationCancelError(
        message: Loc.unexpectedError(),
        currentConsultations: _consultations,
        selectedStatus: currentSelectedStatus,
        hasMorePages: _hasMorePages,
        currentPage: _currentPage,
      ));
      return;
    }

    emit(ConsultationCancelling(
      consultationId: consultationId,
      currentConsultations: _consultations,
      selectedStatus: currentSelectedStatus,
    ));

    final result = await repo.cancelConsultation(id: consultationId);

    result.fold(
          (error) {
        emit(ConsultationCancelError(
          message: error,
          currentConsultations: _consultations,
          selectedStatus: currentSelectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
          (policy) {
        _consultations =
            _consultations.where((c) => c.id != consultationId).toList();

        if (_consultations.isEmpty) {
          emit(ConsultationsEmpty(selectedStatus: currentSelectedStatus));
        } else {
          emit(ConsultationCancelled(
            cancelledId: consultationId,
            consultations: _consultations,
            selectedStatus: currentSelectedStatus,
            hasMorePages: _hasMorePages,
            currentPage: _currentPage,
            refundPercent: policy.refundPercent,
          ));
        }
      },
    );
  }


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
        message: Loc.ratingSendFailedIncompleteData(),
        consultationId: consultationId,
        currentConsultations: _consultations,
        selectedStatus: currentSelectedStatus,
        hasMorePages: _hasMorePages,
        currentPage: _currentPage,
      ));
      return;
    }

    emit(ConsultationRatingSubmitting(
      consultationId: consultationId,
      currentConsultations: _consultations,
      selectedStatus: currentSelectedStatus,
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
        emit(ConsultationRatingError(
          message: error,
          consultationId: consultationId,
          currentConsultations: _consultations,
          selectedStatus: currentSelectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
          (_) {
        emit(ConsultationRatingSubmitted(
          consultationId: consultationId,
          consultations: _consultations,
          selectedStatus: currentSelectedStatus,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ));
      },
    );
  }


  void _emitLoadedOrEmpty(
      List<ConsultationModel> consultations,
      bool hasMorePages,
      ) {
    _consultations = consultations;
    _hasMorePages = hasMorePages;

    if (_consultations.isEmpty) {
      emit(ConsultationsEmpty(selectedStatus: currentSelectedStatus));
    } else {
      emit(ConsultationsLoaded(
        consultations: _consultations,
        selectedStatus: currentSelectedStatus,
        hasMorePages: _hasMorePages,
        currentPage: _currentPage,
      ));
    }
  }
}