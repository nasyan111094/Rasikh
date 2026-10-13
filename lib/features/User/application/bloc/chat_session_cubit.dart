
import 'package:rasikh/config/localization/loc_keys.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/chat_session_repo.dart';
import 'chat_session_state.dart';

const Duration _kPollInterval = Duration(seconds: 10);
const Duration _kMaxWaitDuration = Duration(minutes: 3);
const int _kMaxTokenRenewFailures = 3;

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

  final String _consultationId;
  final ChatSessionRepo _repo = ChatSessionRepo();

  Timer? _pollTimer;
  Timer? _localTimer;
  Timer? _timeoutTimer;
  Timer? _chatTokenRenewTimer;
  int _chatTokenFailures = 0;

  int? _localRemainingSeconds;
  bool _timerStarted = false;

  bool get isLawyer => _repo.userType == 'lawyer';


  void _emitKeepingTimer(ChatSessionState newState) {
    if (isClosed) return;
    final secs = _localRemainingSeconds ?? state.remainingSeconds;
    emit(newState.copyWith(remainingSeconds: secs));
  }

  void _emitError(String message) {
    if (isClosed) return;
    _stopPolling();
    _emitKeepingTimer(state.copyWith(
      phase: ChatSessionPhase.error,
      errorMessage: message,
    ));
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void _resyncTimerIfDrifted(int? serverSeconds) {
    if (!_timerStarted) return;
    if (serverSeconds == null || serverSeconds < 0) return;
    final local = _localRemainingSeconds;
    if (local == null) return;
    if ((serverSeconds - local).abs() > 5) {
      _localRemainingSeconds = serverSeconds;
      if (!isClosed) emit(state.copyWith(remainingSeconds: serverSeconds));
    }
  }


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
        _stopPolling();
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


  Future<void> initialize() async {
    await _initializeSession();
  }


  Future<void> _initializeSession() async {

    if (isLawyer) {
      final acceptResult = await _repo.acceptWritten(_consultationId);
      if (acceptResult.isLeft()) {
        _emitError(
            Loc.fetchSessionDataFailed(acceptResult.fold((l) => l, (r) => '')));
        return;
      }
    }

    final sessionResult = await _repo.fetchSession(_consultationId);
    if (sessionResult.isLeft()) {
      _emitError(
          Loc.fetchSessionDataFailed(sessionResult.fold((l) => l, (r) => '')));
      return;
    }

    final initialSession = sessionResult.fold((l) => null, (r) => r)!;

    if (initialSession.isEnded) {
      _emitKeepingTimer(state.copyWith(phase: ChatSessionPhase.ended));
      return;
    }

    if (initialSession.lawyerId != null || initialSession.clientId != null) {
      if (!isClosed) {
        emit(state.copyWith(
          lawyerId: initialSession.lawyerId ?? state.lawyerId,
          clientId: initialSession.clientId ?? state.clientId,
          canLawyerEndAsNoShow: initialSession.canLawyerEndAsNoShow,
          noShowEligibleAfter: initialSession.noShowEligibleAfter,
        ));
      }
    }

    _seedTimerIfNeeded(initialSession.remainingSeconds);

    final tokenResult = await _repo.fetchChatToken(_consultationId);
    if (tokenResult.isLeft()) {
      _emitError(
          Loc.getChatTokenFailed(tokenResult.fold((l) => l, (r) => '')));
      return;
    }
    final chatToken = tokenResult.fold((l) => null, (r) => r)!;

    final convResult = await _repo.fetchConversation(_consultationId);
    if (convResult.isLeft()) {
      _emitError(
          Loc.fetchChatDataFailed(convResult.fold((l) => l, (r) => '')));
      return;
    }
    final convMeta = convResult.fold((l) => null, (r) => r)!;

    _emitKeepingTimer(state.copyWith(
      credentials: AgoraChatCredentials(
        token: chatToken.token,
        myUserId: convMeta.myUserId,
        peerUserId: convMeta.peerUserId,
        conversationKey: convMeta.conversationKey,
      ),
    ));
    _scheduleChatTokenRenewal(chatToken.expiresAt);

    final joinResult = await _repo.joinChat(_consultationId);
    if (joinResult.isLeft()) {
      _emitError(
          Loc.serverConnectionFailed(joinResult.fold((l) => l, (r) => '')));
      return;
    }

    _emitKeepingTimer(state.copyWith(phase: ChatSessionPhase.waitingForClient));

    _startPolling();
  }


  void _startPolling() {
    _repo.pollSession(_consultationId).then((result) {
      result.fold((_) {}, _applySessionState);
    });

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_kMaxWaitDuration, () {
      if (isClosed) return;
      if (state.phase != ChatSessionPhase.waitingForClient &&
          state.phase != ChatSessionPhase.initializing) return;
      _stopPolling();
      _localTimer?.cancel();
      _localTimer = null;
      _localRemainingSeconds = 0;
      if (!isClosed) {
        emit(state.copyWith(
          remainingSeconds: 0,
          phase: ChatSessionPhase.timerExpired,
        ));
      }
    });

    _pollTimer = Timer.periodic(_kPollInterval, (_) async {
      if (isClosed) return;
      final result = await _repo.pollSession(_consultationId);
      result.fold((_) {}, _applySessionState);
    });
  }

  void _scheduleChatTokenRenewal(DateTime? expiresAt) {
    _chatTokenRenewTimer?.cancel();
    _chatTokenRenewTimer = null;
    if (expiresAt == null) return;
    var lead = expiresAt.difference(DateTime.now()) - const Duration(seconds: 60);
    if (lead.isNegative) lead = const Duration(seconds: 30);
    _chatTokenRenewTimer = Timer(lead, () async {
      if (isClosed) return;
      final result = await _repo.fetchChatToken(_consultationId);
      result.fold(
        (_) {
          _chatTokenFailures++;
          if (_chatTokenFailures >= _kMaxTokenRenewFailures) {
            _emitError(Loc.getChatTokenFailed(''));
          } else {
            _scheduleChatTokenRenewal(
                DateTime.now().add(const Duration(seconds: 30)));
          }
        },
        (newToken) {
          _chatTokenFailures = 0;
          final creds = state.credentials;
          if (creds != null && !isClosed) {
            _emitKeepingTimer(state.copyWith(
              credentials: AgoraChatCredentials(
                token: newToken.token,
                myUserId: creds.myUserId,
                peerUserId: creds.peerUserId,
                conversationKey: creds.conversationKey,
              ),
            ));
          }
          _scheduleChatTokenRenewal(newToken.expiresAt);
        },
      );
    });
  }

  void _applySessionState(WrittenSessionState session) {
    if (isClosed) return;

    if (session.isEnded) {
      _stopPolling();
      _localTimer?.cancel();
      _localTimer = null;
      _localRemainingSeconds = 0;

      if (!isClosed) {
        emit(state.copyWith(
          phase: ChatSessionPhase.ended,
          remainingSeconds: 0,
          lawyerId: session.lawyerId ?? state.lawyerId,
          clientId: session.clientId ?? state.clientId,
          canLawyerEndAsNoShow: session.canLawyerEndAsNoShow,
          noShowEligibleAfter: session.noShowEligibleAfter,
        ));
      }

      _cleanup();
      return;
    }

    if (state.phase == ChatSessionPhase.timerExpired ||
        state.phase == ChatSessionPhase.ended) return;

    _seedTimerIfNeeded(session.remainingSeconds);
    _resyncTimerIfDrifted(session.remainingSeconds);

    ChatSessionPhase? newPhase;

    if (session.isInProgress &&
        (state.phase == ChatSessionPhase.waitingForClient ||
            state.phase == ChatSessionPhase.initializing)) {
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
      canLawyerEndAsNoShow: session.canLawyerEndAsNoShow,
      noShowEligibleAfter: session.noShowEligibleAfter,
    ));
  }


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
          (error) => _emitError(Loc.sendSummaryFailed(error)),
          (_) {},
    );
  }


  Future<void> _cleanup() async {
    _stopPolling();
    _localTimer?.cancel();
    _localTimer = null;
    _chatTokenRenewTimer?.cancel();
    _chatTokenRenewTimer = null;
  }

  @override
  Future<void> close() async {
    await _cleanup();
    return super.close();
  }
}