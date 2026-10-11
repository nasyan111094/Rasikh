
import 'package:rasikh/config/localization/loc_keys.dart';
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
    String ? consultationtype  ,

  })  : _consultationId = consultationId, _consultationType = consultationtype ,
        super(VideoCallState(
        lawyerName: lawyerName,
        lawyerPhotoUrl: lawyerPhotoUrl,
        lawyerId: lawyerId,
        clientId: clientId,
      ));

  final String _consultationId;
  String ? _consultationType ;
  final VideoCallRepo _repo = VideoCallRepo();

  RtcEngine? _engine;
  Timer? _pollTimer;
  Timer? _localTimer;

  int? _localRemainingSeconds;

  bool _timerStarted = false;

  RtcEngine? get engine => _engine;
  bool get isLawyer => _repo.userType == 'lawyer';


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
            phase: VideoCallPhase.timerExpired,
          ));
        }
        return;
      }

      _localRemainingSeconds = current - 1;
      if (!isClosed) emit(state.copyWith(remainingSeconds: _localRemainingSeconds));
    });
  }


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


  Future<void> _initializeCall() async {
    final sessionResult = await _repo.fetchSession(_consultationId , _consultationType);
    if (sessionResult.isLeft()) {
      _emitError(
          Loc.fetchSessionDataFailed(sessionResult.fold((l) => l, (r) => '')));
      return;
    }

    final initialSession = sessionResult.fold((l) => null, (r) => r)!;
    if (initialSession.isEnded) {
      _emitKeepingTimer(state.copyWith(phase: VideoCallPhase.ended));
      return;
    }

    if (initialSession.lawyerId != null || initialSession.clientId != null) {
      if (!isClosed) {
        emit(state.copyWith(
          lawyerId: initialSession.lawyerId ?? state.lawyerId,
          clientId: initialSession.clientId ?? state.clientId,
        ));
      }
    }

    _seedTimerIfNeeded(initialSession.remainingSeconds);

    final tokenResult = await _repo.fetchRtcToken(_consultationId);
    if (tokenResult.isLeft()) {
      _emitError(
          Loc.getCallTokenFailed(tokenResult.fold((l) => l, (r) => '')));
      return;
    }

    final rtcToken = tokenResult.fold((l) => null, (r) => r)!;
    _emitKeepingTimer(state.copyWith(rtcToken: rtcToken));

    final agoraReady = await _initAgora(rtcToken);
    if (!agoraReady) return;

    _emitKeepingTimer(state.copyWith(phase: VideoCallPhase.agoraReady));

    final joinResult = await _repo.joinCall(_consultationId, _consultationType);
    final alreadyJoined = joinResult.isLeft() &&
        _isAlreadyJoinedError(joinResult.fold((l) => l, (r) => ''));

    if (joinResult.isLeft() && !alreadyJoined) {
      _emitError(
          Loc.serverConnectionFailed(joinResult.fold((l) => l, (r) => '')));
      return;
    }

    _emitKeepingTimer(state.copyWith(phase: VideoCallPhase.joiningCall));

    if (alreadyJoined) {
      try {
        await _engine?.leaveChannel();
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 500));
    }

    await _joinAgoraChannel(rtcToken);

    _startPolling();

    if (isLawyer) {
      _repo.notifyLawyerReconnected(_consultationId);
    }
  }


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
      _emitError(Loc.callEngineInitFailed(e));
      return false;
    }
  }


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
        _emitError(Loc.connectionErrorWithCode(err, msg));
      },
    ));
  }

  bool _isAlreadyJoinedError(String error) {
    final lower = error.toLowerCase();
    return lower.contains('already') ||
        lower.contains('already joined') ||
        lower.contains('already in call') ||
        lower.contains('duplicate') ||
        lower.contains('مسبقاً') ||
        lower.contains('مسبقا');
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
          Loc.reconnectFailedAfterAttempts(_kMaxReconnectAttempts));
      return;
    }

    await Future.delayed(Duration(seconds: attempts * 2));
    if (isClosed) return;

    final tokenResult = await _repo.fetchRtcToken(_consultationId);
    if (tokenResult.isLeft()) {
      _emitError(Loc.renewCallTokenFailed());
      return;
    }

    final newToken = tokenResult.fold((l) => null, (r) => r)!;
    _emitKeepingTimer(state.copyWith(rtcToken: newToken));
    await _joinAgoraChannel(newToken);
  }


  void _startPolling() {
    _repo.pollSession(_consultationId, _consultationType).then((result) {
      result.fold((_) {}, _applySessionState);
    });

    _pollTimer = Timer.periodic(_kPollInterval, (_) async {
      if (isClosed) return;
      final result = await _repo.pollSession(_consultationId ,_consultationType);
      result.fold((_) {}, _applySessionState);
    });
  }

  void _applySessionState(InstantSessionState session) {
    if (isClosed) return;

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
          lawyerId: session.lawyerId ?? state.lawyerId,
          clientId: session.clientId ?? state.clientId,
        ));
      }

      _cleanup();
      return;
    }

    if (state.phase == VideoCallPhase.timerExpired ||
        state.phase == VideoCallPhase.ended) return;

    _seedTimerIfNeeded(session.remainingSeconds);

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

    _emitKeepingTimer(state.copyWith(
      phase: newPhase,
      twoMinuteWarningActive: session.instantTwoMinuteWarningActive,
      lawyerId: session.lawyerId ?? state.lawyerId,
      clientId: session.clientId ?? state.clientId,
    ));
  }


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
          (error) => _emitError(Loc.sendSummaryFailed(error)),
          (_) {},
    );
  }


  Future<void> _cleanup() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _localTimer?.cancel();
    _localTimer = null;

    if (isLawyer) {
      await _repo.notifyLawyerDisconnected(_consultationId);
    }

    final engine = _engine;
    _engine = null;

    if (engine == null) return;

    try {
      await engine.muteLocalAudioStream(true);
      await engine.muteLocalVideoStream(true);

      await engine.stopPreview();

      await engine.disableVideo();
      await engine.disableAudio();

      await engine.leaveChannel();

      await engine.release();
    } catch (_) {
    }
  }

  @override
  Future<void> close() async {
    await _cleanup();
    return super.close();
  }
}