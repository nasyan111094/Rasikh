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

  const InstantSessionState({
    required this.consultationId,
    required this.serverTime,
    required this.phase,
    this.remainingSeconds,
    this.sessionStartedAt,
    this.sessionEndsAt,
    this.instantTwoMinuteWarningActive = false,
    this.canLawyerEndAsNoShow = false,
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
      );

  bool get isInProgress => phase == 'in_progress';
  bool get isWaiting =>
      phase == 'waiting_call' || phase == 'waiting' || phase == 'accepted';
  bool get isEnded =>
      phase == 'ended' || phase == 'completed' || phase == 'no_show';
}

// ── Repository ─────────────────────────────────────────────────────────────

class VideoCallRepo {
  final DioAdapterBase _dio = getIt.get<ApiHandler>().dioAdapterBase;

  String get _userType =>
      getIt<CacheHelper>().cachedVendorType == VendorType.user
          ? 'client'
          : 'lawyer';



  // ── Step 2: instant-session (initial fetch) ────────────────────────────
  Future<Either<String, InstantSessionState>> fetchSession(
      String consultationId) async {
    final result = await _dio.get(
      '$_userType/consultations/$consultationId/instant-session',
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
      '$_userType/consultations/$consultationId/rtc-token',
    );
    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(RtcTokenModel.fromJson(data));
    }
    return Left(result.left.toString());
  }

  // ── Step 5: join-call ──────────────────────────────────────────────────
  Future<Either<String, bool>> joinCall(String consultationId) async {
    final result = await _dio.post(
      '$_userType/consultations/$consultationId/instant-session/join-call',
      body: {},
    );
    if (result.isRight) return const Right(true);
    return Left(result.left.toString());
  }

  // ── Step 7: polling ────────────────────────────────────────────────────
  Future<Either<String, InstantSessionState>> pollSession(
      String consultationId) async {
    final result = await _dio.get(
      '$_userType/consultations/$consultationId/instant-session',
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
    if (_userType != 'lawyer') return const Left('Only lawyer can call this');
    final result = await _dio.post(
      '$_userType/consultations/$consultationId/rtc/reconnected',
      body: {},
    );
    if (result.isRight) return const Right(true);
    return Left(result.left.toString());
  }

  Future<Either<String, bool>> notifyLawyerDisconnected(
      String consultationId) async {
    if (_userType != 'lawyer') return const Left('Only lawyer can call this');
    final result = await _dio.post(
      '$_userType/consultations/$consultationId/rtc/disconnected',
      body: {},
    );
    if (result.isRight) return const Right(true);
    return Left(result.left.toString());
  }
}