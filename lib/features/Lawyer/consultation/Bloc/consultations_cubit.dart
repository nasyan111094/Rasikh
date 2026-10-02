
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


  ConsultationStatus get selectedStatus => currentSelectedStatus;
  List<ConsultationModel> get consultations => List.unmodifiable(_consultations);
  bool get hasMorePages => _hasMorePages;
  int get currentPage => _currentPage;


  Future<void> fetchConsultations({ConsultationStatus? status}) async {
    if (status != null) currentSelectedStatus = status;

    _currentPage = 1;
    _consultations = [];

    emit(const ConsultationsLoading());

    final result = await repo.getConsultations(
      page: _currentPage,
      status: currentSelectedStatus,
    );

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
    _consultations.firstWhere(
          (c) => c.id == consultationId,
      orElse: () => throw StateError('Consultation $consultationId not found'),
    );

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
    _consultations.firstWhere(
          (c) => c.id == consultationId,
      orElse: () => throw StateError('Consultation $consultationId not found'),
    );

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
          (_) {
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