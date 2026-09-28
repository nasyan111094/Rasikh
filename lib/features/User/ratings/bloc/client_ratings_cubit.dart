// ─────────────────────────────────────────────────────────────────────────────
// features/User/ratings/logic/client_ratings_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rasikh/features/Lawyer/lawyer_Settings/models/lawyer_ratings_model.dart';
import 'package:rasikh/features/User/ratings/repo/client_ratings_repo.dart';

part 'client_ratings_state.dart';

class ClientRatingsCubit extends Cubit<ClientRatingsState> {
  ClientRatingsCubit(this._repo) : super(ClientRatingsInitial());

  final ClientRatingsRepo _repo;

  // ── Internal state helpers ────────────────────────────────────────────────

  LawyerRatingsModel? _currentModel;
  int _currentPage = 1;
  static const int _pageSize = 10;

  // ── Fetch first page ──────────────────────────────────────────────────────

  Future<void> fetchRatings() async {
    emit(ClientRatingsLoading());
    _currentPage = 1;

    final result = await _repo.getRatings(page: _currentPage, limit: _pageSize);

    result.fold(
      (error) => emit(ClientRatingsError(error)),
      (model) {
        _currentModel = model;
        emit(ClientRatingsLoaded(ratingsModel: model));
      },
    );
  }

  // ── Load next page ────────────────────────────────────────────────────────

  Future<void> loadMoreRatings() async {
    final current = _currentModel;
    if (current == null) return;

    // Guard: no more pages
    if (_currentPage >= current.meta.totalPages) return;

    emit(ClientRatingsPaginationLoading(currentModel: current));

    final nextPage = _currentPage + 1;
    final result = await _repo.getRatings(page: nextPage, limit: _pageSize);

    result.fold(
      (error) {
        // Roll back to loaded state with existing data
        emit(ClientRatingsLoaded(ratingsModel: current));
      },
      (newModel) {
        _currentPage = nextPage;
        // Merge new ratings into the existing list
        final merged = LawyerRatingsModel(
          ratings: [...current.ratings, ...newModel.ratings],
          meta: newModel.meta,
        );
        _currentModel = merged;
        emit(ClientRatingsLoaded(ratingsModel: merged));
      },
    );
  }

  // ── Fetch single rating details ───────────────────────────────────────────

  Future<void> fetchRatingDetail(String ratingId) async {
    emit(ClientRatingDetailLoading());

    final result = await _repo.getRatingById(ratingId);

    result.fold(
      (error) => emit(ClientRatingDetailError(error)),
      (detail) => emit(ClientRatingDetailLoaded(detail: detail)),
    );
  }

  // ── Convenience getter ────────────────────────────────────────────────────

  bool hasMorePages() {
    final current = _currentModel;
    if (current == null) return false;
    return _currentPage < current.meta.totalPages;
  }
}
