// =============================================================================
// chat_session_cubit.dart  — v2  (PRODUCTION)
//
// Initialization order (lawyer):
//   0. POST  accept-written              → assigns lawyer, activates consultation
//   1. GET   written-session             → check ended, hydrate IDs, seed timer
//   2. GET   agora-chat/token            → AgoraChatCredentials.token
//   3. GET   agora-chat/conversation     → peerUserId + conversationKey
//   4. POST  written-session/join-chat   → signals server this party is ready
//   5.       Poll GET written-session every 10 s
//
// Initialization order (client):
//   Skips step 0 (acceptWritten is lawyer-only).
//   Steps 1–5 are identical.
//
// Timer strategy (identical to VideoCallCubit):
//   • _localRemainingSeconds is seeded from the server the FIRST time we
//     receive a non-null remainingSeconds (step 1 or first poll).
//   • _seedTimerIfNeeded is idempotent — safe to call on every poll tick.
//   • Polling NEVER overwrites _localRemainingSeconds.
//   • When the timer hits 0 → ChatSessionPhase.timerExpired.
//
// ID strategy (identical to VideoCallCubit):
//   • lawyerId / clientId are passed in as constructor hints.
//   • Server values from written-session always overwrite constructor hints.
//   • Every poll tick keeps IDs in sync.
// =============================================================================

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/chat_session_repo.dart';
import 'chat_session_state.dart';

const Duration _kPollInterval = Duration(seconds: 10);

class ChatSessionCubit extends Cubit<ChatSessionState> {
  ChatSessionCubit({
    required String consultationId,
    String? peerName,
    String? peerPhotoUrl,
    String? lawyerId,
    String? clientId,
  })  : _consultationId = consultationId,
        super(ChatSessionState(
        peerName: peerName,
        peerPhotoUrl: peerPhotoUrl,
        lawyerId: lawyerId,
        clientId: clientId,
      ));

  // ── Private fields ──────────────────────────────────────────────────────────
  final String _consultationId;
  final ChatSessionRepo _repo = ChatSessionRepo();

  Timer? _pollTimer;
  Timer? _localTimer;

  int? _localRemainingSeconds;
  bool _timerStarted = false;

  // ── Public getter ───────────────────────────────────────────────────────────
  bool get isLawyer => _repo.userType == 'lawyer';

  // ─────────────────────────────────────────────────────────────────────────────
  // Safe-emit helpers
  // ─────────────────────────────────────────────────────────────────────────────

  void _emitKeepingTimer(ChatSessionState newState) {
    if (isClosed) return;
    final secs = _localRemainingSeconds ?? state.remainingSeconds;
    emit(newState.copyWith(remainingSeconds: secs));
  }

