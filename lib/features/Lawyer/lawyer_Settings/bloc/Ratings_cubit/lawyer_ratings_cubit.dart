// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/lawyer_Settings/logic/ratings/lawyer_ratings_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repo/lawyer_ratings_repo.dart';

import '../../models/lawyer_ratings_model.dart';

part 'lawyer_ratings_state.dart';

class LawyerRatingsCubit extends Cubit<LawyerRatingsState> {
  LawyerRatingsCubit(this._repo) : super(LawyerRatingsInitial());

  final LawyerRatingsRepo _repo;

  // ── Internal state helpers ────────────────────────────────────────────────

  LawyerRatingsModel? _currentModel;
  Set<String> _reportedIds = {};
  int _currentPage = 1;
  static const int _pageSize = 10;

  // ── Fetch first page ──────────────────────────────────────────────────────

  Future<void> fetchRatings() async {
    emit(LawyerRatingsLoading());
    _currentPage = 1;

    final result = await _repo.getRatings(page: _currentPage, limit: _pageSize);

    result.fold(
      (error) => emit(LawyerRatingsError(error)),
      (model) {
        _currentModel = model;
        _reportedIds = {};
        emit(LawyerRatingsLoaded(
          ratingsModel: model,
          reportedIds: _reportedIds,
        ));
      },
    );
  }

  // ── Load next page ────────────────────────────────────────────────────────

  Future<void> loadMoreRatings() async {
    final current = _currentModel;
    if (current == null) return;

    // Guard: no more pages
    if (_currentPage >= current.meta.totalPages) return;

    emit(LawyerRatingsPaginationLoading(
      currentModel: current,
      reportedIds: _reportedIds,
    ));

    final nextPage = _currentPage + 1;
    final result = await _repo.getRatings(page: nextPage, limit: _pageSize);

    result.fold(
      (error) {
        // Roll back to loaded state with existing data
        emit(LawyerRatingsLoaded(
          ratingsModel: current,
          reportedIds: _reportedIds,
        ));
      },
      (newModel) {
        _currentPage = nextPage;
        // Merge new ratings into the existing list
        final merged = LawyerRatingsModel(
          ratings: [...current.ratings, ...newModel.ratings],
          meta: newModel.meta,
        );
        _currentModel = merged;
        emit(LawyerRatingsLoaded(
          ratingsModel: merged,
          reportedIds: _reportedIds,
        ));
      },
    );
  }

  // ── Report a rating ───────────────────────────────────────────────────────

  Future<void> reportRating({
    required String ratingId,
    required String message,
  }) async {
    final current = _currentModel;
    if (current == null) return;

    emit(LawyerRatingReportLoading(
      ratingId: ratingId,
      currentModel: current,
      reportedIds: _reportedIds,
    ));

    final result = await _repo.reportRating(
      ratingId: ratingId,
      message: message,
    );

    result.fold(
      (error) => emit(LawyerRatingReportError(
        message: error,
        currentModel: current,
        reportedIds: _reportedIds,
      )),
      (successMessage) {
        // Mark this rating as reported so the UI can disable the button
        _reportedIds = {..._reportedIds, ratingId};
        emit(LawyerRatingReportSuccess(
          message: successMessage,
          currentModel: current,
          reportedIds: _reportedIds,
        ));
      },
    );
  }

  // ── Convenience getter ────────────────────────────────────────────────────

  bool hasMorePages() {
    final current = _currentModel;
    if (current == null) return false;
    return _currentPage < current.meta.totalPages;
  }
}
