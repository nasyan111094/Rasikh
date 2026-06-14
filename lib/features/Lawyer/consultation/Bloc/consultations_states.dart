// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/logic/states/consultations_states.dart
// ─────────────────────────────────────────────────────────────────────────────

import '../models/consultation_model.dart';

// ── List Screen States ────────────────────────────────────────────────────────

abstract class ConsultationsState {
  const ConsultationsState();
}

/// Initial state — nothing has been fetched yet.
class ConsultationsInitial extends ConsultationsState {
  const ConsultationsInitial();
}

/// Full-screen shimmer shown on first fetch or after a filter change.
class ConsultationsLoading extends ConsultationsState {
  const ConsultationsLoading();
}

/// Silent refresh (pull-to-refresh) — current list stays visible beneath the
/// refresh indicator while new data is being fetched.
class ConsultationsRefreshing extends ConsultationsState {
  final List<ConsultationModel> currentConsultations;
  final ConsultationStatus selectedStatus;

  const ConsultationsRefreshing({
    required this.currentConsultations,
    required this.selectedStatus,
  });
}

/// Appending the next page — current list stays visible, a shimmer card is
/// appended at the bottom as a loading indicator.
class ConsultationsPaginating extends ConsultationsState {
  final List<ConsultationModel> currentConsultations;
  final ConsultationStatus selectedStatus;

  const ConsultationsPaginating({
    required this.currentConsultations,
    required this.selectedStatus,
  });
}

/// Data loaded successfully with at least one item.
class ConsultationsLoaded extends ConsultationsState {
  final List<ConsultationModel> consultations;
  final ConsultationStatus selectedStatus;
  final bool hasMorePages;
  final int currentPage;

  const ConsultationsLoaded({
    required this.consultations,
    required this.selectedStatus,
    required this.hasMorePages,
    required this.currentPage,
  });
}

/// Fetch returned an empty list.
class ConsultationsEmpty extends ConsultationsState {
  final ConsultationStatus selectedStatus;

  const ConsultationsEmpty({required this.selectedStatus});
}

/// A network or server error occurred.
class ConsultationsError extends ConsultationsState {
  final String message;
  final ConsultationStatus selectedStatus;

  const ConsultationsError({
    required this.message,
    required this.selectedStatus,
  });
}

// ── Details Screen States ─────────────────────────────────────────────────────

abstract class ConsultationDetailsState {
  const ConsultationDetailsState();
}

/// Initial state before [ConsultationDetailsCubit.fetchDetails] is called.
class ConsultationDetailsInitial extends ConsultationDetailsState {
  const ConsultationDetailsInitial();
}

/// Full-screen shimmer while the detail request is in flight.
class ConsultationDetailsLoading extends ConsultationDetailsState {
  const ConsultationDetailsLoading();
}

/// Details fetched successfully.
class ConsultationDetailsLoaded extends ConsultationDetailsState {
  final ConsultationModel consultation;

  const ConsultationDetailsLoaded({required this.consultation});
}

/// A network or server error occurred while loading details.
class ConsultationDetailsError extends ConsultationDetailsState {
  final String message;

  const ConsultationDetailsError({required this.message});
}