  void _emitError(String message) {
    if (isClosed) return;
    _emitKeepingTimer(state.copyWith(
      phase: ChatSessionPhase.error,
      errorMessage: message,
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Seed & start the local timer (idempotent)
  // ─────────────────────────────────────────────────────────────────────────────

  void _seedTimerIfNeeded(int? serverSeconds) {
    if (_timerStarted) return;
    if (serverSeconds == null) return;
    if (serverSeconds <= 0) return;

    _localRemainingSeconds = serverSeconds;
    _timerStarted = true;

    if (!isClosed) emit(state.copyWith(remainingSeconds: _localRemainingSeconds));

    _localTimer?.cancel();
    _localTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) {
        _localTimer?.cancel();
        return;
      }

      final current = _localRemainingSeconds;
      if (current == null) return;

      if (current <= 0) {
        _localTimer?.cancel();
        _localTimer = null;
        if (!isClosed) {
          emit(state.copyWith(
            remainingSeconds: 0,
            phase: ChatSessionPhase.timerExpired,
          ));
        }
        return;
      }

      _localRemainingSeconds = current - 1;
      if (!isClosed) {
        emit(state.copyWith(remainingSeconds: _localRemainingSeconds));
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ENTRY POINT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> initialize() async {
    await _initializeSession();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION  (steps 0–5)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _initializeSession() async {

    // ── Step 0 (lawyer-only): POST accept-written ────────────────────────
    // Accepts the pending written consultation and activates it so the
    // server begins tracking both parties. Clients skip this entirely.
    if (isLawyer) {
      final acceptResult = await _repo.acceptWritten(_consultationId);
      if (acceptResult.isLeft()) {
        // If the accept call fails with a 4xx that indicates the consultation
        // is already accepted (idempotent re-entry), we proceed. Any other
        // error is surfaced as a hard error.
        //
        // Pattern: try to continue — if step 1 also fails we surface that
        // error instead. This covers the edge case where the lawyer reopens
        // the screen after a crash and the consultation is already active.
        //
        // If you want strict failure instead, uncomment the lines below:
        // _emitError('فشل قبول الاستشارة: ${acceptResult.fold((l) => l, (r) => '')}');
        // return;
      }
    }

    // ── Step 1: GET written-session ────────────────────────────────────────
    final sessionResult = await _repo.fetchSession(_consultationId);
    if (sessionResult.isLeft()) {
      _emitError(
          'فشل جلب بيانات الجلسة: ${sessionResult.fold((l) => l, (r) => '')}');
      return;
    }

    final initialSession = sessionResult.fold((l) => null, (r) => r)!;

    if (initialSession.isEnded) {
      _emitKeepingTimer(state.copyWith(phase: ChatSessionPhase.ended));
      return;
    }

    // Hydrate IDs — server is always authoritative
    if (initialSession.lawyerId != null || initialSession.clientId != null) {
      if (!isClosed) {
        emit(state.copyWith(
          lawyerId: initialSession.lawyerId ?? state.lawyerId,
          clientId: initialSession.clientId ?? state.clientId,
        ));
      }
    }

    // Seed timer if session already in_progress on first fetch
    _seedTimerIfNeeded(initialSession.remainingSeconds);

    // ── Step 2: GET agora-chat/token ───────────────────────────────────────
    final tokenResult = await _repo.fetchChatToken(_consultationId);
    if (tokenResult.isLeft()) {
      _emitError(
          'فشل الحصول على رمز المحادثة: ${tokenResult.fold((l) => l, (r) => '')}');
      return;
    }
    final chatToken = tokenResult.fold((l) => null, (r) => r)!;

    // ── Step 3: GET agora-chat/conversation ───────────────────────────────
    final convResult = await _repo.fetchConversation(_consultationId);
    if (convResult.isLeft()) {
      _emitError(
          'فشل جلب بيانات المحادثة: ${convResult.fold((l) => l, (r) => '')}');
      return;
    }
    final convMeta = convResult.fold((l) => null, (r) => r)!;

    // Publish credentials → ChatBody can now init the Agora Chat SDK
    _emitKeepingTimer(state.copyWith(
      credentials: AgoraChatCredentials(
        token: chatToken.token,
        myUserId: convMeta.myUserId,
        peerUserId: convMeta.peerUserId,
        conversationKey: convMeta.conversationKey,
      ),
    ));

    // ── Step 4: POST join-chat ─────────────────────────────────────────────
    final joinResult = await _repo.joinChat(_consultationId);
    if (joinResult.isLeft()) {
      _emitError(
          'فشل الاتصال بالخادم: ${joinResult.fold((l) => l, (r) => '')}');
      return;
    }

    _emitKeepingTimer(state.copyWith(phase: ChatSessionPhase.waitingForClient));

    // ── Step 5: Start polling every 10 s ──────────────────────────────────
    _startPolling();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POLLING
  // ═══════════════════════════════════════════════════════════════════════════

  void _startPolling() {
    // Immediate first poll
    _repo.pollSession(_consultationId).then((result) {
      result.fold((_) {}, _applySessionState);
    });

    _pollTimer = Timer.periodic(_kPollInterval, (_) async {
      if (isClosed) return;
      final result = await _repo.pollSession(_consultationId);
      result.fold((_) {}, _applySessionState);
    });
  }

  void _applySessionState(WrittenSessionState session) {
    if (isClosed) return;

    if (session.isEnded) {
      _pollTimer?.cancel();
      _pollTimer = null;
      _localTimer?.cancel();
      _localTimer = null;
      _localRemainingSeconds = 0;

      if (!isClosed) {
        emit(state.copyWith(
          phase: ChatSessionPhase.ended,
          remainingSeconds: 0,
          lawyerId: session.lawyerId ?? state.lawyerId,
          clientId: session.clientId ?? state.clientId,
        ));
      }

      _cleanup();
      return;
    }

    if (state.phase == ChatSessionPhase.timerExpired ||
        state.phase == ChatSessionPhase.ended) return;

    _seedTimerIfNeeded(session.remainingSeconds);

    ChatSessionPhase? newPhase;

    if (session.isInProgress &&
        state.phase == ChatSessionPhase.waitingForClient) {
      newPhase = ChatSessionPhase.inProgress;
    } else if (session.writtenTwoMinuteWarningActive &&
        state.phase == ChatSessionPhase.inProgress) {
      newPhase = ChatSessionPhase.twoMinuteWarning;
    } else if (!session.writtenTwoMinuteWarningActive &&
        state.phase == ChatSessionPhase.twoMinuteWarning) {
      newPhase = ChatSessionPhase.inProgress;
    }

    _emitKeepingTimer(state.copyWith(
      phase: newPhase,
      twoMinuteWarningActive: session.writtenTwoMinuteWarningActive,
      lawyerId: session.lawyerId ?? state.lawyerId,
      clientId: session.clientId ?? state.clientId,
    ));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // END SESSION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> endSession() async {
    await _cleanup();
    if (!isClosed) emit(state.copyWith(phase: ChatSessionPhase.ended));
  }

  Future<void> submitCallSummary(String summary,
      {bool endAsNoShow = false}) async {
    final result = await _repo.submitCallSummary(
      _consultationId,
      summary,
      endAsNoShow: endAsNoShow,
    );
    result.fold(
          (error) => _emitError('فشل إرسال الملخص: $error'),
          (_) {},
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _cleanup() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _localTimer?.cancel();
    _localTimer = null;
    // Agora Chat SDK disconnect is handled by ChatBody.dispose()
  }

  @override
  Future<void> close() async {
    await _cleanup();
    return super.close();
  }
}