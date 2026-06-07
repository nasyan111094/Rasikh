// ─────────────────────────────────────────────────────────────────────────────
// video_call_cubit.dart
//
// Exact initialisation order:
//   0. Permission gate (camera + microphone)
//   1. POST  accept-instant
//   2. GET   instant-session
//   3. GET   rtc-token
//   4.       Agora.initialize()
//   5. POST  join-call
//   6.       Agora.joinChannel()
//   7.       Poll GET instant-session every 10 s
//
// Timer strategy:
//   • _localRemainingSeconds is seeded from the server the first time we
//     receive a non-null remainingSeconds (in _applySessionState or in
//     _initializeCall, whichever comes first).
//   • _startLocalTimer() begins the 1-second countdown.
//   • Polling NEVER overwrites _localRemainingSeconds; it only syncs the
//     server phase / two-minute-warning flag.
//   • When the timer hits 0 it emits VideoCallPhase.timerExpired so the UI
//     can show the summary dialog before fully ending.
//
// ID strategy:
//   • lawyerId / clientId can be passed in via the constructor as an
//     optional hint (e.g. from the consultation list screen).
//   • The server is the authoritative source: as soon as the first
//     instant-session response arrives, any non-null IDs from the server
//     overwrite the constructor values in state.
//   • Polling keeps the IDs up-to-date on every tick.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../repo/video_call_repo.dart';
import 'video_call_state.dart';

const int _kMaxReconnectAttempts = 3;
const Duration _kPollInterval = Duration(seconds: 10);

class VideoCallCubit extends Cubit<VideoCallState> {
  VideoCallCubit({
    required String consultationId,
    String? lawyerName,
    String? lawyerPhotoUrl,
    String? lawyerId,
    String? clientId,
  })  : _consultationId = consultationId,
        super(VideoCallState(
        lawyerName: lawyerName,
        lawyerPhotoUrl: lawyerPhotoUrl,
        lawyerId: lawyerId,
        clientId: clientId,
      ));

  // ── Private fields ──────────────────────────────────────────────────────
  final String _consultationId;
  final VideoCallRepo _repo = VideoCallRepo();

  RtcEngine? _engine;
  Timer? _pollTimer;
  Timer? _localTimer;

  /// The single source of truth for remaining seconds; never touched by
  /// polling — only by _startLocalTimer and _seedTimerIfNeeded.
  int? _localRemainingSeconds;

  /// Guard: once the local timer has been seeded + started we never restart
  /// it, even if the server later sends a remainingSeconds value.
  bool _timerStarted = false;

  // ── Public getters ───────────────────────────────────────────────────────
  RtcEngine? get engine => _engine;
  bool get isLawyer => _repo.userType == 'lawyer';

  // ─────────────────────────────────────────────────────────────────────────
  // Safe emit helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Emit while always preserving our locally-managed countdown value.
  void _emitKeepingTimer(VideoCallState newState) {
    if (isClosed) return;
    final secs = _localRemainingSeconds ?? state.remainingSeconds;
    emit(newState.copyWith(remainingSeconds: secs));
  }

