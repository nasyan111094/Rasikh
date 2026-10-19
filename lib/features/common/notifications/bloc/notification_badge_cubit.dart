// features/notifications/logic/cubit/notification_badge_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/notifications_repo.dart';

part 'notification_badge_state.dart';

/// Badge cubit for the bell icon on Home (lawyer & client).
/// Fetches GET /notifications/unread-count → { "count": N }.
class NotificationBadgeCubit extends Cubit<NotificationBadgeState> {
  NotificationBadgeCubit(this._repo) : super(NotificationBadgeInitial());

  final NotificationsRepo _repo;

  Future<void> fetchUnreadCount() async {
    // Avoid parallel fetches.
    if (state is NotificationBadgeLoading) return;
    final previousCount =
        state is NotificationBadgeLoaded ? (state as NotificationBadgeLoaded).count : null;
    emit(NotificationBadgeLoading(previousCount: previousCount));

    final result = await _repo.getUnreadCount();
    result.fold(
      (error) {
        // Keep the old count visible on refresh failure, else emit failure
        // (UI hides the badge on failure).
        if (previousCount != null) {
          emit(NotificationBadgeLoaded(count: previousCount));
        } else {
          emit(NotificationBadgeFailure(error));
        }
      },
      (count) => emit(NotificationBadgeLoaded(count: count < 0 ? 0 : count)),
    );
  }

  /// Optimistically decrement after reading notifications (optional).
  void decrement({int by = 1}) {
    final current = state;
    if (current is NotificationBadgeLoaded) {
      final next = current.count - by;
      emit(NotificationBadgeLoaded(count: next < 0 ? 0 : next));
    }
  }

  /// Reset badge (e.g. after mark-all-as-read / logout).
  void reset() => emit(const NotificationBadgeLoaded(count: 0));
}
