// features/notifications/data/repos/notifications_repo.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_adapter/dio_adapter.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../../../../../../core/utils/api/api_handler.dart';
import '../models/notification_model.dart';

// ── Endpoint constants ────────────────────────────────────────────────────────

class _NotificationsEndpoints {
  static const String myNotifications = 'notifications/my';
  static const String markRead = 'notifications'; // PATCH /notifications/:id/read
  static const String markAllRead = 'notifications/mark-all-read';
}

// ── Repository ────────────────────────────────────────────────────────────────

class NotificationsRepo {
  final DioAdapterBase _adapter = getIt<ApiHandler>().dioAdapterBase;

  // ── GET my notifications (paginated) ─────────────────────────────────────

  Future<Either<String, NotificationsResponse>> getMyNotifications({
    int page = 1,
    int limit = 7,
    bool? isRead,
    String? type,
    String? channel,
    String? status,
    String? search,
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (isRead != null) 'isRead': isRead,
      if (type != null) 'type': type,
      if (channel != null) 'channel': channel,
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      if (fromDate != null) 'fromDate': fromDate,
      if (toDate != null) 'toDate': toDate,
    };

    final result = await _adapter.get(
      _NotificationsEndpoints.myNotifications,
      queryParameters: queryParams,
    );

    if (result.isRight) {
      final data = result.right.data;
      return Right(NotificationsResponse.fromJson(data));
    }
    return Left(_extractError(result.left));
  }

  // ── MARK single notification as read ─────────────────────────────────────

  Future<Either<String, bool>> markAsRead(String notificationId) async {
    final result = await _adapter.patch(
      '${_NotificationsEndpoints.markRead}/$notificationId/read',
    );

    if (result.isRight) {
      return const Right(true);
    }
    return Left(_extractError(result.left));
  }

  // ── MARK all notifications as read ───────────────────────────────────────

  Future<Either<String, bool>> markAllAsRead() async {
    final result = await _adapter.put(
      _NotificationsEndpoints.markAllRead,
    );

    if (result.isRight) {
      return const Right(true);
    }
    return Left(_extractError(result.left));
  }

  // ── Error helper ──────────────────────────────────────────────────────────

  String _extractError(dynamic left) {
    try {
      if (left is DioException) {
        final data = left.response?.data;
        if (data is Map) {
          return data['message']?.toString() ??
              data['error']?['details']?.toString() ??
              'حدث خطأ غير متوقع';
        }
      }
      return left.toString();
    } catch (_) {
      return 'حدث خطأ غير متوقع';
    }
  }
}