  void _emitError(String message) {
    if (isClosed) return;
    _emitKeepingTimer(state.copyWith(
      phase: VideoCallPhase.error,
      errorMessage: message,
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Seed & start the local timer (idempotent — safe to call multiple times)
  // ─────────────────────────────────────────────────────────────────────────

  /// Call whenever we first get a non-null remainingSeconds from the server.
  /// Does nothing if the timer is already running.
  void _seedTimerIfNeeded(int? serverSeconds) {
    if (_timerStarted) return;              // already running, don't reseed
    if (serverSeconds == null) return;      // nothing to seed with yet
    if (serverSeconds <= 0) return;         // session already over

    _localRemainingSeconds = serverSeconds;
    _timerStarted = true;

    // Reflect the seeded value immediately in state
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
        // Emit 00:00 then signal timer expiry so the UI can show the dialog
        if (!isClosed) {
          emit(state.copyWith(
            remainingSeconds: 0,
            phase: VideoCallPhase.timerExpired,
          ));
        }
        return;
      }

      _localRemainingSeconds = current - 1;
      if (!isClosed) emit(state.copyWith(remainingSeconds: _localRemainingSeconds));
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PERMISSION GATE  (step 0)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Entry point called by the UI.
  Future<void> initialize() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    final missing = <Permission>[];
    if (!cameraStatus.isGranted) missing.add(Permission.camera);
    if (!micStatus.isGranted) missing.add(Permission.microphone);

    if (missing.isNotEmpty) {
      final permanentlyDenied =
          cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied;
      emit(state.copyWith(
        phase: permanentlyDenied
            ? VideoCallPhase.permissionPermanentlyDenied
            : VideoCallPhase.permissionDenied,
        missingPermissions: missing,
      ));
      return;
    }

    await _initializeCall();
  }

  /// Called by UI when the user taps "Allow" on the permission overlay.
  Future<void> requestPermissionsAndInitialize() async {
    final results = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final stillMissing = results.entries
        .where((e) => !e.value.isGranted)
        .map((e) => e.key)
        .toList();

    if (stillMissing.isEmpty) {
      await _initializeCall();
    } else {
      final anyPermanentlyDenied =
      results.values.any((s) => s.isPermanentlyDenied);
      emit(state.copyWith(
        phase: anyPermanentlyDenied
            ? VideoCallPhase.permissionPermanentlyDenied
            : VideoCallPhase.permissionDenied,
        missingPermissions: stillMissing,
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALISATION (steps 1–7)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _initializeCall() async {
    // ── Step 2: GET instant-session ────────────────────────────────────────
    final sessionResult = await _repo.fetchSession(_consultationId);
    if (sessionResult.isLeft()) {
      _emitError(
          'فشل جلب بيانات الجلسة: ${sessionResult.fold((l) => l, (r) => '')}');
      return;
    }

    final initialSession = sessionResult.fold((l) => null, (r) => r)!;
    if (initialSession.isEnded) {
      _emitKeepingTimer(state.copyWith(phase: VideoCallPhase.ended));
      return;
    }

    // ── Hydrate lawyerId / clientId from server (authoritative source) ─────
    // The server IDs always win; fall back to whatever was passed in the
    // constructor only when the server returns null.
    if (initialSession.lawyerId != null || initialSession.clientId != null) {
      if (!isClosed) {
        emit(state.copyWith(
          lawyerId: initialSession.lawyerId ?? state.lawyerId,
          clientId: initialSession.clientId ?? state.clientId,
        ));
      }
    }

    // Seed the local timer with whatever the server gave us. If the session
    // is already in_progress the server will return remainingSeconds; if it's
    // still in the waiting phase it may return null (timer seeds later once
    // inProgress is confirmed via polling / Agora onUserJoined).
    _seedTimerIfNeeded(initialSession.remainingSeconds);

    // ── Step 3: GET rtc-token ──────────────────────────────────────────────
    final tokenResult = await _repo.fetchRtcToken(_consultationId);
    if (tokenResult.isLeft()) {
      _emitError(
          'فشل الحصول على رمز الاتصال: ${tokenResult.fold((l) => l, (r) => '')}');
      return;
    }

    final rtcToken = tokenResult.fold((l) => null, (r) => r)!;
    _emitKeepingTimer(state.copyWith(rtcToken: rtcToken));

    // ── Step 4: Agora.initialize() ─────────────────────────────────────────
    final agoraReady = await _initAgora(rtcToken);
    if (!agoraReady) return;

    _emitKeepingTimer(state.copyWith(phase: VideoCallPhase.agoraReady));

    // ── Step 5: POST join-call ─────────────────────────────────────────────
    final joinResult = await _repo.joinCall(_consultationId);
    if (joinResult.isLeft()) {
      _emitError(
          'فشل الاتصال بالخادم: ${joinResult.fold((l) => l, (r) => '')}');
      return;
    }

    _emitKeepingTimer(state.copyWith(phase: VideoCallPhase.joiningCall));

    // ── Step 6: Agora.joinChannel() ────────────────────────────────────────
    await _joinAgoraChannel(rtcToken);

    // ── Step 7: start polling ──────────────────────────────────────────────
    _startPolling();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 4 – Agora initialisation
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> _initAgora(RtcTokenModel token) async {
    try {
      _engine = createAgoraRtcEngine();

      await _engine!.initialize(RtcEngineContext(
        appId: token.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      _registerEventHandlers();

      await _engine!.enableVideo();
      await _engine!.enableAudio();
      await _engine!.startPreview();

      try {
        await _engine!.setEnableSpeakerphone(true);
      } catch (_) {}

      return true;
    } catch (e) {
      _emitError('فشل تهيئة محرك الاتصال: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 6 – Join the Agora channel
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _joinAgoraChannel(RtcTokenModel token) async {
    await _engine!.joinChannel(
      token: token.token,
      channelId: token.channelName,
      uid: token.uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishMicrophoneTrack: true,
        publishCameraTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );

    _emitKeepingTimer(state.copyWith(phase: VideoCallPhase.waitingForLawyer));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AGORA EVENT HANDLERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _registerEventHandlers() {
    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {},
      onUserJoined: (connection, remoteUid, elapsed) {
        if (isClosed) return;
        _emitKeepingTimer(state.copyWith(
          remoteUid: remoteUid,
          phase: VideoCallPhase.inProgress,
          clearError: true,
        ));
      },
      onUserOffline: (connection, remoteUid, reason) {
        if (isClosed) return;
        // If the session is still active, show the waiting overlay again
        // (the lawyer may reconnect). If the session is ending, don't
        // change the phase so the end-flow is not interrupted.
        if (state.isSessionActive) {
          _emitKeepingTimer(state.copyWith(
            clearRemoteUid: true,
            phase: VideoCallPhase.waitingForLawyer,
          ));
        } else {
          _emitKeepingTimer(state.copyWith(clearRemoteUid: true));
        }
      },
      onUserMuteAudio: (connection, remoteUid, muted) {
        if (isClosed) return;
        _emitKeepingTimer(state.copyWith(isRemoteAudioMuted: muted));
      },
      onUserMuteVideo: (connection, remoteUid, muted) {
        if (isClosed) return;
        _emitKeepingTimer(state.copyWith(isRemoteVideoMuted: muted));
      },
      onNetworkQuality: (connection, remoteUid, txQuality, rxQuality) {
        if (isClosed) return;
        if (remoteUid == 0) {
          _emitKeepingTimer(
              state.copyWith(localNetworkQuality: txQuality.index));
        } else {
          _emitKeepingTimer(
              state.copyWith(remoteNetworkQuality: rxQuality.index));
        }
      },
      onConnectionStateChanged:
          (connection, connectionState, reason) async {
        if (isClosed) return;

        if (connectionState ==
            ConnectionStateType.connectionStateReconnecting &&
            state.phase != VideoCallPhase.ended &&
            state.phase != VideoCallPhase.timerExpired) {
          _emitKeepingTimer(
              state.copyWith(phase: VideoCallPhase.reconnecting));
        }

        if (connectionState ==
            ConnectionStateType.connectionStateConnected) {
          if (state.phase == VideoCallPhase.reconnecting) {
            _emitKeepingTimer(state.copyWith(
              phase: state.remoteUid != null
                  ? VideoCallPhase.inProgress
                  : VideoCallPhase.waitingForLawyer,
              reconnectAttempts: 0,
              clearError: true,
            ));
          }
        }

        if (connectionState ==
            ConnectionStateType.connectionStateFailed) {
          await _handleConnectionFailed();
        }
      },
      onTokenPrivilegeWillExpire: (connection, token) async {
        if (isClosed) return;
        final result = await _repo.fetchRtcToken(_consultationId);
        result.fold(
              (_) {},
              (newToken) async {
            _emitKeepingTimer(state.copyWith(rtcToken: newToken));
            await _engine?.renewToken(newToken.token);
          },
        );
      },
      onRequestToken: (connection) async {
        if (isClosed) return;
        final result = await _repo.fetchRtcToken(_consultationId);
        result.fold(
              (_) {},
              (newToken) async {
            _emitKeepingTimer(state.copyWith(rtcToken: newToken));
            await _engine?.renewToken(newToken.token);
          },
        );
      },
      onError: (err, msg) {
        if (isClosed) return;
        const ignoredErrors = [
          ErrorCodeType.errAdmInitPlayout,
          ErrorCodeType.errAdmInitRecording,
        ];
        if (ignoredErrors.contains(err)) return;
        _emitError('خطأ في الاتصال ($err): $msg');
      },
    ));
  }

  Future<void> _handleConnectionFailed() async {
    if (isClosed) return;

    final attempts = state.reconnectAttempts + 1;
    _emitKeepingTimer(state.copyWith(
      reconnectAttempts: attempts,
      phase: VideoCallPhase.reconnecting,
    ));

    if (attempts > _kMaxReconnectAttempts) {
      _emitError(
          'فشل الاتصال بعد $_kMaxReconnectAttempts محاولات إعادة اتصال');
      return;
    }

    await Future.delayed(Duration(seconds: attempts * 2));
    if (isClosed) return;

    final tokenResult = await _repo.fetchRtcToken(_consultationId);
    if (tokenResult.isLeft()) {
      _emitError('فشل تجديد رمز الاتصال');
      return;
    }

    final newToken = tokenResult.fold((l) => null, (r) => r)!;
    _emitKeepingTimer(state.copyWith(rtcToken: newToken));
    await _joinAgoraChannel(newToken);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 7 – Server session polling
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

  void _applySessionState(InstantSessionState session) {
    if (isClosed) return;

    // ── Server says session is over: stop EVERYTHING immediately ─────────
    // This takes priority over any local phase (including timerExpired).
    if (session.isEnded) {
      _pollTimer?.cancel();
      _pollTimer = null;
      _localTimer?.cancel();
      _localTimer = null;
      _localRemainingSeconds = 0;

      if (!isClosed) {
        emit(state.copyWith(
          phase: VideoCallPhase.ended,
          remainingSeconds: 0,
          // Preserve IDs even on the final ended state
          lawyerId: session.lawyerId ?? state.lawyerId,
          clientId: session.clientId ?? state.clientId,
        ));
      }

      // Full hard-stop in background — don't block the state update
      _cleanup();
      return;
    }

    // ── If we are already in a terminal phase, ignore further polls ───────
    if (state.phase == VideoCallPhase.timerExpired ||
        state.phase == VideoCallPhase.ended) return;

    // ── Seed local timer the first time the server gives us seconds ───────
    _seedTimerIfNeeded(session.remainingSeconds);

    // ── Derive phase transition ───────────────────────────────────────────
    VideoCallPhase? newPhase;

    if (session.isInProgress &&
        state.phase == VideoCallPhase.waitingForLawyer) {
      newPhase = VideoCallPhase.inProgress;
    } else if (session.instantTwoMinuteWarningActive &&
        state.phase == VideoCallPhase.inProgress) {
      newPhase = VideoCallPhase.twoMinuteWarning;
    } else if (!session.instantTwoMinuteWarningActive &&
        state.phase == VideoCallPhase.twoMinuteWarning) {
      newPhase = VideoCallPhase.inProgress;
    }

    // ── Update state — always keep IDs in sync from server ────────────────
    _emitKeepingTimer(state.copyWith(
      phase: newPhase,
      twoMinuteWarningActive: session.instantTwoMinuteWarningActive,
      lawyerId: session.lawyerId ?? state.lawyerId,
      clientId: session.clientId ?? state.clientId,
    ));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCAL CONTROLS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleMute() async {
    final muted = !state.isMuted;
    await _engine?.muteLocalAudioStream(muted);
    _emitKeepingTimer(state.copyWith(isMuted: muted));
  }

  Future<void> toggleCamera() async {
    final off = !state.isCameraOff;
    await _engine?.muteLocalVideoStream(off);
    _emitKeepingTimer(state.copyWith(isCameraOff: off));
  }

  Future<void> toggleSpeaker() async {
    final on = !state.isSpeakerOn;
    await _engine?.setEnableSpeakerphone(on);
    _emitKeepingTimer(state.copyWith(isSpeakerOn: on));
  }

  Future<void> flipCamera() async {
    await _engine?.switchCamera();
    _emitKeepingTimer(state.copyWith(isFrontCamera: !state.isFrontCamera));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // END SESSION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Hard-end: cleanup + emit ended. Used by user-initiated end and by the
  /// summary dialog after the lawyer submits (or skips) the summary.
  Future<void> endSession() async {
    await _cleanup();
    if (!isClosed) emit(state.copyWith(phase: VideoCallPhase.ended));
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
    // Stop timers first — no more ticks or polls during teardown
    _pollTimer?.cancel();
    _pollTimer = null;
    _localTimer?.cancel();
    _localTimer = null;

    final engine = _engine;
    _engine = null; // null immediately so no other method can touch it

    if (engine == null) return;

    try {
      // 1. Mute local tracks instantly — camera/mic indicator off NOW
      await engine.muteLocalAudioStream(true);
      await engine.muteLocalVideoStream(true);

      // 2. Stop camera preview
      await engine.stopPreview();

      // 3. Disable video & audio subsystems
      await engine.disableVideo();
      await engine.disableAudio();

      // 4. Leave channel — sends offline signal to remote peer
      await engine.leaveChannel();

      // 5. Full engine release — frees camera, mic, speaker hardware
      await engine.release();
    } catch (_) {
      // Swallow any teardown errors — session ends regardless
    }
  }

  @override
  Future<void> close() async {
    await _cleanup();
    return super.close();
  }
}