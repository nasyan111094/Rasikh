// ─────────────────────────────────────────────────────────────────────────────
// video_call_cubit.dart
//
// Exact initialisation order:
//   0. Permission gate (camera + microphone) — NEW
//   1. POST  accept-instant
//   2. GET   instant-session
//   3. GET   rtc-token
//   4.       Agora.initialize()
//   5. POST  join-call
//   6.       Agora.joinChannel()
//   7.       Poll GET instant-session every 5 s
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../repo/video_call_repo.dart';
import 'video_call_state.dart';

const int _kMaxReconnectAttempts = 3;
const Duration _kPollInterval = Duration(seconds: 5);

class VideoCallCubit extends Cubit<VideoCallState> {
  VideoCallCubit({
    required String consultationId,
    String? lawyerName,
    String? lawyerPhotoUrl,
  })  : _consultationId = consultationId,
        super(VideoCallState(
          lawyerName: lawyerName,
          lawyerPhotoUrl: lawyerPhotoUrl,
        ));

// ── Private fields ─────────────────────────────────────────────────────────
  final String _consultationId;
  final VideoCallRepo _repo = VideoCallRepo();

  RtcEngine? _engine;
  Timer? _pollTimer;

// ── Public getters (needed by the View to render video surfaces) ───────────
  RtcEngine? get engine => _engine;

// ═══════════════════════════════════════════════════════════════════════════
// PERMISSION GATE  (step 0)
// ═══════════════════════════════════════════════════════════════════════════

  /// Entry point called by the UI. Checks permissions before touching Agora.
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

// Permissions already granted → proceed with Agora init
    await _initializeCall();
  }

  /// Called by the UI when the user taps "Allow" on the permission overlay.
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
// ORIGINAL INITIALISATION (steps 1–7) — now private
// ═══════════════════════════════════════════════════════════════════════════

  Future<void> _initializeCall() async {
// ── Step 1: accept-instant ─────────────────────────────────────────────
// TODO: add your accept-instant call here if required

// ── Step 2: GET instant-session ────────────────────────────────────────
    final sessionResult = await _repo.fetchSession(_consultationId);
    if (sessionResult.isLeft()) {
      _emitError(
          'فشل جلب بيانات الجلسة: ${sessionResult.fold((l) => l, (r) => '')}');
      return;
    }

    final initialSession = sessionResult.fold((l) => null, (r) => r)!;
    if (initialSession.isEnded) {
      emit(state.copyWith(phase: VideoCallPhase.ended));
      return;
    }

    emit(state.copyWith(
      remainingSeconds: initialSession.remainingSeconds,
    ));

// ── Step 3: GET rtc-token ──────────────────────────────────────────────
    final tokenResult = await _repo.fetchRtcToken(_consultationId);
    if (tokenResult.isLeft()) {
      _emitError(
          'فشل الحصول على رمز الاتصال: ${tokenResult.fold((l) => l, (r) => '')}');
      return;
    }

    final rtcToken = tokenResult.fold((l) => null, (r) => r)!;
    emit(state.copyWith(rtcToken: rtcToken));

// ── Step 4: Agora.initialize() ─────────────────────────────────────────
    final agoraReady = await _initAgora(rtcToken);
    if (!agoraReady) return;

    emit(state.copyWith(phase: VideoCallPhase.agoraReady));

// ── Step 5: POST join-call ─────────────────────────────────────────────
    final joinResult = await _repo.joinCall(_consultationId);
    if (joinResult.isLeft()) {
      _emitError(
          'فشل الاتصال بالخادم: ${joinResult.fold((l) => l, (r) => '')}');
      return;
    }

    emit(state.copyWith(phase: VideoCallPhase.joiningCall));

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

    emit(state.copyWith(phase: VideoCallPhase.waitingForLawyer));
  }

