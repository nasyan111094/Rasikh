// features/notifications/logic/cubit/notifications_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';


import '../models/notification_model.dart';
import '../repo/notifications_repo.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repo) : super(NotificationsInitial());

  final NotificationsRepo _repo;

  static const int _defaultLimit = 10;

  // ── Fetch first page ──────────────────────────────────────────────────────

  Future<void> fetchNotifications() async {
    emit(NotificationsLoading());

    final result = await _repo.getMyNotifications(
      page: 1,
      limit: _defaultLimit,
    );

    result.fold(
      (error) => emit(NotificationsFailure(error)),
      (response) => emit(
        NotificationsLoaded(
          notifications: response.notifications,
          meta: response.meta,
        ),
      ),
    );
  }

  // ── Pull-to-refresh (keeps old list visible while loading) ────────────────

  Future<void> refreshNotifications() async {
    final current = state;

    // If we have a loaded state, mark as refreshing so UI keeps showing data
    if (current is NotificationsLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(NotificationsLoading());
    }

    final result = await _repo.getMyNotifications(
      page: 1,
      limit: _defaultLimit,
    );

    result.fold(
      (error) {
        // On refresh failure, restore old data with an error snackbar signal
        if (current is NotificationsLoaded) {
          emit(current.copyWith(isRefreshing: false));
        }
        emit(NotificationsFailure(error));
      },
      (response) => emit(
        NotificationsLoaded(
          notifications: response.notifications,
          meta: response.meta,
        ),
      ),
    );
  }

  // ── Load next page (pagination) ───────────────────────────────────────────

  Future<void> loadMoreNotifications() async {
    final current = state;
    if (current is! NotificationsLoaded) return;
    if (!current.hasMore || current.isPaginating) return;

    emit(current.copyWith(isPaginating: true));

    final result = await _repo.getMyNotifications(
      page: current.meta.page + 1,
      limit: _defaultLimit,
    );

    result.fold(
      (error) => emit(current.copyWith(isPaginating: false)),
      (response) => emit(
        NotificationsLoaded(
          notifications: [
            ...current.notifications,
            ...response.notifications,
          ],
          meta: response.meta,
        ),
      ),
    );
  }

  // ── Mark single as read ───────────────────────────────────────────────────

  Future<void> markAsRead(String notificationId) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistic update
    final updated = current.notifications.map((n) {
      return n.id == notificationId
          ? n.copyWith(isRead: true, readAt: DateTime.now().toIso8601String())
          : n;
    }).toList();

    emit(current.copyWith(notifications: updated));

    final result = await _repo.markAsRead(notificationId);
    result.fold(
      (error) {
        // Revert on failure
        emit(current);
      },
      (_) {/* optimistic already applied */},
    );
  }

  // ── Mark all as read ──────────────────────────────────────────────────────

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistic update
    final updated = current.notifications
        .map((n) => n.copyWith(
              isRead: true,
              readAt: DateTime.now().toIso8601String(),
            ))
        .toList();

    emit(current.copyWith(notifications: updated));

    final result = await _repo.markAllAsRead();
    result.fold(
      (error) {
        // Revert on failure
        emit(current);
        emit(MarkReadFailure(error));
      },
      (_) => emit(MarkReadSuccess()),
    );
  }
}
