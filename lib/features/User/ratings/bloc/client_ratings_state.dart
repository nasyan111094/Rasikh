// ─────────────────────────────────────────────────────────────────────────────
// features/User/ratings/logic/client_ratings_state.dart
// ─────────────────────────────────────────────────────────────────────────────

part of 'client_ratings_cubit.dart';

// ── Initial ───────────────────────────────────────────────────────────────────

final class ClientRatingsInitial extends ClientRatingsState {}

// ── Base ──────────────────────────────────────────────────────────────────────

sealed class ClientRatingsState {}

// ── List ──────────────────────────────────────────────────────────────────────

final class ClientRatingsLoading extends ClientRatingsState {}

final class ClientRatingsLoaded extends ClientRatingsState {
  final LawyerRatingsModel ratingsModel;

  ClientRatingsLoaded({required this.ratingsModel});
}

final class ClientRatingsPaginationLoading extends ClientRatingsState {
  final LawyerRatingsModel currentModel;

  ClientRatingsPaginationLoading({required this.currentModel});
}

final class ClientRatingsError extends ClientRatingsState {
  final String message;

  ClientRatingsError(this.message);
}

// ── Detail ────────────────────────────────────────────────────────────────────

final class ClientRatingDetailLoading extends ClientRatingsState {}

final class ClientRatingDetailLoaded extends ClientRatingsState {
  final RatingDetailModel detail;

  ClientRatingDetailLoaded({required this.detail});
}

final class ClientRatingDetailError extends ClientRatingsState {
  final String message;

  ClientRatingDetailError(this.message);
}
