// features/Lawyer/lawyer-home/models/lawyer_dashboard_model.dart

import 'avaiability_status_model.dart';
import 'consultation_model.dart';
import 'nearest.dart';

// ── Last Financial Movement ─────────────────────────────────────────────────────

class LastFinancialMovement {
  final String id;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String description;
  final DateTime createdAt;

  LastFinancialMovement({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
  });

  factory LastFinancialMovement.fromJson(Map<String, dynamic> json) {
    return LastFinancialMovement(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// ── Notifications Meta ───────────────────────────────────────────────────────────

class NotificationsMeta {
  final bool integrated;
  final String source;

  NotificationsMeta({
    required this.integrated,
    required this.source,
  });

  factory NotificationsMeta.fromJson(Map<String, dynamic> json) {
    return NotificationsMeta(
      integrated: json['integrated'] as bool? ?? false,
      source: json['source']?.toString() ?? 'pending_integration',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'integrated': integrated,
      'source': source,
    };
  }
}

// ── Dashboard Response ───────────────────────────────────────────────────────────

class LawyerDashboardResponse {
  final bool success;
  final int statusCode;
  final String message;
  final LawyerDashboardData data;
  final Meta meta;

  LawyerDashboardResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory LawyerDashboardResponse.fromJson(Map<String, dynamic> json) {
    return LawyerDashboardResponse(
      success: json['success'] == true,
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      data: LawyerDashboardData.fromJson(json['data'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
      'data': data.toJson(),
      'meta': meta.toJson(),
    };
  }
}

// ── Dashboard Data ───────────────────────────────────────────────────────────────

class LawyerDashboardData {
  final LawyerAvailabilityStatus availability;
  final int pendingConsultationsCount;
  final List<ScheduledConsultation> todayUpcomingAppointments;
  final LastFinancialMovement? lastFinancialMovement;
  final List<dynamic> recentNotifications;
  final NotificationsMeta notificationsMeta;

  LawyerDashboardData({
    required this.availability,
    required this.pendingConsultationsCount,
    required this.todayUpcomingAppointments,
    this.lastFinancialMovement,
    required this.recentNotifications,
    required this.notificationsMeta,
  });

  factory LawyerDashboardData.fromJson(Map<String, dynamic> json) {
    return LawyerDashboardData(
      availability: LawyerAvailabilityStatus.fromString(
        json['availability']?.toString() ?? 'unavailable',
      ),
      pendingConsultationsCount: (json['pendingConsultationsCount'] as num?)?.toInt() ?? 0,
      todayUpcomingAppointments: (json['todayUpcomingAppointments'] as List<dynamic>?)
          ?.map((e) => ScheduledConsultation.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      lastFinancialMovement: json['lastFinancialMovement'] != null
          ? LastFinancialMovement.fromJson(json['lastFinancialMovement'] as Map<String, dynamic>)
          : null,
      recentNotifications: json['recentNotifications'] as List<dynamic>? ?? [],
      notificationsMeta: NotificationsMeta.fromJson(json['notificationsMeta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availability': availability.value,
      'pendingConsultationsCount': pendingConsultationsCount,
      'todayUpcomingAppointments': todayUpcomingAppointments.map((e) => e.toJson()).toList(),
      'lastFinancialMovement': lastFinancialMovement?.toJson(),
      'recentNotifications': recentNotifications,
      'notificationsMeta': notificationsMeta.toJson(),
    };
  }
}
