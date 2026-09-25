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

// ── Reschedule States ─────────────────────────────────────────────────────────

/// A reschedule POST is in flight for [consultationId].
class ConsultationRescheduling extends ConsultationsState {
  final String consultationId;
  final List<ConsultationModel> currentConsultations;
  final ConsultationStatus selectedStatus;

  const ConsultationRescheduling({
    required this.consultationId,
    required this.currentConsultations,
    required this.selectedStatus,
  });
}

/// The reschedule succeeded. The updated consultation is returned so the UI
/// can optimistically replace the old card.
class ConsultationRescheduled extends ConsultationsState {
  final ConsultationModel updatedConsultation;
  final List<ConsultationModel> consultations;
  final ConsultationStatus selectedStatus;
  final bool hasMorePages;
  final int currentPage;

  const ConsultationRescheduled({
    required this.updatedConsultation,
    required this.consultations,
    required this.selectedStatus,
    required this.hasMorePages,
    required this.currentPage,
  });
}

/// The reschedule failed. The previous list is preserved.
class ConsultationRescheduleError extends ConsultationsState {
  final String message;
  final List<ConsultationModel> currentConsultations;
  final ConsultationStatus selectedStatus;
  final bool hasMorePages;
  final int currentPage;

  const ConsultationRescheduleError({
    required this.message,
    required this.currentConsultations,
    required this.selectedStatus,
    required this.hasMorePages,
    required this.currentPage,
  });
}

// ── Cancel States ─────────────────────────────────────────────────────────────

/// A cancel PATCH is in flight for [consultationId].
class ConsultationCancelling extends ConsultationsState {
  final String consultationId;
  final List<ConsultationModel> currentConsultations;
  final ConsultationStatus selectedStatus;

  const ConsultationCancelling({
    required this.consultationId,
    required this.currentConsultations,
    required this.selectedStatus,
  });
}

/// The cancellation succeeded. The consultation is removed from the local list
/// (or its status is updated to cancelled depending on your UX preference).
class ConsultationCancelled extends ConsultationsState {
  final String cancelledId;
  final List<ConsultationModel> consultations;
  final ConsultationStatus selectedStatus;
  final bool hasMorePages;
  final int currentPage;

  const ConsultationCancelled({
    required this.cancelledId,
    required this.consultations,
    required this.selectedStatus,
    required this.hasMorePages,
    required this.currentPage,
  });
}

/// The cancellation failed. The previous list is preserved.
class ConsultationCancelError extends ConsultationsState {
  final String message;
  final List<ConsultationModel> currentConsultations;
  final ConsultationStatus selectedStatus;
  final bool hasMorePages;
  final int currentPage;

  const ConsultationCancelError({
    required this.message,
    required this.currentConsultations,
    required this.selectedStatus,
    required this.hasMorePages,
    required this.currentPage,
  });
}

// ── Rating States ─────────────────────────────────────────────────────────────

/// A rating POST is in flight for [consultationId].
class ConsultationRatingSubmitting extends ConsultationsState {
  final String consultationId;
  final List<ConsultationModel> currentConsultations;
  final ConsultationStatus selectedStatus;

  const ConsultationRatingSubmitting({
    required this.consultationId,
    required this.currentConsultations,
    required this.selectedStatus,
  });
}

/// The rating submitted successfully for [consultationId]. The rating
/// endpoint doesn't return an updated consultation object, so the local list
/// is passed through unchanged — the API itself enforces "one rating per
/// consultation," so a resubmit attempt will simply surface a 400 error.
class ConsultationRatingSubmitted extends ConsultationsState {
  final String consultationId;
  final List<ConsultationModel> consultations;
  final ConsultationStatus selectedStatus;
  final bool hasMorePages;
  final int currentPage;

  const ConsultationRatingSubmitted({
    required this.consultationId,
    required this.consultations,
    required this.selectedStatus,
    required this.hasMorePages,
    required this.currentPage,
  });
}

/// The rating submission failed. The previous list is preserved.
class ConsultationRatingError extends ConsultationsState {
  final String message;
  final String consultationId;
  final List<ConsultationModel> currentConsultations;
  final ConsultationStatus selectedStatus;
  final bool hasMorePages;
  final int currentPage;

  const ConsultationRatingError({
    required this.message,
    required this.consultationId,
    required this.currentConsultations,
    required this.selectedStatus,
    required this.hasMorePages,
    required this.currentPage,
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