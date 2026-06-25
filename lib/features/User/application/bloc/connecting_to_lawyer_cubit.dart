// ─────────────────────────────────────────────────────────────────────────────
// connecting_to_lawyer_cubit.dart
//
// Owns the "waiting room" polling loop that used to live directly inside
// ConnectingToLawyerScreen's State object. Pulled out into a Cubit so it
// follows the same pattern as ChatSessionCubit / VideoCallCubit:
//   • All async/timer logic lives in the cubit, not the widget.
//   • The widget only reacts to phase changes via BlocConsumer.
//   • isClosed is checked before every emit so a disposed cubit never throws.
//
// Polling:
//   • Every 3 s, fetch the session for the relevant consultation type.
//   • isEnded       → stop polling, phase = ended (consultation cancelled/expired)
//   • isInProgress  → stop polling, phase = joined (the OTHER party has now
//     entered the call/chat — isInProgress only flips once BOTH sides are
//     present, same flag ChatSessionCubit/VideoCallCubit wait for before
//     leaving their own "waiting" phase). isWaiting alone is NOT enough —
//     it just means the session exists and hasn't ended, and can be true
//     while we are still alone in the room.
//   • Otherwise     → keep waiting.
//
// Timeout:
//   • If no join happens within _kMaxWaitDuration, stop polling and emit
//     phase = timedOut so the UI can offer "Cancel" / "Try again" instead of
//     spinning forever.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/models/consultation_model.dart';
import '../../application/repo/chat_session_repo.dart';
import '../../application/repo/video_call_repo.dart';
import 'connecting_to_lawyer_state.dart';

const Duration _kPollInterval = Duration(seconds: 3);
const Duration _kMaxWaitDuration = Duration(minutes: 3);

class ConnectingToLawyerCubit extends Cubit<ConnectingToLawyerState> {
  ConnectingToLawyerCubit({
    required String consultationId,
    required ConsultationType consultationType,
    ChatSessionRepo? chatRepo,
    VideoCallRepo? videoRepo,
  })  : _consultationId = consultationId,
        _consultationType = consultationType,
        _chatRepo = chatRepo ?? ChatSessionRepo(),
        _videoRepo = videoRepo ?? VideoCallRepo(),
        super(const ConnectingToLawyerState());

  final String _consultationId;
  final ConsultationType _consultationType;
  final ChatSessionRepo _chatRepo;
  final VideoCallRepo _videoRepo;

  Timer? _pollTimer;
  Timer? _timeoutTimer;

  // ═══════════════════════════════════════════════════════════════════════
  // ENTRY POINT
  // ═══════════════════════════════════════════════════════════════════════

  void start() {
    _startTimeoutTimer();
    _startPolling();
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_kMaxWaitDuration, () {
      if (isClosed) return;
      if (state.phase != ConnectingPhase.waiting) return;
      _stopAllTimers();
      emit(state.copyWith(phase: ConnectingPhase.timedOut));
    });
  }

  void _startPolling() {
    // Immediate first check, then every 3 s.
    _pollOnce();
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (isClosed) return;
    if (state.phase != ConnectingPhase.waiting) return;

    final isWritten = _consultationType == ConsultationType.written;

    // isInProgress is the server's signal that BOTH parties are present —
    // it's the exact flag chat_session_cubit/video_call_cubit wait for
    // before flipping waitingForClient/waitingForLawyer → inProgress.
    // isWaiting only means "session exists, not ended yet" and can be true
    // while we are still alone in the room, so it must NOT be treated as
    // "the other party joined" — that was the bug causing early navigation.
    bool otherPartyJoined = false;
    bool consultationEnded = false;
    String? error;

    if (isWritten) {
      final result = await _chatRepo.fetchSession(_consultationId);
      result.fold(
            (l) => error = l,
            (session) {
          consultationEnded = session.isEnded;
          otherPartyJoined = session.isInProgress;
        },
      );
    } else {
      final result = await _videoRepo.fetchSession(_consultationId, null);
      result.fold(
            (l) => error = l,
            (session) {
          consultationEnded = session.isEnded;
          otherPartyJoined = session.isInProgress;
        },
      );
    }

    if (isClosed) return;
    if (state.phase != ConnectingPhase.waiting) return;

    if (consultationEnded) {
      _stopAllTimers();
      emit(state.copyWith(phase: ConnectingPhase.ended));
      return;
    }

    if (otherPartyJoined) {
      _stopAllTimers();
      emit(state.copyWith(phase: ConnectingPhase.joined));
      return;
    }

    // Track attempts for the UI (e.g. show "still searching" copy after a
    // while) but don't treat a single transient failure as fatal — only
    // surface it if it keeps failing.
    if (error != null) {
      final failedAttempts = state.attempts + 1;
      // Surface the error once it's failed several times in a row so a
      // single dropped request doesn't interrupt the waiting UI.
      if (failedAttempts >= 3) {
        _stopAllTimers();
        emit(state.copyWith(
          phase: ConnectingPhase.error,
          errorMessage: error,
          attempts: failedAttempts,
        ));
        return;
      }
      emit(state.copyWith(attempts: failedAttempts));
      return;
    }

    emit(state.copyWith(attempts: state.attempts + 1, clearError: true));
  }

  // ═══════════════════════════════════════════════════════════════════════
  // RETRY  (used by the UI when phase == error / timedOut)
  // ═══════════════════════════════════════════════════════════════════════

  void retry() {
    if (!isClosed) emit(const ConnectingToLawyerState());
    start();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════

  void _stopAllTimers() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  @override
  Future<void> close() {
    _stopAllTimers();
    return super.close();
  }
}