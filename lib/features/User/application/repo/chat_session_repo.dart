// =============================================================================
// chat_session_repo.dart  — v2  (PRODUCTION)
//
// API endpoints covered:
//   POST {role}/consultations/{id}/accept-written               → bool  (NEW)
//   GET  {role}/consultations/{id}/written-session              → WrittenSessionState
//   GET  {role}/consultations/{id}/agora-chat/token             → AgoraChatTokenModel
//   GET  {role}/consultations/{id}/agora-chat/conversation      → ConversationMetaModel
//   POST {role}/consultations/{id}/written-session/join-chat    → bool
//   GET  {role}/consultations/{id}/written-session  (poll)      → WrittenSessionState
//   POST lawyer/consultations/{id}/complete                     → bool
//   POST client/ratings                                         → bool
//   POST client/disputes                                        → bool
// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:dio_adapter/dio_adapter.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';

import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/api/api_handler.dart';


// ── Written-session polling model ──────────────────────────────────────────

class WrittenSessionState {
  final String consultationId;
  final DateTime serverTime;
  final String phase;
  final int? remainingSeconds;
  final DateTime? sessionStartedAt;
  final DateTime? sessionEndsAt;
  final bool writtenTwoMinuteWarningActive;
  final bool canLawyerEndAsNoShow;
  final String? noShowEligibleAfter;

  // IDs hydrated from the server
  final String? lawyerId;
  final String? clientId;

  const WrittenSessionState({
    required this.consultationId,
    required this.serverTime,
    required this.phase,
    this.remainingSeconds,
    this.sessionStartedAt,
    this.sessionEndsAt,
    this.writtenTwoMinuteWarningActive = false,
    this.canLawyerEndAsNoShow = false,
    this.noShowEligibleAfter,
    this.lawyerId,
    this.clientId,
  });

  factory WrittenSessionState.fromJson(Map<String, dynamic> json) =>
      WrittenSessionState(
        consultationId: json['consultationId'] as String? ?? '',
        serverTime: DateTime.tryParse(json['serverTime'] as String? ?? '') ??
            DateTime.now(),
        phase: json['phase'] as String? ?? 'waiting_chat',
        remainingSeconds: json['remainingSeconds'] as int?,
        sessionStartedAt: json['sessionStartedAt'] != null
            ? DateTime.tryParse(json['sessionStartedAt'] as String)
            : null,
        sessionEndsAt: json['sessionEndsAt'] != null
            ? DateTime.tryParse(json['sessionEndsAt'] as String)
            : null,
        writtenTwoMinuteWarningActive:
        json['writtenTwoMinuteWarningActive'] as bool? ?? false,
        canLawyerEndAsNoShow: json['canLawyerEndAsNoShow'] as bool? ?? false,
        noShowEligibleAfter: json['noShowEligibleAfter'] as String?,
        lawyerId: json['lawyerId'] as String?,
        clientId: json['clientId'] as String?,
      );

  bool get isInProgress => phase == 'in_progress' || phase == 'in_session';

  bool get isWaiting =>
      phase == 'waiting_chat' || phase == 'waiting' || phase == 'accepted';

  bool get isEnded =>
      phase == 'ended' || phase == 'completed' || phase == 'no_show';
}

// ── Agora Chat token model ─────────────────────────────────────────────────

class AgoraChatTokenModel {
  final String token;
  final DateTime? expiresAt;

  const AgoraChatTokenModel({required this.token, this.expiresAt});

  factory AgoraChatTokenModel.fromJson(Map<String, dynamic> json) =>
      AgoraChatTokenModel(
        token: (json['token'] ?? json['chatToken'] ?? '') as String,
        expiresAt: json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'] as String)
            : null,
      );
}

// ── Conversation metadata model ─────────────────────────────────────────────

class ConversationMetaModel {
  final String myUserId;
  final String peerUserId;
  final String conversationKey;

  const ConversationMetaModel({
    required this.myUserId,
    required this.peerUserId,
    required this.conversationKey,
  });

  factory ConversationMetaModel.fromJson(Map<String, dynamic> json) =>
      ConversationMetaModel(
        myUserId: (json['myUserId'] ?? json['userId'] ?? '') as String,
        peerUserId: (json['peerUserId'] ??
            json['peerId'] ??
            json['peerAgoraId'] ??
            '') as String,
        conversationKey: (json['conversationKey'] ??
            json['channelName'] ??
            json['channel'] ??
            '') as String,
      );
}

// ── Repository ─────────────────────────────────────────────────────────────

class ChatSessionRepo {
  final DioAdapterBase _dio = getIt.get<ApiHandler>().dioAdapterBase;

  String get userType =>
      getIt<CacheHelper>().cachedVendorType == VendorType.user
          ? 'client'
          : 'lawyer';

  // ── Step 0 (lawyer-only): POST accept-written ──────────────────────────
  //
  // Called BEFORE opening the chat UI. Accepts a pending paid written
  // consultation, assigns the lawyer and sets the status to active.
  //
  // The cubit should call this once when the lawyer taps "Accept" on the
  // consultation list; the result gates whether to navigate to ChatScreenSession.
  Future<Either<String, bool>> acceptWritten(String consultationId) async {
    if (userType != 'lawyer') {
      return const Left('Only a lawyer can accept a written consultation');
    }
    final result = await _dio.post(
      'lawyer/consultations/$consultationId/accept-written',
      body: {},
    );
    if (result.isRight) return const Right(true);
    return Left(result.left.toString());
  }

  // ── Step 1: GET written-session ────────────────────────────────────────
  Future<Either<String, WrittenSessionState>> fetchSession(
      String consultationId) async {
    final result = await _dio.get(
      '$userType/consultations/$consultationId/written-session',
    );
    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(WrittenSessionState.fromJson(data));
    }
    return Left(result.left.toString());
  }

  // ── Step 2: GET agora-chat/token ───────────────────────────────────────
  Future<Either<String, AgoraChatTokenModel>> fetchChatToken(
      String consultationId) async {
    final result = await _dio.get(
      '$userType/consultations/$consultationId/agora-chat/token',
    );
    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(AgoraChatTokenModel.fromJson(data));
    }
    return Left(result.left.toString());
  }

  // ── Step 3: GET agora-chat/conversation ───────────────────────────────
  Future<Either<String, ConversationMetaModel>> fetchConversation(
      String consultationId) async {
    final result = await _dio.get(
      '$userType/consultations/$consultationId/agora-chat/conversation',
    );
    if (result.isRight) {
      final data = result.right.data['data'] as Map<String, dynamic>;
      return Right(ConversationMetaModel.fromJson(data));
    }
    return Left(result.left.toString());
  }

  // ── Step 4: POST join-chat ─────────────────────────────────────────────
  Future<Either<String, bool>> joinChat(String consultationId) async {
    final result = await _dio.post(
      '$userType/consultations/$consultationId/written-session/join-chat',
      body: {},
    );
    if (result.isRight) return const Right(true);
    return Left(result.left.toString());
  }

  // ── Polling (every 10 s) — same endpoint as fetchSession ──────────────
  Future<Either<String, WrittenSessionState>> pollSession(
      String consultationId) async {
    return fetchSession(consultationId);
  }

  // ── Lawyer: submit call summary ────────────────────────────────────────
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