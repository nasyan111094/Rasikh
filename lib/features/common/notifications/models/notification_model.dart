// features/notifications/data/models/notification_model.dart

class NotificationModel {
  final String id;
  final String recipient;
  final String recipientModel;
  final String type;
  final String channel;
  final String title;
  final String body;
  final bool isRead;
  final String? readAt;
  final String status;
  final String? scheduledAt;
  final String? sentAt;
  final String? referenceId;
  final String? referenceModel;
  final Map<String, dynamic>? metadata;
  final String createdAt;
  final String updatedAt;

  const NotificationModel({
    required this.id,
    required this.recipient,
    required this.recipientModel,
    required this.type,
    required this.channel,
    required this.title,
    required this.body,
    required this.isRead,
    this.readAt,
    required this.status,
    this.scheduledAt,
    this.sentAt,
    this.referenceId,
    this.referenceModel,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      recipient: json['recipient']?.toString() ?? '',
      recipientModel: json['recipientModel']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      channel: json['channel']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt']?.toString(),
      status: json['status']?.toString() ?? '',
      scheduledAt: json['scheduledAt']?.toString(),
      sentAt: json['sentAt']?.toString(),
      referenceId: json['referenceId']?.toString(),
      referenceModel: json['referenceModel']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'recipient': recipient,
        'recipientModel': recipientModel,
        'type': type,
        'channel': channel,
        'title': title,
        'body': body,
        'isRead': isRead,
        'readAt': readAt,
        'status': status,
        'scheduledAt': scheduledAt,
        'sentAt': sentAt,
        'referenceId': referenceId,
        'referenceModel': referenceModel,
        'metadata': metadata,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  NotificationModel copyWith({bool? isRead, String? readAt}) {
    return NotificationModel(
      id: id,
      recipient: recipient,
      recipientModel: recipientModel,
      type: type,
      channel: channel,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      status: status,
      scheduledAt: scheduledAt,
      sentAt: sentAt,
      referenceId: referenceId,
      referenceModel: referenceModel,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// ── Paginated response wrapper ────────────────────────────────────────────────

class NotificationsMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const NotificationsMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory NotificationsMeta.fromJson(Map<String, dynamic> json) {
    return NotificationsMeta(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class NotificationsResponse {
  final List<NotificationModel> notifications;
  final NotificationsMeta meta;

  const NotificationsResponse({
    required this.notifications,
    required this.meta,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return NotificationsResponse(
      notifications: data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: NotificationsMeta.fromJson(meta),
    );
  }
}
