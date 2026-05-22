// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/logic/states/consultations_states.dart
// ─────────────────────────────────────────────────────────────────────────────



// ── List Screen States ────────────────────────────────────────────────────────

import '../models/consultation_model.dart';

abstract class ConsultationsState {}

/// Initial state before any action
class ConsultationsInitial extends ConsultationsState {}

/// Shimmer loading on first fetch or filter change
class ConsultationsLoading extends ConsultationsState {}

/// Silent refresh (pull-to-refresh) — keeps old data visible
class ConsultationsRefreshing extends ConsultationsState {
  final List<ConsultationModel> currentConsultations;
  final ConsultationStatus selectedStatus;

  ConsultationsRefreshing({
    required this.currentConsultations,
    required this.selectedStatus,
  });
}

/// Paginating — loading next page while showing current list
class ConsultationsPaginating extends ConsultationsState {
  final List<ConsultationModel> currentConsultations;
  final ConsultationStatus selectedStatus;

  ConsultationsPaginating({
    required this.currentConsultations,
    required this.selectedStatus,
  });
}

/// Data loaded successfully
class ConsultationsLoaded extends ConsultationsState {
  final List<ConsultationModel> consultations;
  final ConsultationStatus selectedStatus;
  final bool hasMorePages;
  final int currentPage;

  ConsultationsLoaded({
    required this.consultations,
    required this.selectedStatus,
    required this.hasMorePages,
    required this.currentPage,
  });
}

/// Empty list
class ConsultationsEmpty extends ConsultationsState {
  final ConsultationStatus selectedStatus;

  ConsultationsEmpty({required this.selectedStatus});
}

/// Error occurred
class ConsultationsError extends ConsultationsState {
  final String message;
  final ConsultationStatus selectedStatus;

  ConsultationsError({
    required this.message,
    required this.selectedStatus,
  });
}

// ── Filter Sheet States ───────────────────────────────────────────────────────

abstract class ConsultationsFilterState {}

class ConsultationsFilterInitial extends ConsultationsFilterState {}

class ConsultationsFilterChanged extends ConsultationsFilterState {
  final ConsultationStatus selected;

  ConsultationsFilterChanged({required this.selected});
}

// ── Details Screen States ─────────────────────────────────────────────────────

abstract class ConsultationDetailsState {}

/// Initial state
class ConsultationDetailsInitial extends ConsultationDetailsState {}

/// Shimmer loading
class ConsultationDetailsLoading extends ConsultationDetailsState {}

/// Details loaded
class ConsultationDetailsLoaded extends ConsultationDetailsState {
  final ConsultationModel consultation;

  ConsultationDetailsLoaded({required this.consultation});
}

/// Error
class ConsultationDetailsError extends ConsultationDetailsState {
  final String message;

  ConsultationDetailsError({required this.message});
}