// ═══════════════════════════════════════════════════════════════════════════
// AGORA EVENT HANDLERS
// ═══════════════════════════════════════════════════════════════════════════

  void _registerEventHandlers() {
    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {},
      onUserJoined: (connection, remoteUid, elapsed) {
        if (isClosed) return;
        emit(state.copyWith(
          remoteUid: remoteUid,
          phase: VideoCallPhase.inProgress,
          clearError: true,
        ));
      },
      onUserOffline: (connection, remoteUid, reason) {
        if (isClosed) return;
        emit(state.copyWith(clearRemoteUid: true));
      },
      onUserMuteAudio: (connection, remoteUid, muted) {
        if (isClosed) return;
        emit(state.copyWith(isRemoteAudioMuted: muted));
      },
      onUserMuteVideo: (connection, remoteUid, muted) {
        if (isClosed) return;
        emit(state.copyWith(isRemoteVideoMuted: muted));
      },
      onNetworkQuality: (connection, remoteUid, txQuality, rxQuality) {
        if (isClosed) return;
        if (remoteUid == 0) {
          emit(state.copyWith(localNetworkQuality: txQuality.index));
        } else {
          emit(state.copyWith(remoteNetworkQuality: rxQuality.index));
        }
      },
      onConnectionStateChanged: (connection, connectionState, reason) async {
        if (isClosed) return;

        if (connectionState ==
                ConnectionStateType.connectionStateReconnecting &&
            state.phase != VideoCallPhase.ended) {
          emit(state.copyWith(phase: VideoCallPhase.reconnecting));
        }

        if (connectionState == ConnectionStateType.connectionStateConnected) {
          if (state.phase == VideoCallPhase.reconnecting) {
            emit(state.copyWith(
              phase: state.remoteUid != null
                  ? VideoCallPhase.inProgress
                  : VideoCallPhase.waitingForLawyer,
              reconnectAttempts: 0,
              clearError: true,
            ));
          }
        }

        if (connectionState == ConnectionStateType.connectionStateFailed) {
          await _handleConnectionFailed();
        }
      },
      onTokenPrivilegeWillExpire: (connection, token) async {
        if (isClosed) return;
        final result = await _repo.fetchRtcToken(_consultationId);
        result.fold(
          (_) {},
          (newToken) async {
            emit(state.copyWith(rtcToken: newToken));
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
            emit(state.copyWith(rtcToken: newToken));
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
    emit(state.copyWith(
      reconnectAttempts: attempts,
      phase: VideoCallPhase.reconnecting,
    ));

    if (attempts > _kMaxReconnectAttempts) {
      _emitError('فشل الاتصال بعد $_kMaxReconnectAttempts محاولات إعادة اتصال');
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
    emit(state.copyWith(rtcToken: newToken));
    await _joinAgoraChannel(newToken);
  }

// ═══════════════════════════════════════════════════════════════════════════
// STEP 7 – Server session polling
// ═══════════════════════════════════════════════════════════════════════════

  void _startPolling() {
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

    VideoCallPhase? newPhase;

    if (session.isEnded) {
      newPhase = VideoCallPhase.ended;
    } else if (session.isInProgress &&
        state.phase == VideoCallPhase.waitingForLawyer) {
      newPhase = VideoCallPhase.inProgress;
    } else if (session.instantTwoMinuteWarningActive &&
        state.phase == VideoCallPhase.inProgress) {
      newPhase = VideoCallPhase.twoMinuteWarning;
    } else if (!session.instantTwoMinuteWarningActive &&
        state.phase == VideoCallPhase.twoMinuteWarning) {
      newPhase = VideoCallPhase.inProgress;
    }

    emit(state.copyWith(
      phase: newPhase,
      remainingSeconds: session.remainingSeconds,
      twoMinuteWarningActive: session.instantTwoMinuteWarningActive,
    ));

    if (session.isEnded) _cleanup();
  }

// ═══════════════════════════════════════════════════════════════════════════
// LOCAL CONTROLS
// ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleMute() async {
    final muted = !state.isMuted;
    await _engine?.muteLocalAudioStream(muted);
    emit(state.copyWith(isMuted: muted));
  }

  Future<void> toggleCamera() async {
    final off = !state.isCameraOff;
    await _engine?.muteLocalVideoStream(off);
    emit(state.copyWith(isCameraOff: off));
  }

  Future<void> toggleSpeaker() async {
    final on = !state.isSpeakerOn;
    await _engine?.setEnableSpeakerphone(on);
    emit(state.copyWith(isSpeakerOn: on));
  }

  Future<void> flipCamera() async {
    await _engine?.switchCamera();
    emit(state.copyWith(isFrontCamera: !state.isFrontCamera));
  }

// ═══════════════════════════════════════════════════════════════════════════
// END SESSION (user-initiated)
// ═══════════════════════════════════════════════════════════════════════════

  Future<void> endSession() async {
    await _cleanup();
    emit(state.copyWith(phase: VideoCallPhase.ended));
  }

// ═══════════════════════════════════════════════════════════════════════════
// CLEANUP
// ═══════════════════════════════════════════════════════════════════════════

  Future<void> _cleanup() async {
    _pollTimer?.cancel();
    _pollTimer = null;

    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }

  void _emitError(String message) {
    if (isClosed) return;
    emit(state.copyWith(
      phase: VideoCallPhase.error,
      errorMessage: message,
    ));
  }

  @override
  Future<void> close() async {
    await _cleanup();
    return super.close();
  }
}
