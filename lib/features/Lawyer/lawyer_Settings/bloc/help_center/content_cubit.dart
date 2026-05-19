// features/help_center/logic/content/content_cubit.dart
//
// One cubit drives BOTH PolicyTextScreen instances (privacy-policy & terms).
// The caller decides which endpoint to call by passing the fetch function.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repo/help_center_repo.dart';
import '../../models/help_center_models.dart';


part 'content_state.dart';

enum ContentType { privacyPolicy, terms }

class ContentCubit extends Cubit<ContentState> {
  ContentCubit(this._repo) : super(ContentInitial());

  final HelpCenterRepo _repo;

  Future<void> fetchContent(ContentType type) async {
    emit(ContentLoading());

    final result = type == ContentType.privacyPolicy
        ? await _repo.getPrivacyPolicy()
        : await _repo.getTerms();

    result.fold(
      (error) => emit(ContentFailure(error)),
      (content) => emit(ContentLoaded(content, type: type)),
    );
  }

  Future<void> refreshContent(ContentType type) async {
    final current = state;

    if (current is ContentLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(ContentLoading());
    }

    final result = type == ContentType.privacyPolicy
        ? await _repo.getPrivacyPolicy()
        : await _repo.getTerms();

    result.fold(
      (error) {
        if (current is ContentLoaded) {
          emit(current.copyWith(isRefreshing: false));
        }
        emit(ContentFailure(error));
      },
      (content) => emit(ContentLoaded(content, type: type)),
    );
  }
}
