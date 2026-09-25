// ─────────────────────────────────────────────────────────────────────────────
// video_call_repo.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/api/api_handler.dart';

// ── Models ─────────────────────────────────────────────────────────────────

class RtcTokenModel {
  final String appId;
  final String channelName;
  final int uid;
  final String token;
  final DateTime expiresAt;

  const RtcTokenModel({
    required this.appId,
    required this.channelName,
    required this.uid,
    required this.token,
    required this.expiresAt,
  });

  factory RtcTokenModel.fromJson(Map<String, dynamic> json) => RtcTokenModel(
    appId: json['appId'] as String,
    channelName: json['channelName'] as String,
    uid: json['uid'] as int,
    token: json['token'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );
}

class InstantSessionState {
  final String consultationId;
  final DateTime serverTime;
  final String phase;
  final int? remainingSeconds;
  final DateTime? sessionStartedAt;
  final DateTime? sessionEndsAt;
  final bool instantTwoMinuteWarningActive;
  final bool canLawyerEndAsNoShow;

  // ── IDs hydrated from the server ──────────────────────────────────────────
  final String? lawyerId;
  final String? clientId;

  const InstantSessionState({
    required this.consultationId,
    required this.serverTime,
    required this.phase,
    this.remainingSeconds,
    this.sessionStartedAt,
    this.sessionEndsAt,
    this.instantTwoMinuteWarningActive = false,
    this.canLawyerEndAsNoShow = false,
    this.lawyerId,
    this.clientId,
  });

  factory InstantSessionState.fromJson(Map<String, dynamic> json) =>
      InstantSessionState(
        consultationId: json['consultationId'] as String,
        serverTime: DateTime.parse(json['serverTime'] as String),
        phase: json['phase'] as String? ?? 'not_applicable',
        remainingSeconds: json['remainingSeconds'] as int?,
        sessionStartedAt: json['sessionStartedAt'] != null
            ? DateTime.parse(json['sessionStartedAt'] as String)
            : null,
        sessionEndsAt: json['sessionEndsAt'] != null
            ? DateTime.parse(json['sessionEndsAt'] as String)
            : null,
        instantTwoMinuteWarningActive:
        json['instantTwoMinuteWarningActive'] as bool? ?? false,
        canLawyerEndAsNoShow: json['canLawyerEndAsNoShow'] as bool? ?? false,
        lawyerId: json['lawyerId'] as String?,
        clientId: json['clientId'] as String?,
      );

  bool get isInProgress => phase == 'in_progress' || phase == 'in_session';
  bool get isWaiting =>
      phase == 'waiting_call' || phase == 'waiting' || phase == 'accepted';
  bool get isEnded =>
      phase == 'ended' || phase == 'completed' || phase == 'no_show';
}

// ── Repository ─────────────────────────────────────────────────────────────

class VideoCallRepo {
  final DioAdapterBase _dio = getIt.get<ApiHandler>().dioAdapterBase;

  String get userType =>
      getIt<CacheHelper>().cachedVendorType == VendorType.user
          ? 'client'
          : 'lawyer';

  // ── Step 2: instant-session (initial fetch) ────────────────────────────
  Future<Either<String, InstantSessionState>> fetchSession(
      String consultationId , String? consultationType ) async {
    final result = await _dio.get(
      consultationType!=null && consultationType == "scheduled" ?
      '$userType/consultations/$consultationId/scheduled-session':
      '$userType/consultations/$consultationId/instant-session',
    );
    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(InstantSessionState.fromJson(data));
    }
    return Left(result.left.toString());
  }

  // ── Step 3: rtc-token ──────────────────────────────────────────────────
  Future<Either<String, RtcTokenModel>> fetchRtcToken(
      String consultationId) async {
    final result = await _dio.get(
      '$userType/consultations/$consultationId/rtc-token',
    );
    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(RtcTokenModel.fromJson(data));
    }
    return Left(result.left.toString());
  }

  // ── Step 5: join-call ──────────────────────────────────────────────────
  Future<Either<String, bool>> joinCall(String consultationId , String ? consultationType ) async {



    final result = await _dio.post(
      consultationType!=null && consultationType == "scheduled" ?
      '$userType/consultations/$consultationId/scheduled-session/join-call':
      '$userType/consultations/$consultationId/instant-session/join-call',
      body: {},
    );
    if (result.isRight) return const Right(true);
    return Left(result.left.toString());
  }

  // ── Step 7: polling ────────────────────────────────────────────────────
  Future<Either<String, InstantSessionState>> pollSession(
      String consultationId , String ? consultationType ) async {
    final result = await _dio.get(
      consultationType!=null && consultationType == "scheduled" ?
      '$userType/consultations/$consultationId/scheduled-session':
      '$userType/consultations/$consultationId/instant-session',
    );
    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(InstantSessionState.fromJson(data));
    }
    return Left(result.left.toString());
  }

  // ── Lawyer-only ────────────────────────────────────────────────────────
  Future<Either<String, bool>> notifyLawyerReconnected(
      String consultationId) async {
    if (userType != 'lawyer') return const Left('Only lawyer can call this');
    final result = await _dio.post(
      '$userType/consultations/$consultationId/rtc/reconnected',
      body: {},
    );
    if (result.isRight) return const Right(true);
    return Left(result.left.toString());
  }

  Future<Either<String, bool>> notifyLawyerDisconnected(
      String consultationId) async {
    if (userType != 'lawyer') return const Left('Only lawyer can call this');
    final result = await _dio.post(
      '$userType/consultations/$consultationId/rtc/disconnected',
      body: {},
    );
    if (result.isRight) return const Right(true);
    return Left(result.left.toString());
  }

  Future<Either<String, bool>> submitCallSummary(
      String consultationId,
      String summary, {
        bool endAsNoShow = false,
      }) async {
    if (userType != 'lawyer') return const Left('Only lawyer can call this');
    final result = await _dio.post(
      'lawyer/consultations/$consultationId/complete',
      body: {
        'summary': summary,
        'endAsNoShow': endAsNoShow,
      },
    );
    if (result.isRight) return const Right(true);
    return Left(result.left.toString());
  }

  // ── Client: submit rating ──────────────────────────────────────────────
  Future<Either<String, bool>> submitRating({
    required String consultationId,
    required String lawyerId,
    required String clientId,
    required int stars,
    String? comment,
  }) async {
    final result = await _dio.post(
      'client/ratings',
      body: {
        'consultationId': consultationId,
        'lawyerId': lawyerId,
        'clientId': clientId,
        'stars': stars,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
    if (result.isRight) return const Right(true);
    return Left(result.left.toString());
  }

  // ── Client: open dispute ───────────────────────────────────────────────
  Future<Either<String, bool>> openDispute({
    required String consultationId,
    required String reason,
    required String description,
    List<String> attachments = const [],
  }) async {
    final result = await _dio.post(
      'client/disputes',
      body: {
        'consultation': consultationId,
        'reason': reason,
        'description': description,
        'attachments': attachments,
      },
    );
    if (result.isRight) return const Right(true);
    return Left(result.left.toString());
  }
}