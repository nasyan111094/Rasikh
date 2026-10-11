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
    if (_acceptingIds.contains(consultation.id)) return;
    _acceptingIds.add(consultation.id);
    try {
      final isWritten = consultation.type == 'written';
      final isScheduled = consultation.type == 'scheduled';

      // Emit the correct loading state based on type
      if (isWritten) {
        emit(AcceptWrittenConsultationLoading(consultation.id));
      } else {
        emit(AcceptConsultationLoading(consultation.id));
      }

      // Route to the matching endpoint — scheduled must NOT reuse
      // accept-instant (server returns 400 for wrong type).
      final result = await _repo.acceptConsultationByType(
          consultation.id, consultation.type);

      result.fold(
        (error) {
          if (isWritten) {
            emit(AcceptWrittenConsultationError(error));
          } else {
            emit(AcceptConsultationError(error));
          }
          // Race case (another lawyer took it / already accepted):
          // refresh the list so the stale card disappears.
          fetchConsultations();
        },
        (accepted) {
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

          // Keep dashboard + upcoming in sync without clobbering the
          // success state (separate buildWhen filters in the UI).
          fetchUpcomingScheduled();
          fetchDashboard();
        },
      );
    } finally {
      _acceptingIds.remove(consultation.id);
    }
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

  LawyerDashboardData? _dashboardData;

  Future<void> fetchDashboard() async {
    emit(DashboardLoading());
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