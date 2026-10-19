// features/notifications/logic/cubit/notification_badge_state.dart

part of 'notification_badge_cubit.dart';

sealed class NotificationBadgeState {
  const NotificationBadgeState();
}

final class NotificationBadgeInitial extends NotificationBadgeState {}

final class NotificationBadgeLoading extends NotificationBadgeState {
  final int? previousCount;
  NotificationBadgeLoading({this.previousCount});
}

final class NotificationBadgeLoaded extends NotificationBadgeState {
  final int count;
  const NotificationBadgeLoaded({required this.count});
}

final class NotificationBadgeFailure extends NotificationBadgeState {
  final String message;
  NotificationBadgeFailure(this.message);
}
