// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/lawyer_Settings/logic/ratings/lawyer_ratings_state.dart
// ─────────────────────────────────────────────────────────────────────────────

part of 'lawyer_ratings_cubit.dart';

abstract class LawyerRatingsState {}

// ── Initial ───────────────────────────────────────────────────────────────────

class LawyerRatingsInitial extends LawyerRatingsState {}

// ── Fetch ratings ─────────────────────────────────────────────────────────────

class LawyerRatingsLoading extends LawyerRatingsState {}

class LawyerRatingsLoaded extends LawyerRatingsState {
  final LawyerRatingsModel ratingsModel;
  /// IDs of ratings that have already been reported in this session.
  final Set<String> reportedIds;

  LawyerRatingsLoaded({
    required this.ratingsModel,
    this.reportedIds = const {},
  });
}

class LawyerRatingsError extends LawyerRatingsState {
  final String message;

  LawyerRatingsError(this.message);
}

// ── Pagination (load more) ────────────────────────────────────────────────────

class LawyerRatingsPaginationLoading extends LawyerRatingsState {
  /// Current already-loaded data shown while next page loads.
  final LawyerRatingsModel currentModel;
  final Set<String> reportedIds;

  LawyerRatingsPaginationLoading({
    required this.currentModel,
    required this.reportedIds,
  });
}

// ── Report rating ─────────────────────────────────────────────────────────────

class LawyerRatingReportLoading extends LawyerRatingsState {
  final String ratingId;
  final LawyerRatingsModel currentModel;
  final Set<String> reportedIds;

  LawyerRatingReportLoading({
    required this.ratingId,
    required this.currentModel,
    required this.reportedIds,
  });
}

class LawyerRatingReportSuccess extends LawyerRatingsState {
  final String message;
  final LawyerRatingsModel currentModel;
  final Set<String> reportedIds;

  LawyerRatingReportSuccess({
    required this.message,
    required this.currentModel,
    required this.reportedIds,
  });
}

class LawyerRatingReportError extends LawyerRatingsState {
  final String message;
  final LawyerRatingsModel currentModel;
  final Set<String> reportedIds;

  LawyerRatingReportError({
    required this.message,
    required this.currentModel,
    required this.reportedIds,
  });
}
