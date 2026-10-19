// features/Lawyer/lawyer-home/bloc/lawyer_consultations_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/consultation_model.dart';
import '../models/lawyer_dashboard_model.dart';
import '../models/nearest.dart';
import '../repo/lawyer_consultations_repo.dart';
import 'lawyer_consultations_state.dart';

class LawyerConsultationsCubit extends Cubit<LawyerConsultationsState> {
  final LawyerConsultationsRepo _repo;
  LawyerConsultationsCubit(this._repo) : super(LawyerConsultationsInitial());

  List<Consultation> _consultations = [];

  /// Guards against double-tap / concurrent accepts of the same item.
  final Set<String> _acceptingIds = {};

  List<Consultation> get consultations => List.unmodifiable(_consultations);

  bool isAccepting(String id) => _acceptingIds.contains(id);

  String? acceptedConsultationId;

  int _fetchToken = 0;

  Future<void> fetchConsultations({bool silent = false}) async {
    final token = ++_fetchToken;
    if (!silent) emit(LawyerConsultationsLoading());
    final result = await _repo.getAvailableConsultations();
    if (token != _fetchToken) return; // stale response ignored (applyFilter ran)
    result.fold(
          (error) => emit(LawyerConsultationsError(error)),
          (consultations) {
        _consultations = consultations;
        emit(LawyerConsultationsLoaded(consultations));
      },
    );
  }

  Future<void> acceptConsultation(Consultation consultation) async {
    final normalizedType = consultation.type.toLowerCase().trim();
    const supported = {'instant', 'written', 'scheduled'};
    if (!supported.contains(normalizedType)) {
      emit(AcceptConsultationError('Unsupported consultation type: ${consultation.type}'));
      // TODO(l10n): add Loc key for unsupported consultation type
      await fetchConsultations(silent: true);
      return;
    }
    if (_acceptingIds.contains(consultation.id)) return;
    _acceptingIds.add(consultation.id);
    try {
      final isWritten = normalizedType == 'written';
      final isScheduled = normalizedType == 'scheduled';

      // Emit the correct loading state based on type
      if (isWritten) {
        emit(AcceptWrittenConsultationLoading(consultation.id));
      } else {
        emit(AcceptConsultationLoading(consultation.id));
      }

      // Route to the matching endpoint — scheduled must NOT reuse
      // accept-instant (server returns 400 for wrong type).
      final result = await _repo.acceptConsultationByType(
          consultation.id, normalizedType);

      result.fold(
        (error) async {
          if (isWritten) {
            emit(AcceptWrittenConsultationError(error));
          } else {
            emit(AcceptConsultationError(error));
          }
          // Race case (another lawyer took it / already accepted):
          // refresh the list silently so the error snackbar stays visible.
          await fetchConsultations(silent: true);
        },
        (accepted) async {
          // Remove accepted consultation from local list
          _consultations.removeWhere((c) => c.id == consultation.id);
          emit(LawyerConsultationsLoaded(List.from(_consultations)));

          acceptedConsultationId = consultation.id;

          // Emit the correct success state based on type
          if (isWritten) {
            emit(AcceptWrittenConsultationSuccess(accepted));
          } else if (isScheduled) {
            // Reuse instant-success channel for scheduled; UI navigates
            // to the session screen the same way.
            emit(AcceptConsultationSuccess(accepted));
          } else {
            emit(AcceptConsultationSuccess(accepted));
          }

          // Keep dashboard + upcoming in sync silently without clobbering
          // the success state (separate buildWhen filters in the UI).
          await fetchUpcomingScheduled(silent: true);
          await fetchDashboard(silent: true);
        },
      );
    } finally {
      _acceptingIds.remove(consultation.id);
    }
  }

  List<ScheduledConsultation> _upcomingAppointments = [];

  Future<void> fetchUpcomingScheduled({bool silent = false}) async {
    if (!silent) emit(UpcomingScheduledLoading());
    final result = await _repo.getUpcomingScheduled();
    result.fold(
          (error) => emit(UpcomingScheduledError(error)),
          (list) {
        _upcomingAppointments = list;
        emit(UpcomingScheduledLoaded(list));
      },
    );
  }

  LawyerDashboardData? _dashboardData;

  Future<void> fetchDashboard({bool silent = false}) async {
    if (!silent) emit(DashboardLoading());
    final result = await _repo.getLawyerDashboard();
    result.fold(
          (error) => emit(DashboardError(error)),
          (response) {
        _dashboardData = response.data;
        emit(DashboardLoaded(response.data));
      },
    );
  }

  LawyerDashboardData? get dashboardData => _dashboardData;
}