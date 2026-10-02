import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:permission_handler/permission_handler.dart';

import '../repo/video_call_repo.dart';

enum VideoCallPhase {
  permissionDenied,

  permissionPermanentlyDenied,

  initializing,

  agoraReady,

  joiningCall,

  waitingForLawyer,

  inProgress,

  twoMinuteWarning,

  reconnecting,

  timerExpired,

  ended,

  error,
}

class VideoCallState {
  final RtcTokenModel? rtcToken;

  final VideoCallPhase phase;
  final int? remainingSeconds;
  final bool twoMinuteWarningActive;

  final int? remoteUid;
  final bool isRemoteVideoMuted;
  final bool isRemoteAudioMuted;

  final String? lawyerName;
  final String? lawyerPhotoUrl;
  final String? lawyerId;
  final String? clientId;

  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final bool isFrontCamera;

  final int localNetworkQuality;
  final int remoteNetworkQuality;

  final String? errorMessage;
  final int reconnectAttempts;

  final List<Permission> missingPermissions;

  const VideoCallState({
    this.rtcToken,
    this.phase = VideoCallPhase.initializing,
    this.remainingSeconds,
    this.twoMinuteWarningActive = false,
    this.remoteUid,
    this.isRemoteVideoMuted = false,
    this.isRemoteAudioMuted = false,
    this.lawyerName,
    this.lawyerPhotoUrl,
    this.lawyerId,
    this.clientId,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isSpeakerOn = true,
    this.isFrontCamera = true,
    this.localNetworkQuality = 0,
    this.remoteNetworkQuality = 0,
    this.errorMessage,
    this.reconnectAttempts = 0,
    this.missingPermissions = const [],
  });

  VideoCallState copyWith({
    RtcTokenModel? rtcToken,
    VideoCallPhase? phase,
    int? remainingSeconds,
    bool? twoMinuteWarningActive,
    int? remoteUid,
    bool clearRemoteUid = false,
    bool? isRemoteVideoMuted,
    bool? isRemoteAudioMuted,
    String? lawyerName,
    String? lawyerPhotoUrl,
    String? lawyerId,
    String? clientId,
    bool? isMuted,
    bool? isCameraOff,
    bool? isSpeakerOn,
    bool? isFrontCamera,
    int? localNetworkQuality,
    int? remoteNetworkQuality,
    String? errorMessage,
    bool clearError = false,
    int? reconnectAttempts,
    List<Permission>? missingPermissions,
  }) {
    return VideoCallState(
      rtcToken: rtcToken ?? this.rtcToken,
      phase: phase ?? this.phase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      twoMinuteWarningActive:
      twoMinuteWarningActive ?? this.twoMinuteWarningActive,
      remoteUid: clearRemoteUid ? null : (remoteUid ?? this.remoteUid),
      isRemoteVideoMuted: isRemoteVideoMuted ?? this.isRemoteVideoMuted,
      isRemoteAudioMuted: isRemoteAudioMuted ?? this.isRemoteAudioMuted,
      lawyerName: lawyerName ?? this.lawyerName,
      lawyerPhotoUrl: lawyerPhotoUrl ?? this.lawyerPhotoUrl,
      lawyerId: lawyerId ?? this.lawyerId,
      clientId: clientId ?? this.clientId,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      localNetworkQuality: localNetworkQuality ?? this.localNetworkQuality,
      remoteNetworkQuality: remoteNetworkQuality ?? this.remoteNetworkQuality,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
      missingPermissions: missingPermissions ?? this.missingPermissions,
    );
  }


  bool get isSessionActive =>
      phase == VideoCallPhase.inProgress ||
          phase == VideoCallPhase.twoMinuteWarning;

  bool get isPeerConnected => remoteUid != null;

  String get formattedRemaining {
    final secs = remainingSeconds;
    if (secs == null || secs <= 0) return '00:00';
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String networkQualityLabel(int quality) {
    switch (quality) {
      case 1:
      case 2:
        return Loc.excellent();
      case 3:
        return Loc.good();
      case 4:
        return Loc.weak();
      case 5:
      case 6:
        return Loc.bad();
      default:
        return '';
    }
  }
}