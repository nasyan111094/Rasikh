// features/notifications/logic/cubit/notifications_state.dart

part of 'notifications_cubit.dart';

sealed class NotificationsState {}

// ── Initial ───────────────────────────────────────────────────────────────────

final class NotificationsInitial extends NotificationsState {}

// ── Loading (first fetch / hard refresh) ─────────────────────────────────────

final class NotificationsLoading extends NotificationsState {}

// ── Loaded ────────────────────────────────────────────────────────────────────

final class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final NotificationsMeta meta;

  /// True while a pull-to-refresh is in progress but we still show old data.
  final bool isRefreshing;

  /// True while the next page is being loaded (pagination).
  final bool isPaginating;

  NotificationsLoaded({
    required this.notifications,
    required this.meta,
    this.isRefreshing = false,
    this.isPaginating = false,
  });

  NotificationsLoaded copyWith({
    List<NotificationModel>? notifications,
    NotificationsMeta? meta,
    bool? isRefreshing,
    bool? isPaginating,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      meta: meta ?? this.meta,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isPaginating: isPaginating ?? this.isPaginating,
    );
  }

  bool get hasMore => meta.page < meta.totalPages;
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

// ── Failure ───────────────────────────────────────────────────────────────────

final class NotificationsFailure extends NotificationsState {
  final String message;
  NotificationsFailure(this.message);
}

// ── Mark-read action states ───────────────────────────────────────────────────

final class MarkReadLoading extends NotificationsState {}

final class MarkReadSuccess extends NotificationsState {}

final class MarkReadFailure extends NotificationsState {
  final String message;
  MarkReadFailure(this.message);
}
