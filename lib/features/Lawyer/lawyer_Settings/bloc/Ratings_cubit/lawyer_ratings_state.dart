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

// ── Rating Detail ─────────────────────────────────────────────────────────────

class LawyerRatingDetailLoading extends LawyerRatingsState {}

class LawyerRatingDetailLoaded extends LawyerRatingsState {
  final RatingDetailModel detail;

  LawyerRatingDetailLoaded({required this.detail});
}

class LawyerRatingDetailError extends LawyerRatingsState {
  final String message;

  LawyerRatingDetailError(this.message);
}

// ── Reply to Rating ───────────────────────────────────────────────────────────

class LawyerRatingReplyLoading extends LawyerRatingsState {
  final String ratingId;
  final RatingDetailModel? currentDetail;

  LawyerRatingReplyLoading({
    required this.ratingId,
    this.currentDetail,
  });
}

class LawyerRatingReplySuccess extends LawyerRatingsState {
  final String message;
  final RatingDetailModel? currentDetail;

  LawyerRatingReplySuccess({
    required this.message,
    this.currentDetail,
  });
}

class LawyerRatingReplyError extends LawyerRatingsState {
  final String message;
  final RatingDetailModel? currentDetail;

  LawyerRatingReplyError({
    required this.message,
    this.currentDetail,
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
